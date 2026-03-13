import { initializeApp, getApps, getApp } from "firebase/app";
import { getDatabase } from "firebase/database";

const firebaseConfig = {
    apiKey: "AIzaSyDc8KryzdICxSzGZxDf4LNU3XObuA_frPs",
    authDomain: "refugee-queue.firebaseapp.com",
    projectId: "refugee-queue",
    storageBucket: "refugee-queue.firebasestorage.app",
    messagingSenderId: "184088838294",
    appId: "1:184088838294:web:250dd9c6daa84bba8582b7",
    databaseURL: "https://refugee-queue-default-rtdb.firebaseio.com"
};

// Initialize Firebase
const app = getApps().length > 0 ? getApp() : initializeApp(firebaseConfig);
const db = getDatabase(app);

export { app, db };
