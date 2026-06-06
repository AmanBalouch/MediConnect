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

  // Mock pending requests data (replace with Firestore later)
  final List<Map<String, dynamic>> _allPendingRequests = [
    {'name': 'Ayesha Malik',   'note': 'Chest pain, shortness of breath', 'color': null},
    {'name': 'Zain Khan',      'note': 'Palpitations, dizziness',          'color': null},
    {'name': 'Sara Ahmed',     'note': 'Fever and sore throat for 3 days', 'color': null},
    {'name': 'Omar Farooq',    'note': 'Back pain, difficulty walking',    'color': null},
    {'name': 'Hina Baig',      'note': 'Skin rash on arms and neck',       'color': null},
    {'name': 'Bilal Hussain',  'note': 'Headache and blurred vision',      'color': null},
  ];

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
                  style: AppTheme.heading(Colors.white70, 20),
                ),
                const SizedBox(height: 3),
                Text(
                  displayName,
                  style: AppTheme.heading(Colors.white, 26),
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
                  style: AppTheme.label(Colors.white),
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
                  style: AppTheme.label(AppTheme.textPrimary, 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: AppTheme.body(AppTheme.textSecondary),
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
                  style: AppTheme.small(Colors.white, 12),
                ),
                const SizedBox(height: 6),
                Text(
                  title,
                  style: AppTheme.heading(Colors.white, 26),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: AppTheme.small(Colors.white, 12),
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
                        style: AppTheme.label(AppTheme.primaryTealDark, 15),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Today\'s appts',
                        style: AppTheme.small(AppTheme.textSecondary),
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
                        style: AppTheme.label(AppTheme.primaryBlueDark, 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Earnings',
                        style: AppTheme.small(AppTheme.textSecondary),
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
              Text('Pending requests', style: AppTheme.label(AppTheme.textPrimary, 16)),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/pending-requests'),
                child: Text('View all →', style: AppTheme.label(AppTheme.primaryBlueDark, 16)),
              ),
            ],
          ),
        ),

        // Show max 3 requests on home screen
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
          child: Column(
            children: _allPendingRequests.take(3).toList().asMap().entries.map((entry) {
              final colors = [AppTheme.primaryTeal, AppTheme.primaryBlue, AppTheme.accentAmber];
              final req = entry.value;
              return _pendingCard(
                req['name'],
                req['note'],
                colors[entry.key % colors.length],
              );
            }).toList(),
          ),
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(14, 2, 14, 0),
          child: Text(
            'Today\'s schedule',
            style: AppTheme.label(AppTheme.textPrimary, 16),
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
    // Make sure name and note are never empty
    final patientName = (name == null || name.trim().isEmpty) ? 'Patient' : name.trim();
    final patientNote = (note == null || note.trim().isEmpty) ? 'Needs consultation review' : note.trim();

    // Get initials from name (e.g. "Ayesha Malik" → "AM")
    final initials = patientName
        .split(' ')
        .where((word) => word.isNotEmpty)
        .take(2)
        .map((word) => word[0].toUpperCase())
        .join();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Colored left accent bar
          Container(
            width: 5,
            height: 72,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                bottomLeft: Radius.circular(14),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Avatar circle with initials
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.15),
            ),
            child: Center(
              child: Text(
                initials.isEmpty ? 'P' : initials,
                style: AppTheme.label(color),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Patient name and symptoms
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  patientName,
                  style: AppTheme.body(AppTheme.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  patientNote,
                  style: AppTheme.small(AppTheme.textSecondary, 11),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // Accept button
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Accept',
                style: AppTheme.small(Colors.white, 11),
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
                style: AppTheme.body(joinable ? AppTheme.primaryTealDark : AppTheme.textPrimary),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: AppTheme.small(AppTheme.textSecondary),
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
              style: AppTheme.small(joinable ? Colors.white : AppTheme.textSecondary),
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

