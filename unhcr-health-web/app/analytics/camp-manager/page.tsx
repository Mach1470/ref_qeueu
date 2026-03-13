'use client';

import ManagementLayout from '@/components/dashboard/management-layout';
import { motion } from 'framer-motion';
import {
    Users,
    Activity,
    AlertCircle,
    Clock,
    TrendingUp,
    MapPin,
    Calendar
} from 'lucide-react';
import { AreaChart, Area, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer, BarChart, Bar, Cell, PieChart, Pie } from 'recharts';
import { useSearchParams } from 'next/navigation';
import { Suspense } from 'react';

// Mock Data Generators (Scoped)
const getPerformanceData = (campId: string) => [
    { name: 'Mon', admitted: campId === 'dadaab' ? 45 : 30, critical: campId === 'dadaab' ? 12 : 8, treated: campId === 'dadaab' ? 120 : 85 },
    { name: 'Tue', admitted: campId === 'dadaab' ? 52 : 45, critical: campId === 'dadaab' ? 15 : 12, treated: campId === 'dadaab' ? 132 : 95 },
    { name: 'Wed', admitted: campId === 'dadaab' ? 48 : 35, critical: campId === 'dadaab' ? 10 : 6, treated: campId === 'dadaab' ? 115 : 90 },
    { name: 'Thu', admitted: campId === 'dadaab' ? 60 : 50, critical: campId === 'dadaab' ? 20 : 15, treated: campId === 'dadaab' ? 145 : 110 },
    { name: 'Fri', admitted: campId === 'dadaab' ? 55 : 48, critical: campId === 'dadaab' ? 14 : 9, treated: campId === 'dadaab' ? 135 : 105 },
    { name: 'Sat', admitted: campId === 'dadaab' ? 40 : 38, critical: campId === 'dadaab' ? 18 : 12, treated: campId === 'dadaab' ? 110 : 80 },
    { name: 'Sun', admitted: campId === 'dadaab' ? 35 : 30, critical: campId === 'dadaab' ? 12 : 7, treated: campId === 'dadaab' ? 95 : 70 },
];

const getDemographicsData = (campId: string) => [
    { name: 'Children (0-5)', value: campId === 'dadaab' ? 450 : 320, color: '#386BB8' }, // humanitarian blue
    { name: 'Youth (6-17)', value: campId === 'dadaab' ? 380 : 240, color: '#0ea5e9' }, // ocean-500
    { name: 'Adults (18-60)', value: campId === 'dadaab' ? 520 : 410, color: '#6366f1' }, // indigo-500
    { name: 'Elderly (60+)', value: campId === 'dadaab' ? 150 : 120, color: '#f43f5e' }, // rose-500
];

