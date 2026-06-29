'use client';

import { motion } from 'framer-motion';
import {
    Users,
    Settings,
    LogOut,
    LayoutDashboard,
    Clock,
    ClipboardList,
    Menu,
    X,
    Bell,
    Search
} from 'lucide-react';
import Link from 'next/link';
import { usePathname, useRouter } from 'next/navigation';
import { useState } from 'react';
import EmergencyAlerts from './emergency-alerts';

export default function DashboardLayout({
    children,
    role,
    facilityName
}: {
    children: React.ReactNode;
    role: string;
    facilityName: string;
}) {
    const [isSidebarOpen, setIsSidebarOpen] = useState(true);
    const pathname = usePathname();
    const router = useRouter();

    const navItems = [
        { name: 'Dashboard', icon: <LayoutDashboard size={20} />, href: `/dashboard/${role}` },
        { name: 'Active Queue', icon: <Clock size={20} />, href: `/dashboard/${role}/queue` },
        { name: 'Past Records', icon: <ClipboardList size={20} />, href: `/dashboard/${role}/history` },
        { name: 'Directory', icon: <Users size={20} />, href: `/dashboard/${role}/directory` },
        { name: 'Settings', icon: <Settings size={20} />, href: `/dashboard/${role}/settings` },
    ];

    return (
        <div className="min-h-screen bg-stone-50 flex text-stone-900 overflow-hidden font-sans">
            {/* Sidebar */}
            <motion.aside
                initial={false}
                animate={{ width: isSidebarOpen ? 280 : 80 }}
                className="bg-white border-r border-stone-200 flex flex-col z-30 relative shadow-sm shrink-0 transition-all duration-300"
            >
                <div className="p-6 flex items-center justify-between border-b border-stone-100">
                    <Link href="/" className="flex items-center gap-3 overflow-hidden cursor-pointer group">
                        <div className="w-10 h-10 shrink-0 bg-primary text-white rounded-xl flex items-center justify-center font-bold text-lg shadow-sm">
                            MQ
                        </div>
                        {isSidebarOpen && (
                            <span className="font-display font-bold text-stone-900 tracking-tight text-xl whitespace-nowrap">
                                MyQueue<span className="text-primary font-light">.</span>
                            </span>
                        )}
                    </Link>
                </div>

                <nav className="flex-1 px-4 py-8 space-y-3 overflow-y-auto">
                    {navItems.map((item) => {
                        const isActive = pathname === item.href;
                        return (
                            <Link key={item.name} href={item.href}>
                                <motion.div
                                    whileHover={{ x: 4 }}
                                    className={`flex items-center gap-4 px-4 py-3 rounded-xl transition-all duration-300 ${isActive
                                        ? 'bg-primary/5 text-primary font-semibold shadow-sm border border-primary/10'
                                        : 'text-stone-500 hover:bg-stone-50 hover:text-stone-800 border border-transparent font-medium'
                                        }`}
                                >
                                    <div className={isActive ? 'text-primary' : 'text-stone-400'}>
                                        {item.icon}
                                    </div>
                                    {isSidebarOpen && <span className="text-sm whitespace-nowrap">{item.name}</span>}
                                </motion.div>
                            </Link>
                        );
                    })}
                </nav>

                <div className="p-6 mt-auto border-t border-stone-100">
                    <button
                        onClick={() => router.push('/')}
                        className="w-full flex items-center gap-4 px-4 py-3 text-stone-500 hover:text-rose-600 hover:bg-rose-50 border border-transparent rounded-xl transition-all duration-200 font-medium"
                    >
                        <LogOut size={20} />
                        {isSidebarOpen && <span className="text-sm whitespace-nowrap">Sign Out</span>}
                    </button>
                </div>

                {/* Sidebar toggle button (floating over border) */}
                <button
                    onClick={() => setIsSidebarOpen(!isSidebarOpen)}
                    className="absolute -right-4 top-8 w-8 h-8 rounded-full bg-white border border-stone-200 flex items-center justify-center text-stone-400 hover:text-stone-700 hover:bg-stone-50 transition-all z-40 shadow-sm"
                >
                    {isSidebarOpen ? <X size={14} /> : <Menu size={14} />}
                </button>
            </motion.aside>

            {/* Main Content */}
            <main className="flex-1 flex flex-col h-screen overflow-hidden relative bg-stone-50">
                {/* Topbar */}
                <header className="h-20 bg-white/80 backdrop-blur-md border-b border-stone-200 px-8 flex items-center justify-between shrink-0 z-20 shadow-sm">
                    <div>
                        <div className="flex items-center gap-3">
                            <h2 className="text-sm font-bold text-stone-900 uppercase tracking-widest">{role} Portal</h2>
                            <span className="px-2.5 py-0.5 rounded-full bg-emerald-100 border border-emerald-200 text-[10px] font-bold text-emerald-700 uppercase tracking-widest">Live Operations</span>
                        </div>
                        <p className="text-stone-500 font-medium text-sm mt-0.5">{facilityName}</p>
                    </div>

                    <div className="flex items-center gap-6">
                        {/* Search Bar */}
                        <div className="hidden lg:flex items-center gap-2 bg-stone-100 border border-transparent rounded-full px-4 py-2.5 focus-within:bg-white focus-within:border-primary/30 focus-within:shadow-sm transition-all">
                            <Search size={16} className="text-stone-400" />
                            <input 
                                type="text" 
                                placeholder="Search patient ID..." 
                                className="bg-transparent border-none outline-none text-sm text-stone-800 placeholder-stone-400 w-48 font-medium"
                            />
                        </div>

                        {/* Notifications */}
                        <button className="relative p-2.5 rounded-full bg-stone-100 text-stone-500 hover:text-primary hover:bg-primary/5 transition-colors">
                            <Bell size={20} />
                            <span className="absolute top-1 right-1 w-2.5 h-2.5 rounded-full bg-rose-500 animate-pulse border-2 border-white" />
                        </button>

                        <div className="w-px h-8 bg-stone-200" />

                        <div className="flex items-center gap-4">
                            <div className="text-right mr-2 hidden sm:block">
                                <p className="text-sm font-bold text-stone-900">Staff Member</p>
                                <p className="text-xs text-stone-500 capitalize font-medium">{role}</p>
                            </div>
                            <div className="w-11 h-11 rounded-xl bg-stone-100 border border-stone-200 shadow-sm overflow-hidden shrink-0">
                                <img
                                    src="https://api.dicebear.com/7.x/avataaars/svg?seed=Staff"
                                    alt="Profile"
                                    className="w-full h-full object-cover"
                                />
                            </div>
                        </div>
                    </div>
                </header>

                {/* Fixed Emergency Announcements Banner */}
                <div className="z-10 relative">
                    <EmergencyAlerts />
                </div>

                {/* Scrollable Content Area */}
                <div className="flex-1 overflow-y-auto p-8 lg:p-12 relative z-0">
                    <motion.div
                        initial={{ opacity: 0, y: 10 }}
                        animate={{ opacity: 1, y: 0 }}
                        transition={{ duration: 0.4 }}
                        className="h-full max-w-7xl mx-auto"
                    >
                        {children}
                    </motion.div>
                </div>
            </main>
        </div>
    );
}

