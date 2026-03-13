export interface HealthFacility {
    id: string;
    name: string;
    latitude: number;
    longitude: number;
    type: 'hospital' | 'clinic' | 'health_post';
    address: string;
    capacity?: number;
    isActive: boolean;
    campId: string;
    areaId: string;
    zoneId?: string;
    blockId?: string;
    adminId?: string;
}

export const mockHealthFacilities: HealthFacility[] = [
    {
        id: 'fac_001',
        name: 'UNHCR Main Camp Hospital',
        latitude: 3.1212,
        longitude: 35.3725,
        type: 'hospital',
        address: 'Kakuma Refugee Camp Zone 1, Turkana County',
        capacity: 200,
        isActive: true,
        campId: 'kakuma',
        areaId: 'kakuma-1',
        zoneId: 'k1-z1',
    },
    {
        id: 'fac_002',
        name: 'Kalobeyei Health Center',
        latitude: 3.2855,
        longitude: 35.3315,
        type: 'clinic',
        address: 'Kalobeyei Settlement, Turkana County',
        capacity: 150,
        isActive: true,
        campId: 'kakuma',
        areaId: 'kalobeyei',
        zoneId: 'kal-v1',
    },
    {
        id: 'fac_003',
        name: 'Zone 3 Primary Health Post',
        latitude: 3.1150,
        longitude: 35.3850,
        type: 'health_post',
        address: 'Kakuma Camp Zone 3, Turkana County',
        capacity: 80,
        isActive: true,
        campId: 'kakuma',
        areaId: 'kakuma-3',
        zoneId: 'k3-z1',
    },
    {
        id: 'fac_004',
        name: 'Dadaab Comprehensive Care Center',
        latitude: -0.0627,
        longitude: 40.3144,
        type: 'hospital',
        address: 'Dadaab Refugee Camp, Garissa County',
        capacity: 180,
        isActive: true,
        campId: 'dadaab',
        areaId: 'hagadera',
        zoneId: 'hag-z1',
    },
    {
        id: 'fac_005',
        name: 'Nairobi Urban Refugee Clinic',
        latitude: -1.2921,
        longitude: 36.8219,
        type: 'clinic',
        address: 'Eastleigh, Nairobi',
        capacity: 100,
        isActive: true,
        campId: 'nairobi',
        areaId: 'eastleigh',
    },
];
