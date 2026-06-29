'use client';

import { Suspense } from 'react';
import { useSearchParams } from 'next/navigation';
import DashboardLayout from '@/components/dashboard/dashboard-layout';
import { motion } from 'framer-motion';
import { Pill, Clock, CheckCircle2, AlertCircle, Search, Filter, X, ChevronRight, Check } from 'lucide-react';
import { useState } from 'react';

function PharmacyDashboardContent() {
    const searchParams = useSearchParams();
    const facilityName = searchParams.get('facilityName') || 'UNHCR Hospital';
    const facilityIdFromQuery = searchParams.get('facilityId') || 'fac_001';
    const [selectedPrescription, setSelectedPrescription] = useState<any>(null);

    return (
        <DashboardLayout role="pharmacy" facilityName={facilityName}>
            <motion.div
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                className="space-y-8"
            >
                {/* Welcome Header */}
                <div className="flex flex-col md:flex-row justify-between items-start md:items-end gap-6">
                    <div>
                        <h1 className="text-3xl font-display font-bold text-stone-900">Pharmacy Overview</h1>
                        <p className="text-stone-500 font-medium">Manage prescriptions and medication dispensing</p>
                    </div>
                    <div className="flex gap-4 w-full md:w-auto">
                        <div className="relative group flex-1 md:flex-none">
                            <Search className="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-stone-400 group-focus-within:text-blue-600 transition-colors" />
                            <input
                                type="text"
                                placeholder="Search prescription..."
                                className="pl-12 pr-4 py-3 bg-white border border-stone-200 rounded-2xl focus:border-blue-500 outline-none w-full md:w-64 transition-all shadow-sm font-medium text-stone-900 placeholder-stone-400"
                            />
                        </div>
                        <button className="p-3 bg-white border border-stone-200 rounded-2xl text-stone-500 hover:text-blue-600 hover:border-blue-500 transition-all shadow-sm">
                            <Filter size={20} />
                        </button>
                    </div>
                </div>

                {/* Stats Grid */}
                <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-6">
                    <StatSummaryCard title="Pending" value="8" icon={<Clock />} color="blue" />
                    <StatSummaryCard title="Dispensed" value="142" icon={<CheckCircle2 />} color="emerald" />
                    <StatSummaryCard title="Out of Stock" value="4" icon={<AlertCircle />} color="rose" />
                    <StatSummaryCard title="Inventory" value="92%" icon={<Pill />} color="purple" />
                </div>

                {/* Prescription Queue */}
                <div className="bg-white rounded-3xl p-8 border border-stone-200 shadow-sm overflow-hidden flex flex-col">
                    <div className="flex justify-between items-center mb-6">
                        <h3 className="text-xl font-display font-bold text-stone-900">Incoming Prescriptions</h3>
                        <span className="px-4 py-1.5 bg-blue-50 text-blue-700 rounded-full text-sm font-bold border border-blue-100">8 Waiting</span>
                    </div>

                    <div className="overflow-x-auto">
                        <table className="w-full">
                            <thead>
                                <tr className="text-left text-stone-400 text-xs font-bold uppercase tracking-widest border-b border-stone-100 pb-4">
                                    <th className="pb-4">Patient</th>
                                    <th className="pb-4">Doctor</th>
                                    <th className="pb-4">Medications</th>
                                    <th className="pb-4">Sent At</th>
                                    <th className="pb-4 text-right">Action</th>
                                </tr>
                            </thead>
                            <tbody className="divide-y divide-stone-100">
                                <PrescriptionRow
                                    name="Samuel Okello"
                                    id="REF-1029"
                                    doctor="Dr. Sarah"
                                    meds="Amoxicillin 500mg, Paracetamol"
                                    time="10m ago"
                                    status="Urgent"
                                    onClick={() => setSelectedPrescription({ name: 'Samuel Okello', id: 'REF-1029', doctor: 'Dr. Sarah', meds: ['Amoxicillin 500mg', 'Paracetamol'], time: '10m ago' })}
                                />
                                <PrescriptionRow
                                    name="Mary Njoki"
                                    id="REF-4491"
                                    doctor="Dr. Adams"
                                    meds="Cough Syrup, Vitamin C"
                                    time="15m ago"
                                    status="Ready"
                                    onClick={() => setSelectedPrescription({ name: 'Mary Njoki', id: 'REF-4491', doctor: 'Dr. Adams', meds: ['Cough Syrup', 'Vitamin C'], time: '15m ago' })}
                                />
                                <PrescriptionRow
                                    name="David Kiprotich"
                                    id="REF-7728"
                                    doctor="Dr. Sarah"
                                    meds="Metformin 500mg"
                                    time="22m ago"
                                    status="Processing"
                                    onClick={() => setSelectedPrescription({ name: 'David Kiprotich', id: 'REF-7728', doctor: 'Dr. Sarah', meds: ['Metformin 500mg'], time: '22m ago' })}
                                />
                            </tbody>
                        </table>
                    </div>
                </div>
            </motion.div>

            {/* Dispensing Modal */}
            {selectedPrescription && (
                <div className="fixed inset-0 z-50 flex items-center justify-center p-6 bg-stone-900/40 backdrop-blur-sm">
                    <motion.div
                        initial={{ opacity: 0, scale: 0.95 }}
                        animate={{ opacity: 1, scale: 1 }}
                        className="bg-white rounded-[2.5rem] shadow-2xl w-full max-w-3xl overflow-hidden"
                    >
                        <div className="p-8 border-b border-stone-100 flex justify-between items-center bg-stone-50/50">
                            <div>
                                <h2 className="text-2xl font-display font-bold text-stone-900">Dispense Medication</h2>
                                <p className="text-stone-500 font-medium">Verify items for {selectedPrescription.name}</p>
                            </div>
                            <button onClick={() => setSelectedPrescription(null)} className="p-2 hover:bg-stone-100 rounded-xl text-stone-400 hover:text-stone-600 transition-colors">
                                <X size={24} />
                            </button>
                        </div>

                        <div className="p-8 space-y-8">
                            <div className="bg-stone-50 rounded-2xl p-6 border border-stone-200 flex justify-between items-center shadow-inner">
                                <div>
                                    <p className="text-[10px] font-bold text-stone-500 uppercase tracking-widest mb-1">Prescribed By</p>
                                    <p className="font-bold text-stone-900">{selectedPrescription.doctor}</p>
                                </div>
                                <div className="text-right">
                                    <p className="text-[10px] font-bold text-stone-500 uppercase tracking-widest mb-1">Patient ID</p>
                                    <p className="font-bold text-stone-900">{selectedPrescription.id}</p>
                                </div>
                            </div>

                            <div className="space-y-4">
                                <label className="block text-sm font-black text-stone-900 uppercase tracking-widest">Verify & Pack</label>
                                <div className="space-y-3">
                                    {selectedPrescription.meds.map((med: string, idx: number) => (
                                        <div key={idx} className="p-5 bg-white border border-stone-200 rounded-2xl flex items-center justify-between group hover:border-blue-500 transition-all cursor-pointer shadow-sm">
                                            <div className="flex items-center gap-4">
                                                <div className="w-6 h-6 rounded-full border-2 border-stone-200 flex items-center justify-center group-hover:border-blue-500 group-hover:bg-blue-50 transition-all">
                                                    <Check size={14} className="text-transparent group-hover:text-blue-600" />
                                                </div>
                                                <div>
                                                    <p className="font-bold text-stone-900">{med}</p>
                                                    <p className="text-xs text-stone-500 mt-0.5 font-medium">Dosage as per clinical notes</p>
                                                </div>
                                            </div>
                                            <button className="text-stone-400 group-hover:text-blue-600 transition-colors">
                                                <ChevronRight size={20} />
                                            </button>
                                        </div>
                                    ))}
                                </div>
                            </div>

                            <div className="space-y-4">
                                <label className="block text-sm font-black text-stone-900 uppercase tracking-widest">Counseling Notes</label>
                                <div className="p-5 bg-blue-50 border border-blue-100 rounded-2xl text-blue-800 text-sm font-medium">
                                    Confirm patient understands dosage and duration before completion.
                                </div>
                            </div>

                            <div className="pt-4 flex gap-4">
                                <button
                                    onClick={() => setSelectedPrescription(null)}
                                    className="flex-1 py-4 bg-primary text-white rounded-2xl font-bold shadow-sm hover:bg-primary-dark transition-all flex items-center justify-center gap-2"
                                >
                                    Confirm Dispensing
                                </button>
                                <button className="px-6 py-4 bg-rose-50 text-rose-600 rounded-2xl font-bold flex items-center gap-2 hover:bg-rose-100 transition-colors border border-rose-100">
                                    <AlertCircle size={20} />
                                    Recall
                                </button>
                            </div>
                        </div>
                    </motion.div>
                </div>
            )}
        </DashboardLayout>
    );
}

