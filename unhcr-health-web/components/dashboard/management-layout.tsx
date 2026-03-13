'use client';

import { motion } from 'framer-motion';
import {
    Users,
    Settings,
    LogOut,
    Heart,
    LayoutDashboard,
    BarChart3,
    Map,
    ShieldCheck,
    Menu,
    X
} from 'lucide-react';
import Link from 'next/link';
import { usePathname, useRouter } from 'next/navigation';
import { useState } from 'react';

export default function ManagementLayout({
    children
}: {
    children: React.ReactNode;
}) {
    const [isSidebarOpen, setIsSidebarOpen] = useState(true);
    const pathname = usePathname();
    const router = useRouter();

    const navItems = [
        { name: 'Camp Overview', icon: <LayoutDashboard />, href: '/analytics/camp-manager' },
        { name: 'Health Facilities', icon: <Map />, href: '/analytics/camp-manager/facilities' },
        { name: 'Detailed Metrics', icon: <BarChart3 />, href: '/analytics/camp-manager/metrics' },
        { name: 'Security & Access', icon: <ShieldCheck />, href: '/analytics/camp-manager/access' },
        { name: 'System Settings', icon: <Settings />, href: '/analytics/camp-manager/settings' },
    ];

    return (
        <div className="min-h-screen bg-slate-100 flex">
            {/* Sidebar */}
            <motion.aside
                initial={false}
                animate={{ width: isSidebarOpen ? 280 : 80 }}
                className="bg-white border-r border-slate-200 flex flex-col z-30 shadow-sm"
            >
                <div className="p-6 flex items-center justify-between">
                    <Link href="/" className="flex items-center gap-3 overflow-hidden cursor-pointer group">
                        <div className="w-10 h-10 shrink-0 bg-white rounded-xl flex items-center justify-center overflow-hidden border border-slate-200 p-1 group-hover:scale-110 transition-transform">
                            <img src="/images/app_logo.png" alt="MyQueue Logo" className="w-full h-full object-contain" />
                        </div>
                        {isSidebarOpen && (
                            <span className="font-bold text-slate-900 whitespace-nowrap tracking-tight text-xl">MyQueue</span>
                        )}
                    </Link>
                    <button
                        onClick={() => setIsSidebarOpen(!isSidebarOpen)}
                        className="p-2 hover:bg-slate-50 rounded-lg text-slate-400"
                    >
                        {isSidebarOpen ? <X size={20} /> : <Menu size={20} />}
                    </button>
                </div>

                <nav className="flex-1 px-4 py-8 space-y-2">
                    {navItems.map((item) => {
                        const isActive = pathname === item.href;
                        return (
                            <Link key={item.name} href={item.href}>
                                <motion.div
                                    whileHover={{ x: 4 }}
                                    className={`flex items-center gap-4 px-4 py-3 rounded-xl transition-all duration-200 ${isActive
                                        ? 'bg-blue-50 text-blue-600 shadow-sm'
                                        : 'text-slate-500 hover:bg-slate-50 hover:text-slate-600'
                                        }`}
                                >
                                    <div className={isActive ? 'text-blue-600' : 'text-slate-400'}>
                                        {item.icon}
                                    </div>
                                    {isSidebarOpen && <span className="font-semibold">{item.name}</span>}
                                </motion.div>
                            </Link>
                        );
                    })}
                </nav>

                <div className="p-4 mt-auto">
                    <button
                        onClick={() => router.push('/')}
                        className="w-full flex items-center gap-4 px-4 py-3 text-slate-500 hover:bg-rose-50 hover:text-rose-600 rounded-xl transition-all duration-200"
                    >
                        <LogOut size={20} />
                        {isSidebarOpen && <span className="font-semibold">Exit Panel</span>}
                    </button>
                </div>
            </motion.aside>

            {/* Main Content */}
            <main className="flex-1 flex flex-col h-screen overflow-hidden">
                {/* Topbar */}
                <header className="h-20 bg-white border-b border-slate-200 px-8 flex items-center justify-between shrink-0 z-20">
                    <div>
                        <h2 className="text-sm font-bold text-blue-600 uppercase tracking-widest leading-none mb-1">Camp Management</h2>
                        <p className="text-slate-500 font-bold text-lg">Kakuma Refugee Camp Overview</p>
                    </div>

                    <div className="flex items-center gap-4">
                        <Link
                            href="/"
                            className="px-4 py-2 border border-slate-200 rounded-xl text-sm font-bold text-slate-600 hover:bg-slate-50 transition-all flex items-center gap-2"
                        >
                            <Heart size={16} className="text-blue-600" />
                            Main Website
                        </Link>
                        <div className="flex items-center gap-6">
                            <div className="flex items-center gap-2 bg-slate-100 px-3 py-1.5 rounded-full border border-slate-200">
                                <div className="w-2 h-2 bg-green-500 rounded-full animate-pulse" />
                                <span className="text-[10px] font-bold text-slate-600 uppercase tracking-wider">System Live</span>
                            </div>
                            <div className="w-12 h-12 rounded-2xl bg-slate-900 border-2 border-white shadow-lg overflow-hidden">
                                <img
                                    src="https://api.dicebear.com/7.x/avataaars/svg?seed=Manager"
                                    alt="Manager"
                                    className="w-full h-full object-cover"
                                />
                            </div>
                        </div>
                    </div>
                </header>

                {/* Scrollable Content Area */}
                <div className="flex-1 overflow-y-auto p-10 bg-slate-100">
                    {children}
                </div>
            </main>
        </div>
    );
}
