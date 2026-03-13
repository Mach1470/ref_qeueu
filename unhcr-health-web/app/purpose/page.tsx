'use client';

import { motion } from 'framer-motion';
import { Heart, Shield, Zap, Users, ArrowLeft, Globe, Target, Eye } from 'lucide-react';
import Link from 'next/link';

export default function PurposePage() {
    return (
        <div className="min-h-screen bg-slate-50 font-sans">
            {/* Header */}
            <header className="fixed top-0 w-full z-50 bg-white/90 backdrop-blur-md border-b border-slate-100">
                <div className="container-custom h-20 flex justify-between items-center">
                    <Link href="/" className="flex items-center gap-2 group">
                        <div className="p-2 rounded-xl bg-slate-50 border border-slate-100 group-hover:bg-slate-100 transition-colors">
                            <ArrowLeft size={18} className="text-slate-500" />
                        </div>
                        <span className="font-medium text-slate-500 text-xs">Back to Home</span>
                    </Link>
                    <div className="flex items-center gap-2">
                        <img src="/images/app_logo.png" alt="MyQueue" className="w-8 h-8 object-contain" />
                        <span className="text-xl font-bold text-slate-900 tracking-tight">myqueue</span>
                    </div>
                </div>
            </header>

            <main className="pt-32 pb-20 px-6">
                <div className="container-custom">
                    <motion.div
                        initial={{ opacity: 0, y: 20 }}
                        animate={{ opacity: 1, y: 0 }}
                        className="text-center mb-16"
                    >
                        <span className="px-3 py-1 bg-blue-50 text-primary rounded-full text-[10px] font-bold uppercase tracking-widest border border-blue-100 mb-6 inline-block">
                            Our Mission
                        </span>
                        <h1 className="text-4xl md:text-5xl font-extrabold text-main mb-8 tracking-tight">
                            Elevating Refugee Healthcare <br />
                            <span className="text-primary">Through Innovation.</span>
                        </h1>
                        <p className="text-lg text-secondary leading-relaxed font-light max-w-2xl mx-auto">
                            We believe that accessing healthcare is a fundamental right. Our purpose is to restore dignity and speed to the humanitarian medical journey.
                        </p>
                    </motion.div>

                    <div className="grid md:grid-cols-2 gap-8 mb-16">
                        <motion.div
                            initial={{ opacity: 0, x: -10 }}
                            animate={{ opacity: 1, x: 0 }}
                            transition={{ delay: 0.2 }}
                            className="bg-white p-10 rounded-3xl border border-slate-100 shadow-xl shadow-slate-200/40"
                        >
                            <div className="w-12 h-12 bg-blue-50 text-primary rounded-xl flex items-center justify-center mb-6">
                                <Target size={24} />
                            </div>
                            <h2 className="text-2xl font-bold text-main mb-4 tracking-tight">Our Mission</h2>
                            <p className="text-secondary font-light leading-relaxed">
                                To replace chaotic physical queues with a coordinated digital ecosystem that prioritizes human life and dignity.
                            </p>
                        </motion.div>

                        <motion.div
                            initial={{ opacity: 0, x: 10 }}
                            animate={{ opacity: 1, x: 0 }}
                            transition={{ delay: 0.3 }}
                            className="bg-[#131316] p-10 rounded-3xl text-white shadow-2xl shadow-slate-900/10"
                        >
                            <div className="w-12 h-12 bg-white/5 text-blue-300 rounded-xl flex items-center justify-center mb-6">
                                <Eye size={24} />
                            </div>
                            <h2 className="text-2xl font-bold text-white mb-4 tracking-tight">Our Vision</h2>
                            <p className="text-slate-400 font-light leading-relaxed">
                                A future where every patient in a humanitarian setting receives timely, evidence-based, and compassionate care.
                            </p>
                        </motion.div>
                    </div>

                    {/* Core Values */}
                    <section className="mb-20">
                        <h2 className="text-3xl font-black text-slate-900 mb-12 text-center tracking-tight">The Values That Guide Us</h2>
                        <div className="grid grid-cols-2 md:grid-cols-4 gap-6">
                            <ValueCard icon={<Heart />} title="Dignity" color="rose" />
                            <ValueCard icon={<Shield />} title="Security" color="blue" />
                            <ValueCard icon={<Zap />} title="Speed" color="amber" />
                            <ValueCard icon={<Users />} title="Equity" color="blue" />
                        </div>
                    </section>

                    <motion.div
                        initial={{ opacity: 0, scale: 0.98 }}
                        animate={{ opacity: 1, scale: 1 }}
                        transition={{ delay: 0.5 }}
                        className="bg-primary rounded-4xl p-12 text-white text-center relative overflow-hidden"
                    >
                        <div className="relative z-10">
                            <Globe size={40} className="mx-auto mb-8 opacity-30" />
                            <h2 className="text-3xl font-extrabold mb-6 tracking-tight">A Global Challenge, <br />A Digital Solution.</h2>
                            <p className="text-blue-50/80 text-lg font-light max-w-2xl mx-auto leading-relaxed mb-10">
                                MyQueue is a commitment to improving the lives of forcibly displaced people globally, starting one camp at a time.
                            </p>
                            <Link
                                href="/access"
                                className="h-14 px-8 bg-white text-primary rounded-xl font-bold hover:bg-blue-50 transition-all inline-flex items-center shadow-lg"
                            >
                                Support Our Mission
                            </Link>
                        </div>
                        <div className="absolute top-0 right-0 w-64 h-64 bg-white/5 blur-[100px] rounded-full" />
                    </motion.div>
                </div>
            </main>

            <footer className="py-12 text-center text-slate-400 text-sm font-medium border-t border-slate-100">
                © 2026 MyQueue • Fast. Secure. Purpose-Driven.
            </footer>
        </div>
    );
}

function ValueCard({ icon, title, color }: { icon: React.ReactNode, title: string, color: 'rose' | 'blue' | 'amber' }) {
    const colors = {
        rose: 'text-rose-500 bg-rose-50 border-rose-100',
        blue: 'text-blue-500 bg-blue-50 border-blue-100',
        amber: 'text-amber-500 bg-amber-50 border-amber-100'
    };

    return (
        <div className={`p-8 rounded-4xl border-2 text-center transition-all hover:shadow-lg ${colors[color]}`}>
            <div className="mb-4 flex justify-center scale-125">{icon}</div>
            <h3 className="font-black text-slate-900 group-hover:text-inherit">{title}</h3>
        </div>
    );
}
