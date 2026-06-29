export interface HealthFacility {
    id: string;
    name: string;
    type: 'hospital' | 'clinic' | 'health_post';
    campId: string;
    address: string;
    isActive: boolean;
    coordinates?: {
        lat: number;
        lng: number;
    };
    contact?: string;
}

export interface StaffUser {
    id: string;
    name: string;
    email: string;
    role: 'doctor' | 'nurse' | 'pharmacist' | 'lab_tech' | 'admin';
    facilityId: string;
    department?: string;
    roomAssignment?: string;
    status: 'active' | 'offline' | 'on_leave' | 'pending_approval';
    joinedDate: string;
}
