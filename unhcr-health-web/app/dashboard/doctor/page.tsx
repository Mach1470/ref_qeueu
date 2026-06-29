'use client';

import { Suspense } from 'react';
import { useSearchParams } from 'next/navigation';
import DashboardLayout from '@/components/dashboard/dashboard-layout';
import { motion } from 'framer-motion';
import { Users, Clock, CheckCircle2, AlertCircle, X, Clipboard, ExternalLink, Activity as ActivityIcon, Stethoscope, FileText, Pill } from 'lucide-react';
import { useState, useEffect } from 'react';
import { db } from '@/lib/firebase';
import { ref, onValue, off, remove } from 'firebase/database';

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
                initial={{ opacity: 0, y: 10 }}
                animate={{ opacity: 1, y: 0 }}
                className="space-y-8"
            >
                {/* Welcome Header */}
                <div className="flex flex-col md:flex-row justify-between items-start md:items-end gap-6 bg-white p-8 rounded-3xl border border-stone-200 shadow-sm">
                    <div>
                        <h1 className="text-3xl font-display font-bold text-stone-900 mb-2">Consultation Hub</h1>
                        <p className="text-stone-500 font-medium">Manage your patient queue and record clinical assessments.</p>
                    </div>
                    <div className="bg-stone-50 border border-stone-200 rounded-2xl px-8 py-4 shrink-0 shadow-sm">
                        <p className="text-[10px] font-bold text-stone-400 uppercase tracking-widest mb-1">Current Time</p>
                        <p className="text-2xl font-bold text-stone-900 font-mono">{new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}</p>
                    </div>
                </div>

                {/* Stats Grid */}
                <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-6">
                    <StatSummaryCard title="In Queue" value={queue.length.toString()} icon={<Clock size={24} />} color="blue" />
                    <StatSummaryCard title="Treated Today" value="34" icon={<CheckCircle2 size={24} />} color="emerald" />
                    <StatSummaryCard title="Urgent Cases" value={queue.filter(q => q.status === 'urgent' || q.severity === 'critical').length.toString() || '0'} icon={<AlertCircle size={24} />} color="rose" />
                    <StatSummaryCard title="Avg Wait" value="18m" icon={<ActivityIcon size={24} />} color="amber" />
                </div>

                {/* Main Sections */}
                <div className="grid lg:grid-cols-3 gap-8">
                    {/* Active Queue Table */}
                    <div className="lg:col-span-2 bg-white border border-stone-200 rounded-3xl p-8 flex flex-col h-[650px] shadow-sm">
                        <div className="flex justify-between items-center mb-6 pb-6 border-b border-stone-100">
                            <h3 className="text-xl font-bold text-stone-900 flex items-center gap-3">
                                <Stethoscope className="text-primary" size={20} />
                                Active Patient Queue
                            </h3>
                            <span className="px-4 py-1.5 rounded-full bg-primary/10 text-primary text-xs font-bold border border-primary/20">
                                {queue.length} Waiting
                            </span>
                        </div>

                        <div className="overflow-y-auto pr-2 custom-scrollbar flex-1">
                            {queue.length > 0 ? (
                                <div className="space-y-4">
                                    {queue.map((patient, index) => (
                                        <PatientCard
                                            key={patient.id}
                                            patient={patient}
                                            active={index === 0}
                                            onClick={() => setSelectedPatient(patient)}
                                        />
                                    ))}
                                </div>
                            ) : (
                                <div className="h-full flex flex-col items-center justify-center text-stone-400 space-y-4">
                                    <div className="w-20 h-20 rounded-full bg-stone-50 flex items-center justify-center border border-stone-100">
                                        <CheckCircle2 size={40} className="text-emerald-500/50" />
                                    </div>
                                    <p className="font-medium text-lg text-stone-500">The patient queue is currently empty.</p>
                                </div>
                            )}
                        </div>
                    </div>

                    {/* Quick Actions / Recent Events */}
                    <div className="space-y-8">
                        <div className="bg-gradient-to-br from-primary to-primary-light rounded-3xl p-8 text-white shadow-md relative overflow-hidden">
                            <div className="absolute top-0 right-0 w-32 h-32 bg-white/20 rounded-full blur-2xl -mr-10 -mt-10" />
                            <h3 className="text-xl font-bold mb-3 font-display">Next Patient</h3>
                            <p className="text-blue-50 mb-8 font-medium">Call the next priority patient from the queue.</p>
                            <button className="w-full py-4 bg-white text-primary rounded-2xl font-bold text-sm hover:bg-stone-50 transition-colors shadow-sm active:scale-[0.98]">
                                Call Patient to Room
                            </button>
                        </div>

                        <div className="bg-white border border-stone-200 rounded-3xl p-8 h-[400px] flex flex-col shadow-sm">
                            <h3 className="text-xs font-bold text-stone-400 uppercase tracking-widest mb-6 flex items-center gap-2">
                                <Users size={16} />
                                Clinical Team Chat
                            </h3>
                            <div className="space-y-6 flex-1 overflow-y-auto pr-2">
                                <ChatMessage user="Triage Nurse" msg="Added 3 new patients to standard queue." time="2m ago" />
                                <ChatMessage user="Lab Tech" msg="Malaria panel ready for Amina Yusuf." time="5m ago" isAlert />
                                <ChatMessage user="Pharmacy" msg="Amoxicillin stock running low (Zone C)." time="12m ago" />
                            </div>
                            <div className="mt-4 pt-4 border-t border-stone-100 relative">
                                <input type="text" placeholder="Message team..." className="w-full bg-stone-50 border border-stone-200 rounded-xl px-4 py-3 text-sm text-stone-800 placeholder-stone-400 outline-none focus:border-primary/50 focus:bg-white transition-all font-medium" />
                            </div>
                        </div>
                    </div>
                </div>
            </motion.div>

            {/* Consultation Modal */}
            {selectedPatient && (
                <div className="fixed inset-0 z-50 flex items-center justify-center p-4 sm:p-6 bg-stone-900/60 backdrop-blur-md">
                    <motion.div
                        initial={{ opacity: 0, scale: 0.95, y: 20 }}
                        animate={{ opacity: 1, scale: 1, y: 0 }}
                        className="bg-white rounded-3xl shadow-2xl w-full max-w-5xl overflow-hidden max-h-[90vh] flex flex-col"
                    >
                        <div className="p-8 border-b border-stone-200 flex justify-between items-center bg-stone-50/50">
                            <div className="flex items-center gap-5">
                                <div className="w-14 h-14 rounded-2xl bg-blue-50 flex items-center justify-center text-primary text-2xl font-bold border border-blue-100 shadow-sm">
                                    {selectedPatient.name?.charAt(0) || 'P'}
                                </div>
                                <div>
                                    <h2 className="text-2xl font-display font-bold text-stone-900 leading-tight">{selectedPatient.name}</h2>
                                    <p className="text-xs font-bold text-stone-500 uppercase tracking-widest mt-1">{selectedPatient.id.startsWith('SELF') ? 'REF-ID-CARD' : selectedPatient.id}</p>
                                </div>
                            </div>
                            <div className="flex items-center gap-6">
                                <span className="px-4 py-1.5 bg-amber-50 text-amber-700 text-xs font-bold rounded-full border border-amber-200 uppercase tracking-widest">
                                    {selectedPatient.issue || 'General Consultation'}
                                </span>
                                <button onClick={() => setSelectedPatient(null)} className="p-2 hover:bg-stone-100 rounded-xl text-stone-400 transition-colors border border-transparent hover:border-stone-200">
                                    <X size={24} />
                                </button>
                            </div>
                        </div>

                        <div className="flex-1 overflow-y-auto p-8 grid lg:grid-cols-2 gap-10 custom-scrollbar">
                            {/* Left Side: Patient Info */}
                            <div className="space-y-8">
                                <div className="grid grid-cols-2 gap-4">
                                    <div className="bg-stone-50 border border-stone-200 rounded-2xl p-5 shadow-sm">
                                        <p className="text-[10px] font-bold text-stone-400 uppercase tracking-widest mb-1.5">Age / Gender</p>
                                        <p className="font-bold text-stone-900">28y / Female</p>
                                    </div>
                                    <div className="bg-stone-50 border border-stone-200 rounded-2xl p-5 shadow-sm">
                                        <p className="text-[10px] font-bold text-stone-400 uppercase tracking-widest mb-1.5">Last Visit</p>
                                        <p className="font-bold text-stone-900">12 Dec 2025</p>
                                    </div>
                                </div>

                                <div>
                                    <h4 className="text-xs font-bold text-stone-400 uppercase tracking-widest mb-4 flex items-center gap-2">
                                        <ActivityIcon size={16} className="text-rose-500" />
                                        Triage Vitals
                                    </h4>
                                    <div className="grid grid-cols-2 gap-4">
                                        <VitalCard label="Temp" value="38.5°C" status="High" color="rose" />
                                        <VitalCard label="BP" value="120/80" status="Normal" color="emerald" />
                                        <VitalCard label="Weight" value="72kg" status="-" color="stone" />
                                        <VitalCard label="SpO2" value="98%" status="Normal" color="emerald" />
                                    </div>
                                </div>

                                <div>
                                    <h4 className="text-xs font-bold text-stone-400 uppercase tracking-widest mb-4 flex items-center gap-2">
                                        <Clipboard size={16} className="text-primary" />
                                        Recent History
                                    </h4>
                                    <div className="space-y-3">
                                        <HistoryItem date="Jan 10, 2026" title="General Consultation" notes="Patient reported mild headache and fatigue." />
                                        <HistoryItem date="Oct 15, 2025" title="Lab Test: Malaria" notes="Results were negative." />
                                    </div>
                                </div>
                            </div>

                            {/* Right Side: Diagnosis & Prescription */}
                            <div className="space-y-8 flex flex-col">
                                <div className="space-y-3 flex-1 flex flex-col">
                                    <label className="text-xs font-bold text-stone-400 uppercase tracking-widest flex items-center gap-2">
                                        <FileText size={16} /> Clinical Notes & Diagnosis
                                    </label>
                                    <textarea
                                        placeholder="Enter clinical observations, ICD-10 codes, and diagnosis..."
                                        className="flex-1 w-full p-5 bg-stone-50 border border-stone-200 rounded-2xl outline-none focus:bg-white focus:border-primary/50 transition-all font-medium text-stone-900 resize-none text-sm placeholder-stone-400 shadow-inner"
                                    />
                                </div>

                                <div className="space-y-3">
                                    <div className="flex justify-between items-center">
                                        <label className="text-xs font-bold text-stone-400 uppercase tracking-widest flex items-center gap-2">
                                            <Pill size={16} /> Prescriptions
                                        </label>
                                        <button className="text-xs font-bold text-primary hover:text-primary-dark transition-colors bg-blue-50 px-3 py-1.5 rounded-lg border border-blue-100">+ Add Rx</button>
                                    </div>
                                    <div className="p-4 bg-stone-50 rounded-2xl border border-stone-200 flex justify-between items-center shadow-sm">
                                        <div>
                                            <p className="font-bold text-stone-900 text-sm">Amoxicillin 500mg</p>
                                            <p className="text-xs font-medium text-stone-500 mt-0.5">1 capsule 3x daily - 7 days</p>
                                        </div>
                                        <button className="text-stone-400 hover:text-rose-500 transition-colors p-2 bg-white rounded-lg border border-stone-200"><X size={16} /></button>
                                    </div>
                                </div>
                            </div>
                        </div>
                        
                        {/* Action Footer */}
                        <div className="p-6 border-t border-stone-200 bg-stone-50 flex justify-end gap-4 shrink-0">
                            <button 
                                className="btn-secondary px-8 py-3.5"
                                onClick={() => setSelectedPatient(null)}
                            >
                                Save as Draft
                            </button>
                            <button
                                className="btn-primary px-8 py-3.5"
                                onClick={() => completeConsultation(selectedPatient.id)}
                            >
                                Complete & Discharge
                            </button>
                        </div>
                    </motion.div>
                </div>
            )}
        </DashboardLayout>
    );
}

