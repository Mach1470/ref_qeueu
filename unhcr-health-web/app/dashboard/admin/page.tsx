'use client';

import { motion, AnimatePresence } from 'framer-motion';
import {
    Users,
    UserPlus,
    Search,
    Settings,
    LogOut,
    Briefcase,
    MoreVertical,
    CheckCircle2,
    Clock,
    ArrowRightLeft,
    X,
    TrendingUp,
    ShieldCheck,
    BarChart3
} from 'lucide-react';
import { Suspense, useState } from 'react';
import { useSearchParams } from 'next/navigation';
import Link from 'next/link';
import { mockStaffUsers, StaffUser } from '@/lib/admin-data';
import { mockHealthFacilities } from '@/lib/facilities';
import ActivityDonut from '@/components/dashboard/activity-donut';
import EmergencyAlerts from '@/components/dashboard/emergency-alerts';

// Mock current admin session
const CURRENT_ADMIN_ID = 'staff_001';
const CURRENT_FACILITY_ID = 'fac_001';

function HospitalAdminContent() {
    const searchParams = useSearchParams();
    const facilityIdFromQuery = searchParams.get('facilityId') || CURRENT_FACILITY_ID;
    const facilityNameFromQuery = searchParams.get('facilityName');

    const [activeTab, setActiveTab] = useState<'staff' | 'transfers' | 'analytics' | 'settings'>('staff');
    const [showAddStaffModal, setShowAddStaffModal] = useState(false);

    const facility = mockHealthFacilities.find(f => f.id === facilityIdFromQuery);
    const facilityName = facilityNameFromQuery || facility?.name || 'UNHCR Main Camp Hospital';
    const myStaff = mockStaffUsers.filter(u => u.facilityId === facilityIdFromQuery);

    return (
        <div style={{ backgroundColor: '#f8fafc' }} className="min-h-screen flex text-[#0f172a]" suppressHydrationWarning>
            {/* Sidebar */}
            <aside className="w-72 bg-white border-r border-slate-200 text-slate-900 p-6 flex flex-col fixed h-full z-10 shadow-sm">
                <div className="flex items-center gap-3 mb-12">
                    <div className="w-10 h-10 bg-humanitarian-500 rounded-xl flex items-center justify-center font-bold text-lg">
                        HA
                    </div>
                    <div>
                        <h2 className="font-bold text-lg leading-tight text-slate-900">Admin Portal</h2>
                        <p className="text-xs text-slate-500 font-medium">{facilityName}</p>
                    </div>
                </div>

                <nav className="space-y-2 flex-1">
                    <NavItem
                        icon={<Users size={20} />}
                        label="Staff Management"
                        active={activeTab === 'staff'}
                        onClick={() => setActiveTab('staff')}
                    />
                    <NavItem
                        icon={<ArrowRightLeft size={20} />}
                        label="Transfers"
                        active={activeTab === 'transfers'}
                        onClick={() => setActiveTab('transfers')}
                    />
                    <NavItem
                        icon={<BarChart3 size={20} />}
                        label="Facility Analytics"
                        active={activeTab === 'analytics'}
                        onClick={() => setActiveTab('analytics')}
                    />
                    <NavItem
                        icon={<Settings size={20} />}
                        label="Hospital Settings"
                        active={activeTab === 'settings'}
                        onClick={() => setActiveTab('settings')}
                    />
                </nav>

                <div className="pt-6 border-t border-slate-100">
                    <div className="flex items-center gap-3 mb-6">
                        <div className="w-8 h-8 rounded-full bg-slate-100 flex items-center justify-center border border-slate-200">
                            <span className="text-xs font-bold text-slate-600">SJ</span>
                        </div>
                        <div className="flex-1">
                            <p className="text-sm font-bold">Sarah Johnson</p>
                            <p className="text-xs text-slate-500">Hospital Administrator</p>
                        </div>
                    </div>
                    <Link href="/login" className="flex items-center gap-2 text-rose-400 text-sm font-bold hover:text-rose-300 transition-colors">
                        <LogOut size={16} />
                        Sign Out
                    </Link>
                </div>
            </aside>

            {/* Main Content */}
            <main className="flex-1 ml-72 p-8 md:p-12">
                <header className="flex justify-between items-end mb-10">
                    <div>
                        <h1 className="text-3xl font-black text-slate-900 mb-2">
                            {activeTab === 'staff' && 'Staff Management'}
                            {activeTab === 'transfers' && 'Transfer Requests'}
                            {activeTab === 'analytics' && 'Facility Analytics'}
                            {activeTab === 'settings' && 'Hospital Settings'}
                        </h1>
                        <p className="text-slate-500 font-medium">
                            {activeTab === 'analytics' ? 'Monitor performance and resource usage' : 'Manage your team and facility operations'}
                        </p>
                    </div>
                    {activeTab === 'staff' && (
                        <button
                            onClick={() => setShowAddStaffModal(true)}
                            className="px-6 py-3 bg-humanitarian-600 text-white rounded-xl font-bold flex items-center gap-2 hover:bg-humanitarian-700 transition-all shadow-lg shadow-humanitarian-100"
                        >
                            <UserPlus size={18} />
                            Add Staff Member
                        </button>
                    )}
                </header>

                {/* REAL-TIME EMERGENCY ALERTS */}
                <div className="mb-10">
                    <EmergencyAlerts />
                </div>

                {activeTab === 'staff' && (
                    <div className="space-y-6">
                        {/* Filters */}
                        <div className="bg-white p-4 rounded-2xl border border-slate-200 flex gap-4">
                            <div className="relative flex-1">
                                <Search className="absolute left-4 top-1/2 -translate-y-1/2 text-slate-400 w-5 h-5" />
                                <input
                                    type="text"
                                    placeholder="Search by name, role or email..."
                                    className="w-full pl-12 pr-4 py-2 bg-slate-50 rounded-xl border-none outline-none font-medium"
                                />
                            </div>
                            <select className="bg-slate-50 px-4 rounded-xl border-none outline-none text-sm font-bold text-slate-600">
                                <option>All Roles</option>
                                <option>Doctors</option>
                                <option>Nurses</option>
                            </select>
                        </div>

                        {/* Staff List */}
                        <div className="bg-white rounded-3xl border border-slate-200 overflow-hidden shadow-sm">
                            <table className="w-full text-left">
                                <thead className="bg-slate-50 border-b border-slate-100/50">
                                    <tr>
                                        <th className="p-6 text-xs font-bold text-slate-400 uppercase tracking-widest">Name</th>
                                        <th className="p-6 text-xs font-bold text-slate-400 uppercase tracking-widest">Role</th>
                                        <th className="p-6 text-xs font-bold text-slate-400 uppercase tracking-widest">Assignment</th>
                                        <th className="p-6 text-xs font-bold text-slate-400 uppercase tracking-widest">Status</th>
                                        <th className="p-6 text-xs font-bold text-slate-400 uppercase tracking-widest text-right">Actions</th>
                                    </tr>
                                </thead>
                                <tbody className="divide-y divide-slate-100">
                                    {myStaff.map(staff => (
                                        <StaffRow key={staff.id} staff={staff} />
                                    ))}
                                </tbody>
                            </table>
                        </div>
                    </div>
                )}

                {activeTab === 'analytics' && (
                    <div className="space-y-8">
                        {/* High Level Stats */}
                        <div className="grid md:grid-cols-3 gap-6">
                            <SmallStatCard
                                title="Patient Throughput"
                                value="+12%"
                                subValue="v/s last week"
                                icon={<TrendingUp className="text-blue-600" />}
                            />
                            <SmallStatCard
                                title="Safety Rating"
                                value="99.2%"
                                subValue="Excellent"
                                icon={<ShieldCheck className="text-blue-600" />}
                            />
                            <SmallStatCard
                                title="Resource Opt."
                                value="84%"
                                subValue="Increasing"
                                icon={<BarChart3 className="text-purple-600" />}
                            />
                        </div>

                        <div className="grid lg:grid-cols-2 gap-8">
                            <ActivityDonut />

                            <div className="bg-white rounded-[2.5rem] p-8 border border-slate-200 shadow-sm">
                                <h3 className="text-xl font-bold text-slate-900 mb-6">Department Performance</h3>
                                <div className="space-y-6">
                                    <PerformanceItem label="General OPD" progress={85} color="bg-humanitarian-500" />
                                    <PerformanceItem label="Laboratory" progress={62} color="bg-blue-500" />
                                    <PerformanceItem label="Pharmacy" progress={94} color="bg-purple-500" />
                                    <PerformanceItem label="Maternity" progress={78} color="bg-rose-500" />
                                </div>
                            </div>
                        </div>
                    </div>
                )}

                {/* Modals */}
                <AnimatePresence>
                    {showAddStaffModal && (
                        <CreateStaffModal onClose={() => setShowAddStaffModal(false)} />
                    )}
                </AnimatePresence>
            </main>
        </div>
    );
}

