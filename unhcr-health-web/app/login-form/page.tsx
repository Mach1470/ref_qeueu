'use client';

import { motion } from 'framer-motion';
import { ArrowLeft, Lock, Mail, ShieldCheck, Activity } from 'lucide-react';
import { useSearchParams, useRouter } from 'next/navigation';
import { useState, Suspense } from 'react';

function LoginFormContent() {
    const searchParams = useSearchParams();
    const router = useRouter();
    const role = searchParams.get('role') || 'staff';
    const facilityId = searchParams.get('facilityId') || 'unknown';
    const facilityName = searchParams.get('facilityName') || 'Health Facility';

    const [isLoading, setIsLoading] = useState(false);
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');

    const handleLogin = async (e: React.FormEvent) => {
        e.preventDefault();
        setIsLoading(true);

        setTimeout(() => {
            setIsLoading(false);
            router.push(`/dashboard/${role}?facilityId=${facilityId}`);
        }, 1500);
    };

    return (
        <div className="min-h-screen relative flex flex-col font-sans overflow-hidden">
            {/* Background Layer */}
            <div className="absolute inset-0 z-0 bg-slate-50">
                <div className="absolute inset-0 bg-blue-50/50 backdrop-blur-xl" />
            </div>

            <header className="relative z-20 p-6 h-20 flex items-center">
                <div className="container-custom w-full">
                    <button
                        onClick={() => router.back()}
                        className="inline-flex items-center gap-2 text-slate-500 hover:text-primary transition-colors group"
                    >
                        <div className="p-2 rounded-xl bg-white border border-slate-100 group-hover:bg-blue-50 transition-all font-medium">
                            <ArrowLeft size={16} />
                        </div>
                        <span className="text-xs font-medium tracking-wide">Back</span>
                    </button>
                </div>
            </header>

            <main className="relative z-10 flex-1 flex items-center justify-center p-6 pb-20">
                <div className="w-full max-w-[420px]">
                    <motion.div
                        initial={{ opacity: 0, y: 30, scale: 0.95 }}
                        animate={{ opacity: 1, y: 0, scale: 1 }}
                        transition={{ duration: 0.5, ease: "easeOut" }}
                        className="relative rounded-[2.5rem] overflow-hidden shadow-2xl shadow-black/20"
                    >
                        {/* Glass Card Background */}
                        <div className="absolute inset-0 bg-white border border-slate-100 z-0" />

                        {/* Glow Effect */}
                        <div className="absolute -top-20 -right-20 w-64 h-64 bg-blue-400/30 rounded-full blur-[80px]" />
                        <div className="absolute -bottom-20 -left-20 w-64 h-64 bg-blue-500/30 rounded-full blur-[80px]" />

                        <div className="relative z-10 p-10">
                            <div className="flex flex-col items-center text-center mb-10">
                                <div className="w-16 h-16 bg-linear-to-br from-primary to-blue-400 rounded-2xl flex items-center justify-center text-white shadow-xl shadow-blue-500/20 mb-6 border border-white/10">
                                    <ShieldCheck size={32} />
                                </div>
                                <h1 className="text-2xl font-extrabold text-slate-900 mb-2">Secure Access</h1>
                                <div className="flex flex-col items-center gap-1">
                                    <p className="text-primary font-bold text-[10px] uppercase tracking-[0.2em]">{role.replace('_', ' ')} Portal</p>
                                    <p className="text-slate-500 text-[10px] font-bold uppercase tracking-wider">{facilityName}</p>
                                </div>
                            </div>

                            <form onSubmit={handleLogin} className="space-y-6">
                                <div className="space-y-2">
                                    <label className="block text-xs font-bold text-slate-400 uppercase tracking-widest ml-1">Email Address</label>
                                    <div className="relative group">
                                        <Mail className="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-slate-300 group-focus-within:text-primary transition-colors" />
                                        <input
                                            type="email"
                                            required
                                            value={email}
                                            onChange={(e) => setEmail(e.target.value)}
                                            placeholder="name@unhcr.org"
                                            className="w-full pl-12 pr-4 py-4 bg-slate-50 border border-slate-100 rounded-2xl text-slate-900 placeholder:text-slate-400 focus:bg-white focus:border-primary outline-none transition-all font-medium"
                                        />
                                    </div>
                                </div>

                                <div className="space-y-2">
                                    <label className="block text-xs font-bold text-slate-400 uppercase tracking-widest ml-1">Password</label>
                                    <div className="relative group">
                                        <Lock className="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-slate-300 group-focus-within:text-primary transition-colors" />
                                        <input
                                            type="password"
                                            required
                                            value={password}
                                            onChange={(e) => setPassword(e.target.value)}
                                            placeholder="••••••••"
                                            className="w-full pl-12 pr-4 py-4 bg-slate-50 border border-slate-100 rounded-2xl text-slate-900 placeholder:text-slate-400 focus:bg-white focus:border-primary outline-none transition-all font-medium"
                                        />
                                    </div>
                                </div>

                                <div className="pt-2">
                                    <button
                                        type="submit"
                                        disabled={isLoading}
                                        className="w-full py-4 bg-white text-main rounded-2xl font-bold text-sm uppercase tracking-widest hover:bg-slate-50 hover:scale-[1.02] active:scale-[0.98] transition-all flex items-center justify-center gap-3 shadow-lg shadow-black/10 disabled:opacity-70 disabled:cursor-not-allowed group"
                                    >
                                        {isLoading ? (
                                            <motion.div
                                                animate={{ rotate: 360 }}
                                                transition={{ repeat: Infinity, duration: 1, ease: 'linear' }}
                                            >
                                                <Activity className="w-5 h-5 text-primary" />
                                            </motion.div>
                                        ) : (
                                            'Sign In'
                                        )}
                                    </button>
                                </div>
                            </form>
                        </div>
                    </motion.div>

                    <p className="mt-8 text-center text-slate-400 text-xs font-bold uppercase tracking-widest leading-none">
                        UNHCR Secure System • Monitoring Active
                    </p>
                </div>
            </main>
        </div>
    );
}

export default function LoginFormPage() {
    return (
        <Suspense fallback={<div className="min-h-screen bg-slate-900 flex items-center justify-center text-white">Loading...</div>}>
            <LoginFormContent />
        </Suspense>
    );
}