function StatSummaryCard({ title, value, icon, color }: any) {
    const colorMap: any = {
        blue: 'text-primary bg-blue-50 border-blue-100',
        emerald: 'text-emerald-600 bg-emerald-50 border-emerald-100',
        rose: 'text-rose-600 bg-rose-50 border-rose-100',
        amber: 'text-amber-600 bg-amber-50 border-amber-100',
    };

    return (
        <div className="bg-white border border-stone-200 rounded-3xl p-6 flex items-center gap-5 shadow-sm hover:shadow-md transition-shadow">
            <div className={`w-14 h-14 shrink-0 rounded-2xl flex items-center justify-center border shadow-sm ${colorMap[color]}`}>
                {icon}
            </div>
            <div>
                <p className="text-[10px] font-bold text-stone-400 uppercase tracking-widest mb-1.5">{title}</p>
                <p className="text-3xl font-display font-bold text-stone-900 leading-none">{value}</p>
            </div>
        </div>
    );
}

function PatientCard({ patient, active, onClick }: { patient: any, active: boolean, onClick: () => void }) {
    const isUrgent = patient.status === 'urgent' || patient.severity === 'critical';
    
    return (
        <div 
            onClick={onClick}
            className={`p-5 rounded-2xl border transition-all cursor-pointer flex items-center justify-between shadow-sm ${
                active 
                    ? 'bg-blue-50/50 border-primary/20 hover:bg-blue-50' 
                    : isUrgent
                        ? 'bg-rose-50/50 border-rose-200 hover:bg-rose-50'
                        : 'bg-white border-stone-200 hover:bg-stone-50 hover:border-stone-300'
            }`}
        >
            <div className="flex items-center gap-5">
                <div className={`w-12 h-12 rounded-xl flex items-center justify-center font-bold text-lg border shadow-sm ${
                    active ? 'bg-white text-primary border-primary/20' : 
                    isUrgent ? 'bg-white text-rose-500 border-rose-200' : 
                    'bg-stone-50 text-stone-500 border-stone-200'
                }`}>
                    {patient.name?.charAt(0) || 'P'}
                </div>
                <div>
                    <h4 className="font-bold text-stone-900 text-base">{patient.name || 'Unknown Patient'}</h4>
                    <p className="text-sm font-medium text-stone-500 mt-0.5">{patient.issue || 'General Consultation'}</p>
                </div>
            </div>

            <div className="flex items-center gap-8">
                <div className="text-right hidden sm:block">
                    <p className="text-[10px] font-bold text-stone-400 uppercase tracking-widest">Wait</p>
                    <p className="font-bold text-stone-900 text-base font-sans">{patient.wait}</p>
                </div>
                
                {isUrgent && (
                    <span className="px-3 py-1 bg-rose-100 text-rose-700 text-[10px] font-bold uppercase tracking-widest rounded-lg border border-rose-200">
                        Urgent
                    </span>
                )}
                
                <div className={`text-xs font-bold px-4 py-2 rounded-xl border shadow-sm ${
                    active 
                        ? 'bg-primary text-white border-primary' 
                        : 'bg-white text-stone-600 border-stone-200 hover:bg-stone-50'
                }`}>
                    {active ? 'Consult' : 'View Details'}
                </div>
            </div>
        </div>
    );
}