export default function HospitalAdminDashboard() {
    return (
        <Suspense fallback={<div className="min-h-screen bg-slate-50 flex items-center justify-center">Loading Admin Portal...</div>}>
            <HospitalAdminContent />
        </Suspense>
    );
}

function CreateStaffModal({ onClose }: { onClose: () => void }) {
    const [formData, setFormData] = useState({
        name: '',
        email: '',
        role: 'nurse',
        room: ''
    });

    const [isSubmitting, setIsSubmitting] = useState(false);

    const handleSubmit = async (e: any) => {
        e.preventDefault();
        setIsSubmitting(true);
        // Simulate API call
        await new Promise(resolve => setTimeout(resolve, 1000));
        onClose();
    };

    return (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-6 bg-slate-900/60 backdrop-blur-md">
            <motion.div
                initial={{ opacity: 0, scale: 0.95 }}
                animate={{ opacity: 1, scale: 1 }}
                exit={{ opacity: 0, scale: 0.95 }}
                className="bg-white rounded-4xl shadow-2xl w-full max-w-lg overflow-hidden"
            >
                <div className="p-8 border-b border-slate-100 flex justify-between items-center">
                    <h2 className="text-2xl font-bold text-slate-900">Add Staff Member</h2>
                    <button onClick={onClose} className="p-2 hover:bg-slate-50 rounded-xl text-slate-400">
                        <X size={24} />
                    </button>
                </div>

                <form onSubmit={handleSubmit} className="p-8 space-y-6">
                    <div>
                        <label className="block text-xs font-bold text-slate-400 uppercase tracking-widest mb-2 ml-1">Full Name</label>
                        <input
                            type="text"
                            required
                            placeholder="e.g. John Doe"
                            value={formData.name}
                            onChange={e => setFormData({ ...formData, name: e.target.value })}
                            className="w-full px-5 py-3 bg-slate-50 border-2 border-slate-50 rounded-xl focus:bg-white focus:border-blue-500 outline-none font-bold text-slate-700 transition-all"
                        />
                    </div>
                    <div>
                        <label className="block text-xs font-bold text-slate-400 uppercase tracking-widest mb-2 ml-1">Email Address</label>
                        <input
                            type="email"
                            required
                            placeholder="e.g. john.d@unhcr.org"
                            value={formData.email}
                            onChange={e => setFormData({ ...formData, email: e.target.value })}
                            className="w-full px-5 py-3 bg-slate-50 border-2 border-slate-50 rounded-xl focus:bg-white focus:border-blue-500 outline-none font-bold text-slate-700 transition-all"
                        />
                    </div>
                    <div className="grid grid-cols-2 gap-6">
                        <div>
                            <label className="block text-xs font-bold text-slate-400 uppercase tracking-widest mb-2 ml-1">Role</label>
                            <select
                                value={formData.role}
                                onChange={e => setFormData({ ...formData, role: e.target.value })}
                                className="w-full px-5 py-3 bg-slate-50 border-2 border-slate-50 rounded-xl focus:bg-white focus:border-blue-500 outline-none font-bold text-slate-700 transition-all"
                            >
                                <option value="doctor">Doctor</option>
                                <option value="nurse">Nurse</option>
                                <option value="lab_tech">Lab Technician</option>
                                <option value="pharmacist">Pharmacist</option>
                                <option value="maternity_staff">Maternity Staff</option>
                            </select>
                        </div>
                        <div>
                            <label className="block text-xs font-bold text-slate-400 uppercase tracking-widest mb-2 ml-1">Room / Office</label>
                            <input
                                type="text"
                                placeholder="e.g. Room 4"
                                value={formData.room}
                                onChange={e => setFormData({ ...formData, room: e.target.value })}
                                className="w-full px-5 py-3 bg-slate-50 border-2 border-slate-50 rounded-xl focus:bg-white focus:border-blue-500 outline-none font-bold text-slate-700 transition-all"
                            />
                        </div>
                    </div>

                    <div className="pt-4 flex gap-4">
                        <button
                            type="button"
                            onClick={onClose}
                            className="flex-1 px-6 py-3 bg-slate-100 text-slate-600 rounded-xl font-bold hover:bg-slate-200 transition-colors"
                        >
                            Cancel
                        </button>
                        <button
                            type="submit"
                            disabled={isSubmitting}
                            className="flex-1 px-6 py-3 bg-blue-600 text-white rounded-xl font-bold hover:bg-blue-700 transition-all shadow-lg shadow-blue-100 disabled:opacity-50"
                        >
                            {isSubmitting ? 'Creating...' : 'Create Account'}
                        </button>
                    </div>
                </form>
            </motion.div>
        </div>
    );
}

