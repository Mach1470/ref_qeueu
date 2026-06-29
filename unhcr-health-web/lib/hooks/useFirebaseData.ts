'use client';

import { useState, useEffect } from 'react';
import { ref, onValue } from 'firebase/database';
import { db } from '../firebase';

export function useFirebaseData(path: string) {
    const [data, setData] = useState<any>(null);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState<Error | null>(null);

    useEffect(() => {
        const dataRef = ref(db, path);

        const unsubscribe = onValue(dataRef, (snapshot) => {
            if (snapshot.exists()) {
                setData(snapshot.val());
            } else {
                setData(null);
            }
            setLoading(false);
        }, (err) => {
            console.error("Firebase read error:", err);
            setError(err);
            setLoading(false);
        });

        return () => unsubscribe();
    }, [path]);

    return { data, loading, error };
}
