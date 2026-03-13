'use client';

import ManagementLayout from '@/components/dashboard/management-layout';
import { motion } from 'framer-motion';
import { BarChart3, TrendingUp, Filter, Download } from 'lucide-react';
import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
  AreaChart,
  Area
} from 'recharts';

const data = [
  { name: 'Week 1', cases: 400, births: 24, emergencies: 12 },
  { name: 'Week 2', cases: 300, births: 18, emergencies: 8 },
  { name: 'Week 3', cases: 600, births: 32, emergencies: 22 },
  { name: 'Week 4', cases: 800, births: 45, emergencies: 35 },
];

export default function MetricsPage() {
  return (
    <ManagementLayout>
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        className="space-y-8"
      >
        <div className="flex justify-between items-end">
          <div>
            <h1 className="text-3xl font-bold text-slate-900">Detailed Metrics</h1>
            <p className="text-slate-500 font-medium">Deep dive into health trends and patterns</p>
          </div>
          <div className="flex gap-3">
            <button className="bg-white p-3 rounded-2xl border border-slate-200 text-slate-400 hover:text-ocean-600 transition-all">
              <Filter size={20} />
            </button>
            <button className="bg-ocean-600 py-3 px-6 rounded-2xl text-white font-bold text-sm flex items-center gap-2 shadow-lg shadow-ocean-100">
              <Download size={18} />
              Generate CSV
            </button>
          </div>
        </div>

        <div className="grid lg:grid-cols-2 gap-8">
          <div className="bg-white rounded-[2.5rem] p-10 border border-slate-200 h-[450px] flex flex-col">
            <h3 className="text-xl font-bold mb-8">Weekly Case Distribution</h3>
            <div className="flex-1 w-full">
              <ResponsiveContainer width="100%" height="100%">
                <AreaChart data={data}>
                  <defs>
                    <linearGradient id="colorCases" x1="0" y1="0" x2="0" y2="1">
                      <stop offset="5%" stopColor="#0D9488" stopOpacity={0.1} />
                      <stop offset="95%" stopColor="#0D9488" stopOpacity={0} />
                    </linearGradient>
                  </defs>
                  <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#F1F5F9" />
                  <XAxis dataKey="name" axisLine={false} tickLine={false} tick={{ fill: '#94A3B8', fontSize: 12 }} />
                  <YAxis axisLine={false} tickLine={false} tick={{ fill: '#94A3B8', fontSize: 12 }} />
                  <Tooltip />
                  <Area type="monotone" dataKey="cases" stroke="#0D9488" strokeWidth={3} fillOpacity={1} fill="url(#colorCases)" />
                </AreaChart>
              </ResponsiveContainer>
            </div>
          </div>

          <div className="bg-white rounded-[2.5rem] p-10 border border-slate-200 h-[450px] flex flex-col">
            <h3 className="text-xl font-bold mb-8">Emergencies vs Births</h3>
            <div className="flex-1 w-full">
              <ResponsiveContainer width="100%" height="100%">
                <BarChart data={data}>
                  <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#F1F5F9" />
                  <XAxis dataKey="name" axisLine={false} tickLine={false} tick={{ fill: '#94A3B8', fontSize: 12 }} />
                  <YAxis axisLine={false} tickLine={false} tick={{ fill: '#94A3B8', fontSize: 12 }} />
                  <Tooltip />
                  <Bar dataKey="births" fill="#EC4899" radius={[10, 10, 0, 0]} />
                  <Bar dataKey="emergencies" fill="#F97316" radius={[10, 10, 0, 0]} />
                </BarChart>
              </ResponsiveContainer>
            </div>
          </div>
        </div>
      </motion.div>
    </ManagementLayout>
  );
}