function DashboardContent() {
    const searchParams = useSearchParams();
    const campId = searchParams.get('camp') || 'kakuma';

    const campName = campId === 'kakuma' ? 'Kakuma Refugee Camp' : 'Dadaab Refugee Complex';
    const population = campId === 'kakuma' ? '185,400' : '234,000';
    const activeFacilities = campId === 'kakuma' ? 8 : 12;

    const performanceData = getPerformanceData(campId);
    const demographicsData = getDemographicsData(campId);

    return (
        <div className="space-y-8">
            {/* Header */}
            <div className="flex flex-col md:flex-row justify-between items-start md:items-center gap-4">
                <div>
                    <h1 className="text-3xl font-black text-slate-900 leading-tight">Overview</h1>
                    <p className="text-slate-500 font-medium flex items-center gap-2">
                        <MapPin size={16} className="text-ocean-600" />
                        {campName} • <span className="text-blue-600 font-bold">{population} Residents</span>
                    </p>
                </div>
                <div className="bg-white p-1.5 rounded-2xl border border-slate-200 flex items-center shadow-sm">
                    <button className="px-4 py-2 bg-blue-600 text-white rounded-xl text-xs font-bold transition-all shadow-md">Today</button>
                    <button className="px-4 py-2 text-slate-500 hover:text-slate-900 rounded-xl text-xs font-bold transition-all">Week</button>
                    <button className="px-4 py-2 text-slate-500 hover:text-slate-900 rounded-xl text-xs font-bold transition-all">Month</button>
                </div>
            </div>

            {/* KPI Grid */}
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
                <KpiCard
                    title="Total Patients Today"
                    value={campId === 'dadaab' ? "1,245" : "842"}
                    trend="+12%"
                    icon={<Users size={24} />}
                    color="ocean"
                />
                <KpiCard
                    title="Avg. Wait Time"
                    value="45m"
                    trend="-8m"
                    icon={<Clock size={24} />}
                    color="blue"
                    positive
                />
                <KpiCard
                    title="Critical Cases"
                    value={campId === 'dadaab' ? "34" : "18"}
                    trend="+2"
                    icon={<AlertCircle size={24} />}
                    color="rose"
                    negative
                />
                <KpiCard
                    title="Active Facilities"
                    value={activeFacilities.toString()}
                    trend="100% Ops"
                    icon={<Activity size={24} />}
                    color="indigo"
                />
            </div>

            {/* Charts Section */}
            <div className="grid lg:grid-cols-3 gap-8">
                {/* Main Chart */}
                <div className="lg:col-span-2 bg-white rounded-[2.5rem] p-8 border border-slate-200 shadow-sm">
                    <div className="flex justify-between items-center mb-8">
                        <h3 className="text-xl font-bold text-slate-900">Treatment Trends</h3>
                        <div className="flex items-center gap-2">
                            <span className="w-3 h-3 rounded-full bg-ocean-500"></span>
                            <span className="text-xs font-bold text-slate-400 uppercase tracking-widest mr-4">Treated</span>
                            <span className="w-3 h-3 rounded-full bg-rose-400"></span>
                            <span className="text-xs font-bold text-slate-400 uppercase tracking-widest">Critical</span>
                        </div>
                    </div>
                    <div className="h-[300px] w-full">
                        <ResponsiveContainer width="100%" height="100%">
                            <AreaChart data={performanceData}>
                                <defs>
                                    <linearGradient id="colorTreated" x1="0" y1="0" x2="0" y2="1">
                                        <stop offset="5%" stopColor="#0ea5e9" stopOpacity={0.1} />
                                        <stop offset="95%" stopColor="#0ea5e9" stopOpacity={0} />
                                    </linearGradient>
                                    <linearGradient id="colorCritical" x1="0" y1="0" x2="0" y2="1">
                                        <stop offset="5%" stopColor="#f43f5e" stopOpacity={0.1} />
                                        <stop offset="95%" stopColor="#f43f5e" stopOpacity={0} />
                                    </linearGradient>
                                </defs>
                                <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#f1f5f9" />
                                <XAxis dataKey="name" axisLine={false} tickLine={false} tick={{ fill: '#94a3b8', fontSize: 12, fontWeight: 600 }} dy={10} />
                                <YAxis axisLine={false} tickLine={false} tick={{ fill: '#94a3b8', fontSize: 12, fontWeight: 600 }} />
                                <Tooltip
                                    contentStyle={{ borderRadius: '16px', border: 'none', boxShadow: '0 10px 30px -10px rgba(0,0,0,0.1)' }}
                                    itemStyle={{ fontSize: '12px', fontWeight: 'bold' }}
                                />
                                <Area type="monotone" dataKey="treated" stroke="#0ea5e9" strokeWidth={3} fillOpacity={1} fill="url(#colorTreated)" />
                                <Area type="monotone" dataKey="critical" stroke="#f43f5e" strokeWidth={3} fillOpacity={1} fill="url(#colorCritical)" />
                            </AreaChart>
                        </ResponsiveContainer>
                    </div>
                </div>

                {/* Side Chart */}
                <div className="bg-white rounded-[2.5rem] p-8 border border-slate-200 shadow-sm flex flex-col">
                    <h3 className="text-xl font-bold text-slate-900 mb-2">Demographics</h3>
                    <p className="text-sm text-slate-400 font-medium mb-8">Patient breakdown by age group</p>

                    <div className="flex-1 min-h-[200px] relative">
                        <ResponsiveContainer width="100%" height="100%">
                            <PieChart>
                                <Pie
                                    data={demographicsData}
                                    cx="50%"
                                    cy="50%"
                                    innerRadius={60}
                                    outerRadius={80}
                                    paddingAngle={5}
                                    dataKey="value"
                                >
                                    {demographicsData.map((entry, index) => (
                                        <Cell key={`cell-${index}`} fill={entry.color} strokeWidth={0} />
                                    ))}
                                </Pie>
                                <Tooltip contentStyle={{ borderRadius: '12px', border: 'none' }} />
                            </PieChart>
                        </ResponsiveContainer>
                        {/* Center Label */}
                        <div className="absolute inset-0 flex items-center justify-center pointer-events-none">
                            <div className="text-center">
                                <p className="text-2xl font-black text-slate-900">{campId === 'dadaab' ? '1.5k' : '1.1k'}</p>
                                <p className="text-[10px] font-bold text-slate-400 uppercase tracking-widest">Patients</p>
                            </div>
                        </div>
                    </div>

                    <div className="mt-8 space-y-3">
                        {demographicsData.map((item) => (
                            <div key={item.name} className="flex justify-between items-center text-sm">
                                <div className="flex items-center gap-3">
                                    <div className="w-3 h-3 rounded-full" style={{ backgroundColor: item.color }} />
                                    <span className="font-bold text-slate-600">{item.name}</span>
                                </div>
                                <span className="font-bold text-slate-900">{item.value}</span>
                            </div>
                        ))}
                    </div>
                </div>
            </div>
        </div>
    );
}

export default function CampManagerOverview() {
    return (
        <ManagementLayout>
            <Suspense fallback={<div>Loading dashboard...</div>}>
                <DashboardContent />
            </Suspense>
        </ManagementLayout>
    );
}

function KpiCard({ title, value, trend, icon, color, positive, negative }: any) {
    const colorStyles: any = {
        ocean: 'bg-ocean-50 text-ocean-600',
        blue: 'bg-blue-50 text-blue-600',
        rose: 'bg-rose-50 text-rose-600',
        indigo: 'bg-indigo-50 text-indigo-600',
    };

    const isPositive = trend.startsWith('+') || positive;
    const isNegative = trend.startsWith('-') || negative;

    return (
        <motion.div
            whileHover={{ y: -4 }}
            className="bg-white p-6 rounded-4xl border border-slate-200 shadow-sm hover:shadow-xl transition-all duration-300"
        >
            <div className="flex justify-between items-start mb-4">
                <div className={`p-3 rounded-2xl ${colorStyles[color]}`}>
                    {icon}
                </div>
                {!positive && !negative && (
                    <span className="px-2 py-1 rounded-lg bg-slate-100 text-slate-600 text-xs font-bold">{trend}</span>
                )}
                {positive && (
                    <span className="px-2 py-1 rounded-lg bg-blue-100 text-blue-700 text-xs font-bold">{trend}</span>
                )}
                {negative && (
                    <span className="px-2 py-1 rounded-lg bg-rose-100 text-rose-700 text-xs font-bold">{trend}</span>
                )}
            </div>
            <div>
                <p className="text-slate-400 text-sm font-bold uppercase tracking-widest mb-1">{title}</p>
                <h3 className="text-3xl font-black text-slate-900">{value}</h3>
            </div>
        </motion.div>
    );
}
