'use client';

import { motion } from 'framer-motion';
import { ArrowLeft, Lock, Mail, ChevronRight, AlertCircle, BarChart3 } from 'lucide-react';
import Link from 'next/link';
import { useState, Suspense } from 'react';
import { useRouter, useSearchParams } from 'next/navigation';

function LoginForm() {
    const router = useRouter();
    const searchParams = useSearchParams();
    const campId = searchParams.get('camp') || 'kakuma';

    const [credentials, setCredentials] = useState({ email: '', password: '' });
    const [isSubmitting, setIsSubmitting] = useState(false);
    const [error, setError] = useState('');

    const campName = campId === 'kakuma' ? 'Kakuma Refugee Camp' : 'Dadaab Refugee Complex';

    const handleLogin = async (e: React.FormEvent) => {
        e.preventDefault();
        setIsSubmitting(true);
        setError('');

        // Simulate secure auth check
        setTimeout(() => {
            if (credentials.email === 'admin@unhcr.org' && credentials.password === 'admin123') {
                router.push(`/analytics/camp-manager?camp=${campId}`);
            } else {
                setError('Invalid credentials. Please check your email and password.');
                setIsSubmitting(false);
            }
        }, 1500);
    };

    return (
        <form onSubmit={handleLogin} className="space-y-6">
            {error && (
                <motion.div
                    initial={{ opacity: 0, y: -10 }}
                    animate={{ opacity: 1, y: 0 }}
                    className="p-4 bg-rose-500/20 border border-rose-500/30 rounded-xl flex items-center gap-3 text-rose-200 text-sm font-bold backdrop-blur-md"
                >
                    <AlertCircle size={18} />
                    {error}
                </motion.div>
            )}

            <div className="space-y-2">
                <label className="block text-xs font-bold text-slate-400 uppercase tracking-widest ml-1">Official Email</label>
                <div className="relative group">
                    <Mail className="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-slate-300 group-focus-within:text-primary transition-colors" />
                    <input
                        type="email"
                        required
                        placeholder="name@unhcr.org"
                        value={credentials.email}
                        onChange={(e) => setCredentials({ ...credentials, email: e.target.value })}
                        className="w-full pl-12 pr-4 py-4 bg-slate-50 border border-slate-100 rounded-2xl text-slate-900 placeholder:text-slate-400 focus:bg-white focus:border-primary outline-none transition-all font-medium"
                    />
                </div>
            </div>

            <div className="space-y-2">
                <label className="block text-xs font-bold text-slate-400 uppercase tracking-widest ml-1">Secure Password</label>
                <div className="relative group">
                    <Lock className="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-slate-300 group-focus-within:text-primary transition-colors" />
                    <input
                        type="password"
                        required
                        placeholder="••••••••"
                        value={credentials.password}
                        onChange={(e) => setCredentials({ ...credentials, password: e.target.value })}
                        className="w-full pl-12 pr-4 py-4 bg-slate-50 border border-slate-100 rounded-2xl text-slate-900 placeholder:text-slate-400 focus:bg-white focus:border-primary outline-none transition-all font-medium"
                    />
                </div>
            </div>

            <div className="flex items-center justify-between">
                <label className="flex items-center gap-2 cursor-pointer">
                    <input type="checkbox" className="w-4 h-4 rounded border-white/30 text-primary focus:ring-primary bg-black/20" />
                    <span className="text-sm font-bold text-slate-500">Remember device</span>
                </label>
                <a href="#" className="text-sm font-bold text-primary hover:text-primary-dark transition-colors">Forgot password?</a>
            </div>

            <button
                type="submit"
                disabled={isSubmitting}
                className="w-full py-4 bg-primary text-white rounded-2xl font-black text-sm uppercase tracking-widest hover:bg-primary-dark hover:scale-[1.02] active:scale-[0.98] transition-all flex items-center justify-center gap-2 shadow-lg shadow-blue-500/20 disabled:opacity-70 disabled:cursor-not-allowed mt-8"
            >
                {isSubmitting ? (
                    <span className="animate-pulse">Authenticating...</span>
                ) : (
                    <>
                        Access Dashboard <ChevronRight size={18} />
                    </>
                )}
            </button>

            <p className="text-center text-xs font-medium text-slate-400 mt-8 leading-relaxed">
                Authorized personnel for <span className="text-slate-600 font-bold">{campName}</span> only.
                <br />All access attempts are logged for security.
            </p>
        </form>
    );
}

export default function ManagerLoginPage() {
    return (
        <div className="min-h-screen relative flex flex-col font-sans overflow-hidden">
            {/* Background Layer */}
            <div className="absolute inset-0 z-0 bg-slate-50">
                <div className="absolute inset-0 bg-blue-50/50 backdrop-blur-xl" />
            </div>

            <header className="relative z-20 px-8 py-6 h-20 flex items-center">
                <div className="container-custom w-full">
                    <Link href="/access" className="inline-flex items-center gap-2 text-slate-500 hover:text-primary transition-colors group">
                        <div className="p-2 rounded-xl bg-white border border-slate-100 group-hover:bg-blue-50 transition-all font-medium">
                            <ArrowLeft size={16} />
                        </div>
                        <span className="text-xs font-medium tracking-wide">Back to Selection</span>
                    </Link>
                </div>
            </header>

            <main className="relative z-10 flex-1 flex items-center justify-center p-6">
                <div className="w-full max-w-[420px]">
                    <motion.div
                        initial={{ opacity: 0, y: 30, scale: 0.95 }}
                        animate={{ opacity: 1, y: 0, scale: 1 }}
                        transition={{ duration: 0.5, ease: "easeOut" }}
                        className="relative rounded-[2.5rem] overflow-hidden shadow-2xl shadow-black/40"
                    >
                        {/* Blur Layer */}
                        <div className="absolute inset-0 bg-white border border-slate-100 z-0" />

                        {/* Glows */}
                        <div className="absolute top-0 right-0 w-64 h-64 bg-amber-500/20 rounded-full blur-[80px]" />
                        <div className="absolute bottom-0 left-0 w-64 h-64 bg-slate-500/20 rounded-full blur-[80px]" />

                        <div className="relative z-10 p-10">
                            <div className="flex flex-col items-center text-center mb-10">
                                <div className="w-16 h-16 bg-linear-to-br from-primary to-blue-400 rounded-2xl flex items-center justify-center text-white shadow-xl shadow-blue-500/20 mb-6 border border-white/10">
                                    <BarChart3 size={32} />
                                </div>
                                <h1 className="text-2xl font-extrabold text-slate-900 mb-2">Manager Portal</h1>
                                <p className="text-primary font-bold text-[10px] uppercase tracking-[0.2em] leading-none">Restricted Access Area</p>
                            </div>

                            <Suspense fallback={<div className="text-slate-400 text-center font-bold">Loading...</div>}>
                                <LoginForm />
                            </Suspense>
                        </div>
                    </motion.div>

                    <p className="mt-8 text-center text-slate-400 text-xs font-bold uppercase tracking-widest">
                        Logged Access Only • 2FA Enabled
                    </p>
                </div>
            </main>
        </div>
    );
}
