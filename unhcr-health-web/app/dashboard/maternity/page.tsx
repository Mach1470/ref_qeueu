'use client';

import { Suspense } from 'react';
import { useSearchParams } from 'next/navigation';
import DashboardLayout from '@/components/dashboard/dashboard-layout';
import { motion } from 'framer-motion';
import { Baby, Clock, CheckCircle2, Heart, Calendar, PlusCircle } from 'lucide-react';

function MaternityDashboardContent() {
    const searchParams = useSearchParams();
    const facilityName = searchParams.get('facilityName') || 'UNHCR Hospital';
    const facilityIdFromQuery = searchParams.get('facilityId') || 'fac_001';

    return (
        <DashboardLayout role="maternity" facilityName={facilityName}>
            <motion.div
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                className="space-y-8"
            >
                {/* Welcome Header */}
                <div className="flex justify-between items-end">
                    <div>
                        <h1 className="text-3xl font-bold text-slate-900">{facilityName} | Maternity</h1>
                        <p className="text-slate-500">Antenatal care, delivery tracking, and newborn services</p>
                    </div>
                    <div className="flex gap-3">
                        <button className="px-5 py-2.5 bg-pink-500 text-white rounded-xl text-sm font-bold shadow-lg shadow-pink-100 flex items-center gap-2 hover:scale-105 transition-all">
                            <PlusCircle size={18} />
                            Record Birth
                        </button>
                    </div>
                </div>

                {/* Stats Grid */}
                <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-6">
                    <StatSummaryCard title="Antenatal" value="18" icon={<Clock />} color="humanitarian" />
                    <StatSummaryCard title="Active Labor" value="4" icon={<Heart />} color="rose" />
                    <StatSummaryCard title="Births Today" value="7" icon={<Baby />} color="humanitarian" />
                    <StatSummaryCard title="Scheduled" value="12" icon={<Calendar />} color="green" />
                </div>

                {/* Patient Table */}
                <div className="bg-white rounded-3xl p-8 border border-slate-200 shadow-sm overflow-hidden flex flex-col">
                    <div className="flex justify-between items-center mb-6">
                        <h3 className="text-xl font-bold text-slate-900">Mother & Newborn Care</h3>
                        <span className="px-4 py-1.5 bg-humanitarian-50 text-humanitarian-600 rounded-full text-sm font-bold">22 Active Cases</span>
                    </div>

                    <div className="overflow-x-auto">
                        <table className="w-full">
                            <thead>
                                <tr className="text-left text-slate-400 text-xs font-bold uppercase tracking-widest border-b border-slate-100 pb-4">
                                    <th className="pb-4">Mother Name</th>
                                    <th className="pb-4">Patient ID</th>
                                    <th className="pb-4">EDD / Arrival</th>
                                    <th className="pb-4">Service Type</th>
                                    <th className="pb-4">Status</th>
                                    <th className="pb-4 text-right">Action</th>
                                </tr>
                            </thead>
                            <tbody className="divide-y divide-slate-50">
                                <MaternityRow
                                    name="Amina Warsame"
                                    id="REF-3301"
                                    date="Tomorrow (EDD)"
                                    type="Antenatal"
                                    status="Scheduled"
                                />
                                <MaternityRow
                                    name="Zainab Abdi"
                                    id="REF-8842"
                                    date="2h ago"
                                    type="Delivery"
                                    status="Active Labor"
                                    active
                                />
                                <MaternityRow
                                    name="Sarah Kamau"
                                    id="REF-1192"
                                    date="Today"
                                    type="Postnatal"
                                    status="Waiting"
                                />
                            </tbody>
                        </table>
                    </div>
                </div>
            </motion.div>
        </DashboardLayout>
    );
}

function StatSummaryCard({ title, value, icon, color }: any) {
    const colorMap: any = {
        humanitarian: 'bg-humanitarian-50 text-humanitarian-600 border-humanitarian-100',
        rose: 'bg-rose-50 text-rose-600 border-rose-100',
        green: 'bg-green-50 text-green-600 border-green-100',
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

function MaternityRow({ name, id, date, type, status, active }: any) {
    const statusColors: any = {
        'Scheduled': 'bg-blue-50 text-blue-600 border-blue-100',
        'Active Labor': 'bg-rose-50 text-rose-600 border-rose-100',
        'Waiting': 'bg-slate-50 text-slate-500 border-slate-100',
    };

    return (
        <tr className={`group transition-colors ${active ? 'bg-pink-50/20' : ''}`}>
            <td className="py-6">
                <p className="font-bold text-slate-900">{name}</p>
            </td>
            <td className="py-6">
                <p className="text-xs text-slate-400 font-bold uppercase tracking-tight">{id}</p>
            </td>
            <td className="py-6 text-sm font-medium text-slate-600">
                {date}
            </td>
            <td className="py-6">
                <span className="text-sm font-semibold text-slate-900">{type}</span>
            </td>
            <td className="py-6">
                <span className={`px-3 py-1 rounded-full text-[10px] font-bold uppercase tracking-wider border ${statusColors[status]}`}>
                    {status}
                </span>
            </td>
            <td className="py-6 text-right">
                <button className={`px-5 py-2.5 rounded-xl text-xs font-bold transition-all ${active ? 'bg-pink-500 text-white shadow-lg shadow-pink-100' : 'text-pink-600 hover:bg-pink-50 border border-transparent'
                    }`}>
                    {active ? 'Manage Birth' : 'Open Charter'}
                </button>
            </td>
        </tr>
    );
}

export default function MaternityDashboard() {
    return (
        <Suspense fallback={<div className="min-h-screen bg-slate-50 flex items-center justify-center">Loading Dashboard...</div>}>
            <div suppressHydrationWarning>
                <MaternityDashboardContent />
            </div>
        </Suspense>
    );
}