function SmallStatCard({ title, value, subValue, icon }: any) {
    return (
        <div className="bg-white p-6 rounded-3xl border border-slate-200 flex items-center gap-5">
            <div className="w-12 h-12 rounded-2xl bg-slate-50 flex items-center justify-center">
                {icon}
            </div>
            <div>
                <p className="text-[10px] font-bold text-slate-400 uppercase tracking-widest mb-0.5">{title}</p>
                <div className="flex items-baseline gap-2">
                    <span className="text-2xl font-black text-slate-900">{value}</span>
                    <span className="text-[10px] font-bold text-blue-600">{subValue}</span>
                </div>
            </div>
        </div>
    );
}

function PerformanceItem({ label, progress, color }: any) {
    return (
        <div className="space-y-2">
            <div className="flex justify-between items-center px-1">
                <span className="text-sm font-bold text-slate-600">{label}</span>
                <span className="text-xs font-black text-slate-900">{progress}%</span>
            </div>
            <div className="h-2 w-full bg-slate-100 rounded-full overflow-hidden">
                <motion.div
                    initial={{ width: 0 }}
                    animate={{ width: `${progress}%` }}
                    transition={{ duration: 1, ease: "easeOut" }}
                    className={`h-full ${color}`}
                />
            </div>
        </div>
    );
}

