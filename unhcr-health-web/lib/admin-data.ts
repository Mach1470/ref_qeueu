import { HealthFacility } from './facilities';

export type StaffStatus = 'pending_approval' | 'active' | 'on_leave' | 'transfer_pending' | 'transferred_pending_acceptance';
export type StaffRole = 'doctor' | 'nurse' | 'lab_tech' | 'pharmacist' | 'hospital_admin' | 'maternity_staff';

export interface StaffUser {
    id: string;
    name: string;
    email: string;
    role: StaffRole;
    facilityId: string;
    status: StaffStatus;
    roomAssignment?: string;
    joinedDate: string;
    transferHistory?: {
        fromFacilityId: string;
        toFacilityId: string;
        date: string;
        reason?: string;
    }[];
}

export interface ApprovalRequest {
    id: string;
    type: 'new_account' | 'transfer';
    staffId: string;
    targetFacilityId: string;
    requestDate: string;
    adminComment?: string;
    requesterAdminId: string;
}

// Mock Data
export const mockStaffUsers: StaffUser[] = [
    // Active Staff
    {
        id: 'staff_001',
        name: 'Dr. Sarah Johnson',
        email: 'sarah.j@unhcr.org',
        role: 'hospital_admin',
        facilityId: 'fac_001',
        status: 'active',
        joinedDate: '2024-01-15'
    },
    {
        id: 'staff_002',
        name: 'Dr. Amara Mwangi',
        email: 'amara.m@unhcr.org',
        role: 'doctor',
        facilityId: 'fac_001',
        status: 'active',
        roomAssignment: 'Consultation Room 3',
        joinedDate: '2024-02-01'
    },
    // Pending Approval (New)
    {
        id: 'staff_003',
        name: 'Nurse John Doe',
        email: 'john.d@unhcr.org',
        role: 'nurse',
        facilityId: 'fac_001',
        status: 'pending_approval',
        joinedDate: '2026-01-24' // Today
    },
    // Transfer Pending
    {
        id: 'staff_004',
        name: 'Lab Tech Peter',
        email: 'peter.l@unhcr.org',
        role: 'lab_tech',
        facilityId: 'fac_001',
        status: 'transfer_pending',
        joinedDate: '2023-11-20'
    }
];

export const mockApprovalRequests: ApprovalRequest[] = [
    {
        id: 'req_001',
        type: 'new_account',
        staffId: 'staff_003',
        targetFacilityId: 'fac_001',
        requestDate: '2026-01-24',
        requesterAdminId: 'staff_001'
    }
];
