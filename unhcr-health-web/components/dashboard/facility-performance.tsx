'use client';

const performanceData = [
    { name: 'Kakuma 1', value: 12628, percentage: 80, color: '#10B981', flag: 'K1' },
    { name: 'Kakuma 2', value: 10828, percentage: 70, color: '#F59E0B', flag: 'K2' },
    { name: 'Dadaab North', value: 8628, percentage: 60, color: '#0EA5E9', flag: 'DN' },
    { name: 'Hagadera', value: 6628, percentage: 40, color: '#7C3AED', flag: 'HG' },
    { name: 'Kalobeyei 3', value: 3628, percentage: 30, color: '#EF4444', flag: 'K3' },
];

export default function FacilityPerformance() {
    return (
        <div className="bg-white rounded-[2.5rem] p-8 border border-slate-200 shadow-sm">
            <div className="flex justify-between items-center mb-10">
                <h3 className="text-xl font-black text-slate-900 tracking-tight">Facility Performance</h3>
                <button className="text-xs font-black text-ocean-600 hover:underline">View All</button>
            </div>

            <div className="space-y-8">
                {performanceData.map((item) => (
                    <div key={item.name} className="space-y-3">
                        <div className="flex justify-between items-center text-xs font-black">
                            <div className="flex items-center gap-3">
                                <div className="w-8 h-8 rounded-lg bg-slate-100 flex items-center justify-center text-[10px] text-slate-500 border border-slate-200">
                                    {item.flag}
                                </div>
                                <span className="text-slate-900 uppercase tracking-tight">{item.name}</span>
                            </div>
                            <div className="flex items-center gap-2">
                                <span className="text-slate-900">{item.value.toLocaleString()}</span>
                                <span className="text-slate-400">({item.percentage}%)</span>
                            </div>
                        </div>
                        <div className="h-1.5 w-full bg-slate-50 rounded-full overflow-hidden">
                            <div
                                className="h-full rounded-full transition-all duration-1000"
                                style={{
                                    width: `${item.percentage}%`,
                                    backgroundColor: item.color
                                }}
                            />
                        </div>
                    </div>
                ))}
            </div>
        </div>
    );
}
