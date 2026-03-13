'use client';

import { motion } from 'framer-motion';
import { Shield, CheckCircle2, LayoutDashboard, Stethoscope, Siren } from 'lucide-react';
import Link from 'next/link';

export default function WebPlatformPage() {
    return (
        <div className="min-h-screen bg-slate-50 font-sans">
            {/* Navigation */}
            <nav className="glass fixed top-0 w-full z-50 border-b border-white/20">
                <div className="max-w-7xl mx-auto px-6 py-4 flex justify-between items-center">
                    <Link href="/" className="flex items-center gap-3 group">
                        <div className="w-10 h-10 bg-white rounded-xl flex items-center justify-center border border-slate-200 p-1">
                            <img src="/images/app_logo.png" alt="MyQueue" className="w-full h-full object-contain" />
                        </div>
                        <span className="text-2xl font-black text-slate-900 tracking-tighter">MyQueue</span>
                    </Link>
                    <div className="flex items-center gap-6">
                        <Link href="/" className="text-sm font-bold text-slate-500 hover:text-blue-600">Home</Link>
                        <Link href="/access" className="px-6 py-2 bg-blue-600 text-white rounded-xl font-bold text-sm hover:scale-105 transition-all">
                            Access Portal
                        </Link>
                    </div>
                </div>
            </nav>

            {/* Header */}
            <header className="pt-40 pb-20 px-6 bg-white border-b border-slate-200">
                <div className="max-w-5xl mx-auto text-center">
                    <span className="text-blue-600 font-bold text-xs uppercase tracking-widest mb-4 block">For Hospitals & Clinics</span>
                    <h1 className="text-6xl font-black text-slate-900 mb-6 tracking-tighter">The MyQueue Web Platform</h1>
                    <p className="text-2xl text-slate-500 max-w-2xl mx-auto leading-relaxed font-medium">
                        A real-time healthcare coordination dashboard designed for refugee settlement health facilities.
                    </p>
                </div>
            </header>

            {/* Intro */}
            <section className="py-24 px-6">
                <div className="max-w-4xl mx-auto text-lg text-slate-600 leading-relaxed font-medium space-y-6">
                    <p>
                        The MyQueue Web Platform enables hospitals and clinics in refugee settlements to manage patient flow, reduce overcrowding, and respond faster to urgent cases.
                    </p>
                    <p>
                        Built for high-demand, low-resource environments, the platform provides healthcare teams with real-time visibility into service requests—allowing better planning, prioritization, and delivery of care.
                    </p>
                </div>
            </section>

            {/* Who Uses Section */}
            <section className="py-24 px-6 bg-slate-50 text-slate-900">
                <div className="max-w-7xl mx-auto">
                    <div className="grid md:grid-cols-2 gap-20 items-center">
                        <div>
                            <h2 className="text-4xl font-black mb-8">Designed for Healthcare Teams</h2>
                            <p className="text-slate-400 mb-10 text-lg">
                                MyQueue streamlines operations for every role in the facility. Each user has simplified, role-based access to the tools they need.
                            </p>
                            <div className="grid grid-cols-2 gap-x-8 gap-y-4">
                                <RoleItem label="Doctors & Clinicians" />
                                <RoleItem label="Laboratory Staff" />
                                <RoleItem label="Pharmacists" />
                                <RoleItem label="Maternity Teams" />
                                <RoleItem label="Hospital Admins" />
                                <RoleItem label="Ambulance Coordinators" />
                            </div>
                        </div>
                        <div className="bg-white p-10 rounded-[3rem] border border-blue-100 shadow-xl">
                            <div className="flex items-center gap-4 mb-8">
                                <Shield className="text-blue-400" size={32} />
                                <h3 className="text-2xl font-bold">Secure Access</h3>
                            </div>
                            <p className="text-slate-500 leading-relaxed">
                                The MyQueue Web Platform uses role-based access to ensure that users only see information relevant to their responsibilities. Sensitive health data is protected, and all access is logged for accountability.
                            </p>
                        </div>
                    </div>
                </div>
            </section>

            {/* Core Features */}
            <section className="py-32 px-6 bg-slate-50">
                <div className="max-w-7xl mx-auto space-y-32">

                    {/* Feature 1 */}
                    <FeatureBlock
                        icon={<LayoutDashboard className="text-ocean-600" />}
                        title="Live Patient Request Dashboard"
                        desc="See demand instantly instead of relying on physical queues. Incoming patient requests appear in real-time with severity indicators."
                        items={['Incoming Requests', 'Service Type Analysis', 'Priority Level Tracking']}
                        image="/images/doctor.png"
                        align="left"
                    />

                    {/* Feature 2 */}
                    <FeatureBlock
                        icon={<Stethoscope className="text-blue-600" />}
                        title="Department-Level Queues"
                        desc="Each department manages its own digital queue, reducing congestion and confusion in waiting halls."
                        items={['Outpatient (OPD)', 'Laboratory & Pharmacy', 'Maternity Care', 'Emergency Services']}
                        image="/images/pharmacy.png"
                        align="right"
                    />

                    {/* Feature 3 */}
                    <FeatureBlock
                        icon={<Siren className="text-rose-600" />}
                        title="Emergency & Ambulance Coordination"
                        desc="Faster response for life-threatening situations. Emergency requests trigger instant alerts for ambulance teams."
                        items={['Instant Critical Alerts', 'Ambulance Dispatch', 'Live Status Updates']}
                        image="/images/ambulance.png"
                        align="left"
                    />
                </div>
            </section>

            {/* CTA */}
            <section className="py-24 px-6 bg-white text-center border-t border-slate-100">
                <h2 className="text-4xl font-black text-slate-900 mb-8">Ready to modernize your facility?</h2>
                <div className="flex flex-wrap justify-center gap-4">
                    <Link href="/concept-note" className="px-8 py-3 bg-slate-100 text-slate-600 rounded-xl font-bold hover:bg-slate-200 transition-all">
                        Read Concept Note
                    </Link>
                    <Link href="/access" className="px-8 py-3 bg-ocean-600 text-white rounded-xl font-bold hover:bg-ocean-700 transition-all shadow-lg shadow-ocean-200">
                        Launch Web Platform
                    </Link>
                </div>
            </section>
        </div>
    );
}

