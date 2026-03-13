'use client';

import Link from 'next/link';
import { ArrowLeft, Download, Printer, CheckCircle2 } from 'lucide-react';

export default function ConceptNotePage() {
    return (
        <div className="min-h-screen bg-slate-100 font-sans print:bg-white text-slate-800">
            {/* Navigation (Screen Only) */}
            <nav className="fixed top-0 w-full z-50 bg-white/80 backdrop-blur-md border-b border-slate-200 print:hidden">
                <div className="max-w-4xl mx-auto px-8 py-4 flex justify-between items-center">
                    <Link href="/" className="flex items-center gap-2 text-slate-600 hover:text-slate-900 font-bold text-sm">
                        <ArrowLeft size={16} /> Back to Site
                    </Link>
                    <div className="flex gap-4">
                        <button onClick={() => window.print()} className="flex items-center gap-2 px-4 py-2 bg-blue-600 text-white rounded-lg font-bold text-xs hover:bg-blue-700 transition-colors">
                            <Printer size={14} /> Print Concept Note
                        </button>
                    </div>
                </div>
            </nav>

            {/* Document Content */}
            <main className="max-w-4xl mx-auto bg-white min-h-screen my-10 md:my-28 p-12 md:p-20 shadow-xl print:shadow-none print:m-0 print:p-0 pt-32 md:pt-32">

                {/* Header */}
                <header className="border-b-2 border-blue-600 pb-8 mb-12">
                    <div className="flex justify-between items-start mb-6">
                        <h1 className="text-4xl font-bold text-slate-900 leading-tight tracking-tight">
                            MyQueue: Digital Healthcare Hub
                        </h1>
                        <div className="bg-blue-600 text-white px-3 py-1 font-bold text-[10px] uppercase tracking-widest shrink-0">
                            Concept Note
                        </div>
                    </div>
                    <p className="text-xl text-slate-600 font-medium">
                        Digital Healthcare Queue Management and Emergency Coordination for Refugee Settlements
                    </p>
                </header>

                {/* Body */}
                <div className="space-y-12 leading-relaxed text-lg">

                    <section>
                        <h2 className="text-xs font-bold uppercase tracking-widest text-slate-400 mb-6 border-b border-slate-100 pb-2">Problem Statement</h2>
                        <p className="mb-6">
                            Access to healthcare in refugee settlements is severely constrained by long physical queues, overcrowded facilities, and limited coordination between patients and providers. Refugees frequently endure wait times of several hours in extreme heat to receive basic checks, while emergency cases often face critical delays due to lack of triage visibility.
                        </p>
                        <p>
                            Healthcare providers work under immense pressure with no real-time data on patient demand. This lack of visibility makes effective planning, staffing, and prioritization nearly impossible, leaving vulnerable populations at heightened risk.
                        </p>
                    </section>

                    <section>
                        <h2 className="text-xs font-bold uppercase tracking-widest text-slate-400 mb-6 border-b border-slate-100 pb-2">Solution Overview</h2>
                        <p className="mb-6">
                            MyQueue is a digital healthcare coordination system designed specifically for the operational realities of refugee settlements. It replaces chaotic physical queues with a unified web and mobile platform that connects patients, clinics, and ambulance services in real time.
                        </p>
                        <div className="bg-slate-50 p-8 rounded-2xl border border-slate-100 space-y-5">
                            <div className="flex gap-4 items-start">
                                <span className="font-bold text-slate-900 w-24 shrink-0">1. Refugees</span>
                                <p className="text-slate-600 text-base">Submit healthcare requests remotely through a simple mobile application.</p>
                            </div>
                            <div className="flex gap-4 items-start">
                                <span className="font-bold text-slate-900 w-24 shrink-0">2. Hospitals</span>
                                <p className="text-slate-600 text-base">Manage patient flow and prioritize care through a centralized web dashboard.</p>
                            </div>
                            <div className="flex gap-4 items-start">
                                <span className="font-bold text-slate-900 w-24 shrink-0">3. Emergency</span>
                                <p className="text-slate-600 text-base">Critical cases trigger immediate automated alerts for ambulance dispatch.</p>
                            </div>
                        </div>
                        <p className="mt-6">
                            This system drastically reduces waiting times, accelerates emergency response, and restores dignity to the healthcare experience.
                        </p>
                    </section>

                    <section>
                        <h2 className="text-xs font-bold uppercase tracking-widest text-slate-400 mb-6 border-b border-slate-100 pb-2">Target Beneficiaries</h2>
                        <div className="grid md:grid-cols-2 gap-y-4 gap-x-8">
                            <BeneficiaryItem text="Refugees accessing outpatient care" />
                            <BeneficiaryItem text="Pregnant women & maternal health patients" />
                            <BeneficiaryItem text="Elderly persons & persons with disabilities" />
                            <BeneficiaryItem text="Healthcare workers & hospital administrators" />
                            <BeneficiaryItem text="Emergency response teams" />
                        </div>
                    </section>

                    <section>
                        <h2 className="text-xs font-bold uppercase tracking-widest text-slate-400 mb-6 border-b border-slate-100 pb-2">Implementation Plan</h2>
                        <div className="grid md:grid-cols-3 gap-6">
                            <PhaseCard phase="Phase 1" title="Pilot: Kakuma" desc="Initial deployment and user testing in Kakuma Refugee Camp." />
                            <PhaseCard phase="Phase 2" title="Expansion: Dadaab" desc="Refinement and rollout to Dadaab Refugee Camp." />
                            <PhaseCard phase="Phase 3" title="Global Scale" desc="Adaptation for additional humanitarian contexts." />
                        </div>
                    </section>

                    <section>
                        <h2 className="text-xs font-bold uppercase tracking-widest text-slate-400 mb-6 border-b border-slate-100 pb-2">Expected Impact</h2>
                        <div className="grid gap-4">
                            <ImpactRow text="Reduction in physical queue times at healthcare facilities" />
                            <ImpactRow text="Faster emergency and ambulance response times" />
                            <ImpactRow text="Improved access to maternal and vulnerable-group care" />
                            <ImpactRow text="Enhanced planning efficiency for healthcare teams" />
                            <ImpactRow text="Increased dignity and safety for patient populations" />
                        </div>
                    </section>

                    <section>
                        <h2 className="text-xs font-bold uppercase tracking-widest text-slate-400 mb-6 border-b border-slate-100 pb-2">Data Protection & Ethics</h2>
                        <p>
                            MyQueue is built with humanitarian data protection principles at its core. The platform ensures secure handling of sensitive health data, strict role-based access, and ethical technology design that prioritizes refugee dignity, safety, and informed consent.
                        </p>
                    </section>

                </div>

                {/* Footer */}
                <footer className="mt-20 pt-8 border-t border-slate-200 text-xs text-slate-400 flex justify-between items-center">
                    <p>© 2026 MyQueue. All Rights Reserved.</p>
                    <p className="font-bold text-slate-300">myqueue-portal.org</p>
                </footer>

            </main>
        </div>
    );
}

function BeneficiaryItem({ text }: { text: string }) {
    return (
        <div className="flex items-center gap-3 text-base font-medium">
            <div className="w-1.5 h-1.5 rounded-full bg-blue-500 shrink-0" />
            {text}
        </div>
    );
}

function PhaseCard({ phase, title, desc }: any) {
    return (
        <div className="p-6 bg-slate-50 rounded-xl border border-slate-100">
            <span className="text-[10px] font-bold uppercase tracking-widest text-blue-600 mb-2 block">{phase}</span>
            <h3 className="font-bold text-slate-900 mb-2">{title}</h3>
            <p className="text-sm text-slate-500 leading-relaxed font-medium">{desc}</p>
        </div>
    );
}

function ImpactRow({ text }: { text: string }) {
    return (
        <div className="flex items-start gap-3">
            <CheckCircle2 size={18} className="text-blue-500 mt-0.5 shrink-0" />
            <span className="text-slate-700 font-medium">{text}</span>
        </div>
    );
}
