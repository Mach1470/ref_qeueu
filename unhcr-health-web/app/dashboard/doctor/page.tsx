'use client';

import { Suspense } from 'react';
import { useSearchParams } from 'next/navigation';
import DashboardLayout from '@/components/dashboard/dashboard-layout';
import { motion } from 'framer-motion';
import { Users, Clock, CheckCircle2, AlertCircle, X, Clipboard, ExternalLink, Activity as ActivityIcon } from 'lucide-react';
import { useState, useEffect } from 'react';
import { db } from '@/lib/firebase';
import { ref, onValue, off, remove } from 'firebase/database';
import EmergencyAlerts from '@/components/dashboard/emergency-alerts';

function DoctorDashboardContent() {
    const searchParams = useSearchParams();
    const facilityName = searchParams.get('facilityName') || 'UNHCR Hospital';
    const facilityIdFromQuery = searchParams.get('facilityId') || 'fac_001';
    const [selectedPatient, setSelectedPatient] = useState<any>(null);
    const [queue, setQueue] = useState<any[]>([]);

    const completeConsultation = async (patientId: string) => {
        try {
            const patientRef = ref(db, `facility_queues/${facilityIdFromQuery}/${patientId}`);
            await remove(patientRef);
            setSelectedPatient(null);
        } catch (error) {
            console.error("Error completing consultation:", error);
        }
    };

    useEffect(() => {
        const queueRef = ref(db, `facility_queues/${facilityIdFromQuery}`);
        const unsubscribe = onValue(queueRef, (snapshot) => {
            const data = snapshot.val();
            if (data) {
                const list = Object.entries(data).map(([id, val]: [string, any]) => ({
                    id,
                    ...val,
                    wait: Math.floor((Date.now() - (val.arrivalTime || Date.now())) / 60000) + 'm'
                })).sort((a, b) => (a.arrivalTime || 0) - (b.arrivalTime || 0));
                setQueue(list);
            } else {
                setQueue([]);
            }
        });
        return () => off(queueRef);
    }, [facilityIdFromQuery]);

    return (
        <DashboardLayout role="doctor" facilityName={facilityName}>
            <motion.div
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                className="space-y-8"
            >
                {/* Real-time Emergency Feed */}
                <EmergencyAlerts />

                {/* Welcome Header */}
                <div className="flex justify-between items-end">
                    <div>
                        <h1 className="text-3xl font-bold text-slate-900">Doctor's Overview</h1>
                        <p className="text-slate-500">Monitor and manage your patient queue in real-time</p>
                    </div>
                    <div className="text-right">
                        <p className="text-sm font-bold text-slate-400 uppercase tracking-wider">Current Time</p>
                        <p className="text-2xl font-bold text-slate-900">{new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}</p>
                    </div>
                </div>

                {/* Stats Grid */}
                <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-6">
                    <StatSummaryCard title="In Queue" value="12" icon={<Clock />} color="humanitarian" />
                    <StatSummaryCard title="Treated Today" value="34" icon={<CheckCircle2 />} color="green" />
                    <StatSummaryCard title="Urgent Cases" value="3" icon={<AlertCircle />} color="rose" />
                    <StatSummaryCard title="Average Wait" value="18m" icon={<ActivityIcon />} color="ocean" />
                </div>

                {/* Main Sections */}
                <div className="grid lg:grid-cols-3 gap-8">
                    {/* Active Queue Table */}
                    <div className="lg:col-span-2 bg-white rounded-3xl p-8 border border-slate-200 shadow-sm overflow-hidden flex flex-col">
                        <div className="flex justify-between items-center mb-6">
                            <h3 className="text-xl font-bold text-slate-900">Patient Queue</h3>
                            <button className="text-blue-600 font-bold text-sm hover:text-blue-700 transition-colors">View All</button>
                        </div>

                        <div className="overflow-x-auto">
                            <table className="w-full">
                                <thead>
                                    <tr className="text-left text-slate-400 text-xs font-bold uppercase tracking-widest border-b border-slate-100 pb-4">
                                        <th className="pb-4">Patient</th>
                                        <th className="pb-4">Issue</th>
                                        <th className="pb-4">Wait Time</th>
                                        <th className="pb-4">Status</th>
                                        <th className="pb-4 text-right">Action</th>
                                    </tr>
                                </thead>
                                <tbody className="divide-y divide-slate-50">
                                    {queue.length > 0 ? (
                                        queue.map((patient, index) => (
                                            <PatientRow
                                                key={patient.id}
                                                name={patient.name}
                                                id={patient.id.startsWith('SELF') ? 'REF-ID-CARD' : patient.id}
                                                issue={patient.issue || 'General Consultation'}
                                                wait={patient.wait}
                                                status={patient.status}
                                                active={index === 0}
                                                onClick={() => setSelectedPatient(patient)}
                                            />
                                        ))
                                    ) : (
                                        <tr>
                                            <td colSpan={5} className="py-12 text-center text-slate-400 font-medium italic">
                                                The patient queue is currently empty.
                                            </td>
                                        </tr>
                                    )}
                                </tbody>
                            </table>
                        </div>
                    </div>

                    {/* Quick Actions / Recent Events */}
                    <div className="space-y-6">
                        <div className="bg-linear-to-br from-blue-500 to-blue-700 rounded-3xl p-8 text-white shadow-lg shadow-blue-100">
                            <h3 className="text-xl font-bold mb-4">Quick Consultation</h3>
                            <p className="text-blue-50 mb-6 font-medium">Ready for the next patient?</p>
                            <button className="w-full py-4 bg-white text-blue-600 rounded-2xl font-bold text-lg hover:bg-blue-50 transition-colors shadow-lg">
                                Call Next Patient
                            </button>
                        </div>

                        <div className="bg-white rounded-3xl p-8 border border-slate-200 shadow-sm">
                            <h3 className="text-xl font-bold text-slate-900 mb-6">Staff Chat</h3>
                            <div className="space-y-4">
                                <ChatMessage user="Dr. Adams" msg="Case REF-902 received at Pharmacy" time="2m ago" />
                                <ChatMessage user="Lab Tech" msg="Lab results ready for Amina Yusuf" time="5m ago" />
                            </div>
                        </div>
                    </div>
                </div>
            </motion.div>

            {/* Consultation Modal */}
            {selectedPatient && (
                <div className="fixed inset-0 z-50 flex items-center justify-center p-6 bg-slate-900/60 backdrop-blur-md">
                    <motion.div
                        initial={{ opacity: 0, scale: 0.95 }}
                        animate={{ opacity: 1, scale: 1 }}
                        className="bg-white rounded-[2.5rem] shadow-2xl w-full max-w-4xl overflow-hidden max-h-[90vh] flex flex-col"
                    >
                        <div className="p-8 border-b border-slate-100 flex justify-between items-center">
                            <div>
                                <h2 className="text-2xl font-bold text-slate-900">Consultation Profile</h2>
                                <p className="text-slate-500 font-medium">Record diagnosis and treatment for {selectedPatient.name}</p>
                            </div>
                            <button onClick={() => setSelectedPatient(null)} className="p-2 hover:bg-slate-50 rounded-xl text-slate-400">
                                <X size={24} />
                            </button>
                        </div>

                        <div className="flex-1 overflow-y-auto p-8 grid lg:grid-cols-2 gap-8">
                            {/* Left Side: Patient Info */}
                            <div className="space-y-6">
                                <div className="bg-slate-50 rounded-3xl p-6 border border-slate-100">
                                    <div className="flex items-center gap-4 mb-6">
                                        <div className="w-16 h-16 rounded-full bg-blue-100 flex items-center justify-center text-blue-600 text-2xl font-black">
                                            {selectedPatient.name.charAt(0)}
                                        </div>
                                        <div>
                                            <h3 className="text-xl font-bold text-slate-900">{selectedPatient.name}</h3>
                                            <p className="text-sm font-bold text-slate-400 uppercase tracking-widest">{selectedPatient.id}</p>
                                        </div>
                                    </div>

                                    <div className="grid grid-cols-2 gap-4">
                                        <div className="p-4 bg-white rounded-2xl border border-slate-100">
                                            <p className="text-[10px] font-bold text-slate-400 uppercase tracking-widest mb-1">Age / Gender</p>
                                            <p className="font-bold text-slate-900">28y / Male</p>
                                        </div>
                                        <div className="p-4 bg-white rounded-2xl border border-slate-100">
                                            <p className="text-[10px] font-bold text-slate-400 uppercase tracking-widest mb-1">Last Visit</p>
                                            <p className="font-bold text-slate-900">12 Dec 2025</p>
                                        </div>
                                    </div>
                                </div>

                                <div>
                                    <h4 className="text-sm font-black text-slate-900 uppercase tracking-widest mb-4 flex items-center gap-2">
                                        <ActivityIcon size={16} className="text-blue-500" />
                                        Vitals (Mock Data)
                                    </h4>
                                    <div className="grid grid-cols-2 gap-4">
                                        <VitalCard label="Temp" value="38.5°C" status="High" color="rose" />
                                        <VitalCard label="BP" value="120/80" status="Normal" color="blue" />
                                        <VitalCard label="Weight" value="72kg" status="Stable" color="blue" />
                                        <VitalCard label="SpO2" value="98%" status="Ideal" color="green" />
                                    </div>
                                </div>

                                <div>
                                    <h4 className="text-sm font-black text-slate-900 uppercase tracking-widest mb-4 flex items-center gap-2">
                                        <Clipboard size={16} className="text-blue-500" />
                                        Recent History
                                    </h4>
                                    <div className="space-y-3">
                                        <HistoryItem date="Jan 10, 2026" title="General Consultation" notes="Patient reported mild headache and fatigue." />
                                        <HistoryItem date="Oct 15, 2025" title="Lab Test: Malaria" notes="Results were negative." />
                                    </div>
                                </div>
                            </div>

                            {/* Right Side: Diagnosis & Prescription */}
                            <div className="space-y-6">
                                <div className="space-y-4">
                                    <label className="block text-sm font-black text-slate-900 uppercase tracking-widest">Diagnosis Notes</label>
                                    <textarea
                                        placeholder="Enter clinical observations and diagnosis..."
                                        className="w-full h-40 p-5 bg-slate-50 border-2 border-slate-50 rounded-3xl outline-none focus:bg-white focus:border-blue-500 transition-all font-medium text-slate-700 resize-none"
                                    />
                                </div>

                                <div className="space-y-4">
                                    <div className="flex justify-between items-center">
                                        <label className="block text-sm font-black text-slate-900 uppercase tracking-widest">Prescriptions</label>
                                        <button className="text-xs font-bold text-blue-600 hover:text-blue-700">+ Add Medication</button>
                                    </div>
                                    <div className="space-y-3">
                                        <div className="p-4 bg-blue-50/50 rounded-2xl border border-blue-100/50 flex justify-between items-center">
                                            <div>
                                                <p className="font-bold text-slate-900 text-sm">Amoxicillin 500mg</p>
                                                <p className="text-xs text-slate-500">1x3 daily - 7 days</p>
                                            </div>
                                            <button className="text-rose-400 hover:text-rose-500"><X size={16} /></button>
                                        </div>
                                    </div>
                                </div>

                                <div className="pt-6 border-t border-slate-100 flex gap-4">
                                    <button
                                        className="flex-1 py-4 bg-slate-900 text-white rounded-2xl font-bold flex items-center justify-center gap-2 hover:bg-slate-800 transition-colors"
                                        onClick={() => completeConsultation(selectedPatient.id)}
                                    >
                                        Complete Consultation
                                    </button>
                                    <button className="px-6 py-4 border-2 border-slate-200 text-slate-400 rounded-2xl font-bold hover:border-blue-500 hover:text-blue-600 transition-all">
                                        <ExternalLink size={20} />
                                    </button>
                                </div>
                            </div>
                        </div>
                    </motion.div>
                </div>
            )}
        </DashboardLayout>
    );
}

