export interface LocationNode {
    id: string;
    name: string;
    type: 'camp' | 'area' | 'zone' | 'village' | 'section' | 'block';
    children?: LocationNode[];
}

export const campLocations: LocationNode[] = [
    {
        id: 'kakuma',
        name: 'Kakuma Refugee Camp',
        type: 'camp',
        children: [
            {
                id: 'kakuma-1',
                name: 'Kakuma 1',
                type: 'area',
                children: [
                    { id: 'k1-z1', name: 'Zone 1', type: 'zone', children: generateBlocks('k1-z1', 15) },
                    { id: 'k1-z2', name: 'Zone 2', type: 'zone', children: generateBlocks('k1-z2', 12) },
                    { id: 'k1-z3', name: 'Zone 3', type: 'zone', children: generateBlocks('k1-z3', 10) },
                    { id: 'k1-z4', name: 'Zone 4', type: 'zone', children: generateBlocks('k1-z4', 8) },
                ]
            },
            {
                id: 'kakuma-2',
                name: 'Kakuma 2',
                type: 'area',
                children: [
                    { id: 'k2-z1', name: 'Zone 1', type: 'zone', children: generateBlocks('k2-z1', 8) },
                    { id: 'k2-z2', name: 'Zone 2', type: 'zone', children: generateBlocks('k2-z2', 10) },
                ]
            },
            {
                id: 'kakuma-3',
                name: 'Kakuma 3',
                type: 'area',
                children: [
                    { id: 'k3-z1', name: 'Zone 1', type: 'zone', children: generateBlocks('k3-z1', 14) },
                    { id: 'k3-z2', name: 'Zone 2', type: 'zone', children: generateBlocks('k3-z2', 12) },
                    { id: 'k3-z3', name: 'Zone 3', type: 'zone', children: generateBlocks('k3-z3', 10) },
                ]
            },
            {
                id: 'kakuma-4',
                name: 'Kakuma 4',
                type: 'area',
                children: [
                    { id: 'k4-z1', name: 'Zone 1', type: 'zone', children: generateBlocks('k4-z1', 6) },
                    { id: 'k4-z2', name: 'Zone 2', type: 'zone', children: generateBlocks('k4-z2', 5) },
                    { id: 'k4-z3', name: 'Zone 3', type: 'zone', children: generateBlocks('k4-z3', 7) },
                ]
            },
            {
                id: 'kalobeyei',
                name: 'Kalobeyei Settlement',
                type: 'area',
                children: [
                    { id: 'kal-v1', name: 'Village 1', type: 'village', children: generateBlocks('kal-v1', 20) },
                    { id: 'kal-v2', name: 'Village 2', type: 'village', children: generateBlocks('kal-v2', 18) },
                    { id: 'kal-v3', name: 'Village 3', type: 'village', children: generateBlocks('kal-v3', 25) },
                ]
            }
        ]
    },
    {
        id: 'dadaab',
        name: 'Dadaab Refugee Complex',
        type: 'camp',
        children: [
            {
                id: 'hagadera',
                name: 'Hagadera',
                type: 'area',
                children: Array.from({ length: 7 }, (_, i) => ({
                    id: `hag-s${String.fromCharCode(65 + i)}`,
                    name: `Section ${String.fromCharCode(65 + i)}`, // Section A-G
                    type: 'section',
                    children: generateBlocks(`hag-s${String.fromCharCode(65 + i)}`, 10)
                }))
            },
            {
                id: 'dagahaley',
                name: 'Dagahaley',
                type: 'area',
                children: [
                    { id: 'dag-s1', name: 'Section B1', type: 'section', children: generateBlocks('dag-s1', 10) },
                    { id: 'dag-s2', name: 'Section B2', type: 'section', children: generateBlocks('dag-s2', 10) },
                    { id: 'dag-s3', name: 'Section B3', type: 'section', children: generateBlocks('dag-s3', 10) },
                ]
            },
            {
                id: 'ifo',
                name: 'Ifo',
                type: 'area',
                children: Array.from({ length: 18 }, (_, i) => ({
                    id: `ifo-s${i + 1}`,
                    name: `Section ${i + 1}`,
                    type: 'section',
                    children: generateBlocks(`ifo-s${i + 1}`, 8)
                }))
            },
            {
                id: 'ifo-2',
                name: 'Ifo 2',
                type: 'area',
                children: Array.from({ length: 9 }, (_, i) => ({
                    id: `ifo2-s${i + 1}`,
                    name: `Section ${i + 1}`,
                    type: 'section',
                    children: generateBlocks(`ifo2-s${i + 1}`, 6)
                }))
            }
        ]
    }
];

function generateBlocks(parentPrefix: string, count: number): LocationNode[] {
    return Array.from({ length: count }, (_, i) => ({
        id: `${parentPrefix}-b${i + 1}`,
        name: `Block ${i + 1}`,
        type: 'block'
    }));
}
