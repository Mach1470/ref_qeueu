'use client';

import { motion } from 'framer-motion';
import {
  Activity,
  ArrowRight,
  Globe,
  Shield,
  Users,
  Tent,
  Building2,
  Siren,
  CheckCircle2,
  Mail,
  Smartphone
} from 'lucide-react';
import Link from 'next/link';

export default function HomePage() {
  return (
    <div className="min-h-screen bg-slate-50 font-sans">
      {/* Navigation */}
      <nav className="bg-white/80 backdrop-blur-md fixed top-0 w-full z-50 border-b border-slate-100/50 shadow-sm/5 transition-all duration-300">
        <div className="container-custom h-20 flex justify-between items-center">
          <Link href="/" className="flex items-center gap-3 group cursor-pointer">
            <div className="p-2 bg-blue-50/50 rounded-xl group-hover:bg-blue-100/50 transition-colors">
              <img src="/images/app_logo.png" alt="MyQueue" className="w-8 h-8 object-contain" />
            </div>
            <span className="text-xl font-bold text-main tracking-tight group-hover:text-primary transition-colors">
              myqueue
            </span>
          </Link>

          <div className="hidden md:flex items-center gap-8 font-medium text-sm text-slate-500">
            <Link href="/purpose" className="hover:text-primary transition-colors">Our Purpose</Link>
            <Link href="/impact" className="hover:text-primary transition-colors">Impact</Link>
            <Link href="/stories" className="hover:text-primary transition-colors">Impact Stories</Link>
            <a href="#partners" className="hover:text-primary transition-colors">Partners</a>
          </div>

          <div className="flex items-center gap-4">
            <Link href="/access" className="hidden sm:inline-flex px-5 py-2.5 font-medium text-sm text-slate-600 hover:text-primary transition-colors">
              Log in
            </Link>

            <Link href="/concept-note" className="btn-primary rounded-full px-8 shadow-blue-500/20 shadow-lg hover:shadow-blue-500/30">
              Contact us
            </Link>
          </div>
        </div>
      </nav>

      {/* Hero Section */}
      <section id="hero" className="pt-40 pb-24 bg-white overflow-hidden relative border-b border-slate-100">
        <div className="absolute inset-0 bg-[radial-gradient(circle_at_top_right,_var(--tw-gradient-stops))] from-blue-50/40 via-transparent to-transparent opacity-70" />

        <div className="container-custom relative z-10">
          <div className="grid lg:grid-cols-2 gap-16 items-center">
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.6 }}
            >
              <div className="inline-block mb-8 px-4 py-1.5 bg-blue-50/80 border border-blue-100/50 rounded-full backdrop-blur-sm">
                <span className="text-primary font-bold text-[11px] uppercase tracking-widest flex items-center gap-2">
                  <span className="w-2 h-2 rounded-full bg-blue-400 animate-pulse" />
                  Refugee Health Elevated
                </span>
              </div>

              <h1 className="text-5xl sm:text-[3.5rem] leading-[1.15] font-extrabold text-main mb-8 tracking-tight">
                Ending <span className="text-slate-400 font-bold">Long Queues.</span>
                <br />
                <span className="text-primary bg-clip-text text-transparent bg-gradient-to-r from-blue-600 to-blue-400">Saving Lives.</span>
              </h1>

              <p className="text-lg text-secondary mb-10 leading-relaxed font-light max-w-lg">
                MyQueue is a digital healthcare coordination system designed for refugee settlements. We help hospitals manage patient flow, reduce overcrowding, and enable faster emergency response through a secure platform.
              </p>

              <div className="flex flex-wrap gap-4">
                <Link href="/access" className="btn-primary h-14 px-10 text-base rounded-full shadow-xl shadow-blue-600/20 hover:shadow-2xl hover:shadow-blue-600/30">
                  Request a Demo
                  <ArrowRight size={18} />
                </Link>
                <Link href="/web-platform" className="px-8 h-14 rounded-full border border-slate-200 text-slate-600 font-medium flex items-center justify-center hover:bg-slate-50 hover:border-slate-300 transition-all">
                  See How It Works
                </Link>
              </div>
            </motion.div>

            <motion.div
              initial={{ opacity: 0, scale: 0.95, x: 20 }}
              animate={{ opacity: 1, scale: 1, x: 0 }}
              transition={{ duration: 0.8, delay: 0.2, ease: "easeOut" }}
              className="relative"
            >
              <div className="relative bg-white rounded-4xl p-3 shadow-2xl shadow-blue-900/10 border border-slate-100 overflow-hidden transform hover:scale-[1.01] transition-transform duration-700">
                <div className="absolute inset-0 bg-slate-900/5 mix-blend-overlay z-10 pointer-events-none" />
                <img
                  src="/images/doctor.png"
                  alt="MyQueue Hero"
                  className="w-full rounded-3xl object-cover aspect-[4/3]"
                />

                {/* Floating Status Card */}
                <div className="absolute bottom-8 left-8 right-8 z-20 flex justify-between items-end">
                  <div className="bg-white/95 backdrop-blur-xl p-5 rounded-3xl border border-white/40 shadow-xl shadow-black/5">
                    <div className="flex items-center gap-3 mb-2">
                      <span className="relative flex h-3 w-3">
                        <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-blue-400 opacity-75"></span>
                        <span className="relative inline-flex rounded-full h-3 w-3 bg-blue-500"></span>
                      </span>
                      <p className="text-[10px] font-bold text-slate-400 uppercase tracking-widest">Live System Status</p>
                    </div>
                    <p className="font-bold text-main text-xl tracking-tight">8 Active Facilities</p>
                    <p className="text-secondary text-xs mt-1">Processing 1,240 patients daily</p>
                  </div>
                </div>
              </div>

              {/* Decorative elements */}
              <div className="absolute -z-10 -bottom-10 -right-10 w-64 h-64 bg-blue-100/50 rounded-full blur-3xl opacity-60" />
            </motion.div>
          </div>
        </div>
      </section>

      {/* The Problem Section */}
      <section id="problem" className="py-32 bg-white relative">
        <div className="absolute top-0 left-1/2 -translate-x-1/2 w-full max-w-7xl h-px bg-gradient-to-r from-transparent via-slate-100 to-transparent" />

        <div className="container-custom">
          <div className="text-center mb-20 max-w-3xl mx-auto">
            <span className="text-primary font-bold text-[11px] uppercase tracking-widest mb-6 block bg-blue-50 inline-block px-4 py-1.5 rounded-full">The Challenge</span>
            <h2 className="text-4xl md:text-5xl font-extrabold text-main mb-8 tracking-tight">Accessing Healthcare Should Not Mean <span className="text-slate-400 decoration-4 underline-offset-4 decoration-rose-200/50">Endless Waiting.</span></h2>
            <p className="text-lg text-secondary leading-relaxed font-light">
              In refugee settlements, accessing healthcare often requires standing in long queues under extreme heat. Overcrowded facilities, limited staff, and manual systems lead to delays in treatment and slow emergency response.
            </p>
          </div>

          <div className="grid md:grid-cols-3 gap-8">
            <ProblemCard
              icon={<Users className="text-rose-500" />}
              title="Vulnerable Patients"
              desc="For pregnant women, the elderly, and persons with disabilities, delays are not just inconvenient—they are dangerous."
              delay={0}
            />
            <ProblemCard
              icon={<Siren className="text-amber-500" />}
              title="Emergency Delays"
              desc="Emergency cases get lost in manual systems and overcrowded waiting areas, slowing down critical response times."
              delay={0.1}
            />
            <ProblemCard
              icon={<Activity className="text-primary" />}
              title="Staff Overload"
              desc="Healthcare workers face too many patients with no real-time visibility to manage demand effectively."
              delay={0.2}
            />
          </div>
        </div>
      </section>

      {/* The Solution */}
      <section className="py-32 bg-[#0B1120] text-white overflow-hidden relative">
        <div className="absolute top-0 left-0 w-full h-full bg-[url('/grid-pattern.svg')] opacity-5" />
        <div className="absolute top-10 left-10 w-96 h-96 bg-blue-600/20 rounded-full blur-[120px] pointer-events-none" />

        <div className="container-custom relative z-10">
          <div className="text-center mb-24 max-w-3xl mx-auto">
            <span className="text-blue-400 font-bold text-[11px] uppercase tracking-widest mb-6 block">The MyQueue Solution</span>
            <h2 className="text-4xl md:text-5xl font-extrabold mb-8 tracking-tight leading-tight">From Physical Queues to <br /><span className="text-transparent bg-clip-text bg-gradient-to-r from-blue-400 to-blue-500">Digital Coordination.</span></h2>
            <p className="text-lg text-slate-400 leading-relaxed font-light">
              MyQueue replaces long physical queues with a coordinated digital system. Refugees submit healthcare requests through a simple mobile application, while hospitals manage patient flow through our centralized platform.
            </p>
          </div>

          <div className="grid lg:grid-cols-2 gap-20 items-center">
            <div className="bg-slate-800/50 backdrop-blur-md rounded-4xl p-12 border border-white/5 shadow-2xl hover:border-white/10 transition-colors">
              <h3 className="text-3xl font-bold mb-6 text-white">The Web Platform</h3>
              <div className="w-16 h-1 bg-blue-500 rounded-full mb-8" />
              <p className="text-slate-400 mb-10 leading-relaxed text-lg font-light">
                Hospitals and clinics can view live traffic, monitor department-level queues, prioritize urgent cases, and coordinate staff resources effectively.
              </p>
              <ul className="space-y-5 mb-12">
                <SolutionCheck text="Live Patient Request Dashboard" />
                <SolutionCheck text="Department-Level Queues (OPD, Lab, Pharmacy)" />
                <SolutionCheck text="Emergency & Ambulance Alerts" />
                <SolutionCheck text="Staff & Resource Allocation" />
              </ul>
              <Link href="/web-platform" className="inline-flex items-center gap-2 text-white font-bold bg-blue-600/20 hover:bg-blue-600/30 px-6 py-3 rounded-xl border border-blue-500/30 transition-all group">
                Explore Web Platform <ArrowRight size={18} className="group-hover:translate-x-1 transition-transform" />
              </Link>
            </div>

            <div className="relative">
              <div className="grid gap-6">
                <FeatureCard
                  title="Maternity Care"
                  desc="Maternity requests are prioritized digitally, reducing complexity for mothers."
                  color="blue"
                />
                <FeatureCard
                  title="Emergency Response"
                  desc="Emergency requests trigger real-time alerts for immediate coordination."
                  color="rose"
                />
                <FeatureCard
                  title="Pharmacy & Lab"
                  desc="Digital queuing reduces congestion and improves service flow."
                  color="amber"
                />
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Partners/Designed For */}
      <section className="py-24 bg-slate-50 border-y border-slate-100">
        <div className="container-custom">
          <p className="text-xs font-bold text-slate-400 uppercase tracking-widest text-center mb-12">Trusted by Humanitarian Teams</p>

          <div className="grid grid-cols-2 md:grid-cols-5 gap-12 items-center justify-items-center opacity-60 grayscale hover:grayscale-0 transition-all duration-700">
            <DesignedForIcon icon={<Globe size={32} />} label="International Orgs" />
            <DesignedForIcon icon={<Tent size={32} />} label="Refugee Camps" />
            <DesignedForIcon icon={<Siren size={32} />} label="Emergency Teams" />
            <DesignedForIcon icon={<Building2 size={32} />} label="Public Health" />
            <DesignedForIcon icon={<Users size={32} />} label="Community Partners" />
          </div>
        </div>
      </section>

      <section className="py-32 bg-white">
        <div className="container-custom grid lg:grid-cols-2 gap-20 items-center">
          <div>
            <div className="inline-block mb-6 px-4 py-1.5 bg-green-50 text-green-700 text-[10px] font-bold uppercase tracking-widest rounded-full">
              Expansion Plan
            </div>
            <h2 className="text-4xl font-extrabold text-main mb-8 tracking-tight leading-tight">Starting in Kakuma. Expanding to Dadaab. Built to Scale.</h2>
            <p className="text-lg text-secondary mb-10 leading-relaxed font-light">
              MyQueue will be piloted in Kakuma Refugee Camp, working closely with healthcare providers to refine the system based on real-world use. Following the pilot phase, the platform will expand to Dadaab and other settlements.
            </p>

            <div className="space-y-8">
              <div>
                <h3 className="text-main font-bold text-lg mb-4">Real Impact Metrics</h3>
                <div className="grid sm:grid-cols-2 gap-4">
                  <ImpactRow text="Reduced waiting times" />
                  <ImpactRow text="Faster emergency response" />
                  <ImpactRow text="Improved maternal access" />
                  <ImpactRow text="Restored patient dignity" />
                </div>
              </div>
            </div>
          </div>

          <div className="bg-slate-900 text-white rounded-4xl p-12 relative overflow-hidden flex flex-col justify-between min-h-[400px] shadow-2xl">
            <div className="relative z-10">
              <div className="w-12 h-12 bg-blue-500/20 rounded-2xl flex items-center justify-center mb-8 border border-blue-500/30">
                <Shield size={24} className="text-blue-400" />
              </div>

              <h3 className="text-2xl font-bold mb-6">Security, Privacy & Dignity</h3>
              <p className="text-slate-400 leading-relaxed font-light mb-8 text-base">
                MyQueue is built with humanitarian data protection principles at its core. Sensitive health information is protected through secure systems, role-based access, and ethical design practices.
              </p>

              <div className="pt-8 border-t border-white/10">
                <p className="text-white font-medium text-lg leading-relaxed">
                  Refugee dignity, safety, and consent guide every aspect of the platform.
                </p>
              </div>
            </div>

            {/* Abstract shapes */}
            <div className="absolute top-0 right-0 w-64 h-64 bg-blue-600 opacity-20 blur-[100px] rounded-full pointer-events-none" />
            <div className="absolute bottom-0 left-0 w-48 h-48 bg-blue-600 opacity-10 blur-[80px] rounded-full pointer-events-none" />
          </div>
        </div>
      </section>

      {/* CTA */}
      <section className="py-32 bg-primary text-white text-center relative overflow-hidden">
        <div className="absolute inset-0 bg-[url('/grid-pattern.svg')] opacity-10" />
        <div className="absolute inset-0 bg-gradient-to-b from-transparent to-blue-900/30" />

        <div className="container-custom relative z-10">
          <h2 className="text-4xl md:text-5xl font-extrabold mb-8 tracking-tight">Let's Transform Healthcare Access.</h2>
          <p className="text-xl text-blue-100 mb-12 max-w-2xl mx-auto font-light leading-relaxed">
            Whether you are a healthcare provider, humanitarian organization, or partner, MyQueue is ready to work with you.
          </p>
          <div className="flex flex-wrap justify-center gap-6">
            <button className="h-14 px-10 bg-white text-primary rounded-full font-bold hover:bg-blue-50 transition-all text-base shadow-xl hover:shadow-2xl hover:-translate-y-1">
              Request a Demo
            </button>
            <Link href="/concept-note" className="h-14 px-10 border border-white/40 text-white rounded-full font-bold hover:bg-white/10 transition-all text-base flex items-center gap-2">
              Partner With Us
            </Link>
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer className="bg-white pt-24 pb-12 border-t border-slate-100">
        <div className="container-custom">
          <div className="grid grid-cols-1 lg:grid-cols-12 gap-16 mb-20">
            <div className="lg:col-span-4">
              <div className="flex items-center gap-3 mb-8">
                <div className="p-2 bg-slate-50 rounded-lg">
                  <img src="/images/app_logo.png" alt="Logo" className="w-6 h-6" />
                </div>
                <span className="font-bold text-main tracking-tight text-xl">myqueue</span>
              </div>
              <p className="text-secondary text-sm leading-relaxed mb-10 font-light max-w-xs">
                Fast, professional, purpose-driven healthcare coordination services for humanitarian settings.
              </p>
              <div className="flex gap-4">
                <SocialIcon icon={<Globe size={18} />} />
                <SocialIcon icon={<Mail size={18} />} />
                <SocialIcon icon={<Smartphone size={18} />} />
              </div>
            </div>

            <div className="lg:col-span-8 grid grid-cols-2 md:grid-cols-3 gap-12">
              <div>
                <h4 className="font-bold text-main text-[11px] uppercase tracking-widest mb-8">About Us</h4>
                <ul className="space-y-4 text-slate-500 text-sm font-medium">
                  <li><Link href="/purpose" className="hover:text-primary transition-colors">Our Purpose</Link></li>
                  <li><Link href="/impact" className="hover:text-primary transition-colors">Our Impact</Link></li>
                  <li><Link href="/stories" className="hover:text-primary transition-colors">Impact Stories</Link></li>
                  <li><a href="#partners" className="hover:text-primary transition-colors font-sans">Partners</a></li>
                </ul>
              </div>

              <div>
                <h4 className="font-bold text-main text-[11px] uppercase tracking-widest mb-8">Solutions</h4>
                <ul className="space-y-4 text-slate-500 text-sm font-medium">
                  <li><a href="#" className="hover:text-primary transition-colors">Queue Management</a></li>
                  <li><a href="#" className="hover:text-primary transition-colors">Emergency Response</a></li>
                  <li><a href="#" className="hover:text-primary transition-colors">Maternity Care</a></li>
                  <li><a href="#" className="hover:text-primary transition-colors">Data Analytics</a></li>
                </ul>
              </div>

              <div>
                <h4 className="font-bold text-main text-[11px] uppercase tracking-widest mb-8">Get the App</h4>
                <div className="space-y-4">
                  <button className="w-full h-12 px-5 bg-[#0B1120] text-white rounded-xl flex items-center gap-4 hover:bg-slate-800 transition-all group shadow-md hover:shadow-lg">
                    <img src="https://cdn-icons-png.flaticon.com/512/888/888857.png" alt="Google Play" className="w-5 h-5 invert opacity-80 group-hover:opacity-100 transition-opacity" />
                    <div className="text-left">
                      <p className="text-[9px] font-bold text-slate-400 uppercase leading-none mb-0.5">Get it on</p>
                      <p className="text-xs font-bold leading-none">Google Play</p>
                    </div>
                  </button>
                  <button className="w-full h-12 px-5 bg-[#0B1120] text-white rounded-xl flex items-center gap-4 hover:bg-slate-800 transition-all group shadow-md hover:shadow-lg">
                    <img src="https://cdn-icons-png.flaticon.com/512/888/888841.png" alt="App Store" className="w-5 h-5 invert opacity-80 group-hover:opacity-100 transition-opacity" />
                    <div className="text-left">
                      <p className="text-[9px] font-bold text-slate-400 uppercase leading-none mb-0.5">Download on the</p>
                      <p className="text-xs font-bold leading-none">App Store</p>
                    </div>
                  </button>
                </div>
              </div>
            </div>
          </div>

          <div className="pt-8 border-t border-slate-100 flex flex-col md:flex-row justify-between items-center gap-8">
            <div className="flex items-center gap-8 text-[10px] font-bold text-slate-400 uppercase tracking-widest leading-none">
              <a href="#" className="hover:text-main transition-colors">Privacy Policy</a>
              <a href="#" className="hover:text-main transition-colors">Terms</a>
              <a href="#" className="hover:text-main transition-colors">Safeguarding</a>
            </div>
            <p className="text-slate-400 text-[10px] font-bold uppercase tracking-widest leading-none">© 2026 myqueue.</p>
          </div>
        </div>
      </footer>
    </div>
  );
}

