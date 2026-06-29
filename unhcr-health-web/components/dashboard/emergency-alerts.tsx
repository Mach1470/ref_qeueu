'use client';

import { useState, useEffect } from 'react';
import { db } from '@/lib/firebase';
import { ref, onValue, off } from 'firebase/database';
import { motion, AnimatePresence } from 'framer-motion';
import { Siren, Clock, MapPin, AlertCircle } from 'lucide-react';

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
        <div className="bg-white border-b border-stone-200 shadow-sm w-full">
            <AnimatePresence mode="popLayout">
                {requests.map((req) => (
                    <motion.div
                        key={req.id}
                        initial={{ opacity: 0, height: 0 }}
                        animate={{ opacity: 1, height: 'auto' }}
                        exit={{ opacity: 0, height: 0 }}
                        className={`px-8 py-3 flex items-center justify-between border-b last:border-0 transition-colors ${req.status === 'searching'
                            ? 'bg-rose-50 border-rose-100'
                            : 'bg-amber-50 border-amber-100'
                            }`}
                    >
                        <div className="flex items-center gap-4">
                            <div className={`p-2 rounded-full ${req.status === 'searching' ? 'bg-rose-100 text-rose-600' : 'bg-amber-100 text-amber-600'
                                }`}>
                                {req.status === 'searching' ? <Siren size={18} className="animate-pulse" /> : <AlertCircle size={18} />}
                            </div>
                            <div>
                                <div className="flex items-center gap-3">
                                    <p className="font-bold text-stone-900">{req.patientName}</p>
                                    <span className={`px-2 py-0.5 rounded-full text-[10px] font-bold uppercase tracking-widest ${req.status === 'searching' ? 'bg-rose-200 text-rose-700' : 'bg-amber-200 text-amber-800'
                                        }`}>
                                        {req.status === 'searching' ? 'Critical Emergency' : 'Urgent Transfer'}
                                    </span>
                                </div>
                                <div className="flex items-center gap-3 text-xs font-medium text-stone-500 mt-1">
                                    <span className="flex items-center gap-1.5"><MapPin size={12} /> {req.locationName}</span>
                                    <span className="flex items-center gap-1.5"><Clock size={12} /> {new Date(req.createdAt).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}</span>
                                </div>
                            </div>
                        </div>

                        <div>
                            <button className={`btn-primary py-2 px-4 text-sm ${req.status === 'searching' ? 'bg-rose-600 hover:bg-rose-700 shadow-rose-600/20' : 'bg-amber-600 hover:bg-amber-700 shadow-amber-600/20'}`}>
                                View Details
                            </button>
                        </div>
                    </motion.div>
                ))}
            </AnimatePresence>
        </div>
    );
}
