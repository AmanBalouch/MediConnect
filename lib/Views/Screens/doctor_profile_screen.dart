import 'package:flutter/material.dart';
import 'package:mediconnectcode/Models/doctor_model.dart';
import 'package:mediconnectcode/main.dart';

class DoctorProfileScreen extends StatelessWidget {
  final DoctorModel doctor;
  final Color avatarColor;

  const DoctorProfileScreen({
    super.key,
    required this.doctor,
    required this.avatarColor,
  });

  @override
  Widget build(BuildContext context) {
    final initials = _getInitials(doctor.name);
    final specialty = doctor.specializations.isNotEmpty
        ? doctor.specializations.join(', ')
        : 'General';
    final fee = doctor.consultationFee != null
        ? 'Rs. ${doctor.consultationFee}'
        : 'N/A';
    final experience = doctor.yearsOfExperience.isNotEmpty
        ? '${doctor.yearsOfExperience} years'
        : '—';

    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      body: Column(
        children: [
          // ── Header ──────────────────────────────────────────────────────
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primaryTealDark,
                  AppTheme.primaryTeal,
                  AppTheme.primaryTealMedium,
                ],
              ),
            ),
            padding: EdgeInsets.fromLTRB(
              16,
              MediaQuery.of(context).padding.top + 12,
              16,
              28,
            ),
            child: Column(
              children: [
                // Back button row
                Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.4),
                        ),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Avatar
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.5),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: AppTheme.heading(Colors.white, 28),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Doctor name
                Text(
                  doctor.name ?? 'Unknown Doctor',
                  style: AppTheme.heading(Colors.white, 22),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 4),

                // Specialty
                Text(
                  specialty,
                  style: AppTheme.body(Colors.white70, 14),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                // Stats row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _statChip(Icons.people_rounded, '${doctor.patientChecked} patients', Colors.white70),
                    const SizedBox(width: 12),
                    _statChip(Icons.payments_rounded, fee, Colors.white70),
                  ],
                ),
              ],
            ),
          ),

          // ── Details Body ────────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Professional Info card
                  _infoCard(
                    title: 'Professional Info',
                    children: [
                      _infoRow(Icons.school_rounded, 'Degree', doctor.degree.isNotEmpty ? doctor.degree : '—'),
                      _divider(),
                      _infoRow(Icons.work_history_rounded, 'Experience', experience),
                      _divider(),
                      _infoRow(Icons.verified_rounded, 'PMDC License', doctor.pmdcLicenseNumber.isNotEmpty ? doctor.pmdcLicenseNumber : '—'),
                      _divider(),
                      _infoRow(Icons.medical_services_rounded, 'Specializations', specialty),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Clinic Info card
                  _infoCard(
                    title: 'Clinic Info',
                    children: [
                      _infoRow(Icons.local_hospital_rounded, 'Clinic', doctor.clinicName ?? '—'),
                      _divider(),
                      _infoRow(Icons.location_on_rounded, 'Address', doctor.clinicAddress ?? '—'),
                      _divider(),
                      _infoRow(Icons.payments_outlined, 'Consultation Fee', fee),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Verified badge
                  if (doctor.isVerified)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryTealLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.primaryTeal.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.verified_rounded, color: AppTheme.primaryTeal, size: 20),
                          const SizedBox(width: 10),
                          Text(
                            'Verified Doctor',
                            style: AppTheme.body(AppTheme.primaryTealDark),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 90), // space for FAB
                ],
              ),
            ),
          ),
        ],
      ),

      // ── Send Request FAB ─────────────────────────────────────────────────
      floatingActionButton: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: FloatingActionButton.extended(
          onPressed: () {
            // TODO: implement send request
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Request feature coming soon!')),
            );
          },
          backgroundColor: AppTheme.primaryTeal,
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          label: Row(
            children: [
              const Icon(Icons.send_rounded, color: Colors.white, size: 18),
              const SizedBox(width: 10),
              Text(
                'Send Request',
                style: AppTheme.label(Colors.white, 16),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  String _getInitials(String? name) {
    if (name == null || name.trim().isEmpty) return 'DR';
    return name
        .trim()
        .split(' ')
        .where((w) => w.isNotEmpty)
        .take(2)
        .map((w) => w[0].toUpperCase())
        .join();
  }

  Widget _statChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 5),
          Text(label, style: AppTheme.small(color, 12)),
        ],
      ),
    );
  }

  Widget _infoCard({required String title, required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Text(title, style: AppTheme.label(AppTheme.textPrimary, 15)),
          ),
          ...children,
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.primaryTeal, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTheme.small(AppTheme.textTertiary, 11)),
                const SizedBox(height: 2),
                Text(value, style: AppTheme.body(AppTheme.textPrimary, 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Divider(
      height: 1,
      indent: 46,
      endIndent: 16,
      color: AppTheme.borderColor,
    );
  }
}
