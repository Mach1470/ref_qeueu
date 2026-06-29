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
        <div className="min-h-screen bg-stone-50 flex flex-col font-sans">
            {/* Header */}
            <header className="px-8 py-6 h-24 flex justify-between items-center border-b border-stone-200 bg-white shadow-sm">
                <div className="container-custom w-full flex justify-between items-center">
                    <Link href="/" className="flex items-center gap-3 group">
                        <div className="p-2.5 rounded-xl bg-stone-50 border border-stone-200 group-hover:bg-stone-100 transition-colors">
                            <ArrowLeft size={20} className="text-stone-600" />
                        </div>
                        <span className="font-semibold text-stone-600 text-sm">Back to Home</span>
                    </Link>
                    <div className="flex items-center gap-2">
                        <div className="w-10 h-10 rounded-xl bg-primary text-white flex items-center justify-center shadow-md">
                            <span className="font-bold text-lg">MQ</span>
                        </div>
                    </div>
                </div>
            </header>

            <main className="flex-1 flex items-center justify-center p-6">
                <div className="w-full max-w-5xl">
                    <div className="text-center mb-12 max-w-2xl mx-auto">
                        <motion.h1
                            initial={{ opacity: 0, y: 10 }}
                            animate={{ opacity: 1, y: 0 }}
                            className="text-4xl md:text-5xl font-display font-bold text-stone-900 mb-4 tracking-tight"
                        >
                            Establish Connection
                        </motion.h1>
                        <motion.p
                            initial={{ opacity: 0, y: 10 }}
                            animate={{ opacity: 1, y: 0 }}
                            transition={{ delay: 0.1 }}
                            className="text-lg text-stone-500 font-medium"
                        >
                            Select your operational region to access the secure network.
                        </motion.p>
                    </div>

                    <div className="flex gap-6 mb-12 justify-center">
                        <StepIndicator active={step === 'country'} completed={step !== 'country'} label="Region" number={1} />
                        <div className="w-16 h-px bg-stone-300 self-center" />
                        <StepIndicator active={step === 'camps'} completed={step === 'role'} label="Camp" number={2} />
                        <div className="w-16 h-px bg-stone-300 self-center" />
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
        <div className="flex flex-col items-center gap-3">
            <div className={`w-10 h-10 rounded-full flex items-center justify-center font-bold text-sm transition-all duration-300 ${active ? 'bg-primary text-white shadow-md shadow-primary/20 scale-110' :
                completed ? 'bg-blue-50 text-primary border border-blue-100' : 'bg-stone-100 text-stone-400 border border-stone-200'
                }`}>
                {completed ? <ArrowRight size={16} /> : number}
            </div>
            <span className={`text-[11px] font-bold uppercase tracking-widest ${active ? 'text-stone-900' : 'text-stone-400'}`}>{label}</span>
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
                className="group relative w-full max-w-md bg-white rounded-3xl p-10 border border-stone-200 hover:border-primary/50 hover:shadow-xl hover:shadow-primary/5 transition-all duration-300 text-left"
            >
                <div className="absolute top-10 right-10 p-4 rounded-2xl bg-stone-50 text-stone-400 group-hover:bg-primary group-hover:text-white transition-colors">
                    <Globe size={24} />
                </div>
                <div className="mt-4 mb-10">
                    <span className="px-3.5 py-1.5 rounded-full bg-stone-100 text-stone-500 text-[10px] font-bold uppercase tracking-widest group-hover:bg-blue-50 group-hover:text-primary transition-colors">Operational</span>
                    <h2 className="text-3xl font-display font-bold text-stone-900 mt-6 group-hover:text-primary transition-colors">Kenya</h2>
                    <p className="text-stone-500 mt-3 text-base font-medium leading-relaxed">Primary humanitarian operational zone.</p>
                </div>
                <div className="flex items-center gap-2 text-stone-500 font-bold text-sm group-hover:text-primary transition-colors">
                    <span>Select Region</span>
                    <ArrowRight size={18} className="group-hover:translate-x-2 transition-transform" />
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
            className="w-full max-w-3xl mx-auto"
        >
            <div className="grid md:grid-cols-2 gap-8">
                {camps.map((camp) => (
                    <button
                        key={camp.id}
                        onClick={() => onSelect(camp.id, camp.name)}
                        className="group bg-white p-10 rounded-3xl border border-stone-200 hover:border-primary/50 hover:shadow-xl hover:shadow-primary/5 transition-all text-left relative overflow-hidden"
                    >
                        <div className="relative z-10">
                            <div className="w-12 h-12 bg-stone-50 rounded-xl flex items-center justify-center text-stone-400 mb-8 group-hover:bg-primary group-hover:text-white transition-colors border border-stone-100 group-hover:border-primary">
                                <MapPin size={20} />
                            </div>
                            <h3 className="text-2xl font-bold text-stone-900 mb-3">{camp.name}</h3>
                            <p className="text-base text-stone-500 font-medium mb-8">{camp.count}</p>
                            <div className="flex items-center gap-2 text-xs font-bold uppercase tracking-widest text-stone-400 group-hover:text-primary transition-colors">
                                Select Camp <ChevronRight size={14} />
                            </div>
                        </div>
                    </button>
                ))}
            </div>
            <button onClick={onBack} className="mt-12 mx-auto flex items-center gap-2 text-stone-500 hover:text-stone-900 font-bold text-sm transition-colors">
                <ArrowLeft size={18} /> Back to Regions
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
            <div className="text-center mb-12">
                <span className="text-xs font-bold text-stone-500 uppercase tracking-widest">Selected Location</span>
                <h3 className="text-3xl font-display font-bold text-stone-900 mt-2">{campName}</h3>
            </div>

            <div className="grid md:grid-cols-2 gap-8">
                <button
                    onClick={() => onSelect('staff')}
                    className="group bg-white p-10 rounded-3xl border border-stone-200 hover:border-primary/50 hover:shadow-xl hover:shadow-primary/5 transition-all text-left"
                >
                    <div className="w-14 h-14 bg-stone-50 text-stone-500 rounded-2xl flex items-center justify-center mb-8 group-hover:bg-primary group-hover:text-white transition-all border border-stone-100 group-hover:border-primary group-hover:scale-105">
                        <Stethoscope size={24} />
                    </div>
                    <h3 className="text-2xl font-bold text-stone-900 mb-3">Health Facilities</h3>
                    <p className="text-stone-500 font-medium leading-relaxed mb-10 text-base">
                        Access for Doctors, Nurses, Lab Techs, Pharmacists, and Facility Admins.
                    </p>
                    <div className="btn-primary w-fit shadow-sm text-sm py-3 px-6">
                        Enter Staff Portal <ArrowRight size={16} />
                    </div>
                </button>

                <button
                    onClick={() => onSelect('manager')}
                    className="group bg-white p-10 rounded-3xl border border-stone-200 hover:border-primary/50 hover:shadow-xl hover:shadow-primary/5 transition-all text-left"
                >
                    <div className="w-14 h-14 bg-stone-50 text-stone-500 rounded-2xl flex items-center justify-center mb-8 group-hover:bg-primary group-hover:text-white transition-all border border-stone-100 group-hover:border-primary group-hover:scale-105">
                        <BarChart3 size={24} />
                    </div>
                    <h3 className="text-2xl font-bold text-stone-900 mb-3">Camp Management</h3>
                    <p className="text-stone-500 font-medium leading-relaxed mb-10 text-base">
                        Secure area for Camp Managers and High-Level Administrators.
                    </p>
                    <div className="btn-primary w-fit shadow-sm text-sm py-3 px-6">
                        Secure Login <ArrowRight size={16} />
                    </div>
                </button>
            </div>
            <button onClick={onBack} className="mt-12 mx-auto flex items-center gap-2 text-stone-500 hover:text-stone-900 font-bold text-sm transition-colors">
                <ArrowLeft size={18} /> Change Camp
            </button>
        </motion.div>
    );
}
