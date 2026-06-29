'use client';

import { motion } from 'framer-motion';
import { Hospital, MapPin, ArrowRight, Search, Info, Building2, Activity } from 'lucide-react';
import Link from 'next/link';
import { useState, Suspense } from 'react';
import { useRouter, useSearchParams } from 'next/navigation';
import { useFirebaseData } from '@/lib/hooks/useFirebaseData';

function FilteredFacilities() {
    const searchParams = useSearchParams();
    const router = useRouter();
    const campId = searchParams.get('camp') || 'kakuma';
    const [searchQuery, setSearchQuery] = useState('');

    const { data, loading } = useFirebaseData('facilities');

    // Convert object to array if needed, then filter
    const facilitiesList = data ? Object.values(data) as any[] : [];

    const filteredFacilities = facilitiesList.filter(facility =>
        facility.campId === campId &&
        facility.name.toLowerCase().includes(searchQuery.toLowerCase())
    );

    const campName = campId === 'kakuma' ? 'Kakuma Refugee Camp' : 'Dadaab Refugee Complex';

    if (loading) {
        return (
            <div className="container-custom py-12 flex flex-col items-center justify-center min-h-[50vh]">
                <div className="w-12 h-12 border-4 border-stone-200 border-t-primary rounded-full animate-spin mb-4"></div>
                <h3 className="text-xl font-display font-bold text-stone-900">Loading facilities...</h3>
            </div>
        );
    }

    return (
        <div className="container-custom py-12">
            <div className="flex flex-col md:flex-row justify-between items-end mb-16 gap-6">
                <div>
                    <div className="flex items-center gap-2 mb-4">
                        <Link href="/access" className="text-[10px] font-bold text-stone-400 uppercase tracking-widest hover:text-primary transition-colors">
                            {campName}
                        </Link>
                        <span className="text-stone-300">/</span>
                        <span className="text-[10px] font-bold text-primary uppercase tracking-widest text-left">Select Facility</span>
                    </div>
                    <h1 className="text-3xl font-display font-bold text-stone-900">Choose Your Facility</h1>
                </div>

                <div className="relative w-full md:w-80">
                    <Search className="absolute left-4 top-1/2 -translate-y-1/2 text-stone-400 w-4 h-4" />
                    <input
                        type="text"
                        placeholder="Search facility name..."
                        value={searchQuery}
                        onChange={(e) => setSearchQuery(e.target.value)}
                        className="w-full pl-11 pr-4 py-3 bg-white border border-stone-200 rounded-xl focus:border-primary outline-none font-medium text-stone-600 shadow-sm transition-all text-sm placeholder-stone-400"
                    />
                </div>
            </div>

            <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-8">
                {filteredFacilities.map((facility) => (
                    <Link href={`/select-role?facilityId=${facility.id}&facilityName=${encodeURIComponent(facility.name)}`} key={facility.id}>
                        <motion.div
                            whileHover={{ y: -4 }}
                            className="bg-white rounded-3xl p-8 border border-stone-200 shadow-sm hover:border-primary/50 hover:shadow-xl hover:shadow-primary/5 transition-all cursor-pointer h-full flex flex-col group relative overflow-hidden"
                        >
                            {!facility.isActive && (
                                <div className="absolute inset-0 bg-white/90 backdrop-blur-[2px] z-10 flex items-center justify-center">
                                    <span className="px-3 py-1.5 bg-stone-100 text-stone-500 rounded-lg font-bold text-[9px] uppercase tracking-widest">Currently Offline</span>
                                </div>
                            )}

                            <div className="flex justify-between items-start mb-6">
                                <div className={`w-12 h-12 rounded-2xl flex items-center justify-center text-white shadow-sm ${facility.type === 'hospital' ? 'bg-primary' :
                                    facility.type === 'clinic' ? 'bg-blue-500' : 'bg-emerald-500'
                                    }`}>
                                    {facility.type === 'hospital' && <Hospital size={24} />}
                                    {facility.type === 'clinic' && <Building2 size={24} />}
                                    {facility.type === 'health_post' && <Activity size={24} />}
                                </div>
                                <div className={`px-2 py-1 rounded-md text-[9px] font-bold uppercase tracking-widest ${facility.isActive ? 'bg-blue-50 text-blue-700' : 'bg-rose-50 text-rose-600'
                                    }`}>
                                    {facility.isActive ? 'Online' : 'Offline'}
                                </div>
                            </div>

                            <h2 className="text-xl font-bold text-stone-900 mb-2 group-hover:text-primary transition-colors">
                                {facility.name}
                            </h2>

                            <div className="flex items-center gap-2 text-stone-500 mb-6 font-medium text-xs">
                                <MapPin size={14} />
                                {facility.address}
                            </div>

                            <div className="mt-auto pt-6 border-t border-stone-100 flex items-center justify-between text-xs font-bold text-stone-400 group-hover:text-primary transition-colors">
                                <span>Enter Portal</span>
                                <ArrowRight size={16} className="group-hover:translate-x-1 transition-transform" />
                            </div>
                        </motion.div>
                    </Link>
                ))}
            </div>

            {filteredFacilities.length === 0 && (
                <div className="text-center py-20 bg-white rounded-3xl border border-stone-200 shadow-sm">
                    <div className="w-16 h-16 bg-stone-50 rounded-full flex items-center justify-center mx-auto mb-6 text-stone-400">
                        <Info size={32} />
                    </div>
                    <h3 className="text-xl font-display font-bold text-stone-900 mb-2">No Facilities Found</h3>
                    <p className="text-stone-500 font-medium">Try searching for a different name or checking your spelling.</p>
                </div>
            )}
        </div>
    );
}

export default function SelectFacilityPage() {
    return (
        <div className="min-h-screen bg-stone-50 font-sans p-6 md:p-12">
            <Suspense fallback={<div className="flex items-center justify-center h-screen font-bold text-stone-400">Loading facilities...</div>}>
                <FilteredFacilities />
            </Suspense>

            <footer className="py-12 text-center text-stone-400 text-sm font-medium">
                © 2026 UNHCR Health Queue System
            </footer>
        </div>
    );
}
