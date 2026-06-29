'use client';

import { useState } from 'react';
import { db, auth } from '@/lib/firebase';
import { ref, set } from 'firebase/database';
import { createUserWithEmailAndPassword, signInWithEmailAndPassword } from 'firebase/auth';

const demoFacilities = {
    'fac_001': {
        id: 'fac_001',
        name: 'Kakuma General Hospital',
        type: 'hospital',
        campId: 'kakuma',
        address: 'Zone 1, Kakuma Camp',
        isActive: true,
        contact: '+254 700 000 001'
    },
    'fac_002': {
        id: 'fac_002',
        name: 'Dadaab Health Post',
        type: 'health_post',
        campId: 'dadaab',
        address: 'Sector 3, Dadaab',
        isActive: true,
        contact: '+254 700 000 002'
    }
};

const demoStaff = {
    'staff_001': {
        id: 'staff_001',
        name: 'Dr. Sarah Connor',
        email: 'admin@unhcr.org',
        role: 'admin',
        facilityId: 'fac_001',
        status: 'active',
        joinedDate: '2024-01-01'
    },
    'staff_002': {
        id: 'staff_002',
        name: 'Dr. John Smith',
        email: 'doctor@unhcr.org',
        role: 'doctor',
        facilityId: 'fac_001',
        department: 'OPD',
        status: 'active',
        joinedDate: '2024-02-15'
    }
};

export default function SetupPage() {
    const [status, setStatus] = useState('');
    const [loading, setLoading] = useState(false);

    const runSetup = async () => {
        setLoading(true);
        setStatus('Starting setup...');

        try {
            // 1. Create or Sign In to Auth Account FIRST to bypass permission denied
            setStatus('Authenticating to get write permissions...');
            try {
                await createUserWithEmailAndPassword(auth, 'admin@unhcr.org', 'password123');
            } catch (e: any) {
                if (e.code === 'auth/email-already-in-use') {
                    await signInWithEmailAndPassword(auth, 'admin@unhcr.org', 'password123');
                } else {
                    throw e;
                }
            }

            try {
                await createUserWithEmailAndPassword(auth, 'doctor@unhcr.org', 'password123');
            } catch (e: any) {
                // Ignore if it exists, we are already logged in as admin which should be enough
                if (e.code !== 'auth/email-already-in-use') throw e;
            }

            // 2. Seed Database
            setStatus('Seeding database facilities and staff...');
            await set(ref(db, 'facilities'), demoFacilities);
            await set(ref(db, 'staff'), demoStaff);

            setStatus('✅ Setup Complete! You can now log in using admin@unhcr.org / password123');
        } catch (error: any) {
            console.error(error);
            setStatus(`❌ Error: ${error.message}. If it says Permission Denied, please set your Firebase Realtime Database rules to true!`);
        } finally {
            setLoading(false);
        }
    };

    return (
        <div className="min-h-screen flex items-center justify-center bg-slate-50 p-6">
            <div className="bg-white p-8 rounded-2xl shadow-xl max-w-md w-full text-center">
                <h1 className="text-2xl font-bold mb-4 text-slate-900">Database Setup</h1>
                <p className="text-slate-500 mb-8 text-sm">
                    This will populate your Firebase database with demo facilities, staff, and create the necessary authentication accounts so you can log in.
                </p>
                
                <button
                    onClick={runSetup}
                    disabled={loading}
                    className="w-full bg-blue-600 hover:bg-blue-700 text-white font-bold py-3 px-4 rounded-xl transition-all disabled:opacity-50"
                >
                    {loading ? 'Running Setup...' : 'Run Setup & Seed Data'}
                </button>

                {status && (
                    <div className="mt-6 p-4 bg-slate-50 rounded-lg text-sm text-slate-700 font-medium text-left break-words">
                        {status}
                    </div>
                )}

                {status.includes('✅') && (
                    <a href="/" className="mt-4 block text-blue-600 font-bold hover:underline">
                        Go to Home / Login
                    </a>
                )}
            </div>
        </div>
    );
}
