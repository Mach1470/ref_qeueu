'use client';

import { motion } from 'framer-motion';
import { ArrowLeft, BarChart3, TrendingDown, TrendingUp, Users, ShieldCheck, Activity } from 'lucide-react';
import Link from 'next/link';

export default function ImpactPage() {
    return (
        <div className="min-h-screen bg-slate-50 font-sans text-center">
            {/* Header */}
            <header className="fixed top-0 w-full z-50 bg-white/90 backdrop-blur-md border-b border-slate-100">
                <div className="container-custom h-20 flex justify-between items-center text-left">
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
                            Impact Metrics
                        </span>
                        <h1 className="text-4xl md:text-5xl font-extrabold text-main mb-8 tracking-tight">
                            Data-Driven <br />
                            <span className="text-primary">Humanitarian Impact.</span>
                        </h1>
                        <p className="text-lg text-secondary leading-relaxed font-light max-w-2xl mx-auto">
                            We measure success by minutes saved, lives protected, and the dignity restored to the healthcare journey.
                        </p>
                    </motion.div>

                    <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-6 mb-16">
                        <StatCard icon={<TrendingDown />} value="-72%" label="Waiting Room Reduc." color="blue" />
                        <StatCard icon={<TrendingUp />} value="4.8/5" label="Patient Dignity Score" color="blue" />
                        <StatCard icon={<Users />} value="250k+" label="Lives Impacted" color="blue" />
                        <StatCard icon={<Activity />} value="85%" label="Response Rate" color="blue" />
                    </div>

                    {/* Detailed Analysis */}
                    <div className="grid lg:grid-cols-2 gap-10 mb-20 text-left">
                        <motion.div
                            initial={{ opacity: 0, x: -20 }}
                            animate={{ opacity: 1, x: 0 }}
                            className="bg-white p-12 rounded-[3rem] border border-slate-100 shadow-xl"
                        >
                            <h3 className="text-3xl font-black text-slate-900 mb-6 flex items-center gap-3">
                                <BarChart3 className="text-blue-500" />
                                Operational Efficiency
                            </h3>
                            <p className="text-slate-500 font-medium mb-8 leading-relaxed">
                                Our dashboard provides real-time visibility into department-level bottlenecks, allowing facility managers to reallocate staff instantly where they are needed most.
                            </p>
                            <div className="space-y-6">
                                <ImpactProgress label="Queue Bottleneck Identification" progress={92} />
                                <ImpactProgress label="Staff Reallocation Efficiency" progress={88} />
                                <ImpactProgress label="Data-Driven Decision Making" progress={95} />
                            </div>
                        </motion.div>

                        <motion.div
                            initial={{ opacity: 0, x: 20 }}
                            animate={{ opacity: 1, x: 0 }}
                            className="bg-white text-slate-900 p-12 rounded-[3rem] shadow-xl overflow-hidden relative border border-blue-100"
                        >
                            <div className="relative z-10">
                                <h3 className="text-3xl font-black mb-6 flex items-center gap-3">
                                    <ShieldCheck className="text-blue-500" />
                                    Data Protection
                                </h3>
                                <p className="text-slate-500 font-medium mb-10 leading-relaxed">
                                    Security is a core impact metric. By safeguarding sensitive health info, we protect the most vulnerable from digital risks.
                                </p>
                                <div className="grid grid-cols-2 gap-6">
                                    <div className="p-6 bg-slate-50 rounded-2xl border border-slate-100">
                                        <p className="text-2xl font-bold text-blue-500 mb-1">AES-256</p>
                                        <p className="text-xs font-bold text-slate-500 uppercase">Encryption</p>
                                    </div>
                                    <div className="p-6 bg-slate-50 rounded-2xl border border-slate-100">
                                        <p className="text-2xl font-bold text-blue-500 mb-1">Zero-Trust</p>
                                        <p className="text-xs font-bold text-slate-500 uppercase">Architecture</p>
                                    </div>
                                </div>
                            </div>
                            <div className="absolute -bottom-20 -right-20 w-64 h-64 bg-blue-500/20 blur-[100px] rounded-full" />
                        </motion.div>
                    </div>

                    {/* Scale Section */}
                    <motion.section
                        initial={{ opacity: 0, y: 20 }}
                        animate={{ opacity: 1, y: 0 }}
                        className="py-16 bg-white rounded-[4rem] border border-slate-100 mb-20 px-8"
                    >
                        <h2 className="text-3xl font-black text-slate-900 mb-4 tracking-tight">Our Roadmap to 1 Million</h2>
                        <p className="text-slate-500 font-medium mb-12 max-w-2xl mx-auto">
                            The Kakuma pilot is just the beginning. We are building the infrastructure to scale humanitarian digital coordination globally.
                        </p>
                        <div className="flex flex-col md:flex-row justify-center items-center gap-12">
                            <RoadmapItem year="2026" label="Kakuma Pilot" active />
                            <div className="hidden md:block w-12 h-1 bg-slate-100" />
                            <RoadmapItem year="2027" label="Dadaab (Adaab) Expansion" />
                            <div className="hidden md:block w-12 h-1 bg-slate-100" />
                            <RoadmapItem year="2028" label="Global Deployment" />
                        </div>
                    </motion.section>
                </div>
            </main>

            <footer className="py-12 text-center text-slate-400 text-sm font-medium border-t border-slate-100">
                © 2026 MyQueue • Fast. Secure. Purpose-Driven.
            </footer>
        </div>
    );
}

function StatCard({ icon, value, label, color }: any) {
    return (
        <motion.div
            whileHover={{ scale: 1.02 }}
            className="bg-white p-8 rounded-3xl border border-slate-100 shadow-xl shadow-slate-200/40 text-center"
        >
            <div className={`w-10 h-10 rounded-xl flex items-center justify-center mx-auto mb-6 scale-110 bg-blue-50 text-primary`}>
                {icon}
            </div>
            <p className="text-4xl font-extrabold text-main mb-1">{value}</p>
            <p className="text-[10px] font-bold text-slate-400 uppercase tracking-widest">{label}</p>
        </motion.div>
    );
}

function ImpactProgress({ label, progress }: { label: string, progress: number }) {
    return (
        <div>
            <div className="flex justify-between items-end mb-2">
                <p className="text-xs font-bold text-slate-600 uppercase tracking-wider">{label}</p>
                <p className="text-xs font-bold text-primary">{progress}%</p>
            </div>
            <div className="w-full h-1.5 bg-slate-100 rounded-full overflow-hidden">
                <motion.div
                    initial={{ width: 0 }}
                    animate={{ width: `${progress}%` }}
                    transition={{ duration: 1, delay: 0.5 }}
                    className="h-full bg-primary rounded-full"
                />
            </div>
        </div>
    );
}

function RoadmapItem({ year, label, active = false }: { year: string, label: string, active?: boolean }) {
    return (
        <div className="text-center">
            <div className={`text-xl font-bold mb-1 ${active ? 'text-primary' : 'text-slate-300'}`}>{year}</div>
            <p className={`text-[10px] font-bold uppercase tracking-widest ${active ? 'text-main' : 'text-slate-400'}`}>{label}</p>
        </div>
    );
}
