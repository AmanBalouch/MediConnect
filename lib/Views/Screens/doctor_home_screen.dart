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
  late Future<String?> _currentUserNameFuture;
  bool _initializedNameFuture = false;

  @override
  void initState() {
    super.initState();
    _doctorStateFuture = _loadDoctorState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initializedNameFuture) {
      _currentUserNameFuture = context
          .read<LoginViewModel>()
          .getCurrentUserName();
      _initializedNameFuture = true;
    }
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

  // TODO: Firestore integration - temporarily using hardcoded data for UI development

  Widget _buildUserHeader() {
    return FutureBuilder<String?>(
      future: _currentUserNameFuture,
      builder: (context, snapshot) {
        final displayName = snapshot.data?.trim().isNotEmpty == true
            ? snapshot.data!.trim()
            : 'Doctor';
        final initials = displayName
            .split(' ')
            .where((part) => part.isNotEmpty)
            .take(2)
            .map((part) => part[0].toUpperCase())
            .join();

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Doctor Dashboard',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                    // fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  displayName,
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: Colors.white,
                    // fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(9),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.4),
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  initials.isNotEmpty ? initials : 'DR',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
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
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
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

  Widget _approvedDoctorUI() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(
            14,
            MediaQuery.of(context).padding.top + 18,
            14,
            22,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.primaryBlueDark,
                AppTheme.primaryBlue,
                AppTheme.primaryBlue,
              ],
            ),
          ),
          child: _buildUserHeader(),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryTealLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '12',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              color: AppTheme.primaryTealDark,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Today\'s appts',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                          fontSize: 8.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlueLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rs.9.6K',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              color: AppTheme.primaryBlueDark,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Earnings',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                          fontSize: 8.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pending requests',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(
                'View all →',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.primaryBlueDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
          child: Column(
            children: [
              _pendingCard(
                'Ayesha Malik',
                'Chest pain, shortness of breath',
                AppTheme.primaryTeal,
              ),
              _pendingCard(
                'Zain Khan',
                'Palpitations, dizziness',
                AppTheme.primaryBlue,
              ),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(14, 2, 14, 0),
          child: Text(
            'Today\'s schedule',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
          child: Column(
            children: [
              _scheduleCard('10:00 AM — Ayesha M.', 'Cardiology consult', true),
              _scheduleCard('2:00 PM — Zain K.', 'Follow-up', false),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _pendingCard(String? name, String? note, Color color) {
    final safeName = (name ?? '').trim().isEmpty ? 'Patient' : name!.trim();
    final safeNote = (note ?? '').trim().isEmpty
        ? 'Needs consultation review'
        : note!.trim();
    final initials = safeName
        .split(' ')
        .where((e) => e.isNotEmpty)
        .map((e) => e[0])
        .take(2)
        .join()
        .toUpperCase();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border(
          left: BorderSide(color: color, width: 4),
          top: BorderSide(color: AppTheme.borderColor, width: 1),
          right: BorderSide(color: AppTheme.borderColor, width: 1),
          bottom: BorderSide(color: AppTheme.borderColor, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: color.withValues(alpha: 0.15),
            ),
            child: Center(
              child: Text(
                initials.isEmpty ? 'P' : initials,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: color,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  safeName,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1a1a2e),
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  safeNote,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6b7280),
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Accept',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 9,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _scheduleCard(String title, String subtitle, bool joinable) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
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
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: joinable
                      ? AppTheme.primaryTealDark
                      : AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 8.5,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: joinable ? AppTheme.primaryTeal : AppTheme.borderColor,
              borderRadius: BorderRadius.circular(7),
            ),
            child: Text(
              joinable ? '💬 Join' : 'Pending',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: joinable ? Colors.white : AppTheme.textSecondary,
                fontSize: 8,
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
      body: FutureBuilder<DoctorAccessState>(
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
      bottomNavigationBar: AppBottomNavBar(currentIndex: 0, onTap: _onNavTap),
    );
  }
}
