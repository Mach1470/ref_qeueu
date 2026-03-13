'use client';

import ManagementLayout from '@/components/dashboard/management-layout';
import { motion, AnimatePresence } from 'framer-motion';
import {
  ShieldCheck,
  UserPlus,
  Fingerprint,
  Lock,
  ShieldAlert,
  Plus,
  Search,
  Hospital,
  ChevronRight,
  User,
  Power,
  MapPin,
  X,
  Settings
} from 'lucide-react';
import { useState } from 'react';
import { mockHealthFacilities, HealthFacility } from '@/lib/facilities';
import { campLocations, LocationNode } from '@/lib/locations';

export default function AdvancedAccessPage() {
  const [activeTab, setActiveTab] = useState<'provision' | 'approvals' | 'logs' | 'areas'>('approvals');
  const [showCreateModal, setShowCreateModal] = useState(false);

  // Mock pending staff for approval
  const pendingStaff = [
    {
      id: 'staff_003',
      name: 'Nurse John Doe',
      email: 'john.d@unhcr.org',
      role: 'nurse',
      facility: 'UNHCR Main Camp Hospital',
      date: 'Today'
    },
    {
      id: 'staff_004',
      name: 'Lab Tech Peter',
      email: 'peter.l@unhcr.org',
      role: 'lab_tech',
      facility: 'UNHCR Main Camp Hospital',
      status: 'Transfer Requested',
      date: 'Yesterday'
    }
  ];

  return (
    <ManagementLayout>
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        className="space-y-8"
      >
        <div className="flex justify-between items-end">
          <div>
            <h1 className="text-3xl font-bold text-slate-900">Security & Access</h1>
            <p className="text-slate-500 font-medium">Manage system access, staff provisioning, and regional controls</p>
          </div>
          <div className="flex bg-white p-1 rounded-2xl border border-slate-200">
            <TabButton
              active={activeTab === 'approvals'}
              onClick={() => setActiveTab('approvals')}
              label="Approvals"
              count={2}
            />
            <TabButton
              active={activeTab === 'provision'}
              onClick={() => setActiveTab('provision')}
              label="Provision Staff"
            />
            <TabButton
              active={activeTab === 'areas'}
              onClick={() => setActiveTab('areas')}
              label="Regional Controls"
            />
            <TabButton
              active={activeTab === 'logs'}
              onClick={() => setActiveTab('logs')}
              label="Logs"
            />
          </div>
        </div>

        <AnimatePresence mode="wait">
          {activeTab === 'approvals' && (
            <motion.div
              key="approvals"
              initial={{ opacity: 0, x: -10 }}
              animate={{ opacity: 1, x: 0 }}
              exit={{ opacity: 0, x: 10 }}
              className="space-y-6"
            >
              <div className="bg-white rounded-[2.5rem] border border-slate-200 overflow-hidden">
                <div className="p-8 border-b border-slate-100">
                  <h2 className="text-xl font-bold text-slate-900">Pending Approvals</h2>
                  <p className="text-slate-500 text-sm">Review staff account requests and transfers</p>
                </div>
                <div>
                  {pendingStaff.map((staff) => (
                    <div key={staff.id} className="p-6 border-b border-slate-50 flex items-center justify-between hover:bg-slate-50 transition-colors">
                      <div className="flex items-center gap-4">
                        <div className="w-12 h-12 bg-amber-100 text-amber-600 rounded-2xl flex items-center justify-center font-bold">
                          {staff.name.charAt(0)}
                        </div>
                        <div>
                          <div className="flex items-center gap-2 mb-1">
                            <h3 className="font-bold text-slate-900">{staff.name}</h3>
                            {staff.status === 'Transfer Requested' ? (
                              <span className="px-2 py-0.5 bg-purple-100 text-purple-700 text-[10px] font-bold uppercase rounded-full">Transfer</span>
                            ) : (
                              <span className="px-2 py-0.5 bg-blue-100 text-blue-700 text-[10px] font-bold uppercase rounded-full">New Account</span>
                            )}
                          </div>
                          <p className="text-sm text-slate-500 font-medium">{staff.role} • {staff.facility}</p>
                        </div>
                      </div>
                      <div className="flex items-center gap-3">
                        <button className="px-4 py-2 bg-slate-100 text-slate-600 font-bold text-xs rounded-xl hover:bg-slate-200 transition-colors">Reject</button>
                        <button className="px-4 py-2 bg-blue-600 text-white font-bold text-xs rounded-xl hover:bg-blue-700 transition-colors shadow-lg shadow-blue-100">Approve</button>
                      </div>
                    </div>
                  ))}
                </div>
              </div>
            </motion.div>
          )}

          {activeTab === 'provision' && (
            <motion.div
              key="provision"
              initial={{ opacity: 0, x: -10 }}
              animate={{ opacity: 1, x: 0 }}
              exit={{ opacity: 0, x: 10 }}
              className="space-y-6"
            >
              <div className="flex justify-between items-center">
                <div className="relative group w-96">
                  <Search className="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-slate-400 group-focus-within:text-ocean-600 transition-colors" />
                  <input
                    type="text"
                    placeholder="Search facilities or staff..."
                    className="w-full pl-12 pr-4 py-3 bg-white border border-slate-200 rounded-2xl focus:border-ocean-500 outline-none transition-all shadow-sm"
                  />
                </div>
                <button
                  onClick={() => setShowCreateModal(true)}
                  className="px-6 py-3 bg-ocean-600 text-white rounded-2xl font-bold flex items-center gap-2 hover:scale-105 transition-all shadow-lg shadow-ocean-100"
                >
                  <Plus size={20} />
                  Add Health Facility
                </button>
              </div>

              <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
                {mockHealthFacilities.map(facility => (
                  <ProvisionCard key={facility.id} facility={facility} />
                ))}
              </div>
            </motion.div>
          )}

          {activeTab === 'areas' && (
            <motion.div
              key="areas"
              initial={{ opacity: 0, x: -10 }}
              animate={{ opacity: 1, x: 0 }}
              exit={{ opacity: 0, x: 10 }}
              className="grid lg:grid-cols-2 gap-8"
            >
              {campLocations.map(camp => (
                <CampControlCard key={camp.id} camp={camp} />
              ))}
            </motion.div>
          )}

          {activeTab === 'logs' && (
            <motion.div
              key="logs"
              initial={{ opacity: 0, x: -10 }}
              animate={{ opacity: 1, x: 0 }}
              exit={{ opacity: 0, x: 10 }}
              className="bg-white rounded-[2.5rem] p-8 border border-slate-200 shadow-sm"
            >
              <div className="space-y-4">
                <LogEntry title="Admin login from unrecognized IP" location="Nairobi, KE" time="5m ago" urgent />
                <LogEntry title="Dr. Sarah Johnson logged in" location="Main Hospital" time="15m ago" />
                <LogEntry title="New staff account provisioned" location="System" time="1h ago" />
              </div>
            </motion.div>
          )}
        </AnimatePresence>
      </motion.div>

      {/* Create Hospital Modal */}
      <AnimatePresence>
        {showCreateModal && (
          <CreateHospitalModal onClose={() => setShowCreateModal(false)} />
        )}
      </AnimatePresence>
    </ManagementLayout>
  );
}

