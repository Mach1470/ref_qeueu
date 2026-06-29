'use client';

import { motion } from 'framer-motion';
import {
  Activity,
  ArrowRight,
  Globe,
  Shield,
  Users,
  Stethoscope,
  Microscope,
  Pill,
  Baby,
  CheckCircle2
} from 'lucide-react';
import Link from 'next/link';
import { useEffect, useState } from 'react';

export default function HomePage() {
  const [scrolled, setScrolled] = useState(false);

  useEffect(() => {
    const handleScroll = () => {
      setScrolled(window.scrollY > 50);
    };
    window.addEventListener('scroll', handleScroll);
    return () => window.removeEventListener('scroll', handleScroll);
  }, []);

  return (
    <div className="min-h-screen bg-stone-50 font-sans text-stone-900 selection:bg-primary/20">
      {/* Navigation */}
      <nav className={`fixed top-0 w-full z-50 transition-all duration-500 border-b ${scrolled ? 'bg-white/90 backdrop-blur-xl border-stone-200 shadow-sm' : 'bg-transparent border-transparent'}`}>
        <div className="container-custom h-24 flex justify-between items-center">
          <Link href="/" className="flex items-center gap-3 group">
            <div className="w-12 h-12 rounded-xl bg-primary text-white flex items-center justify-center shadow-md">
              <span className="font-bold text-xl">MQ</span>
            </div>
            <span className="text-2xl font-display font-bold tracking-tight text-stone-900">
              MyQueue <span className="text-primary font-normal">Health</span>
            </span>
          </Link>

          <div className="hidden md:flex items-center gap-10 font-semibold text-stone-600">
            <Link href="#workflow" className="hover:text-primary transition-colors">Clinical Workflow</Link>
            <Link href="#impact" className="hover:text-primary transition-colors">Real Impact</Link>
            <Link href="#security" className="hover:text-primary transition-colors">Security</Link>
          </div>

          <div className="flex items-center gap-4">
            <Link href="/access" className="hidden sm:flex btn-secondary shadow-sm bg-white">
              Staff Portal Login
            </Link>
          </div>
        </div>
      </nav>

      <main className="relative z-10 pt-32">
        {/* Hero Section */}
        <section className="relative min-h-[85vh] flex items-center py-20">
          <div className="container-custom grid lg:grid-cols-2 gap-16 items-center">
            
            <motion.div
              initial={{ opacity: 0, y: 30 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.8, ease: "easeOut" }}
              className="max-w-2xl"
            >
              <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-blue-50 border border-blue-100 mb-10 shadow-sm">
                <span className="w-2.5 h-2.5 rounded-full bg-primary animate-pulse" />
                <span className="text-primary-dark text-xs font-bold tracking-widest uppercase">iRHIS Integrated System</span>
              </div>

              <h1 className="text-5xl sm:text-6xl lg:text-7xl font-display font-extrabold tracking-tight mb-8 leading-tight text-stone-900">
                Coordinating <br />
                <span className="text-primary">
                  Refugee Health.
                </span>
              </h1>

              <p className="text-lg sm:text-xl text-stone-600 mb-12 leading-relaxed max-w-xl font-medium">
                A professional, end-to-end clinical workflow platform for UNHCR settlements. Managing patient flow from Triage to Pharmacy with real-time precision.
              </p>

              <div className="flex flex-wrap gap-4">
                <Link href="/access" className="btn-primary h-16 px-10 text-lg shadow-md">
                  Access Dashboards
                  <ArrowRight size={20} />
                </Link>
                <a href="#workflow" className="btn-secondary h-16 px-10 text-lg shadow-sm bg-white">
                  Explore Workflow
                </a>
              </div>

              {/* Quick Stats */}
              <div className="mt-20 grid grid-cols-3 gap-8 pt-10 border-t border-stone-200">
                <div>
                  <p className="text-4xl font-bold text-stone-900 mb-2">1.2k</p>
                  <p className="text-xs text-stone-500 uppercase tracking-widest font-bold">Patients Today</p>
                </div>
                <div>
                  <p className="text-4xl font-bold text-stone-900 mb-2">12m</p>
                  <p className="text-xs text-stone-500 uppercase tracking-widest font-bold">Avg Wait Time</p>
                </div>
                <div>
                  <p className="text-4xl font-bold text-emerald-600 mb-2">98%</p>
                  <p className="text-xs text-stone-500 uppercase tracking-widest font-bold">System Uptime</p>
                </div>
              </div>
            </motion.div>

            {/* Right Side Visual */}
            <motion.div
              initial={{ opacity: 0, scale: 0.95 }}
              animate={{ opacity: 1, scale: 1 }}
              transition={{ duration: 1, delay: 0.2 }}
              className="relative hidden lg:block"
            >
              {/* Main App Preview Card */}
              <div className="bg-white border border-stone-200 shadow-xl shadow-stone-200/50 rounded-3xl p-8 z-20 relative">
                <div className="flex items-center justify-between mb-8 pb-6 border-b border-stone-100">
                  <div className="flex items-center gap-4">
                    <div className="w-12 h-12 rounded-xl bg-blue-50 border border-blue-100 flex items-center justify-center text-primary">
                      <Stethoscope size={24} />
                    </div>
                    <div>
                      <h3 className="font-bold text-lg text-stone-900 leading-tight">OPD Consultation</h3>
                      <p className="text-sm font-medium text-stone-500 mt-1">Dr. Sarah Omondi • Room 4</p>
                    </div>
                  </div>
                  <div className="px-4 py-1.5 bg-emerald-50 text-emerald-700 text-xs font-bold rounded-full border border-emerald-200 uppercase tracking-widest">
                    Live Status
                  </div>
                </div>

                <div className="space-y-4">
                  {[
                    { name: 'Fatuma Hassan', priority: 'Critical Emergency', time: '2m', status: 'rose' },
                    { name: 'John Deng', priority: 'Urgent Transfer', time: '14m', status: 'amber' },
                    { name: 'Amina Ali', priority: 'Standard Queue', time: '28m', status: 'stone' }
                  ].map((patient, i) => (
                    <div key={i} className="bg-stone-50 rounded-2xl p-5 border border-stone-100 flex items-center justify-between">
                      <div>
                        <p className="font-bold text-stone-900">{patient.name}</p>
                        <p className={`text-xs font-bold mt-1.5 uppercase tracking-widest ${
                          patient.status === 'rose' ? 'text-rose-600' : 
                          patient.status === 'amber' ? 'text-amber-600' : 'text-stone-500'
                        }`}>{patient.priority}</p>
                      </div>
                      <div className="text-right">
                        <p className="text-xs text-stone-500 font-bold uppercase tracking-widest">Wait</p>
                        <p className="font-bold text-lg text-stone-900 font-sans mt-0.5">{patient.time}</p>
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            </motion.div>
          </div>
        </section>

        {/* Clinical Workflow Section */}
        <section id="workflow" className="py-32 relative border-t border-stone-200 bg-white">
          <div className="container-custom">
            <div className="text-center max-w-3xl mx-auto mb-24">
              <h2 className="heading-primary text-4xl md:text-5xl mb-6">Complete Clinical Workflow</h2>
              <p className="text-stone-600 text-xl font-medium leading-relaxed">
                Designed to mirror standard UNHCR and MSF protocols. Patients flow seamlessly from entry to discharge with real-time digital tracking.
              </p>
            </div>

            <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-8">
              <WorkflowCard 
                icon={<Activity className="text-primary" size={28} />}
                title="1. Triage Station"
                desc="Vitals assessment, initial symptom recording, and automated queue priority assignment (MTS guidelines)."
              />
              <WorkflowCard 
                icon={<Stethoscope className="text-emerald-600" size={28} />}
                title="2. OPD Consultation"
                desc="Doctor dashboard with patient history, diagnosis coding (ICD-10), and digital prescription building."
              />
              <WorkflowCard 
                icon={<Microscope className="text-purple-600" size={28} />}
                title="3. Laboratory"
                desc="Test request queue, sample tracking, and structured result entry with abnormal value flagging."
              />
              <WorkflowCard 
                icon={<Pill className="text-amber-600" size={28} />}
                title="4. Pharmacy Desk"
                desc="Digital prescription receiving, inventory checking, and dispensing workflow with safety checks."
              />
              <WorkflowCard 
                icon={<Baby className="text-pink-600" size={28} />}
                title="Maternity Ward"
                desc="Specialized dashboard for Antenatal Care (ANC), active labor tracking, and postnatal follow-ups."
              />
              <WorkflowCard 
                icon={<Shield className="text-blue-600" size={28} />}
                title="Command Center"
                desc="Camp manager overview of all facility queues, staff allocation, and outbreak surveillance."
              />
            </div>
          </div>
        </section>

        {/* Impact Section */}
        <section id="impact" className="py-32 relative border-t border-stone-200 bg-stone-50">
          <div className="container-custom relative z-10">
            <div className="grid lg:grid-cols-2 gap-16 items-center">
              <div>
                <h2 className="heading-primary text-4xl md:text-5xl mb-8 leading-tight">Transforming Care in Humanitarian Settings</h2>
                <p className="text-stone-600 text-xl mb-12 leading-relaxed font-medium">
                  By digitizing the patient journey, we eliminate physical lines, reduce exposure to elements, and give healthcare workers the tools they need to make data-driven decisions.
                </p>

                <ul className="space-y-8">
                  <ImpactCheck text="Reduces physical wait times by up to 70%" />
                  <ImpactCheck text="Prevents lost paper records and duplicate prescriptions" />
                  <ImpactCheck text="Enables early outbreak detection across camps" />
                  <ImpactCheck text="Restores dignity to the patient experience" />
                </ul>
              </div>

              <div className="bg-white border border-stone-200 shadow-xl shadow-stone-200/50 rounded-3xl p-10 md:p-14">
                <div className="space-y-10">
                  <h3 className="font-display font-bold text-3xl text-stone-900">Live Impact Metrics</h3>
                  
                  <div>
                    <div className="flex justify-between text-sm mb-3 font-bold uppercase tracking-widest">
                      <span className="text-stone-500">Queue Efficiency</span>
                      <span className="text-emerald-600">+72%</span>
                    </div>
                    <div className="h-3 w-full bg-stone-100 rounded-full overflow-hidden">
                      <div className="h-full bg-emerald-500 rounded-full" style={{ width: '72%' }} />
                    </div>
                  </div>

                  <div>
                    <div className="flex justify-between text-sm mb-3 font-bold uppercase tracking-widest">
                      <span className="text-stone-500">Data Accuracy</span>
                      <span className="text-primary">99.9%</span>
                    </div>
                    <div className="h-3 w-full bg-stone-100 rounded-full overflow-hidden">
                      <div className="h-full bg-primary rounded-full" style={{ width: '99.9%' }} />
                    </div>
                  </div>

                  <div>
                    <div className="flex justify-between text-sm mb-3 font-bold uppercase tracking-widest">
                      <span className="text-stone-500">Response Speed</span>
                      <span className="text-rose-600">-18 mins</span>
                    </div>
                    <div className="h-3 w-full bg-stone-100 rounded-full overflow-hidden">
                      <div className="h-full bg-rose-500 rounded-full" style={{ width: '85%' }} />
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </section>

        {/* CTA */}
        <section className="py-32 relative bg-white border-t border-stone-200">
          <div className="container-custom relative z-10 text-center max-w-4xl mx-auto">
            <h2 className="heading-primary text-5xl md:text-6xl mb-8">Ready to Coordinate?</h2>
            <p className="text-xl text-stone-600 mb-12 font-medium">
              Access the live dashboards and see how digital health management transforms refugee care.
            </p>
            <Link href="/access" className="btn-primary h-16 px-12 text-lg inline-flex shadow-lg shadow-primary/20">
              Enter Staff Portal
              <ArrowRight size={24} />
            </Link>
          </div>
        </section>
      </main>

      {/* Footer */}
      <footer className="border-t border-stone-200 bg-stone-100 py-16">
        <div className="container-custom flex flex-col md:flex-row justify-between items-center gap-8">
          <div className="flex items-center gap-3 text-stone-600">
            <Globe size={24} />
            <span className="font-bold tracking-tight text-lg">UNHCR Health Innovation</span>
          </div>
          <p className="text-stone-500 text-sm font-semibold">
            Designed for humanitarian operations. © 2026
          </p>
        </div>
      </footer>
    </div>
  );
}

// Components
function WorkflowCard({ icon, title, desc }: { icon: React.ReactNode, title: string, desc: string }) {
  return (
    <div className="bg-white border border-stone-200 shadow-sm rounded-2xl p-8 hover:shadow-md hover:border-stone-300 transition-all duration-300">
      <div className="w-16 h-16 rounded-2xl bg-stone-50 border border-stone-100 flex items-center justify-center mb-6">
        {icon}
      </div>
      <h3 className="text-xl font-bold text-stone-900 mb-4">{title}</h3>
      <p className="text-stone-600 leading-relaxed font-medium">{desc}</p>
    </div>
  );
}

function ImpactCheck({ text }: { text: string }) {
  return (
    <li className="flex items-center gap-5">
      <div className="w-8 h-8 rounded-full bg-emerald-50 flex items-center justify-center shrink-0 border border-emerald-100">
        <CheckCircle2 className="text-emerald-600" size={18} />
      </div>
      <span className="text-xl text-stone-700 font-medium">{text}</span>
    </li>
  );
}
