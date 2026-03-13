'use client';

import { useState, useEffect } from 'react';
import { db } from '@/lib/firebase';
import { ref, onValue, off } from 'firebase/database';
import { motion, AnimatePresence } from 'framer-motion';
import { Siren, Clock, MapPin } from 'lucide-react';

export interface EmergencyRequest {
    id: string;
    patientName: string;
    locationName: string;
    status: 'searching' | 'accepted' | 'arrived' | 'completed' | 'cancelled';
    createdAt: number;
    severity?: 'critical' | 'urgent' | 'stable';
}

export default function EmergencyAlerts() {
    const [requests, setRequests] = useState<EmergencyRequest[]>([]);

    useEffect(() => {
        const requestsRef = ref(db, 'emergency_requests');

        onValue(requestsRef, (snapshot) => {
            const data = snapshot.val();
            if (data) {
                const list = Object.entries(data).map(([id, val]: [string, any]) => ({
                    id,
                    patientName: (val as EmergencyRequest).patientName || `Patient ${id.substring(0, 4)}`,
                    locationName: (val as EmergencyRequest).locationName || 'Unknown Location',
                    status: (val as EmergencyRequest).status,
                    createdAt: (val as EmergencyRequest).createdAt,
                    severity: (val as EmergencyRequest).severity,
                }))
                    .filter(req => req.status !== 'completed' && req.status !== 'cancelled')
                    .sort((a, b) => b.createdAt - a.createdAt);

                setRequests(list);
            } else {
                setRequests([]);
            }
        });

        return () => off(requestsRef);
    }, []);

    if (requests.length === 0) return null;

    return (
        <div className="space-y-4">
            <h3 className="text-sm font-black text-rose-600 uppercase tracking-widest flex items-center gap-2">
                <Siren size={16} className="animate-pulse" />
                Live Emergency Alerts ({requests.length})
            </h3>

            <div className="grid gap-3">
                <AnimatePresence mode="popLayout">
                    {requests.map((req) => (
                        <motion.div
                            key={req.id}
                            initial={{ opacity: 0, x: -20 }}
                            animate={{ opacity: 1, x: 0 }}
                            exit={{ opacity: 0, scale: 0.95 }}
                            className={`p-4 rounded-2xl border-2 flex items-center justify-between transition-all ${req.status === 'searching'
                                ? 'bg-rose-50 border-rose-100 shadow-lg shadow-rose-100'
                                : 'bg-amber-50 border-amber-100'
                                }`}
                        >
                            <div className="flex items-center gap-4">
                                <div className={`w-10 h-10 rounded-xl flex items-center justify-center ${req.status === 'searching' ? 'bg-rose-500 text-white' : 'bg-amber-500 text-white'
                                    }`}>
                                    <Siren size={20} />
                                </div>
                                <div>
                                    <p className="font-bold text-slate-900">{req.patientName}</p>
                                    <div className="flex items-center gap-2 text-[10px] font-bold text-slate-500 uppercase tracking-tight">
                                        <MapPin size={10} /> {req.locationName}
                                        <span className="mx-1">•</span>
                                        <Clock size={10} /> {new Date(req.createdAt).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
                                    </div>
                                </div>
                            </div>

                            <div className="text-right">
                                <span className={`px-2 py-0.5 rounded-full text-[9px] font-black uppercase tracking-widest ${req.status === 'searching' ? 'bg-rose-100 text-rose-600' : 'bg-amber-100 text-amber-600'
                                    }`}>
                                    {req.status}
                                </span>
                            </div>
                        </motion.div>
                    ))}
                </AnimatePresence>
            </div>
        </div>
    );
}
