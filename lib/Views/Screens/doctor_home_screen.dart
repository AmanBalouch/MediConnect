import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mediconnectcode/ViewModels/login_viewmodel.dart';
import 'package:mediconnectcode/main.dart';
import 'package:mediconnectcode/Views/Widgets/app_bottom_nav_bar.dart';

class DoctorHomeScreen extends StatefulWidget {
  const DoctorHomeScreen({super.key});

  @override
  State<DoctorHomeScreen> createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends State<DoctorHomeScreen> {
  late Future<DoctorAccessState> _doctorStateFuture;

  @override
  void initState() {
    super.initState();
    _doctorStateFuture = _loadDoctorState();
  }

  Future<DoctorAccessState> _loadDoctorState() {
    return context.read<LoginViewModel>().getDoctorAccessState();
  }

  void _refreshState() {
    setState(() {
      _doctorStateFuture = _loadDoctorState();
    });
  }

  void _goToDoctorDetails() {
    Navigator.pushNamed(context, '/doctor-details');
  }

  void _onNavTap(int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/doctor-home');
        break;
      case 1:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Chat screen not implemented yet')),
        );
        break;
      case 2:
        Navigator.pushNamed(context, '/symptom-checker');
        break;
      case 3:
        Navigator.pushNamed(context, '/settings');
        break;
    }
  }

  Widget _buildStatusCard({
    required Color color,
    required IconData icon,
    required String title,
    required String message,
    required List<Widget> actions,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.18)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
          if (actions.isNotEmpty) ...[
            const SizedBox(height: 20),
            Wrap(spacing: 12, runSpacing: 12, children: actions),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required VoidCallback onPressed,
    bool filled = true,
  }) {
    if (filled) {
      return ElevatedButton(onPressed: onPressed, child: Text(label));
    }

    return OutlinedButton(onPressed: onPressed, child: Text(label));
  }

  Widget _buildSimpleStateUI({
    required String title,
    required String subtitle,
    required String message,
    required Color color,
    required IconData icon,
    required String primaryButtonLabel,
    required VoidCallback primaryButtonAction,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [color, AppTheme.primaryBlueDark],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Doctor Home',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.82),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildStatusCard(
            color: color,
            icon: icon,
            title: title,
            message: message,
            actions: [
              _buildActionButton(
                label: 'Refresh status',
                onPressed: _refreshState,
                filled: false,
              ),
              _buildActionButton(
                label: primaryButtonLabel,
                onPressed: primaryButtonAction,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Approved doctor UI inspired by mediconnect_mobile_ui_template.html
  Widget _approvedDoctorUI() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Gradient header
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppTheme.primaryBlue, AppTheme.primaryBlueDark],
            ),
          ),
          padding: EdgeInsets.fromLTRB(
            16,
            MediaQuery.of(context).padding.top + 12,
            16,
            16,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Doctor Dashboard',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Dr. Your Name',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white.withValues(alpha: 0.18),
                ),
                child: Center(
                  child: Text(
                    'DR',
                    style: Theme.of(
                      context,
                    ).textTheme.labelLarge?.copyWith(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),
        // Stats row
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlueLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '12',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: AppTheme.primaryBlueDark,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Today\'s appts',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(left: 8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryTealLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rs.9.6K',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: AppTheme.primaryTealDark,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Earnings',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),
        // Pending requests header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Pending requests',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            TextButton(onPressed: () {}, child: const Text('View all →')),
          ],
        ),

        // Example pending cards
        Column(
          children: [
            _pendingCard(
              'Ayesha Malik',
              'Chest pain, shortness of breath',
              AppTheme.primaryTeal,
            ),
            const SizedBox(height: 8),
            _pendingCard(
              'Zain Khan',
              'Palpitations, dizziness',
              AppTheme.primaryBlue,
            ),
          ],
        ),

        const SizedBox(height: 16),
        Text(
          'Today\'s schedule',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Column(
          children: [
            _scheduleCard('10:00 AM — Ayesha M.', 'Cardiology consult', true),
            const SizedBox(height: 8),
            _scheduleCard('2:00 PM — Zain K.', 'Follow-up', false),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _pendingCard(String name, String note, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: color.withValues(alpha: 0.12),
            ),
            child: Center(
              child: Text(
                name.split(' ').map((e) => e[0]).take(2).join(),
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(note, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Accept',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _scheduleCard(String title, String subtitle, bool joinable) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: joinable ? AppTheme.primaryTealLight : const Color(0xFFF3F4F6),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: joinable
                      ? AppTheme.primaryTealDark
                      : AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: joinable ? AppTheme.primaryTeal : AppTheme.borderColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              joinable ? '💬 Join' : 'Pending',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: joinable ? Colors.white : AppTheme.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBodyForState(DoctorAccessState state) {
    switch (state) {
      case DoctorAccessState.approved:
        return _approvedDoctorUI();
      case DoctorAccessState.pendingReview:
        return _buildSimpleStateUI(
          title: 'Review in progress',
          subtitle: 'Your request is pending',
          message:
              'Your request is pending. Admin review is still in progress, so please wait for approval.',
          color: Colors.orange,
          icon: Icons.hourglass_top_rounded,
          primaryButtonLabel: 'Edit details',
          primaryButtonAction: _goToDoctorDetails,
        );
      case DoctorAccessState.changesRequested:
        return _buildSimpleStateUI(
          title: 'Changes requested',
          subtitle: 'Please update your profile',
          message:
              'Admin requested changes to your profile. Please update your details and submit them again.',
          color: Colors.red,
          icon: Icons.edit_note_rounded,
          primaryButtonLabel: 'Update details',
          primaryButtonAction: _goToDoctorDetails,
        );
      case DoctorAccessState.firstLogin:
        return _buildSimpleStateUI(
          title: 'Complete your profile',
          subtitle: 'Start your first request',
          message:
              'We could not find a doctor request for this account yet. Please fill in your professional details to submit your first request.',
          color: AppTheme.primaryBlue,
          icon: Icons.assignment_ind_rounded,
          primaryButtonLabel: 'Start details form',
          primaryButtonAction: _goToDoctorDetails,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      body: SafeArea(
        child: FutureBuilder<DoctorAccessState>(
          future: _doctorStateFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Padding(
                padding: const EdgeInsets.all(24),
                child: _buildStatusCard(
                  color: AppTheme.accentRed,
                  icon: Icons.error_outline_rounded,
                  title: 'Unable to load status',
                  message:
                      'We could not check your doctor approval state right now. Please try again.',
                  actions: [
                    _buildActionButton(
                      label: 'Try again',
                      onPressed: _refreshState,
                    ),
                  ],
                ),
              );
            }

            final state = snapshot.data ?? DoctorAccessState.firstLogin;

            return RefreshIndicator(
              onRefresh: () async => _refreshState(),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                children: [_buildBodyForState(state)],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(currentIndex: 0, onTap: _onNavTap),
    );
  }
}