function RoleItem({ label }: { label: string }) {
    return (
        <div className="flex items-center gap-3 text-slate-600 font-bold">
            <div className="w-2 h-2 rounded-full bg-blue-500" />
            {label}
        </div>
    );
}

function FeatureBlock({ icon, title, desc, items, image, align }: { icon: React.ReactNode, title: string, desc: string, items: string[], image: string, align: 'left' | 'right' }) {
    return (
        <div className={`flex flex-col lg:flex-row gap-16 items-center ${align === 'right' ? 'lg:flex-row-reverse' : ''}`}>
            <div className="lg:w-1/2">
                <div className="w-14 h-14 bg-white rounded-2xl flex items-center justify-center border border-slate-200 shadow-sm mb-6">
                    {icon}
                </div>
                <h3 className="text-3xl font-black text-slate-900 mb-4 tracking-tight">{title}</h3>
                <p className="text-lg text-slate-500 leading-relaxed mb-8 font-medium">
                    {desc}
                </p>
                <ul className="space-y-4">
                    {items.map((item: string, i: number) => (
                        <li key={i} className="flex items-center gap-3 font-bold text-slate-700">
                            <CheckCircle2 size={20} className="text-blue-500" />
                            {item}
                        </li>
                    ))}
                </ul>
            </div>
            <div className="lg:w-1/2">
                <div className="bg-white p-4 rounded-[3rem] border border-slate-200 shadow-xl rotate-1 hover:rotate-0 transition-transform duration-500">
                    <img src={image} alt={title} className="w-full rounded-[2.5rem]" />
                </div>
            </div>
        </div>
    );
}
