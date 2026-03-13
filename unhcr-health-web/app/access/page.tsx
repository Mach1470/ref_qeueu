'use client';

import { motion, AnimatePresence } from 'framer-motion';
import { ArrowRight, MapPin, User, LogIn, ChevronRight, Globe, Building2, Stethoscope, BarChart3, ArrowLeft } from 'lucide-react';
import Link from 'next/link';
import { useState } from 'react';
import { useRouter } from 'next/navigation';

type AccessStep = 'country' | 'camps' | 'role';

export default function AccessPage() {
    const router = useRouter();
    const [step, setStep] = useState<AccessStep>('country');
    const [selectedCountry, setSelectedCountry] = useState<string>('');
    const [selectedCamp, setSelectedCamp] = useState<{ id: string, name: string } | null>(null);

    const handleCampSelect = (campId: string, campName: string) => {
        setSelectedCamp({ id: campId, name: campName });
        setStep('role');
    };

    const handleRoleSelect = (role: 'staff' | 'manager') => {
        if (!selectedCamp) return;

        if (role === 'staff') {
            router.push(`/select-facility?camp=${selectedCamp.id}`);
        } else {
            router.push(`/manager-login?camp=${selectedCamp.id}`);
        }
    };

    return (
        <div className="min-h-screen bg-slate-50 flex flex-col font-sans">
            {/* Header */}
            <header className="px-8 py-6 h-20 flex justify-between items-center border-b border-slate-50">
                <div className="container-custom w-full flex justify-between items-center">
                    <Link href="/" className="flex items-center gap-2 group">
                        <div className="p-2 rounded-xl bg-white border border-slate-100 group-hover:bg-slate-50 transition-colors">
                            <ArrowLeft size={18} className="text-slate-500" />
                        </div>
                        <span className="font-medium text-slate-500 text-xs">Back to Home</span>
                    </Link>
                    <div className="flex items-center gap-2">
                        <img src="/images/app_logo.png" alt="MyQueue" className="w-8 h-8 opacity-20 grayscale" />
                    </div>
                </div>
            </header>

            <main className="flex-1 flex items-center justify-center p-6">
                <div className="w-full max-w-5xl">
                    <div className="text-center mb-10 max-w-2xl mx-auto">
                        <motion.h1
                            initial={{ opacity: 0, y: 10 }}
                            animate={{ opacity: 1, y: 0 }}
                            className="text-3xl md:text-4xl font-extrabold text-main mb-4 tracking-tight"
                        >
                            Establish Connection
                        </motion.h1>
                        <motion.p
                            initial={{ opacity: 0, y: 10 }}
                            animate={{ opacity: 1, y: 0 }}
                            transition={{ delay: 0.1 }}
                            className="text-base text-slate-500 font-light"
                        >
                            Select your operational region to access the secure network.
                        </motion.p>
                    </div>

                    <div className="flex gap-4 mb-8 justify-center">
                        <StepIndicator active={step === 'country'} completed={step !== 'country'} label="Region" number={1} />
                        <div className="w-12 h-px bg-slate-300 self-center" />
                        <StepIndicator active={step === 'camps'} completed={step === 'role'} label="Camp" number={2} />
                        <div className="w-12 h-px bg-slate-300 self-center" />
                        <StepIndicator active={step === 'role'} completed={false} label="Role" number={3} />
                    </div>

                    <div className="relative min-h-[400px]">
                        <AnimatePresence mode="wait">
                            {step === 'country' && (
                                <CountrySelection onSelect={() => { setSelectedCountry('kenya'); setStep('camps'); }} />
                            )}
                            {step === 'camps' && (
                                <CampSelection onSelect={handleCampSelect} onBack={() => setStep('country')} />
                            )}
                            {step === 'role' && selectedCamp && (
                                <RoleSelection
                                    campName={selectedCamp.name}
                                    onSelect={handleRoleSelect}
                                    onBack={() => setStep('camps')}
                                />
                            )}
                        </AnimatePresence>
                    </div>
                </div>
            </main>
        </div>
    );
}

function StepIndicator({ active, completed, label, number }: any) {
    return (
        <div className="flex flex-col items-center gap-2">
            <div className={`w-7 h-7 rounded-full flex items-center justify-center font-bold text-xs transition-all duration-300 ${active ? 'bg-primary text-white shadow-lg scale-110' :
                completed ? 'bg-blue-200 text-primary' : 'bg-slate-200 text-slate-400'
                }`}>
                {completed ? <ArrowRight size={12} /> : number}
            </div>
            <span className={`text-[10px] font-bold uppercase tracking-wider ${active ? 'text-main' : 'text-slate-400'}`}>{label}</span>
        </div>
    );
}

function CountrySelection({ onSelect }: { onSelect: () => void }) {
    return (
        <motion.div
            key="country"
            initial={{ opacity: 0, x: 20 }}
            animate={{ opacity: 1, x: 0 }}
            exit={{ opacity: 0, x: -20 }}
            className="flex justify-center"
        >
            <button
                onClick={onSelect}
                className="group relative w-full max-w-sm bg-white rounded-3xl p-8 border border-slate-100 hover:border-primary hover:shadow-2xl hover:shadow-blue-500/10 transition-all duration-500 text-left"
            >
                <div className="absolute top-8 right-8 p-3 rounded-2xl bg-blue-50 text-primary group-hover:bg-primary group-hover:text-white transition-colors">
                    <Globe size={20} />
                </div>
                <div className="mt-4 mb-8">
                    <span className="px-3 py-1 rounded-full bg-slate-50 text-slate-400 text-[10px] font-bold uppercase tracking-widest group-hover:bg-blue-100 group-hover:text-primary transition-colors">Operational</span>
                    <h2 className="text-2xl font-extrabold text-main mt-4 group-hover:text-primary transition-colors">Kenya</h2>
                    <p className="text-slate-500 mt-2 text-sm font-light leading-relaxed">Primary humanitarian operational zone.</p>
                </div>
                <div className="flex items-center gap-2 text-slate-400 font-bold text-xs group-hover:text-primary transition-colors">
                    <span>Select Region</span>
                    <ArrowRight size={16} className="group-hover:translate-x-2 transition-transform" />
                </div>
            </button>
        </motion.div>
    );
}

