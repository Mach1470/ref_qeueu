'use client';

import { PieChart, Pie, Cell, ResponsiveContainer, Tooltip } from 'recharts';

const data = [
    { name: 'To Be Packed', value: 110000, color: '#0EA5E9' },
    { name: 'Process Delivery', value: 98000, color: '#F59E0B' },
    { name: 'Delivery Done', value: 140000, color: '#10B981' },
    { name: 'Returned', value: 67236, color: '#EF4444' },
];

export default function ActivityDonut() {
    const total = data.reduce((acc, curr) => acc + curr.value, 0);

    return (
        <div className="bg-white rounded-[2.5rem] p-8 border border-slate-200 shadow-sm flex flex-col items-center">
            <div className="w-full flex justify-between items-center mb-8">
                <h3 className="text-xl font-black text-slate-900 tracking-tight">Treatment Activity</h3>
                <div className="flex gap-2">
                    {['1W', '1M', '3W', 'YTD'].map(t => (
                        <button key={t} className={`w-10 h-8 rounded-lg text-[10px] font-black transition-all ${t === '1W' ? 'bg-slate-900 text-white' : 'bg-slate-50 text-slate-400 hover:bg-slate-100'
                            }`}>{t}</button>
                    ))}
                </div>
            </div>

            <div className="relative w-full h-64">
                <ResponsiveContainer width="100%" height="100%">
                    <PieChart>
                        <Pie
                            data={data}
                            cx="50%"
                            cy="50%"
                            innerRadius={70}
                            outerRadius={95}
                            paddingAngle={5}
                            dataKey="value"
                            stroke="none"
                            animationBegin={500}
                            animationDuration={1500}
                        >
                            {data.map((entry, index) => (
                                <Cell key={`cell-${index}`} fill={entry.color} />
                            ))}
                        </Pie>
                        <Tooltip
                            contentStyle={{ borderRadius: '20px', border: 'none', boxShadow: '0 25px 50px -12px rgb(0 0 0 / 0.25)' }}
                        />
                    </PieChart>
                </ResponsiveContainer>
                <div className="absolute inset-0 flex flex-col items-center justify-center pointer-events-none">
                    <p className="text-3xl font-black text-slate-900 tracking-tighter">{total.toLocaleString()}</p>
                    <p className="text-[10px] font-bold text-slate-400 uppercase tracking-widest">Total Active</p>
                </div>
            </div>

            <div className="w-full grid grid-cols-2 gap-x-8 gap-y-4 mt-6">
                {data.map(item => (
                    <div key={item.name} className="flex items-center justify-between">
                        <div className="flex items-center gap-2">
                            <div className="w-2.5 h-2.5 rounded-full" style={{ backgroundColor: item.color }} />
                            <span className="text-[11px] font-bold text-slate-500">{item.name}</span>
                        </div>
                        <span className="text-[11px] font-black text-slate-900">{item.value.toLocaleString()}</span>
                    </div>
                ))}
            </div>
        </div>
    );
}
