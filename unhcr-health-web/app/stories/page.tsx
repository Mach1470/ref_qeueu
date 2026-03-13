'use client';

import { motion } from 'framer-motion';
import { ArrowLeft, MessageSquare, Heart, Clock, Siren, Star } from 'lucide-react';
import Link from 'next/link';

export default function StoriesPage() {
    const stories = [
        {
            title: "Maternal Care Redefined",
            subtitle: "Dignity for expecting mothers",
            icon: <Heart className="text-rose-500" />,
            content: "Before MyQueue, Amina had to wait 5 hours in the heat for a prenatal checkup. Now, she receives a digital confirmation and arrives just minutes before her appointment, ensuring she stays healthy and rested.",
            color: "rose"
        },
        {
            title: "Seconds Matter",
            subtitle: "Emergency Ambulance Dispatch",
            icon: <Siren className="text-amber-500" />,
            content: "When an emergency occurred in Village 3, the MyQueue alert reached the dispatch center instantly. The ambulance was routed automatically, saving 12 critical minutes in response time.",
            color: "amber"
        },
        {
            title: "The Pharmacy Flow",
            subtitle: "Reducing Congestion",
            icon: <Clock className="text-blue-500" />,
            content: "By digitizing the pharmacy queue, we reduced waiting room overcrowding by 65%. Patients now receive their medication through a streamlined window system, minimizing the risk of infection.",
            color: "blue"
        }
    ];

    return (
        <div className="min-h-screen bg-slate-50 font-sans">
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
                        <span className="px-3 py-1 bg-rose-50 text-rose-600 rounded-full text-[10px] font-bold uppercase tracking-widest border border-rose-100 mb-6 inline-block">
                            Impact Stories
                        </span>
                        <h1 className="text-4xl md:text-5xl font-extrabold text-main mb-8 tracking-tight">
                            Real Stories. <br />
                            <span className="text-rose-500">Life-Changing Results.</span>
                        </h1>
                        <p className="text-lg text-secondary leading-relaxed font-light max-w-2xl mx-auto">
                            Beyond data points are real people whose lives are being improved by more accessible healthcare.
                        </p>
                    </motion.div>

                    {/* Stories Grid */}
                    <div className="grid md:grid-cols-3 gap-10 mb-20">
                        {stories.map((story, index) => (
                            <StoryCard key={index} story={story} index={index} />
                        ))}
                    </div>

                    {/* Testimonial Section */}
                    <motion.div
                        initial={{ opacity: 0, y: 30 }}
                        animate={{ opacity: 1, y: 0 }}
                        transition={{ delay: 0.5 }}
                        className="bg-white p-12 md:p-20 rounded-[4rem] border border-slate-100 shadow-2xl relative overflow-hidden"
                    >
                        <MessageSquare className="absolute top-10 right-10 text-slate-50 w-40 h-40 z-0" />
                        <div className="relative z-10">
                            <div className="flex gap-1 mb-8">
                                {[1, 2, 3, 4, 5].map(i => <Star key={i} size={20} className="fill-amber-400 text-amber-400" />)}
                            </div>
                            <p className="text-2xl md:text-3xl font-bold text-slate-800 italic leading-relaxed mb-10">
                                &quot;MyQueue has completely transformed how we manage patient intake in Kakuma. We no longer have hundreds of people waiting in the sun—we have a calm, organized system that works for everyone.&quot;
                            </p>
                            <div className="flex items-center gap-4">
                                <div className="w-14 h-14 bg-slate-100 rounded-2xl overflow-hidden grayscale">
                                    <img src="/images/doctor.png" alt="Doctor" className="w-full h-full object-cover" />
                                </div>
                                <div>
                                    <h4 className="font-black text-slate-900">Dr. Samuel Omondi</h4>
                                    <p className="text-slate-500 text-sm font-bold uppercase tracking-widest">Chief of Staff, Kakuma Main</p>
                                </div>
                            </div>
                        </div>
                    </motion.div>
                </div>
            </main>

            <footer className="py-12 text-center text-slate-400 text-sm font-medium border-t border-slate-100">
                © 2026 MyQueue • Fast. Secure. Purpose-Driven.
            </footer>
        </div>
    );
}

function StoryCard({ story, index }: any) {
    const borderColors: any = {
        rose: 'hover:border-rose-200',
        amber: 'hover:border-amber-200',
        blue: 'hover:border-blue-200'
    };

    return (
        <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: index * 0.1 }}
            whileHover={{ y: -10 }}
            className={`bg-white p-10 rounded-[3rem] border border-slate-100 shadow-xl transition-all ${borderColors[story.color]}`}
        >
            <div className="w-14 h-14 bg-slate-50 rounded-2xl flex items-center justify-center mb-8 scale-110">
                {story.icon}
            </div>
            <h3 className="text-2xl font-black text-slate-900 mb-2 tracking-tight">{story.title}</h3>
            <p className="text-xs font-bold text-slate-400 uppercase tracking-widest mb-6">{story.subtitle}</p>
            <p className="text-slate-500 font-medium leading-relaxed">
                {story.content}
            </p>
            <div className={`mt-8 w-12 h-1 bg-slate-100 rounded-full group-hover:w-full transition-all duration-500`} />
        </motion.div>
    );
}
