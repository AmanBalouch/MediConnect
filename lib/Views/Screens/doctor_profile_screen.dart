import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mediconnectcode/Models/doctor_model.dart';
import 'package:mediconnectcode/ViewModels/consultation_request_viewmodel.dart';
import 'package:mediconnectcode/main.dart';

class DoctorProfileScreen extends StatefulWidget {
  final DoctorModel doctor;
  final Color avatarColor;

  const DoctorProfileScreen({
    super.key,
    required this.doctor,
    required this.avatarColor,
  });

  @override
  State<DoctorProfileScreen> createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends State<DoctorProfileScreen> {
  bool _alreadySent = false;
  bool _checkingStatus = true;

  @override
  void initState() {
    super.initState();
    _checkRequestStatus();
  }

  Future<void> _checkRequestStatus() async {
    final vm = context.read<ConsultationRequestViewModel>();
    final sent =
        await vm.hasAlreadySentRequest(widget.doctor.uid);
    if (mounted) {
      setState(() {
        _alreadySent = sent;
        _checkingStatus = false;
      });
    }
  }

  Future<void> _sendRequest() async {
    final vm = context.read<ConsultationRequestViewModel>();
    final success = await vm.sendRequest(
      doctorId: widget.doctor.uid,
      doctorName: widget.doctor.name ?? 'Doctor',
      note: '',
    );
    if (!mounted) return;
    if (success) {
      setState(() => _alreadySent = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Request sent successfully!'),
          backgroundColor: AppTheme.primaryTeal,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(vm.errorMessage ?? 'Failed to send request.'),
          backgroundColor: AppTheme.accentRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final doctor = widget.doctor;
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
          // ── Header ───────────────────────────────────────────────────
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
                            color: Colors.white.withValues(alpha: 0.4)),
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
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.5),
                        width: 2),
                  ),
                  child: Center(
                    child: Text(initials,
                        style: AppTheme.heading(Colors.white, 28)),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  doctor.name ?? 'Unknown Doctor',
                  style: AppTheme.heading(Colors.white, 22),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(specialty,
                    style: AppTheme.body(Colors.white70, 14),
                    textAlign: TextAlign.center),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _statChip(Icons.people_rounded,
                        '${doctor.patientChecked} patients', Colors.white70),
                    const SizedBox(width: 12),
                    _statChip(
                        Icons.payments_rounded, fee, Colors.white70),
                  ],
                ),
              ],
            ),
          ),

          // ── Details ──────────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _infoCard(
                    title: 'Professional Info',
                    children: [
                      _infoRow(Icons.school_rounded, 'Degree',
                          doctor.degree.isNotEmpty ? doctor.degree : '—'),
                      _divider(),
                      _infoRow(Icons.work_history_rounded, 'Experience',
                          experience),
                      _divider(),
                      _infoRow(
                          Icons.verified_rounded,
                          'PMDC License',
                          doctor.pmdcLicenseNumber.isNotEmpty
                              ? doctor.pmdcLicenseNumber
                              : '—'),
                      _divider(),
                      _infoRow(Icons.medical_services_rounded,
                          'Specializations', specialty),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _infoCard(
                    title: 'Clinic Info',
                    children: [
                      _infoRow(Icons.local_hospital_rounded, 'Clinic',
                          doctor.clinicName ?? '—'),
                      _divider(),
                      _infoRow(Icons.location_on_rounded, 'Address',
                          doctor.clinicAddress ?? '—'),
                      _divider(),
                      _infoRow(Icons.payments_outlined,
                          'Consultation Fee', fee),
                    ],
                  ),
                  const SizedBox(height: 14),
                  if (doctor.isVerified)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryTealLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppTheme.primaryTeal
                                .withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.verified_rounded,
                              color: AppTheme.primaryTeal, size: 20),
                          const SizedBox(width: 10),
                          Text('Verified Doctor',
                              style:
                                  AppTheme.body(AppTheme.primaryTealDark)),
                        ],
                      ),
                    ),
                  const SizedBox(height: 90),
                ],
              ),
            ),
          ),
        ],
      ),

      // ── Send Request FAB ─────────────────────────────────────────────
      floatingActionButton: Consumer<ConsultationRequestViewModel>(
        builder: (context, vm, _) {
          if (_checkingStatus) {
            return Container(
              height: 52,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppTheme.borderColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Center(child: CircularProgressIndicator()),
            );
          }

          if (_alreadySent) {
            return Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: FloatingActionButton.extended(
                onPressed: null,
                backgroundColor: AppTheme.borderColor,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                label: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded,
                        color: AppTheme.primaryTeal, size: 18),
                    const SizedBox(width: 10),
                    Text('Request Sent',
                        style: AppTheme.label(AppTheme.textSecondary, 16)),
                  ],
                ),
              ),
            );
          }

          return Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: FloatingActionButton.extended(
              onPressed: vm.isLoading ? null : _sendRequest,
              backgroundColor: AppTheme.primaryTeal,
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              label: vm.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Row(
                      children: [
                        const Icon(Icons.send_rounded,
                            color: Colors.white, size: 18),
                        const SizedBox(width: 10),
                        Text('Send Request',
                            style: AppTheme.label(Colors.white, 16)),
                      ],
                    ),
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

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
        border:
            Border.all(color: Colors.white.withValues(alpha: 0.25)),
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

  Widget _infoCard(
      {required String title, required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderColor),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Text(title,
                style: AppTheme.label(AppTheme.textPrimary, 15)),
          ),
          ...children,
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.primaryTeal, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: AppTheme.small(AppTheme.textTertiary, 11)),
                const SizedBox(height: 2),
                Text(value,
                    style: AppTheme.body(AppTheme.textPrimary, 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => Divider(
      height: 1,
      indent: 46,
      endIndent: 16,
      color: AppTheme.borderColor);
}