function NavItem({ icon, label, active, onClick }: any) {
    return (
        <button
            onClick={onClick}
            className={`w-full flex items-center gap-3 px-4 py-3 rounded-xl transition-all font-bold text-sm ${active ? 'bg-blue-50 text-blue-600 shadow-sm' : 'text-slate-500 hover:text-blue-600 hover:bg-blue-50/50'
                }`}
        >
            {icon}
            {label}
        </button>
    );
}

function StaffRow({ staff }: { staff: StaffUser }) {
    const statusColors: any = {
        active: 'bg-blue-100 text-blue-700',
        pending_approval: 'bg-amber-100 text-amber-700',
        transfer_pending: 'bg-purple-100 text-purple-700',
        on_leave: 'bg-slate-100 text-slate-600',
    };

    const statusLabels: any = {
        active: 'Active',
        pending_approval: 'Pending Approval',
        transfer_pending: 'Transfer Requested',
        on_leave: 'On Leave',
    };

    return (
        <tr className="hover:bg-slate-50/50 transition-colors group">
            <td className="p-6">
                <div className="flex items-center gap-3">
                    <div className="w-10 h-10 rounded-full bg-slate-100 flex items-center justify-center font-bold text-slate-500 text-sm">
                        {staff.name.charAt(0)}
                    </div>
                    <div>
                        <p className="font-bold text-slate-900">{staff.name}</p>
                        <p className="text-xs text-slate-500 font-medium">{staff.email}</p>
                    </div>
                </div>
            </td>
            <td className="p-6">
                <div className="flex items-center gap-2">
                    <Briefcase size={14} className="text-slate-400" />
                    <span className="text-sm font-bold text-slate-700 capitalize">{staff.role.replace('_', ' ')}</span>
                </div>
            </td>
            <td className="p-6 text-sm font-medium text-slate-500">
                {staff.roomAssignment || 'Unassigned'}
            </td>
            <td className="p-6">
                <span className={`inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-xs font-bold uppercase tracking-wider ${statusColors[staff.status] || 'bg-slate-100 text-slate-500'}`}>
                    {staff.status === 'active' && <CheckCircle2 size={12} />}
                    {staff.status === 'pending_approval' && <Clock size={12} />}
                    {statusLabels[staff.status] || staff.status}
                </span>
            </td>
            <td className="p-6 text-right">
                <button className="p-2 hover:bg-slate-100 rounded-lg text-slate-400 hover:text-slate-900 transition-colors">
                    <MoreVertical size={18} />
                </button>
            </td>
        </tr>
    );
}
