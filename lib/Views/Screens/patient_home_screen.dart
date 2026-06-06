import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mediconnectcode/ViewModels/login_viewmodel.dart';
import 'package:mediconnectcode/ViewModels/patient_home_viewmodel.dart';
import 'package:mediconnectcode/Models/doctor_model.dart';
import 'package:mediconnectcode/main.dart';
import 'package:mediconnectcode/Views/Widgets/index.dart';
import 'package:mediconnectcode/Views/Screens/doctor_profile_screen.dart';

class PatientHomeScreen extends StatefulWidget {
  const PatientHomeScreen({super.key});

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  late Future<String?> _currentUserNameFuture;
  bool _initializedNameFuture = false;

  @override
  void initState() {
    super.initState();
    // Fetch doctors from Firebase when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PatientHomeViewModel>().fetchDoctors();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initializedNameFuture) {
      _currentUserNameFuture =
          context.read<LoginViewModel>().getCurrentUserName();
      _initializedNameFuture = true;
    }
  }

  void _onNavTap(int index) {
    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.pushNamed(context, '/chat');
        break;
      case 2:
        Navigator.pushNamed(context, '/symptom-checker');
        break;
      case 3:
        Navigator.pushNamed(context, '/settings');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PatientHomeViewModel>(
      builder: (context, vm, child) {
        return Scaffold(
          backgroundColor: AppTheme.bgColor,
          bottomNavigationBar: AppBottomNavBar(currentIndex: 0, onTap: _onNavTap),
          body: Column(
            children: [
              // ── Gradient Header ────────────────────────────────────────
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
                  14,
                  MediaQuery.of(context).padding.top + 16,
                  14,
                  16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Greeting row with avatar
                    FutureBuilder<String?>(
                      future: _currentUserNameFuture,
                      builder: (context, snapshot) {
                        final displayName =
                            snapshot.data?.trim().isNotEmpty == true
                                ? snapshot.data!.trim()
                                : 'Patient';
                        final initials = displayName
                            .split(' ')
                            .where((p) => p.isNotEmpty)
                            .take(2)
                            .map((p) => p[0].toUpperCase())
                            .join();

                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Hello,',
                                    style: AppTheme.body(Colors.white70, 16),
                                  ),
                                  Text(
                                    displayName,
                                    style: AppTheme.heading(Colors.white, 24),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Avatar — same style as doctor home
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.4),
                                  width: 2,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  initials.isNotEmpty ? initials : 'P',
                                  style: AppTheme.label(Colors.white, 16),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 12),
                    Text(
                      'Find your doctor',
                      style: AppTheme.heading(Colors.white, 20),
                    ),
                    const SizedBox(height: 12),

                    // Search bar
                    TextField(
                      controller: _searchController,
                      onChanged: (query) => vm.filterDoctors(query),
                      style: AppTheme.body(AppTheme.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Search doctors, specialists...',
                        hintStyle: AppTheme.small(AppTheme.textTertiary),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: AppTheme.textTertiary,
                          size: 18,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Fee filter chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: PatientHomeViewModel.feeRanges.map((range) {
                          final isActive = range == vm.selectedFeeRange;
                          return GestureDetector(
                            onTap: () => vm.setFeeRange(range),
                            child: Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: isActive
                                    ? Colors.white
                                    : Colors.white.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.4),
                                ),
                              ),
                              child: Text(
                                range,
                                style: AppTheme.small(
                                  isActive
                                      ? AppTheme.primaryTealDark
                                      : Colors.white,
                                  11,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Specialty Filter Chips ─────────────────────────────────
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(
                    children: vm.getSpecialties().map((specialty) {
                      final isActive = specialty == vm.selectedSpecialty;
                      return GestureDetector(
                        onTap: () => vm.setSpecialty(specialty),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isActive
                                ? AppTheme.primaryTeal
                                : AppTheme.cardColor,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppTheme.borderColor),
                          ),
                          child: Text(
                            specialty,
                            style: AppTheme.small(
                              isActive ? Colors.white : AppTheme.textSecondary,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              // ── Doctors List ───────────────────────────────────────────
              Expanded(
                child: _buildDoctorList(vm),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDoctorList(PatientHomeViewModel vm) {
    // Loading state (first load only)
    if (vm.isLoading && vm.allDoctors.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // Error state
    if (vm.errorMessage != null && vm.allDoctors.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => vm.fetchDoctors(),
        color: AppTheme.primaryTeal,
        child: ListView(
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.25),
            Column(
              children: [
                Icon(Icons.wifi_off_outlined, size: 48, color: AppTheme.textTertiary),
                const SizedBox(height: 12),
                Text(vm.errorMessage!, style: AppTheme.body(AppTheme.textSecondary)),
                const SizedBox(height: 8),
                Text(
                  'Pull down to retry',
                  style: AppTheme.small(AppTheme.textTertiary),
                ),
              ],
            ),
          ],
        ),
      );
    }

    // Empty state
    if (vm.filteredDoctors.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => vm.fetchDoctors(),
        color: AppTheme.primaryTeal,
        child: ListView(
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.25),
            Column(
              children: [
                Icon(Icons.person_off_outlined, size: 48, color: AppTheme.textTertiary),
                const SizedBox(height: 12),
                Text('No doctors found', style: AppTheme.body(AppTheme.textSecondary)),
                const SizedBox(height: 8),
                Text('Pull down to refresh', style: AppTheme.small(AppTheme.textTertiary)),
              ],
            ),
          ],
        ),
      );
    }

    // Doctors list — pull down to refresh
    return RefreshIndicator(
      onRefresh: () => vm.fetchDoctors(),
      color: AppTheme.primaryTeal,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        itemCount: vm.filteredDoctors.length,
        itemBuilder: (context, index) {
          final doctor = vm.filteredDoctors[index];
          final color = vm.getAvatarColor(index, context);
          return _buildDoctorCard(doctor, color, vm);
        },
      ),
    );
  }

  Widget _buildDoctorCard(DoctorModel doctor, Color avatarColor, PatientHomeViewModel vm) {
    final initials = vm.getInitials(doctor.name);
    final specialty = doctor.specializations.isNotEmpty
        ? doctor.specializations.first
        : 'General';
    final experience = doctor.yearsOfExperience.isNotEmpty
        ? '${doctor.yearsOfExperience} yrs exp'
        : '';
    final fee = doctor.consultationFee != null
        ? 'Rs.${doctor.consultationFee}'
        : 'Fee N/A';
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DoctorProfileScreen(
            doctor: doctor,
            avatarColor: avatarColor,
          ),
        ),
      ),
      child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: avatarColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(initials, style: AppTheme.label(avatarColor)),
            ),
          ),
          const SizedBox(width: 14),

          // Doctor info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doctor.name ?? 'Unknown Doctor',
                  style: AppTheme.body(AppTheme.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  experience.isNotEmpty ? '$specialty · $experience' : specialty,
                  style: AppTheme.small(AppTheme.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Fee and Patient Count
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(fee, style: AppTheme.label(AppTheme.primaryTeal)),
              const SizedBox(height: 4),
              Text(
                '${doctor.patientChecked} patients',
                style: AppTheme.small(AppTheme.textTertiary),
              ),
            ],
          ),
        ],
      ),
    ),
    );
  }
}
