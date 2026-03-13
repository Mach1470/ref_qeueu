'use client';

import ManagementLayout from '@/components/dashboard/management-layout';
import { motion } from 'framer-motion';
import { Settings, Globe, Bell, Database, HardDrive, Cpu } from 'lucide-react';

export default function SettingsPage() {
  return (
    <ManagementLayout>
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        className="space-y-8"
      >
        <div>
          <h1 className="text-3xl font-bold text-slate-900">System Settings</h1>
          <p className="text-slate-500 font-medium">Configure global platform parameters and infrastructure</p>
        </div>

        <div className="bg-white rounded-[2.5rem] p-10 border border-slate-200 grid md:grid-cols-2 gap-12">
          <div className="space-y-8">
            <h3 className="text-xl font-bold">General Settings</h3>
            <SettingItem icon={<Globe />} title="Language & Locale" desc="Default system language and timezone" />
            <SettingItem icon={<Bell />} title="Notifications" desc="Push alerts and email reporting triggers" />
            <SettingItem icon={<Settings size={20} />} title="Queue Logic" desc="Patient prioritization and wait time algorithms" />
          </div>

          <div className="space-y-8">
            <h3 className="text-xl font-bold">Infrastructure</h3>
            <SettingItem icon={<Database />} title="Cloud Storage" desc="Health record encryption and retention" />
            <SettingItem icon={<HardDrive />} title="Local Cache" desc="Offline operational parameters" />
            <SettingItem icon={<Cpu />} title="API Limits" desc="System integration throughput settings" />
          </div>
        </div>

        <div className="flex justify-end gap-4">
          <button className="px-8 py-4 bg-slate-200 rounded-2xl font-bold text-slate-700 hover:bg-slate-300 transition-all">Discard Changes</button>
          <button className="px-8 py-4 bg-ocean-600 rounded-2xl font-bold text-white hover:shadow-xl transition-all">Save Configuration</button>
        </div>
      </motion.div>
    </ManagementLayout>
  );
}

function SettingItem({ icon, title, desc }: any) {
  return (
    <div className="flex items-start gap-4 p-4 rounded-2xl hover:bg-slate-50 transition-all cursor-pointer group">
      <div className="w-12 h-12 bg-slate-100 rounded-xl flex items-center justify-center text-slate-400 group-hover:text-ocean-600 transition-colors">
        {icon}
      </div>
      <div className="flex-1">
        <p className="font-bold text-slate-900 mb-1">{title}</p>
        <p className="text-sm text-slate-500 font-medium leading-tight">{desc}</p>
      </div>
      <div className="w-12 h-6 bg-slate-200 rounded-full mt-2 relative">
        <div className="absolute left-1 top-1 w-4 h-4 bg-white rounded-full" />
      </div>
    </div>
  );
}
