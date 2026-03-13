'use client';

import { useState, useRef, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import {
    ChevronDown,
    ChevronRight,
    ArrowLeft,
    Globe,
    Tent,
    Building2,
    ShieldCheck,
    Stethoscope,
    Beaker,
    Pill,
    Baby,
    LayoutDashboard,
    Check
} from 'lucide-react';
import { useRouter } from 'next/navigation';

type Step = 'region' | 'category' | 'role';

export default function LoginDropdown() {
    const [isOpen, setIsOpen] = useState(false);
    const [step, setStep] = useState<Step>('region');
    const [selections, setSelections] = useState({
        region: '',
        category: '',
        role: ''
    });

    const dropdownRef = useRef<HTMLDivElement>(null);
    const router = useRouter();

    // Close dropdown on click outside
    useEffect(() => {
        function handleClickOutside(event: MouseEvent) {
            if (dropdownRef.current && !dropdownRef.current.contains(event.target as Node)) {
                setIsOpen(false);
            }
        }
        document.addEventListener('mousedown', handleClickOutside);
        return () => document.removeEventListener('mousedown', handleClickOutside);
    }, []);

    // Reset flow when closed
    useEffect(() => {
        if (!isOpen) {
            setTimeout(() => {
                setStep('region');
                setSelections({ region: '', category: '', role: '' });
            }, 300);
        }
    }, [isOpen]);

    const handleRegionSelect = (region: string) => {
        setSelections(prev => ({ ...prev, region }));
        setStep('category');
    };

    const handleCategorySelect = (category: string) => {
        setSelections(prev => ({ ...prev, category }));
        if (category === 'manager') {
            // Redirect to camp manager login
            router.push(`/manager-login?camp=${selections.region}`);
            setIsOpen(false);
        } else {
            setStep('role');
        }
    };

    const handleRoleSelect = (role: string) => {
        setSelections(prev => ({ ...prev, role }));
        // Redirect to staff login
        router.push(`/login-form?role=${role}&facilityName=${selections.region.charAt(0).toUpperCase() + selections.region.slice(1)} Health Facility`);
        setIsOpen(false);
    };

    const goBack = () => {
        if (step === 'category') setStep('region');
        if (step === 'role') setStep('category');
    };

    return (
        <div className="relative" ref={dropdownRef}>
            <button
                onClick={() => setIsOpen(!isOpen)}
                className={`flex items-center gap-2 px-6 py-2.5 rounded-full text-sm font-bold transition-all duration-300 ${isOpen
                    ? 'bg-slate-900 text-white shadow-xl'
                    : 'bg-white text-slate-700 hover:bg-slate-50 border border-slate-100 shadow-sm'
                    }`}
            >
                Log in
                <motion.div animate={{ rotate: isOpen ? 180 : 0 }}>
                    <ChevronDown size={16} />
                </motion.div>
            </button>

            <AnimatePresence>
                {isOpen && (
                    <motion.div
                        initial={{ opacity: 0, y: 10, scale: 0.95 }}
                        animate={{ opacity: 1, y: 0, scale: 1 }}
                        exit={{ opacity: 0, y: 10, scale: 0.95 }}
                        className="absolute right-0 mt-4 w-72 bg-white rounded-4xl shadow-2xl border border-slate-100 overflow-hidden z-60"
                    >
                        {/* Header Info */}
                        <div className="bg-slate-50 px-6 py-4 border-b border-slate-100 flex items-center justify-between">
                            <div className="flex items-center gap-2">
                                <Globe size={14} className="text-blue-500" />
                                <span className="text-[10px] font-black text-slate-400 uppercase tracking-widest">Kenya 2026</span>
                            </div>
                            {step !== 'region' && (
                                <button onClick={goBack} className="p-1.5 hover:bg-white rounded-lg text-slate-400 transition-colors">
                                    <ArrowLeft size={14} />
                                </button>
                            )}
                        </div>

                        <div className="p-2">
                            <AnimatePresence mode="wait">
                                {step === 'region' && (
                                    <motion.div
                                        key="region"
                                        initial={{ x: 20, opacity: 0 }}
                                        animate={{ x: 0, opacity: 1 }}
                                        exit={{ x: -20, opacity: 0 }}
                                        className="space-y-1"
                                    >
                                        <p className="px-4 py-2 text-[10px] font-black text-slate-400 uppercase tracking-widest">Select Region</p>
                                        <OptionButton
                                            icon={<Tent size={18} />}
                                            label="Kakuma"
                                            desc="Turkana County"
                                            onClick={() => handleRegionSelect('kakuma')}
                                        />
                                        <OptionButton
                                            icon={<Tent size={18} />}
                                            label="Dadaab"
                                            desc="Garissa County"
                                            onClick={() => handleRegionSelect('dadaab')}
                                        />
                                    </motion.div>
                                )}

                                {step === 'category' && (
                                    <motion.div
                                        key="category"
                                        initial={{ x: 20, opacity: 0 }}
                                        animate={{ x: 0, opacity: 1 }}
                                        exit={{ x: -20, opacity: 0 }}
                                        className="space-y-1"
                                    >
                                        <p className="px-4 py-2 text-[10px] font-black text-slate-400 uppercase tracking-widest">Category ({selections.region})</p>
                                        <OptionButton
                                            icon={<Building2 size={18} />}
                                            label="Health Facility staff"
                                            desc="Doctors, Lab, Pharmacy"
                                            onClick={() => handleCategorySelect('staff')}
                                        />
                                        <OptionButton
                                            icon={<ShieldCheck size={18} />}
                                            label="Camp Manager"
                                            desc="Admin & Operations"
                                            onClick={() => handleCategorySelect('manager')}
                                        />
                                    </motion.div>
                                )}

                                {step === 'role' && (
                                    <motion.div
                                        key="role"
                                        initial={{ x: 20, opacity: 0 }}
                                        animate={{ x: 0, opacity: 1 }}
                                        exit={{ x: -20, opacity: 0 }}
                                        className="space-y-1 max-h-[350px] overflow-y-auto"
                                    >
                                        <p className="px-4 py-2 text-[10px] font-black text-slate-400 uppercase tracking-widest">Staff Role</p>
                                        <OptionButton icon={<Stethoscope size={18} />} label="Doctor" onClick={() => handleRoleSelect('doctor')} />
                                        <OptionButton icon={<Beaker size={18} />} label="Laboratory" onClick={() => handleRoleSelect('lab')} />
                                        <OptionButton icon={<Pill size={18} />} label="Pharmacy" onClick={() => handleRoleSelect('pharmacy')} />
                                        <OptionButton icon={<Baby size={18} />} label="Maternity" onClick={() => handleRoleSelect('maternity')} />
                                        <OptionButton icon={<LayoutDashboard size={18} />} label="Admin" onClick={() => handleRoleSelect('admin')} />
                                    </motion.div>
                                )}
                            </AnimatePresence>
                        </div>
                    </motion.div>
                )}
            </AnimatePresence>
        </div>
    );
}

function OptionButton({ icon, label, desc, onClick }: { icon: React.ReactNode, label: string, desc?: string, onClick: () => void }) {
    return (
        <button
            onClick={onClick}
            className="w-full flex items-center justify-between p-4 hover:bg-slate-50 rounded-2xl transition-all group text-left"
        >
            <div className="flex items-center gap-4">
                <div className="w-10 h-10 rounded-xl bg-slate-100 flex items-center justify-center text-slate-500 group-hover:bg-blue-500 group-hover:text-white transition-all duration-300">
                    {icon}
                </div>
                <div>
                    <p className="text-sm font-bold text-slate-800 tracking-tight group-hover:text-blue-600 transition-colors uppercase">{label}</p>
                    {desc && <p className="text-[10px] font-medium text-slate-400">{desc}</p>}
                </div>
            </div>
            <ChevronRight size={16} className="text-slate-300 group-hover:translate-x-1 group-hover:text-blue-500 transition-all" />
        </button>
    );
}