function StatSummaryCard({ title, value, icon, color }: any) {
    const colorMap: any = {
        primary: 'bg-stone-100 text-stone-700 border-stone-200',
        blue: 'bg-blue-50 text-blue-600 border-blue-100',
        emerald: 'bg-emerald-50 text-emerald-600 border-emerald-100',
        rose: 'bg-rose-50 text-rose-600 border-rose-100',
        purple: 'bg-purple-50 text-purple-600 border-purple-100',
    };

    return (
        <div className="bg-white rounded-3xl p-6 border border-stone-200 shadow-sm flex items-center gap-6 hover:shadow-md transition-shadow">
            <div className={`w-14 h-14 shrink-0 rounded-2xl flex items-center justify-center border shadow-sm ${colorMap[color] || colorMap.primary}`}>
                {icon}
            </div>
            <div>
                <h4 className="text-stone-400 text-xs font-bold uppercase tracking-widest mb-1">{title}</h4>
                <p className="text-3xl font-display font-bold text-stone-900">{value}</p>
            </div>
        </div>
    );
}

function PrescriptionRow({ name, id, doctor, meds, time, status, onClick }: any) {
    const statusColors: any = {
        'Urgent': 'bg-rose-50 text-rose-700 border-rose-200',
        'Ready': 'bg-emerald-50 text-emerald-700 border-emerald-200',
        'Processing': 'bg-amber-50 text-amber-700 border-amber-200',
    };

    return (
        <tr className="group transition-colors hover:bg-stone-50/50">
            <td className="py-6">
                <div>
                    <p className="font-bold text-stone-900">{name}</p>
                    <p className="text-xs text-stone-500 font-medium mt-0.5">{id}</p>
                </div>
            </td>
            <td className="py-6 font-bold text-stone-700 text-sm">
                {doctor}
            </td>
            <td className="py-6">
                <p className="text-sm font-semibold text-stone-900 max-w-xs truncate">{meds}</p>
            </td>
            <td className="py-6 text-sm text-stone-500 font-medium">
                {time}
            </td>
            <td className="py-6 text-right">
                <button
                    onClick={onClick}
                    className="px-5 py-2.5 bg-blue-600 text-white rounded-xl text-xs font-bold shadow-sm hover:bg-blue-700 transition-colors"
                >
                    Dispense
                </button>
            </td>
        </tr>
    );
}

export default function PharmacyDashboard() {
    return (
        <Suspense fallback={<div className="min-h-screen bg-stone-50 flex items-center justify-center font-bold text-primary">Loading Dashboard...</div>}>
            <div suppressHydrationWarning>
                <PharmacyDashboardContent />
            </div>
        </Suspense>
    );
}