function VitalCard({ label, value, status, color }: any) {
    const colorMap: any = {
        rose: 'text-rose-500 bg-rose-50 border-rose-100',
        humanitarian: 'text-humanitarian-500 bg-humanitarian-50 border-humanitarian-100',
        blue: 'text-blue-500 bg-blue-50 border-blue-100',
        green: 'text-green-500 bg-green-50 border-green-100'
    };

    return (
        <div className="p-4 bg-white rounded-2xl border border-slate-100">
            <p className="text-[10px] font-bold text-slate-400 uppercase tracking-widest mb-1">{label}</p>
            <div className="flex justify-between items-end">
                <p className="text-lg font-black text-slate-900">{value}</p>
                <span className={`text-[8px] font-black uppercase px-1.5 py-0.5 rounded-full ${colorMap[color]}`}>{status}</span>
            </div>
        </div>
    );
}

function HistoryItem({ date, title, notes }: any) {
    return (
        <div className="p-4 bg-white rounded-2xl border border-slate-100">
            <div className="flex justify-between items-start mb-1">
                <h5 className="font-bold text-slate-900 text-sm">{title}</h5>
                <span className="text-[10px] text-slate-400 font-bold">{date}</span>
            </div>
            <p className="text-xs text-slate-500 line-clamp-1">{notes}</p>
        </div>
    );
}

