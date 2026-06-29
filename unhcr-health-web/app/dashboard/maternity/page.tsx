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
                        <h1 className="text-3xl font-display font-bold text-stone-900">{facilityName} | Maternity</h1>
                        <p className="text-stone-500 font-medium">Antenatal care, delivery tracking, and newborn services</p>
                    </div>
                    <div className="flex gap-3">
                        <button className="px-5 py-3 bg-rose-600 hover:bg-rose-700 text-white rounded-2xl text-sm font-bold shadow-sm transition-colors flex items-center gap-2 hover:scale-105">
                            <PlusCircle size={18} />
                            Record Birth
                        </button>
                    </div>
                </div>

                {/* Stats Grid */}
                <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-6">
                    <StatSummaryCard title="Antenatal" value="18" icon={<Clock />} color="blue" />
                    <StatSummaryCard title="Active Labor" value="4" icon={<Heart />} color="rose" />
                    <StatSummaryCard title="Births Today" value="7" icon={<Baby />} color="purple" />
                    <StatSummaryCard title="Scheduled" value="12" icon={<Calendar />} color="emerald" />
                </div>

                {/* Patient Table */}
                <div className="bg-white rounded-3xl p-8 border border-stone-200 shadow-sm overflow-hidden flex flex-col">
                    <div className="flex justify-between items-center mb-6">
                        <h3 className="text-xl font-display font-bold text-stone-900">Mother & Newborn Care</h3>
                        <span className="px-4 py-1.5 bg-blue-50 text-blue-700 rounded-full text-sm font-bold border border-blue-100">22 Active Cases</span>
                    </div>

                    <div className="overflow-x-auto">
                        <table className="w-full">
                            <thead>
                                <tr className="text-left text-stone-400 text-xs font-bold uppercase tracking-widest border-b border-stone-100 pb-4">
                                    <th className="pb-4">Mother Name</th>
                                    <th className="pb-4">Patient ID</th>
                                    <th className="pb-4">EDD / Arrival</th>
                                    <th className="pb-4">Service Type</th>
                                    <th className="pb-4">Status</th>
                                    <th className="pb-4 text-right">Action</th>
                                </tr>
                            </thead>
                            <tbody className="divide-y divide-stone-100">
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
        primary: 'bg-stone-100 text-stone-700 border-stone-200',
        blue: 'bg-blue-50 text-blue-600 border-blue-100',
        rose: 'bg-rose-50 text-rose-600 border-rose-100',
        purple: 'bg-purple-50 text-purple-600 border-purple-100',
        emerald: 'bg-emerald-50 text-emerald-600 border-emerald-100',
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

function MaternityRow({ name, id, date, type, status, active }: any) {
    const statusColors: any = {
        'Scheduled': 'bg-blue-50 text-blue-700 border-blue-200',
        'Active Labor': 'bg-rose-50 text-rose-700 border-rose-200',
        'Waiting': 'bg-stone-100 text-stone-600 border-stone-200',
    };

    return (
        <tr className={`group transition-colors ${active ? 'bg-rose-50/30' : 'hover:bg-stone-50/50'}`}>
            <td className="py-6">
                <p className="font-bold text-stone-900">{name}</p>
            </td>
            <td className="py-6">
                <p className="text-xs text-stone-500 font-bold uppercase tracking-tight">{id}</p>
            </td>
            <td className="py-6 text-sm font-medium text-stone-600">
                {date}
            </td>
            <td className="py-6">
                <span className="text-sm font-bold text-stone-700">{type}</span>
            </td>
            <td className="py-6">
                <span className={`px-3 py-1.5 rounded-lg text-[10px] font-bold uppercase tracking-wider border shadow-sm ${statusColors[status]}`}>
                    {status}
                </span>
            </td>
            <td className="py-6 text-right">
                <button className={`px-5 py-2.5 rounded-xl text-xs font-bold transition-all ${active ? 'bg-rose-600 text-white shadow-sm hover:bg-rose-700' : 'text-rose-600 hover:bg-stone-100 border border-transparent'
                    }`}>
                    {active ? 'Manage Birth' : 'Open Charter'}
                </button>
            </td>
        </tr>
    );
}

export default function MaternityDashboard() {
    return (
        <Suspense fallback={<div className="min-h-screen bg-stone-50 flex items-center justify-center font-bold text-primary">Loading Dashboard...</div>}>
            <div suppressHydrationWarning>
                <MaternityDashboardContent />
            </div>
        </Suspense>
    );
}
