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
    BarChart3,
    Activity,
    Menu
} from 'lucide-react';
import { Suspense, useState } from 'react';
import { useSearchParams } from 'next/navigation';
import Link from 'next/link';
import { useFirebaseData } from '@/lib/hooks/useFirebaseData';
import { StaffUser } from '@/lib/types';
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
    const [isSidebarOpen, setIsSidebarOpen] = useState(true);

    const { data: facilitiesData, loading: loadingFacilities } = useFirebaseData('facilities');
    const { data: staffData, loading: loadingStaff } = useFirebaseData('staff');

    const facilitiesList = facilitiesData ? Object.values(facilitiesData) as any[] : [];
    const staffList = staffData ? Object.values(staffData) as any[] : [];

    const facility = facilitiesList.find(f => f.id === facilityIdFromQuery);
    const facilityName = facilityNameFromQuery || facility?.name || 'UNHCR Main Camp Hospital';
    const myStaff = staffList.filter(u => u.facilityId === facilityIdFromQuery);

    return (
        <div className="min-h-screen flex bg-stone-50 text-stone-900 overflow-hidden font-sans" suppressHydrationWarning>
            {/* Sidebar */}
            <motion.aside
                initial={false}
                animate={{ width: isSidebarOpen ? 280 : 80 }}
                className="bg-white border-r border-stone-200 flex flex-col z-30 relative shadow-sm shrink-0"
            >
                <div className="p-6 flex items-center justify-between border-b border-stone-100">
                    <Link href="/" className="flex items-center gap-3 overflow-hidden cursor-pointer group">
                        <div className="w-10 h-10 shrink-0 bg-primary text-white rounded-xl flex items-center justify-center overflow-hidden border border-primary/20 shadow-sm group-hover:bg-primary-dark transition-all">
                            <span className="font-bold text-lg">MQ</span>
                        </div>
                        {isSidebarOpen && (
                            <div>
                                <span className="font-display font-bold text-stone-900 tracking-tight text-lg block leading-none">
                                    Admin Portal<span className="text-primary font-bold">.</span>
                                </span>
                            </div>
                        )}
                    </Link>
                </div>

                <nav className="flex-1 px-4 py-6 space-y-2 overflow-y-auto custom-scrollbar">
                    <NavItem
                        icon={<Users size={20} />}
                        label="Staff Management"
                        active={activeTab === 'staff'}
                        isSidebarOpen={isSidebarOpen}
                        onClick={() => setActiveTab('staff')}
                    />
                    <NavItem
                        icon={<ArrowRightLeft size={20} />}
                        label="Transfers"
                        active={activeTab === 'transfers'}
                        isSidebarOpen={isSidebarOpen}
                        onClick={() => setActiveTab('transfers')}
                    />
                    <NavItem
                        icon={<BarChart3 size={20} />}
                        label="Facility Analytics"
                        active={activeTab === 'analytics'}
                        isSidebarOpen={isSidebarOpen}
                        onClick={() => setActiveTab('analytics')}
                    />
                    <NavItem
                        icon={<Settings size={20} />}
                        label="Hospital Settings"
                        active={activeTab === 'settings'}
                        isSidebarOpen={isSidebarOpen}
                        onClick={() => setActiveTab('settings')}
                    />
                </nav>

                <div className="p-4 mt-auto border-t border-stone-100 bg-stone-50/50">
                    {isSidebarOpen && (
                        <div className="flex items-center gap-3 mb-4 px-2">
                            <div className="w-10 h-10 rounded-xl bg-blue-100 flex items-center justify-center border border-blue-200 shadow-sm overflow-hidden text-primary font-bold">
                                SJ
                            </div>
                            <div className="flex-1">
                                <p className="text-sm font-bold text-stone-900 leading-tight">Sarah Johnson</p>
                                <p className="text-[10px] text-stone-500 font-bold uppercase tracking-widest">Administrator</p>
                            </div>
                        </div>
                    )}
                    <Link href="/" className="w-full flex items-center gap-4 px-4 py-3 text-rose-600 hover:bg-rose-50 hover:border-rose-100 border border-transparent rounded-xl transition-all duration-200 font-bold">
                        <LogOut size={20} />
                        {isSidebarOpen && <span className="text-sm">Sign Out</span>}
                    </Link>
                </div>

                {/* Sidebar toggle button (floating) */}
                <button
                    onClick={() => setIsSidebarOpen(!isSidebarOpen)}
                    className="absolute -right-4 top-8 w-8 h-8 rounded-full bg-white border border-stone-200 flex items-center justify-center text-stone-500 hover:text-primary hover:border-primary transition-all z-40 shadow-sm"
                >
                    {isSidebarOpen ? <X size={14} /> : <Menu size={14} />}
                </button>
            </motion.aside>

            {/* Main Content */}
            <main className="flex-1 flex flex-col h-screen overflow-hidden relative bg-stone-50">
                {/* Topbar */}
                <header className="h-20 bg-white border-b border-stone-200 px-8 flex items-center justify-between shrink-0 z-20 shadow-sm">
                    <div>
                        <div className="flex items-center gap-3">
                            <h2 className="text-sm font-bold text-primary uppercase tracking-widest">Admin Control</h2>
                        </div>
                        <p className="text-stone-500 font-medium text-sm">{facilityName}</p>
                    </div>

                    <div className="flex items-center gap-6">
                        {/* Search Bar */}
                        <div className="hidden lg:flex items-center gap-3 bg-stone-50 border border-stone-200 rounded-full px-5 py-2.5 focus-within:bg-white focus-within:border-primary/50 transition-all shadow-inner">
                            <Search size={18} className="text-stone-400" />
                            <input 
                                type="text" 
                                placeholder="Search entire facility..." 
                                className="bg-transparent border-none outline-none text-sm text-stone-800 placeholder-stone-400 w-64 font-medium"
                            />
                        </div>
                    </div>
                </header>

                <div className="flex-1 overflow-y-auto custom-scrollbar flex flex-col">
                    <EmergencyAlerts />
                    <div className="p-6 lg:p-10 relative z-10 flex-1">
                        <motion.div
                            initial={{ opacity: 0, y: 10 }}
                            animate={{ opacity: 1, y: 0 }}
                            transition={{ duration: 0.4 }}
                        >
                            <header className="flex flex-col md:flex-row md:justify-between md:items-end mb-10 gap-6 bg-white p-8 rounded-3xl border border-stone-200 shadow-sm">
                                <div>
                                    <h1 className="text-3xl font-display font-bold text-stone-900 mb-2">
                                        {activeTab === 'staff' && 'Staff Management'}
                                        {activeTab === 'transfers' && 'Transfer Requests'}
                                        {activeTab === 'analytics' && 'Facility Analytics'}
                                        {activeTab === 'settings' && 'Hospital Settings'}
                                    </h1>
                                    <p className="text-stone-500 font-medium text-lg">
                                        {activeTab === 'analytics' ? 'Monitor performance and resource usage across the facility.' : 'Manage your medical team and daily hospital operations.'}
                                    </p>
                                </div>
                                {activeTab === 'staff' && (
                                    <button
                                        onClick={() => setShowAddStaffModal(true)}
                                        className="btn-primary flex items-center gap-2 whitespace-nowrap shadow-sm px-6 py-3.5 text-sm"
                                    >
                                        <UserPlus size={18} />
                                        Add Staff Member
                                    </button>
                                )}
                            </header>

                            {activeTab === 'staff' && (
                                <div className="space-y-6">
                                    {/* Filters */}
                                    <div className="bg-white border border-stone-200 rounded-2xl p-4 flex flex-col sm:flex-row gap-4 shadow-sm">
                                        <div className="relative flex-1">
                                            <Search className="absolute left-4 top-1/2 -translate-y-1/2 text-stone-400 w-5 h-5" />
                                            <input
                                                type="text"
                                                placeholder="Search by name, role or email..."
                                                className="w-full pl-12 pr-4 py-3 bg-stone-50 border border-stone-200 rounded-xl outline-none focus:border-primary/50 focus:bg-white text-stone-900 placeholder-stone-400 transition-all text-sm font-medium"
                                            />
                                        </div>
                                        <select className="bg-stone-50 border border-stone-200 px-4 py-3 rounded-xl outline-none text-sm font-bold text-stone-700 focus:border-primary/50 focus:bg-white appearance-none min-w-[160px] shadow-sm">
                                            <option value="all">All Roles</option>
                                            <option value="doctors">Doctors</option>
                                            <option value="nurses">Nurses</option>
                                        </select>
                                    </div>

                                    {/* Staff List */}
                                    <div className="bg-white border border-stone-200 rounded-3xl overflow-hidden shadow-sm">
                                        <div className="overflow-x-auto">
                                            <table className="w-full text-left">
                                                <thead className="bg-stone-50 border-b border-stone-200">
                                                    <tr>
                                                        <th className="p-5 text-[10px] font-bold text-stone-500 uppercase tracking-widest">Name</th>
                                                        <th className="p-5 text-[10px] font-bold text-stone-500 uppercase tracking-widest">Role</th>
                                                        <th className="p-5 text-[10px] font-bold text-stone-500 uppercase tracking-widest">Assignment</th>
                                                        <th className="p-5 text-[10px] font-bold text-stone-500 uppercase tracking-widest">Status</th>
                                                        <th className="p-5 text-[10px] font-bold text-stone-500 uppercase tracking-widest text-right">Actions</th>
                                                    </tr>
                                                </thead>
                                                <tbody className="divide-y divide-stone-100">
                                                    {myStaff.map(staff => (
                                                        <StaffRow key={staff.id} staff={staff} />
                                                    ))}
                                                </tbody>
                                            </table>
                                        </div>
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
                                            subValue="vs last week"
                                            icon={<TrendingUp size={24} />}
                                            color="blue"
                                        />
                                        <SmallStatCard
                                            title="Safety Rating"
                                            value="99.2%"
                                            subValue="Excellent"
                                            icon={<ShieldCheck size={24} />}
                                            color="emerald"
                                        />
                                        <SmallStatCard
                                            title="Resource Opt."
                                            value="84%"
                                            subValue="Increasing"
                                            icon={<BarChart3 size={24} />}
                                            color="purple"
                                        />
                                    </div>

                                    <div className="grid lg:grid-cols-2 gap-8">
                                        <div className="bg-white border border-stone-200 rounded-3xl p-8 shadow-sm">
                                            <h3 className="text-xl font-bold text-stone-900 mb-6 flex items-center gap-3">
                                                <Activity className="text-primary" size={20} />
                                                Facility Activity Breakdown
                                            </h3>
                                            <div className="flex justify-center items-center h-[300px]">
                                                <ActivityDonut />
                                            </div>
                                        </div>

                                        <div className="bg-white border border-stone-200 rounded-3xl p-8 shadow-sm">
                                            <h3 className="text-xl font-bold text-stone-900 mb-8">Department Performance</h3>
                                            <div className="space-y-8">
                                                <PerformanceItem label="General OPD" progress={85} color="bg-primary" />
                                                <PerformanceItem label="Laboratory" progress={62} color="bg-blue-500" />
                                                <PerformanceItem label="Pharmacy" progress={94} color="bg-emerald-500" />
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
                        </motion.div>
                    </div>
                </div>
            </main>
        </div>
    );
}

export default function HospitalAdminDashboard() {
    return (
        <Suspense fallback={<div className="min-h-screen bg-stone-50 flex items-center justify-center text-primary font-bold">Loading Admin Portal...</div>}>
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
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 sm:p-6 bg-stone-900/40 backdrop-blur-sm">
            <motion.div
                initial={{ opacity: 0, scale: 0.95, y: 20 }}
                animate={{ opacity: 1, scale: 1, y: 0 }}
                exit={{ opacity: 0, scale: 0.95, y: 20 }}
                className="bg-white border border-stone-200 rounded-3xl shadow-2xl w-full max-w-lg overflow-hidden"
            >
                <div className="p-8 border-b border-stone-100 flex justify-between items-center bg-stone-50/50">
                    <h2 className="text-2xl font-display font-bold text-stone-900">Add Staff Member</h2>
                    <button onClick={onClose} className="p-2 hover:bg-stone-100 rounded-xl text-stone-400 hover:text-stone-600 transition-colors">
                        <X size={24} />
                    </button>
                </div>

                <form onSubmit={handleSubmit} className="p-8 space-y-6">
                    <div>
                        <label className="block text-[10px] font-bold text-stone-500 uppercase tracking-widest mb-2 ml-1">Full Name</label>
                        <input
                            type="text"
                            required
                            placeholder="e.g. John Doe"
                            value={formData.name}
                            onChange={e => setFormData({ ...formData, name: e.target.value })}
                            className="w-full px-5 py-4 bg-stone-50 border border-stone-200 rounded-2xl focus:bg-white focus:border-primary/50 outline-none text-sm font-bold text-stone-900 transition-all placeholder-stone-400 shadow-inner"
                        />
                    </div>
                    <div>
                        <label className="block text-[10px] font-bold text-stone-500 uppercase tracking-widest mb-2 ml-1">Email Address</label>
                        <input
                            type="email"
                            required
                            placeholder="e.g. john.d@unhcr.org"
                            value={formData.email}
                            onChange={e => setFormData({ ...formData, email: e.target.value })}
                            className="w-full px-5 py-4 bg-stone-50 border border-stone-200 rounded-2xl focus:bg-white focus:border-primary/50 outline-none text-sm font-bold text-stone-900 transition-all placeholder-stone-400 shadow-inner"
                        />
                    </div>
                    <div className="grid grid-cols-2 gap-6">
                        <div>
                            <label className="block text-[10px] font-bold text-stone-500 uppercase tracking-widest mb-2 ml-1">Role</label>
                            <select
                                value={formData.role}
                                onChange={e => setFormData({ ...formData, role: e.target.value })}
                                className="w-full px-5 py-4 bg-stone-50 border border-stone-200 rounded-2xl focus:bg-white focus:border-primary/50 outline-none text-sm font-bold text-stone-900 transition-all appearance-none shadow-inner"
                            >
                                <option value="doctor">Doctor</option>
                                <option value="nurse">Nurse</option>
                                <option value="lab_tech">Lab Technician</option>
                                <option value="pharmacist">Pharmacist</option>
                                <option value="maternity_staff">Maternity Staff</option>
                            </select>
                        </div>
                        <div>
                            <label className="block text-[10px] font-bold text-stone-500 uppercase tracking-widest mb-2 ml-1">Room / Office</label>
                            <input
                                type="text"
                                placeholder="e.g. Room 4"
                                value={formData.room}
                                onChange={e => setFormData({ ...formData, room: e.target.value })}
                                className="w-full px-5 py-4 bg-stone-50 border border-stone-200 rounded-2xl focus:bg-white focus:border-primary/50 outline-none text-sm font-bold text-stone-900 transition-all placeholder-stone-400 shadow-inner"
                            />
                        </div>
                    </div>

                    <div className="pt-6 flex gap-4 mt-8">
                        <button
                            type="button"
                            onClick={onClose}
                            className="flex-1 px-6 py-4 bg-stone-100 text-stone-600 rounded-2xl font-bold hover:bg-stone-200 transition-colors"
                        >
                            Cancel
                        </button>
                        <button
                            type="submit"
                            disabled={isSubmitting}
                            className="flex-1 btn-primary py-4 text-base"
                        >
                            {isSubmitting ? 'Creating...' : 'Create Account'}
                        </button>
                    </div>
                </form>
            </motion.div>
        </div>
    );
}

function SmallStatCard({ title, value, subValue, icon, color }: any) {
    const colorStyles: any = {
        blue: 'text-primary bg-blue-50 border-blue-100',
        emerald: 'text-emerald-600 bg-emerald-50 border-emerald-100',
        purple: 'text-purple-600 bg-purple-50 border-purple-100',
    };

    return (
        <div className="bg-white border border-stone-200 rounded-3xl p-6 flex items-center gap-5 shadow-sm hover:shadow-md transition-shadow">
            <div className={`w-14 h-14 shrink-0 rounded-2xl flex items-center justify-center border shadow-sm ${colorStyles[color]}`}>
                {icon}
            </div>
            <div>
                <p className="text-[10px] font-bold text-stone-400 uppercase tracking-widest mb-1">{title}</p>
                <div className="flex items-baseline gap-2">
                    <span className="text-3xl font-display font-bold text-stone-900">{value}</span>
                    <span className={`text-[10px] font-bold uppercase ${colorStyles[color].split(' ')[0]}`}>{subValue}</span>
                </div>
            </div>
        </div>
    );
}

function PerformanceItem({ label, progress, color }: any) {
    return (
        <div className="space-y-3">
            <div className="flex justify-between items-center px-1">
                <span className="text-sm font-bold text-stone-600">{label}</span>
                <span className="text-xs font-black text-stone-900">{progress}%</span>
            </div>
            <div className="h-2.5 w-full bg-stone-100 rounded-full overflow-hidden shadow-inner">
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

function NavItem({ icon, label, active, onClick, isSidebarOpen }: any) {
    return (
        <button
            onClick={onClick}
            className={`w-full flex items-center gap-4 px-4 py-3.5 rounded-2xl transition-all duration-300 font-bold ${active 
                ? 'bg-blue-50 text-primary shadow-sm border border-blue-100' 
                : 'text-stone-500 hover:bg-stone-50 hover:text-stone-900 border border-transparent'
            }`}
        >
            <div className={active ? 'text-primary' : 'text-stone-400'}>
                {icon}
            </div>
            {isSidebarOpen && <span className="text-sm whitespace-nowrap">{label}</span>}
        </button>
    );
}

function StaffRow({ staff }: { staff: StaffUser }) {
    const statusColors: any = {
        active: 'bg-emerald-50 text-emerald-700 border-emerald-200',
        pending_approval: 'bg-amber-50 text-amber-700 border-amber-200',
        transfer_pending: 'bg-purple-50 text-purple-700 border-purple-200',
        on_leave: 'bg-stone-100 text-stone-600 border-stone-200',
    };

    const statusLabels: any = {
        active: 'Active',
        pending_approval: 'Pending',
        transfer_pending: 'Transferring',
        on_leave: 'On Leave',
    };

    return (
        <tr className="hover:bg-stone-50/50 transition-colors group border-b border-stone-100 last:border-0">
            <td className="p-5">
                <div className="flex items-center gap-4">
                    <div className="w-12 h-12 rounded-xl bg-stone-50 border border-stone-200 flex items-center justify-center font-bold text-stone-500 text-lg shadow-sm">
                        {staff.name.charAt(0)}
                    </div>
                    <div>
                        <p className="font-bold text-stone-900 text-base">{staff.name}</p>
                        <p className="text-xs text-stone-500 font-medium mt-0.5">{staff.email}</p>
                    </div>
                </div>
            </td>
            <td className="p-5">
                <div className="flex items-center gap-2">
                    <Briefcase size={16} className="text-stone-400" />
                    <span className="text-sm font-bold text-stone-700 capitalize">{staff.role.replace('_', ' ')}</span>
                </div>
            </td>
            <td className="p-5 text-sm font-bold text-stone-500 font-mono">
                {staff.roomAssignment || 'Unassigned'}
            </td>
            <td className="p-5">
                <span className={`inline-flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-[10px] font-bold uppercase tracking-wider border shadow-sm ${statusColors[staff.status] || 'bg-stone-100 text-stone-500 border-stone-200'}`}>
                    {staff.status === 'active' && <CheckCircle2 size={14} />}
                    {staff.status === 'pending_approval' && <Clock size={14} />}
                    {statusLabels[staff.status] || staff.status}
                </span>
            </td>
            <td className="p-5 text-right">
                <button className="p-2 hover:bg-stone-100 rounded-xl text-stone-400 hover:text-stone-900 transition-colors border border-transparent hover:border-stone-200">
                    <MoreVertical size={20} />
                </button>
            </td>
        </tr>
    );
}

