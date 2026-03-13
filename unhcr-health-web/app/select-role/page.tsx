'use client';

import { motion } from 'framer-motion';
import {
    ArrowLeft,
    Stethoscope,
    Syringe,
    TestTube2,
    Pill,
    Baby,
    ShieldCheck,
    ArrowRight
} from 'lucide-react';
import Link from 'next/link';
import { useSearchParams, useRouter } from 'next/navigation';
import { Suspense } from 'react';

function SelectRoleContent() {
    const searchParams = useSearchParams();
    const router = useRouter();
    const facilityId = searchParams.get('facilityId') || '';
    const facilityName = searchParams.get('facilityName') || 'Health Facility';

    const roles = [
        { id: 'doctor', title: 'Doctor', icon: <Stethoscope size={32} />, color: 'blue', desc: 'Consultations & Diagnosis' },
        { id: 'pharmacy', title: 'Pharmacy', icon: <Pill size={32} />, color: 'amber', desc: 'Medication Dispensing' },
        { id: 'lab', title: 'Laboratory', icon: <TestTube2 size={32} />, color: 'purple', desc: 'Tests & Results' },
        { id: 'maternity', title: 'Maternity', icon: <Baby size={32} />, color: 'rose', desc: 'Prenatal & Delivery' },
        { id: 'admin', title: 'Hospital Admin', icon: <ShieldCheck size={32} />, color: 'slate', desc: 'Staff & Facility Ops' },
    ];

    return (
        <div className="min-h-screen bg-slate-50 flex flex-col font-sans">
            {/* Header */}
            <header className="px-8 py-6 h-20 flex justify-between items-center border-b border-slate-50 text-left">
                <div className="container-custom w-full flex justify-between items-center">
                    <button
                        onClick={() => router.back()}
                        className="flex items-center gap-2 group w-fit"
                    >
                        <div className="p-2 rounded-xl bg-white border border-slate-100 group-hover:bg-slate-50 transition-colors">
                            <ArrowLeft size={18} className="text-slate-500" />
                        </div>
                        <span className="font-medium text-slate-500 text-xs">Back to Facilities</span>
                    </button>
                </div>
            </header>

            <main className="flex-1 flex flex-col items-center p-6 md:p-12">
                <div className="container-custom w-full">
                    <div className="text-center mb-16 max-w-2xl mx-auto">
                        <span className="px-3 py-1 bg-white rounded-full text-[10px] font-bold text-slate-400 uppercase tracking-widest border border-slate-100 shadow-sm mb-4 inline-block">
                            {facilityName}
                        </span>
                        <h1 className="text-3xl md:text-4xl font-extrabold text-main mb-4 tracking-tight">Select Your Role</h1>
                        <p className="text-base text-slate-500 font-light">Identify your position to access the correct tools.</p>
                    </div>

                    <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
                        {roles.map((role, index) => (
                            <RoleCard
                                key={role.id}
                                role={role}
                                index={index}
                                facilityId={facilityId}
                                facilityName={facilityName}
                            />
                        ))}
                    </div>
                </div>
            </main>
        </div>
    );
}

function RoleCard({ role, index, facilityId, facilityName }: any) {
    const colorStyles: any = {
        teal: 'bg-blue-50 text-primary group-hover:bg-primary group-hover:text-white',
        blue: 'bg-blue-50 text-primary group-hover:bg-primary group-hover:text-white',
        purple: 'bg-indigo-50 text-indigo-600 group-hover:bg-indigo-600 group-hover:text-white',
        amber: 'bg-amber-50 text-amber-600 group-hover:bg-amber-600 group-hover:text-white',
        rose: 'bg-rose-50 text-rose-600 group-hover:bg-rose-600 group-hover:text-white',
        slate: 'bg-slate-50 text-slate-500 group-hover:bg-main group-hover:text-white',
    };

    return (
        <Link href={`/login-form?role=${role.id}&facilityId=${facilityId}&facilityName=${encodeURIComponent(facilityName)}`}>
            <motion.div
                initial={{ opacity: 0, y: 10 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: index * 0.1 }}
                whileHover={{ y: -4 }}
                className="bg-white rounded-4xl p-10 border border-slate-100 shadow-xl shadow-slate-200/40 hover:border-blue-100 transition-all cursor-pointer group h-full flex flex-col items-center text-center"
            >
                <div className={`w-16 h-16 rounded-2xl flex items-center justify-center mb-6 transition-colors duration-300 shadow-sm ${colorStyles[role.color]}`}>
                    {role.icon}
                </div>

                <h3 className="text-xl font-bold text-main mb-2">{role.title}</h3>
                <p className="text-slate-500 font-light text-sm mb-8 leading-relaxed">{role.desc}</p>

                <div className="mt-auto flex items-center gap-2 text-[10px] font-bold text-slate-300 group-hover:text-primary transition-colors uppercase tracking-widest">
                    <span>Continue to Login</span>
                    <ArrowRight size={14} className="group-hover:translate-x-1 transition-transform" />
                </div>
            </motion.div>
        </Link>
    );
}

export default function SelectRolePage() {
    return (
        <Suspense fallback={<div className="min-h-screen bg-slate-50 flex items-center justify-center font-bold text-slate-400">Loading roles...</div>}>
            <SelectRoleContent />
        </Suspense>
    );
}