function CampSelection({ onSelect, onBack }: { onSelect: (id: string, name: string) => void, onBack: () => void }) {
    const camps = [
        { id: 'kakuma', name: 'Kakuma Refugee Camp', count: '4 Areas, 3 Villages' },
        { id: 'dadaab', name: 'Dadaab (Adaab) Complex', count: '3 Main Camps' },
    ];

    return (
        <motion.div
            key="camps"
            initial={{ opacity: 0, x: 20 }}
            animate={{ opacity: 1, x: 0 }}
            exit={{ opacity: 0, x: -20 }}
            className="w-full max-w-2xl mx-auto"
        >
            <div className="grid md:grid-cols-2 gap-6">
                {camps.map((camp) => (
                    <button
                        key={camp.id}
                        onClick={() => onSelect(camp.id, camp.name)}
                        className="group bg-white p-8 rounded-4xl border border-slate-100 hover:border-slate-200 hover:shadow-xl hover:shadow-slate-200/40 transition-all text-left relative overflow-hidden"
                    >
                        <div className="relative z-10">
                            <div className="w-10 h-10 bg-slate-50 rounded-xl flex items-center justify-center text-slate-400 mb-6 group-hover:bg-main group-hover:text-white transition-colors">
                                <MapPin size={18} />
                            </div>
                            <h3 className="text-xl font-bold text-main mb-2">{camp.name}</h3>
                            <p className="text-sm text-slate-500 font-light mb-6">{camp.count}</p>
                            <div className="flex items-center gap-2 text-[10px] font-bold uppercase tracking-widest text-slate-400 group-hover:text-main transition-colors">
                                Select Camp <ChevronRight size={12} />
                            </div>
                        </div>
                    </button>
                ))}
            </div>
            <button onClick={onBack} className="mt-8 mx-auto flex items-center gap-2 text-slate-400 hover:text-slate-600 font-bold text-sm transition-colors">
                <ArrowLeft size={16} /> Back to Regions
            </button>
        </motion.div>
    );
}

function RoleSelection({ campName, onSelect, onBack }: { campName: string, onSelect: (role: 'staff' | 'manager') => void, onBack: () => void }) {
    return (
        <motion.div
            key="role"
            initial={{ opacity: 0, x: 20 }}
            animate={{ opacity: 1, x: 0 }}
            exit={{ opacity: 0, x: -20 }}
            className="w-full max-w-4xl mx-auto"
        >
            <div className="text-center mb-8">
                <span className="text-xs font-bold text-slate-400 uppercase tracking-widest">Selected Location</span>
                <h3 className="text-2xl font-black text-slate-900">{campName}</h3>
            </div>

            <div className="grid md:grid-cols-2 gap-8">
                <button
                    onClick={() => onSelect('staff')}
                    className="group bg-white p-10 rounded-4xl border border-blue-100 hover:border-primary hover:shadow-2xl hover:shadow-blue-500/10 transition-all text-left"
                >
                    <div className="w-14 h-14 bg-blue-50 text-primary rounded-2xl flex items-center justify-center mb-8 group-hover:scale-105 transition-transform">
                        <Stethoscope size={24} />
                    </div>
                    <h3 className="text-2xl font-extrabold text-main mb-2">Health Facilities</h3>
                    <p className="text-slate-500 font-light leading-relaxed mb-8">
                        Access for Doctors, Nurses, Lab Techs, Pharmacists, and Facility Admins.
                    </p>
                    <div className="h-11 px-6 bg-primary text-white rounded-xl font-bold text-xs inline-flex items-center gap-2 group-hover:bg-primary-dark transition-colors">
                        Enter Staff Portal <ArrowRight size={14} />
                    </div>
                </button>

                <button
                    onClick={() => onSelect('manager')}
                    className="group bg-white p-10 rounded-4xl border border-blue-100 hover:border-primary hover:shadow-2xl hover:shadow-blue-500/10 transition-all text-left"
                >
                    <div className="w-14 h-14 bg-blue-50 text-primary rounded-2xl flex items-center justify-center mb-8 group-hover:scale-105 transition-transform">
                        <BarChart3 size={24} />
                    </div>
                    <h3 className="text-2xl font-extrabold text-main mb-2">Camp Management</h3>
                    <p className="text-slate-500 font-light leading-relaxed mb-8">
                        Secure area for Camp Managers and High-Level Administrators.
                    </p>
                    <div className="h-11 px-6 bg-primary text-white rounded-xl font-bold text-xs inline-flex items-center gap-2 group-hover:bg-primary-dark transition-colors">
                        Secure Login <ArrowRight size={14} />
                    </div>
                </button>
            </div>
            <button onClick={onBack} className="mt-10 mx-auto flex items-center gap-2 text-slate-400 hover:text-slate-600 font-bold text-sm transition-colors">
                <ArrowLeft size={16} /> Change Camp
            </button>
        </motion.div>
    );
}
