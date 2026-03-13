'use client';

import { motion } from 'framer-motion';
import { TrendingUp, TrendingDown } from 'lucide-react';
import { LineChart, Line, ResponsiveContainer } from 'recharts';

interface PremiumKPICardProps {
    title: string;
    value: string;
    trend: string;
    positive?: boolean;
    data: { v: number }[];
    color: string;
}

export default function PremiumKPICard({ title, value, trend, positive, data, color }: PremiumKPICardProps) {
    return (
        <div className="bg-white rounded-[2rem] p-7 border border-slate-200 shadow-sm hover:shadow-xl hover:-translate-y-1 transition-all duration-300 group">
            <div className="flex justify-between items-start mb-4">
                <div>
                    <h4 className="text-slate-400 text-[10px] font-black uppercase tracking-[0.2em] leading-none mb-3">{title}</h4>
                    <p className="text-3xl font-black text-slate-900 tracking-tighter">{value}</p>
                </div>
                <div className={`px-2 py-1 rounded-lg text-[10px] font-black flex items-center gap-1 ${positive ? 'bg-green-50 text-green-600' : 'bg-rose-50 text-rose-600'
                    }`}>
                    {positive ? <TrendingUp size={10} /> : <TrendingDown size={10} />}
                    {trend}
                </div>
            </div>

            <div className="h-16 w-full -mb-2">
                <ResponsiveContainer width="100%" height="100%">
                    <LineChart data={data}>
                        <Line
                            type="monotone"
                            dataKey="v"
                            stroke={color}
                            strokeWidth={3}
                            dot={false}
                            animationDuration={2000}
                        />
                    </LineChart>
                </ResponsiveContainer>
            </div>
        </div>
    );
}
