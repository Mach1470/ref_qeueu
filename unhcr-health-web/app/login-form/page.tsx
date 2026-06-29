'use client';

import { motion } from 'framer-motion';
import { ArrowLeft, Lock, Mail, ShieldCheck, Activity } from 'lucide-react';
import { useSearchParams, useRouter } from 'next/navigation';
import { useState, Suspense } from 'react';

import { signInWithEmailAndPassword } from 'firebase/auth';
import { auth } from '@/lib/firebase';

function LoginFormContent() {
    const searchParams = useSearchParams();
    const router = useRouter();
    const role = searchParams.get('role') || 'staff';
    const facilityId = searchParams.get('facilityId') || 'unknown';
    const facilityName = searchParams.get('facilityName') || 'Health Facility';

    const [isLoading, setIsLoading] = useState(false);
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');
    const [error, setError] = useState('');

    const handleLogin = async (e: React.FormEvent) => {
        e.preventDefault();
        setIsLoading(true);
        setError('');

        try {
            await signInWithEmailAndPassword(auth, email, password);
            router.push(`/dashboard/${role}?facilityId=${facilityId}`);
        } catch (err: any) {
            console.error("Auth error:", err);
            setError('Invalid credentials. Please check your email and password.');
        } finally {
            setIsLoading(false);
        }
    };

    return (
        <div className="min-h-screen relative flex flex-col font-sans overflow-hidden bg-stone-50">
            <header className="relative z-20 p-6 h-20 flex items-center">
                <div className="container-custom w-full">
                    <button
                        onClick={() => router.back()}
                        className="inline-flex items-center gap-2 text-stone-500 hover:text-blue-600 transition-colors group"
                    >
                        <div className="p-2 rounded-xl bg-white border border-stone-200 shadow-sm group-hover:bg-blue-50 group-hover:border-blue-100 transition-all font-medium">
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
                        className="bg-white rounded-[2.5rem] p-10 shadow-sm border border-stone-200 relative overflow-hidden"
                    >
                        <div className="relative z-10">
                            <div className="flex flex-col items-center text-center mb-10">
                                <div className="w-16 h-16 bg-stone-100 rounded-2xl flex items-center justify-center text-stone-600 shadow-inner mb-6 border border-stone-200">
                                    <ShieldCheck size={32} />
                                </div>
                                <h1 className="text-3xl font-display font-bold text-stone-900 mb-2">Secure Access</h1>
                                <div className="flex flex-col items-center gap-1 mt-2">
                                    <p className="text-blue-600 font-bold text-[10px] uppercase tracking-[0.2em]">{role.replace('_', ' ')} Portal</p>
                                    <p className="text-stone-400 text-[10px] font-bold uppercase tracking-wider">{facilityName}</p>
                                </div>
                            </div>

                            <form onSubmit={handleLogin} className="space-y-6">
                                {error && (
                                    <div className="p-4 bg-rose-50 border border-rose-200 rounded-2xl flex items-center gap-3 text-rose-700 text-sm font-bold shadow-sm">
                                        {error}
                                    </div>
                                )}
                                <div className="space-y-2">
                                    <label className="block text-xs font-bold text-stone-500 uppercase tracking-widest ml-1">Email Address</label>
                                    <div className="relative group">
                                        <Mail className="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-stone-400 group-focus-within:text-blue-600 transition-colors" />
                                        <input
                                            type="email"
                                            required
                                            value={email}
                                            onChange={(e) => setEmail(e.target.value)}
                                            placeholder="name@unhcr.org"
                                            className="w-full pl-12 pr-4 py-4 bg-stone-50 border border-stone-200 rounded-2xl text-stone-900 placeholder-stone-400 focus:bg-white focus:border-blue-500 focus:shadow-sm outline-none transition-all font-medium"
                                        />
                                    </div>
                                </div>

                                <div className="space-y-2">
                                    <label className="block text-xs font-bold text-stone-500 uppercase tracking-widest ml-1">Password</label>
                                    <div className="relative group">
                                        <Lock className="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-stone-400 group-focus-within:text-blue-600 transition-colors" />
                                        <input
                                            type="password"
                                            required
                                            value={password}
                                            onChange={(e) => setPassword(e.target.value)}
                                            placeholder="••••••••"
                                            className="w-full pl-12 pr-4 py-4 bg-stone-50 border border-stone-200 rounded-2xl text-stone-900 placeholder-stone-400 focus:bg-white focus:border-blue-500 focus:shadow-sm outline-none transition-all font-medium"
                                        />
                                    </div>
                                </div>

                                <div className="pt-2">
                                    <button
                                        type="submit"
                                        disabled={isLoading}
                                        className="w-full py-4 bg-primary text-white rounded-2xl font-bold text-sm uppercase tracking-widest hover:bg-primary-dark hover:scale-[1.02] active:scale-[0.98] transition-all flex items-center justify-center gap-3 shadow-md disabled:opacity-70 disabled:cursor-not-allowed group"
                                    >
                                        {isLoading ? (
                                            <motion.div
                                                animate={{ rotate: 360 }}
                                                transition={{ repeat: Infinity, duration: 1, ease: 'linear' }}
                                            >
                                                <Activity className="w-5 h-5 text-white" />
                                            </motion.div>
                                        ) : (
                                            'Sign In'
                                        )}
                                    </button>
                                </div>
                            </form>
                        </div>
                    </motion.div>

                    <p className="mt-8 text-center text-stone-400 text-xs font-bold uppercase tracking-widest leading-none">
                        UNHCR Secure System • Monitoring Active
                    </p>
                </div>
            </main>
        </div>
    );
}

export default function LoginFormPage() {
    return (
        <Suspense fallback={<div className="min-h-screen bg-stone-50 flex items-center justify-center text-primary font-bold">Loading...</div>}>
            <LoginFormContent />
        </Suspense>
    );
}