function StatSummaryCard({ title, value, icon, color }: any) {
    const colorMap: any = {
        humanitarian: 'bg-humanitarian-50 text-humanitarian-600 border-humanitarian-100',
        green: 'bg-green-50 text-green-600 border-green-100',
        rose: 'bg-rose-50 text-rose-600 border-rose-100',
        ocean: 'bg-ocean-50 text-ocean-600 border-ocean-100',
    };

    return (
        <div className="bg-white rounded-3xl p-6 border border-slate-200 shadow-sm flex items-center gap-6">
            <div className={`w-14 h-14 shrink-0 rounded-2xl flex items-center justify-center border ${colorMap[color]}`}>
                {icon}
            </div>
            <div>
                <h4 className="text-slate-400 text-xs font-bold uppercase tracking-widest">{title}</h4>
                <p className="text-2xl font-extrabold text-slate-900">{value}</p>
            </div>
        </div>
    );
}

function PatientRow({ name, id, issue, wait, status, active, urgent, onClick }: { name: string, id: string, issue: string, wait: string, status: string, active: boolean, urgent?: boolean, onClick: () => void }) {
    return (
        <tr className={`group transition-colors ${active ? 'bg-blue-50/50' : ''}`}>
            <td className="py-4">
                <div>
                    <p className="font-bold text-slate-900">{name}</p>
                    <p className="text-xs text-slate-400 font-medium">{id}</p>
                </div>
            </td>
            <td className="py-4">
                <span className="text-sm font-medium text-slate-900">{issue}</span>
            </td>
            <td className="py-4">
                <div className="flex items-center gap-2 text-slate-500 text-sm">
                    <Clock size={14} />
                    {wait}
                </div>
            </td>
            <td className="py-4">
                <span className={`px-3 py-1 rounded-full text-[10px] font-bold uppercase tracking-wider border ${active
                    ? 'bg-orange-50 text-orange-600 border-orange-100'
                    : urgent
                        ? 'bg-rose-50 text-rose-600 border-rose-100'
                        : 'bg-slate-50 text-slate-500 border-slate-100'
                    }`}>
                    {status}
                </span>
            </td>
            <td className="py-4 text-right">
                <div className={`px-4 py-2 rounded-xl text-xs font-bold transition-all ${active
                    ? 'bg-humanitarian-500 text-white shadow-lg shadow-humanitarian-100 hover:scale-105'
                    : 'text-humanitarian-600 hover:bg-humanitarian-50 border border-transparent'
                    }`}>
                    {active ? 'View Details' : 'Start Consultation'}
                </div>
            </td>
        </tr>
    );
}

function ChatMessage({ user, msg, time }: any) {
    return (
        <div className="flex gap-4">
            <div className="w-10 h-10 shrink-0 bg-slate-100 rounded-xl" />
            <div>
                <div className="flex items-center gap-2 mb-1">
                    <span className="text-sm font-bold text-slate-900">{user}</span>
                    <span className="text-[10px] text-slate-400 font-medium">{time}</span>
                </div>
                <p className="text-xs text-slate-500 leading-tight">{msg}</p>
            </div>
        </div>
    );
}

export default function DoctorDashboard() {
    return (
        <Suspense fallback={<div className="min-h-screen bg-slate-50 flex items-center justify-center">Loading Dashboard...</div>}>
            <DoctorDashboardContent />
        </Suspense>
    );
}