function TabButton({ active, onClick, label, count }: any) {
  return (
    <button
      onClick={onClick}
      className={`px-6 py-2.5 rounded-xl text-sm font-bold transition-all flex items-center gap-2 ${active
        ? 'bg-ocean-600 text-white shadow-md'
        : 'text-slate-500 hover:text-ocean-600'
        }`}
    >
      {label}
      {count > 0 && (
        <span className={`w-5 h-5 flex items-center justify-center rounded-full text-[10px] ${active ? 'bg-white text-ocean-600' : 'bg-rose-500 text-white'}`}>
          {count}
        </span>
      )}
    </button>
  );
}

function ProvisionCard({ facility }: { facility: HealthFacility }) {
  return (
    <div className="bg-white p-6 rounded-4xl border border-slate-200 hover:border-ocean-500 transition-all group relative overflow-hidden">
      {!facility.isActive && (
        <div className="absolute inset-0 bg-slate-50/80 backdrop-blur-[2px] z-10 flex items-center justify-center">
          <div className="bg-white px-4 py-2 rounded-xl border border-slate-200 shadow-sm text-xs font-bold text-slate-400 uppercase tracking-widest">
            Deactivated
          </div>
        </div>
      )}

      <div className="flex justify-between items-start mb-6">
        <div className="w-12 h-12 bg-ocean-50 text-ocean-600 rounded-xl flex items-center justify-center border border-ocean-100">
          <Hospital size={24} />
        </div>
        <div className="flex items-center gap-2">
          <button className="p-2 text-slate-400 hover:text-ocean-600 transition-colors">
            <Settings size={18} />
          </button>
          <div className="w-px h-4 bg-slate-200 mx-1" />
          <Power className={`w-5 h-5 cursor-pointer transition-colors ${facility.isActive ? 'text-blue-500 hover:text-blue-600' : 'text-slate-300'}`} />
        </div>
      </div>

      <h3 className="font-bold text-slate-900 mb-1">{facility.name}</h3>
      <p className="text-xs text-slate-400 mb-6 flex items-center gap-1 font-medium">
        <MapPin size={12} />
        {facility.address.split(',')[0]}
      </p>

      <div className="space-y-4">
        <div className="flex justify-between items-center bg-slate-50 p-4 rounded-2xl">
          <div className="flex items-center gap-3">
            <div className="w-8 h-8 bg-white rounded-lg flex items-center justify-center shadow-sm">
              <User className="w-5 h-5 text-slate-400" />
            </div>
            <div>
              <p className="text-[10px] font-bold text-slate-400 uppercase tracking-widest leading-none mb-1">Admin</p>
              <p className="text-sm font-bold text-slate-700">Sarah Johnson</p>
            </div>
          </div>
          <ChevronRight className="w-4 h-4 text-slate-300" />
        </div>

        <button className="w-full py-3 border-2 border-dashed border-slate-200 rounded-2xl text-slate-400 font-bold text-xs hover:border-orange-500 hover:text-orange-600 hover:bg-orange-50 transition-all flex items-center justify-center gap-2">
          <UserPlus size={16} />
          Add Staff Member
        </button>
      </div>
    </div>
  );
}

