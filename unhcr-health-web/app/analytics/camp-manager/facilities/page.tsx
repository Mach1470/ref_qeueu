'use client';

import ManagementLayout from '@/components/dashboard/management-layout';
import { motion } from 'framer-motion';
import { mockHealthFacilities } from '@/lib/facilities';
import { Hospital, MapPin, Users, Activity, ExternalLink } from 'lucide-react';

export default function FacilitiesPage() {
  return (
    <ManagementLayout>
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        className="space-y-8"
      >
        <div>
          <h1 className="text-3xl font-bold text-slate-900">Health Facilities</h1>
          <p className="text-slate-500 font-medium">Monitoring and managing health facilities across the camp</p>
        </div>

        <div className="grid lg:grid-cols-2 gap-6">
          {mockHealthFacilities.map((facility, index) => (
            <motion.div
              key={facility.id}
              initial={{ opacity: 0, scale: 0.95 }}
              animate={{ opacity: 1, scale: 1 }}
              transition={{ delay: index * 0.05 }}
              className="bg-white rounded-4xl p-8 border border-slate-200 shadow-sm hover:shadow-xl transition-all group"
            >
              <div className="flex justify-between items-start mb-6">
                <div className="w-14 h-14 bg-ocean-50 rounded-2xl flex items-center justify-center text-ocean-600 border border-ocean-100 group-hover:bg-ocean-600 group-hover:text-white transition-colors duration-300">
                  <Hospital size={28} />
                </div>
                <div className="text-right">
                  <span className="px-3 py-1 bg-green-50 text-green-600 rounded-full text-xs font-bold uppercase tracking-wider border border-green-100">Active</span>
                  <p className="text-xs text-slate-400 mt-2 font-bold tracking-tight">ID: {facility.id}</p>
                </div>
              </div>

              <h2 className="text-2xl font-bold text-slate-900 mb-2">{facility.name}</h2>
              <div className="flex items-center gap-2 text-slate-500 mb-6 font-medium">
                <MapPin size={16} />
                <span className="text-sm">{facility.address}</span>
              </div>

              <div className="grid grid-cols-3 gap-4 py-6 border-t border-slate-50">
                <div className="text-center">
                  <p className="text-xl font-bold text-slate-900">120</p>
                  <div className="flex items-center justify-center gap-1 text-slate-400">
                    <Users size={12} />
                    <span className="text-[10px] font-bold uppercase tracking-widest">Patients</span>
                  </div>
                </div>
                <div className="text-center border-x border-slate-50">
                  <p className="text-xl font-bold text-slate-900">12</p>
                  <div className="flex items-center justify-center gap-1 text-slate-400">
                    <Activity size={12} />
                    <span className="text-[10px] font-bold uppercase tracking-widest">Staff</span>
                  </div>
                </div>
                <div className="text-center">
                  <p className="text-xl font-bold text-slate-900">85%</p>
                  <div className="flex items-center justify-center gap-1 text-slate-400">
                    <div className="w-2 h-2 rounded-full bg-teal-500" />
                    <span className="text-[10px] font-bold uppercase tracking-widest">Uptime</span>
                  </div>
                </div>
              </div>

              <div className="mt-4 flex justify-end">
                <button className="flex items-center gap-2 text-sm font-bold text-ocean-600 hover:text-ocean-700 transition-all">
                  Full Analytics <ExternalLink size={16} />
                </button>
              </div>
            </motion.div>
          ))}
        </div>
      </motion.div>
    </ManagementLayout>
  );
}
