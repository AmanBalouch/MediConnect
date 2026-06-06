import 'package:flutter/material.dart';
import 'package:mediconnectcode/main.dart';

class AllPendingRequestsScreen extends StatefulWidget {
  const AllPendingRequestsScreen({super.key});

  @override
  State<AllPendingRequestsScreen> createState() =>
      _AllPendingRequestsScreenState();
}

class _AllPendingRequestsScreenState extends State<AllPendingRequestsScreen> {
  final TextEditingController _searchController = TextEditingController();

  // All requests (replace with Firestore later)
  final List<Map<String, dynamic>> _allRequests = [
    {'name': 'Ayesha Malik',  'note': 'Chest pain, shortness of breath'},
    {'name': 'Zain Khan',     'note': 'Palpitations, dizziness'},
    {'name': 'Sara Ahmed',    'note': 'Fever and sore throat for 3 days'},
    {'name': 'Omar Farooq',   'note': 'Back pain, difficulty walking'},
    {'name': 'Hina Baig',     'note': 'Skin rash on arms and neck'},
    {'name': 'Bilal Hussain', 'note': 'Headache and blurred vision'},
    {'name': 'Nadia Qureshi', 'note': 'Stomach cramps and nausea'},
    {'name': 'Hamza Sheikh',  'note': 'Joint pain, swollen knees'},
  ];

  List<Map<String, dynamic>> _filtered = [];

  final List<Color> _colors = [
    AppTheme.primaryTeal,
    AppTheme.primaryBlue,
    AppTheme.accentAmber,
    AppTheme.primaryTealDark,
    AppTheme.primaryBlueDark,
  ];

  @override
  void initState() {
    super.initState();
    _filtered = _allRequests;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    setState(() {
      if (query.trim().isEmpty) {
        _filtered = _allRequests;
      } else {
        _filtered = _allRequests.where((req) {
          final name = (req['name'] ?? '').toLowerCase();
          final note = (req['note'] ?? '').toLowerCase();
          return name.contains(query.toLowerCase()) ||
              note.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryBlue,
        elevation: 0,
        title: Text('Pending Requests', style: AppTheme.label(Colors.white, 16)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Search bar (attached to appbar)
          Container(
            color: AppTheme.primaryBlue,
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 16),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearch,
              style: AppTheme.body(AppTheme.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search by name or symptom...',
                hintStyle: AppTheme.small(AppTheme.textTertiary),
                prefixIcon: const Icon(Icons.search, color: Colors.white54, size: 20),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Results count
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${_filtered.length} request${_filtered.length == 1 ? '' : 's'}',
                style: AppTheme.small(AppTheme.textSecondary),
              ),
            ),
          ),

          // List
          Expanded(
            child: _filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 48, color: AppTheme.textTertiary),
                        const SizedBox(height: 12),
                        Text('No results found', style: AppTheme.body(AppTheme.textTertiary)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(14, 4, 14, 24),
                    itemCount: _filtered.length,
                    itemBuilder: (context, index) {
                      final req = _filtered[index];
                      final color = _colors[index % _colors.length];
                      return _buildCard(req['name'], req['note'], color);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(String? name, String? note, Color color) {
    final patientName = (name == null || name.trim().isEmpty) ? 'Patient' : name.trim();
    final patientNote = (note == null || note.trim().isEmpty) ? 'Needs consultation review' : note.trim();
    final initials = patientName
        .split(' ')
        .where((w) => w.isNotEmpty)
        .take(2)
        .map((w) => w[0].toUpperCase())
        .join();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Row(
        children: [
          // Left accent bar
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

          // Avatar
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

          // Name and note
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
              child: Text('Accept', style: AppTheme.small(Colors.white, 11)),
            ),
          ),
        ],
      ),
    );
  }
}