function CampControlCard({ camp }: { camp: LocationNode }) {
  return (
    <div className="bg-white rounded-[2.5rem] p-8 border border-slate-200 shadow-sm">
      <div className="flex justify-between items-center mb-10">
        <div>
          <h3 className="text-xl font-bold text-slate-900">{camp.name}</h3>
          <p className="text-sm text-slate-400 font-medium tracking-tight">Manage all sections within this complex</p>
        </div>
        <div className="flex items-center gap-3">
          <span className="text-xs font-bold text-slate-400 uppercase tracking-widest">Global Status</span>
          <div className="w-12 h-6 bg-blue-500 rounded-full relative shadow-inner">
            <div className="absolute right-1 top-1 w-4 h-4 bg-white rounded-full shadow-sm" />
          </div>
        </div>
      </div>

      <div className="grid gap-4">
        {camp.children?.map(area => (
          <div key={area.id} className="p-6 bg-slate-50 rounded-3xl border border-slate-100 flex justify-between items-center group hover:bg-white hover:shadow-xl hover:-translate-y-1 transition-all duration-300">
            <div className="flex items-center gap-4">
              <div className="w-10 h-10 bg-white rounded-xl flex items-center justify-center text-slate-400 border border-slate-100 group-hover:text-ocean-600 transition-colors">
                <MapPin size={20} />
              </div>
              <div>
                <p className="font-bold text-slate-900">{area.name}</p>
                <p className="text-xs text-slate-400 font-bold uppercase tracking-wider">{area.children?.length || 0} Zones Active</p>
              </div>
            </div>
            <div className="flex items-center gap-6">
              <button className="text-[10px] font-bold text-ocean-600 uppercase tracking-widest hover:underline">Edit Zones</button>
              <div className="w-10 h-5 bg-blue-500 rounded-full relative">
                <div className="absolute right-1 top-0.5 w-4 h-4 bg-white rounded-full shadow-sm" />
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}

function CreateHospitalModal({ onClose }: { onClose: () => void }) {
  const [step, setStep] = useState(1);
  const [formData, setFormData] = useState({
    name: '',
    camp: '',
    area: '',
    zone: '',
    block: '',
    type: 'hospital'
  });

  const selectedCamp = campLocations.find(c => c.id === formData.camp);
  const selectedArea = selectedCamp?.children?.find(a => a.id === formData.area);
  const selectedZone = selectedArea?.children?.find(z => z.id === formData.zone);

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-6 sm:p-20">
      <motion.div
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        exit={{ opacity: 0 }}
        onClick={onClose}
        className="absolute inset-0 bg-slate-900/60 backdrop-blur-md"
      />
      <motion.div
        initial={{ opacity: 0, scale: 0.9, y: 20 }}
        animate={{ opacity: 1, scale: 1, y: 0 }}
        exit={{ opacity: 0, scale: 0.9, y: 20 }}
        className="relative w-full max-w-2xl bg-white rounded-[3rem] shadow-3xl flex flex-col overflow-hidden"
      >
        <div className="p-8 border-b border-slate-100 flex justify-between items-center">
          <div>
            <h2 className="text-2xl font-bold text-slate-900">Add Health Facility</h2>
            <div className="flex gap-2 mt-2">
              {[1, 2, 3].map(s => (
                <div key={s} className={`h-1.5 w-12 rounded-full transition-all duration-500 ${step >= s ? 'bg-ocean-600' : 'bg-slate-100'}`} />
              ))}
            </div>
          </div>
          <button onClick={onClose} className="p-3 hover:bg-slate-100 rounded-2xl text-slate-400">
            <X size={24} />
          </button>
        </div>

        <div className="p-10 flex-1 overflow-y-auto">
          {step === 1 && (
            <motion.div initial={{ opacity: 0, x: 20 }} animate={{ opacity: 1, x: 0 }} className="space-y-6">
              <h3 className="text-lg font-bold text-slate-800 mb-8">Basic Information</h3>
              <div>
                <label className="block text-xs font-bold text-slate-400 uppercase tracking-widest mb-3 ml-1">Hospital Name</label>
                <input
                  type="text"
                  placeholder="e.g. Kakuma West Medical Center"
                  value={formData.name}
                  onChange={e => setFormData({ ...formData, name: e.target.value })}
                  className="w-full px-6 py-4 bg-slate-50 border-2 border-slate-50 rounded-2xl focus:bg-white focus:border-ocean-500 outline-none transition-all font-medium"
                />
              </div>
              <div>
                <label className="block text-xs font-bold text-slate-400 uppercase tracking-widest mb-3 ml-1">Facility Type</label>
                <div className="grid grid-cols-3 gap-4">
                  {['hospital', 'clinic', 'health_post'].map(t => (
                    <button
                      key={t}
                      onClick={() => setFormData({ ...formData, type: t as any })}
                      className={`py-4 rounded-2xl border-2 font-bold capitalize transition-all ${formData.type === t ? 'border-ocean-600 bg-ocean-50 text-ocean-600' : 'border-transparent bg-slate-50 text-slate-500'
                        }`}
                    >
                      {t.replace('_', ' ')}
                    </button>
                  ))}
                </div>
              </div>
            </motion.div>
          )}

          {step === 2 && (
            <motion.div initial={{ opacity: 0, x: 20 }} animate={{ opacity: 1, x: 0 }} className="space-y-6">
              <h3 className="text-lg font-bold text-slate-800 mb-8">Location Hierarchy</h3>
              <div className="grid grid-cols-2 gap-6">
                <div>
                  <label className="block text-xs font-bold text-slate-400 uppercase tracking-widest mb-3 ml-1">Camp</label>
                  <select
                    value={formData.camp}
                    onChange={e => setFormData({ ...formData, camp: e.target.value, area: '', zone: '', block: '' })}
                    className="w-full px-6 py-4 bg-slate-50 border-2 border-slate-50 rounded-2xl outline-none font-bold text-slate-700"
                  >
                    <option value="">Select Camp</option>
                    {campLocations.map(c => <option key={c.id} value={c.id}>{c.name}</option>)}
                  </select>
                </div>
                <div>
                  <label className="block text-xs font-bold text-slate-400 uppercase tracking-widest mb-3 ml-1">Area / Sector</label>
                  <select
                    value={formData.area}
                    disabled={!formData.camp}
                    onChange={e => setFormData({ ...formData, area: e.target.value, zone: '', block: '' })}
                    className="w-full px-6 py-4 bg-slate-50 border-2 border-slate-50 rounded-2xl outline-none font-bold text-slate-700 disabled:opacity-50"
                  >
                    <option value="">Select Area</option>
                    {selectedCamp?.children?.map(a => <option key={a.id} value={a.id}>{a.name}</option>)}
                  </select>
                </div>
                <div>
                  <label className="block text-xs font-bold text-slate-400 uppercase tracking-widest mb-3 ml-1">
                    {selectedArea?.id === 'kalobeyei' ? 'Village' : (selectedCamp?.id === 'dadaab' ? 'Section' : 'Zone')}
                  </label>
                  <select
                    value={formData.zone}
                    disabled={!formData.area}
                    onChange={e => setFormData({ ...formData, zone: e.target.value, block: '' })}
                    className="w-full px-6 py-4 bg-slate-50 border-2 border-slate-50 rounded-2xl outline-none font-bold text-slate-700 disabled:opacity-50"
                  >
                    <option value="">{selectedArea?.id === 'kalobeyei' ? 'Select Village' : (selectedCamp?.id === 'dadaab' ? 'Select Section' : 'Select Zone')}</option>
                    {selectedArea?.children?.map(z => <option key={z.id} value={z.id}>{z.name}</option>)}
                  </select>
                </div>
                <div>
                  <label className="block text-xs font-bold text-slate-400 uppercase tracking-widest mb-3 ml-1">Block</label>
                  <select
                    value={formData.block}
                    disabled={!formData.zone}
                    onChange={e => setFormData({ ...formData, block: e.target.value })}
                    className="w-full px-6 py-4 bg-slate-50 border-2 border-slate-50 rounded-2xl outline-none font-bold text-slate-700 disabled:opacity-50"
                  >
                    <option value="">Select Block</option>
                    {selectedZone?.children?.map(b => <option key={b.id} value={b.id}>{b.name}</option>)}
                  </select>
                </div>
              </div>
            </motion.div>
          )}

          {step === 3 && (
            <motion.div initial={{ opacity: 0, x: 20 }} animate={{ opacity: 1, x: 0 }} className="space-y-6">
              <h3 className="text-lg font-bold text-slate-800 mb-8">Admin Assignment</h3>
              <div className="bg-ocean-50 p-6 rounded-4xl border border-ocean-100 flex items-center gap-6">
                <div className="w-16 h-16 bg-white rounded-2xl flex items-center justify-center text-ocean-600 shadow-sm border border-ocean-50">
                  <UserPlus size={32} />
                </div>
                <div className="flex-1">
                  <p className="font-bold text-slate-900 leading-tight mb-1">Invite Hospital Administrator</p>
                  <p className="text-sm text-ocean-700/60 font-medium">This user will manage all internal staff and queues.</p>
                </div>
              </div>
              <input
                type="email"
                placeholder="admin.email@unhcr.org"
                className="w-full px-6 py-4 bg-slate-50 border-2 border-slate-50 rounded-2xl focus:bg-white focus:border-ocean-500 outline-none transition-all font-medium"
              />
            </motion.div>
          )}
        </div>

        <div className="p-8 border-t border-slate-100 bg-slate-50 flex justify-between">
          <button
            onClick={() => step > 1 ? setStep(step - 1) : onClose()}
            className="px-8 py-3 text-slate-500 font-bold hover:text-slate-700 transition-colors"
          >
            {step === 1 ? 'Cancel' : 'Back'}
          </button>
          <button
            onClick={() => step < 3 ? setStep(step + 1) : onClose()}
            className="px-10 py-3 bg-ocean-600 text-white rounded-2xl font-bold shadow-lg shadow-ocean-100 hover:scale-105 transition-all"
          >
            {step === 3 ? 'Finalize & Create' : 'Next Step'}
          </button>
        </div>
      </motion.div>
    </div>
  );
}

function LogEntry({ title, location, time, urgent }: any) {
  return (
    <div className={`p-5 rounded-2xl flex justify-between items-center border ${urgent ? 'bg-rose-50 border-rose-100' : 'bg-slate-50 border-slate-100'}`}>
      <div className="flex items-center gap-4">
        <div className={`w-10 h-10 rounded-xl flex items-center justify-center ${urgent ? 'bg-rose-500 text-white' : 'bg-slate-200 text-slate-500'}`}>
          {urgent ? <ShieldAlert size={20} /> : <ShieldCheck size={20} />}
        </div>
        <div>
          <p className={`font-bold text-sm ${urgent ? 'text-rose-700' : 'text-slate-900'}`}>{title}</p>
          <p className="text-xs text-slate-400 font-medium">{location}</p>
        </div>
      </div>
      <span className="text-[10px] font-bold text-slate-400 uppercase tracking-widest">{time}</span>
    </div>
  );
}