// Components
function ProblemCard({ icon, title, desc, delay }: any) {
  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      whileInView={{ opacity: 1, y: 0 }}
      viewport={{ once: true }}
      transition={{ delay: delay || 0, duration: 0.5 }}
      className="p-10 bg-white rounded-3xl border border-slate-100 shadow-sm hover:shadow-xl hover:-translate-y-1 transition-all duration-300 group"
    >
      <div className="w-12 h-12 bg-slate-50 rounded-2xl flex items-center justify-center mb-8 border border-slate-100 group-hover:scale-110 transition-transform duration-300">
        <div className="transform scale-125">
          {icon}
        </div>
      </div>
      <h3 className="text-xl font-bold text-main mb-4 leading-tight">{title}</h3>
      <p className="text-secondary text-base leading-relaxed font-light">{desc}</p>
    </motion.div>
  );
}

function SolutionCheck({ text }: { text: string }) {
  return (
    <li className="flex items-center gap-4">
      <div className="w-6 h-6 rounded-full bg-blue-500/20 flex items-center justify-center shrink-0">
        <CheckCircle2 className="text-blue-400" size={14} />
      </div>
      <span className="font-medium text-base text-slate-300">{text}</span>
    </li>
  );
}

function FeatureCard({ title, desc, color }: any) {
  const colors: any = {
    blue: "text-blue-300 border-blue-500/30 bg-blue-500/10",
    rose: "text-rose-300 border-rose-500/30 bg-rose-500/10",
    amber: "text-amber-300 border-amber-500/30 bg-amber-500/10"
  };

  return (
    <div className={`backdrop-blur-sm p-8 rounded-3xl border ${colors[color].replace('text-', 'border-').split(' ')[1]} bg-white/5 hover:bg-white/10 transition-colors`}>
      <h4 className={`font-bold text-lg mb-2 ${colors[color].split(' ')[0]}`}>{title}</h4>
      <p className="text-sm text-slate-400 font-light leading-relaxed">{desc}</p>
    </div>
  )
}

function DesignedForIcon({ icon, label }: any) {
  return (
    <div className="flex flex-col items-center gap-4 group cursor-default">
      <div className="p-4 bg-white rounded-2xl border border-slate-100 shadow-sm text-slate-400 group-hover:text-primary group-hover:border-blue-100 group-hover:scale-110 group-hover:shadow-md transition-all duration-300">
        {icon}
      </div>
      <span className="text-[10px] font-bold text-slate-400 uppercase tracking-widest text-center group-hover:text-main transition-colors">{label}</span>
    </div>
  );
}

function ImpactRow({ text }: { text: string }) {
  return (
    <div className="flex items-center gap-3 p-4 bg-slate-50 rounded-2xl border border-slate-100 text-secondary font-medium text-sm group hover:border-blue-100 transition-colors">
      <Activity size={18} className="text-slate-400 group-hover:text-primary transition-colors" />
      {text}
    </div>
  );
}

function SocialIcon({ icon }: { icon: React.ReactNode }) {
  return (
    <a href="#" className="w-10 h-10 rounded-xl bg-slate-50 border border-slate-100 flex items-center justify-center text-slate-400 hover:text-white hover:bg-primary hover:border-primary transition-all duration-300">
      {icon}
    </a>
  );
}