function VitalCard({ label, value, status, color }: any) {
    const colorMap: any = {
        rose: 'text-rose-600',
        emerald: 'text-emerald-600',
        stone: 'text-stone-500'
    };

    return (
        <div className="bg-white border border-stone-200 rounded-2xl p-4 shadow-sm">
            <p className="text-[10px] font-bold text-stone-400 uppercase tracking-widest mb-2">{label}</p>
            <div className="flex justify-between items-end">
                <p className="text-lg font-bold text-stone-900">{value}</p>
                <span className={`text-[10px] font-bold ${colorMap[color]}`}>{status}</span>
            </div>
        </div>
    );
}

function HistoryItem({ date, title, notes }: any) {
    return (
        <div className="bg-white border border-stone-200 rounded-2xl p-4 shadow-sm">
            <div className="flex justify-between items-start mb-2">
                <h5 className="font-bold text-stone-900 text-sm">{title}</h5>
                <span className="text-[10px] font-bold text-stone-400 uppercase tracking-widest">{date}</span>
            </div>
            <p className="text-sm font-medium text-stone-500 line-clamp-2 leading-relaxed">{notes}</p>
        </div>
    );
}

function ChatMessage({ user, msg, time, isAlert }: any) {
    return (
        <div className="flex gap-4">
            <div className={`w-10 h-10 shrink-0 rounded-xl flex items-center justify-center text-xs font-bold border shadow-sm ${
                isAlert ? 'bg-rose-50 text-rose-600 border-rose-100' : 'bg-stone-50 text-stone-500 border-stone-200'
            }`}>
                {user.charAt(0)}
            </div>
            <div>
                <div className="flex items-center gap-3 mb-1">
                    <span className={`text-xs font-bold tracking-wide ${isAlert ? 'text-rose-600' : 'text-stone-900'}`}>{user}</span>
                    <span className="text-[10px] font-bold text-stone-400">{time}</span>
                </div>
                <p className="text-sm font-medium text-stone-500 leading-relaxed">{msg}</p>
            </div>
        </div>
    );
}

export default function DoctorDashboard() {
    return (
        <Suspense fallback={<div className="min-h-screen bg-stone-50 flex items-center justify-center text-primary font-medium">Loading Dashboard...</div>}>
            <DoctorDashboardContent />
        </Suspense>
    );
}

