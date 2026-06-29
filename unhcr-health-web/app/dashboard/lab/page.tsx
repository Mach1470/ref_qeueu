'use client';

import { Suspense } from 'react';
import { useSearchParams } from 'next/navigation';
import DashboardLayout from '@/components/dashboard/dashboard-layout';
import { motion } from 'framer-motion';
import { Microscope, Clock, CheckCircle2, FlaskConical, Beaker, FileText, X, AlertCircle } from 'lucide-react';
import { useState } from 'react';

function LabDashboardContent() {
    const searchParams = useSearchParams();
    const facilityName = searchParams.get('facilityName') || 'UNHCR Hospital';
    const facilityIdFromQuery = searchParams.get('facilityId') || 'fac_001';
    const [selectedSample, setSelectedSample] = useState<any>(null);

    return (
        <DashboardLayout role="lab" facilityName={facilityName}>
            <motion.div
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                className="space-y-8"
            >
                {/* Welcome Header */}
                <div className="flex justify-between items-end">
                    <div>
                        <h1 className="text-3xl font-display font-bold text-stone-900">Laboratory Dashboard</h1>
                        <p className="text-stone-500 font-medium">Track samples and manage diagnostic reports</p>
                    </div>
                    <div className="flex gap-3">
                        <button className="px-5 py-3 bg-blue-600 hover:bg-blue-700 text-white rounded-2xl text-sm font-bold shadow-sm transition-colors flex items-center gap-2">
                            <FlaskConical size={18} />
                            New Sample
                        </button>
                    </div>
                </div>

                {/* Stats Grid */}
                <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-6">
                    <StatSummaryCard title="Awaiting Collect" value="5" icon={<Clock />} color="blue" />
                    <StatSummaryCard title="Processing" value="12" icon={<Beaker />} color="purple" />
                    <StatSummaryCard title="Completed" value="89" icon={<CheckCircle2 />} color="emerald" />
                    <StatSummaryCard title="Reports Sent" value="76" icon={<FileText />} color="primary" />
                </div>

                {/* Sample Status Table */}
                <div className="bg-white rounded-3xl p-8 border border-stone-200 shadow-sm overflow-hidden flex flex-col">
                    <div className="flex justify-between items-center mb-6">
                        <h3 className="text-xl font-display font-bold text-stone-900">Sample Queue</h3>
                        <div className="flex gap-2">
                            <span className="px-3 py-1 bg-blue-50 text-blue-600 rounded-lg text-xs font-bold border border-blue-100">5 Waiting</span>
                            <span className="px-3 py-1 bg-purple-50 text-purple-600 rounded-lg text-xs font-bold border border-purple-100">12 Processing</span>
                        </div>
                    </div>

                    <div className="overflow-x-auto">
                        <table className="w-full">
                            <thead>
                                <tr className="text-left text-stone-400 text-xs font-bold uppercase tracking-widest border-b border-stone-100 pb-4">
                                    <th className="pb-4">Patient</th>
                                    <th className="pb-4">Test Requested</th>
                                    <th className="pb-4">Collection Time</th>
                                    <th className="pb-4">Status</th>
                                    <th className="pb-4 text-right">Action</th>
                                </tr>
                            </thead>
                            <tbody className="divide-y divide-stone-100">
                                <SampleRow
                                    name="Sarah Ali"
                                    id="REF-5521"
                                    test="Blood Count, Malaria"
                                    time="5m ago"
                                    status="Awaiting"
                                    onClick={() => setSelectedSample({ name: 'Sarah Ali', id: 'REF-5521', test: 'Blood Count, Malaria', status: 'Awaiting' })}
                                />
                                <SampleRow
                                    name="Ahmed Noor"
                                    id="REF-0019"
                                    test="Urinalysis"
                                    time="12m ago"
                                    status="Processing"
                                    active
                                    onClick={() => setSelectedSample({ name: 'Ahmed Noor', id: 'REF-0019', test: 'Urinalysis', status: 'Processing' })}
                                />
                                <SampleRow
                                    name="Beatrice Wanjiku"
                                    id="REF-9283"
                                    test="Thyroid Profile"
                                    time="25m ago"
                                    status="Processing"
                                    active
                                    onClick={() => setSelectedSample({ name: 'Beatrice Wanjiku', id: 'REF-9283', test: 'Thyroid Profile', status: 'Processing' })}
                                />
                            </tbody>
                        </table>
                    </div>
                </div>
            </motion.div>

            {/* Result Entry Modal */}
            {selectedSample && (
                <div className="fixed inset-0 z-50 flex items-center justify-center p-6 bg-stone-900/40 backdrop-blur-sm">
                    <motion.div
                        initial={{ opacity: 0, scale: 0.95 }}
                        animate={{ opacity: 1, scale: 1 }}
                        className="bg-white rounded-[2.5rem] shadow-2xl w-full max-w-2xl overflow-hidden"
                    >
                        <div className="p-8 border-b border-stone-100 flex justify-between items-center bg-stone-50/50">
                            <div>
                                <h2 className="text-2xl font-display font-bold text-stone-900">Lab Result Entry</h2>
                                <p className="text-stone-500 font-medium">Entering results for {selectedSample.name}</p>
                            </div>
                            <button onClick={() => setSelectedSample(null)} className="p-2 hover:bg-stone-100 rounded-xl text-stone-400 hover:text-stone-600 transition-colors">
                                <X size={24} />
                            </button>
                        </div>

                        <div className="p-8 space-y-6">
                            <div className="bg-stone-50 rounded-2xl p-6 border border-stone-200 shadow-inner flex justify-between items-center">
                                <div>
                                    <p className="text-[10px] font-bold text-stone-500 uppercase tracking-widest mb-1">Test Requested</p>
                                    <p className="font-bold text-stone-900">{selectedSample.test}</p>
                                </div>
                                <div className="text-right">
                                    <p className="text-[10px] font-bold text-stone-500 uppercase tracking-widest mb-1">Sample ID</p>
                                    <p className="font-bold text-stone-900">#LAB-{selectedSample.id.split('-')[1]}</p>
                                </div>
                            </div>

                            <div className="space-y-4">
                                <label className="block text-sm font-black text-stone-900 uppercase tracking-widest">Test Results</label>
                                <div className="grid gap-4">
                                    {selectedSample.test.split(',').map((test: string, idx: number) => (
                                        <div key={idx} className="flex gap-4 items-center">
                                            <div className="flex-1">
                                                <p className="text-xs font-bold text-stone-500 mb-1 capitalize">{test.trim()}</p>
                                                <input
                                                    type="text"
                                                    placeholder="Enter value..."
                                                    className="w-full px-5 py-3 bg-stone-50 border border-stone-200 rounded-xl outline-none focus:bg-white focus:border-primary/50 transition-all font-bold text-stone-900 shadow-inner"
                                                />
                                            </div>
                                            <div className="w-24">
                                                <p className="text-xs font-bold text-stone-500 mb-1">Unit</p>
                                                <input
                                                    type="text"
                                                    placeholder="e.g. g/dL"
                                                    className="w-full px-3 py-3 bg-stone-50 border border-stone-200 rounded-xl outline-none focus:bg-white focus:border-primary/50 transition-all font-bold text-stone-900 shadow-inner"
                                                />
                                            </div>
                                        </div>
                                    ))}
                                </div>
                            </div>

                            <div className="space-y-4">
                                <label className="block text-sm font-black text-stone-900 uppercase tracking-widest">Lab Notes</label>
                                <textarea
                                    placeholder="Add any observations or remarks..."
                                    className="w-full h-32 p-5 bg-stone-50 border border-stone-200 rounded-2xl outline-none focus:bg-white focus:border-primary/50 transition-all font-medium text-stone-900 resize-none shadow-inner"
                                />
                            </div>

                            <div className="pt-4 flex gap-4">
                                <button
                                    className="flex-1 py-4 bg-primary text-white hover:bg-primary-dark rounded-2xl font-bold transition-colors shadow-sm"
                                >
                                    Submit Results
                                </button>
                                <button className="px-6 py-4 bg-rose-50 text-rose-600 rounded-2xl font-bold flex items-center gap-2 hover:bg-rose-100 transition-colors border border-rose-100">
                                    <AlertCircle size={20} />
                                    Flag Error
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
        green: 'bg-emerald-50 text-emerald-600 border-emerald-100',
        emerald: 'bg-emerald-50 text-emerald-600 border-emerald-100',
        ocean: 'bg-blue-50 text-blue-600 border-blue-100',
        blue: 'bg-blue-50 text-blue-600 border-blue-100',
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

function SampleRow({ name, id, test, time, status, active, onClick }: any) {
    const statusColors: any = {
        'Awaiting': 'bg-stone-50 text-stone-600 border-stone-200',
        'Processing': 'bg-purple-50 text-purple-700 border-purple-200',
        'Ready': 'bg-emerald-50 text-emerald-700 border-emerald-200',
    };

    return (
        <tr className={`group transition-colors ${active ? 'bg-purple-50/30' : 'hover:bg-stone-50/50'}`}>
            <td className="py-6">
                <div>
                    <p className="font-bold text-stone-900">{name}</p>
                    <p className="text-xs text-stone-500 font-medium mt-0.5">{id}</p>
                </div>
            </td>
            <td className="py-6">
                <span className="text-sm font-bold text-stone-700">{test}</span>
            </td>
            <td className="py-6 text-sm text-stone-500 font-medium">
                {time}
            </td>
            <td className="py-6">
                <span className={`px-3 py-1.5 rounded-lg text-[10px] font-bold uppercase tracking-wider border shadow-sm ${statusColors[status]}`}>
                    {status}
                </span>
            </td>
            <td className="py-6 text-right">
                <button
                    onClick={onClick}
                    className={`px-5 py-2.5 rounded-xl text-xs font-bold transition-all ${active ? 'bg-primary text-white shadow-sm hover:bg-primary-dark' : 'text-primary hover:bg-stone-100 border border-transparent'
                        }`}>
                    {status === 'Awaiting' ? 'Collect Sample' : 'Enter Results'}
                </button>
            </td>
        </tr>
    );
}

export default function LabDashboard() {
    return (
        <Suspense fallback={<div className="min-h-screen bg-stone-50 flex items-center justify-center font-bold text-primary">Loading Dashboard...</div>}>
            <div suppressHydrationWarning>
                <LabDashboardContent />
            </div>
        </Suspense>
    );
}
