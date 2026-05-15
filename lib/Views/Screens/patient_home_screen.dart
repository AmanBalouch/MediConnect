import 'package:flutter/material.dart';
import 'package:mediconnectcode/main.dart';
import 'package:mediconnectcode/Views/Widgets/index.dart';

class PatientHomeScreen extends StatefulWidget {
  const PatientHomeScreen({super.key});

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedSpecialty = 'All';

  // Mock doctors data
  final List<Map<String, dynamic>> allDoctors = [
    {
      'name': 'Dr. Rahil Mehmood',
      'specialty': 'Cardiology',
      'experience': '8 yrs',
      'rating': 4.9,
      'fee': 'Rs.800',
      'avatar': 'RM',
      'avatarColor': 'green',
    },
    {
      'name': 'Dr. Sana Akhtar',
      'specialty': 'Neurology',
      'experience': '12 yrs',
      'rating': 4.8,
      'fee': 'Rs.1200',
      'avatar': 'SA',
      'avatarColor': 'blue',
    },
    {
      'name': 'Dr. Farhan Ali',
      'specialty': 'Dermatology',
      'experience': '5 yrs',
      'rating': 4.7,
      'fee': 'Rs.600',
      'avatar': 'FA',
      'avatarColor': 'amber',
    },
    {
      'name': 'Dr. Ayesha Khan',
      'specialty': 'Cardiology',
      'experience': '6 yrs',
      'rating': 4.6,
      'fee': 'Rs.900',
      'avatar': 'AK',
      'avatarColor': 'green',
    },
    {
      'name': 'Dr. Hassan Malik',
      'specialty': 'Orthopedic',
      'experience': '10 yrs',
      'rating': 4.8,
      'fee': 'Rs.1000',
      'avatar': 'HM',
      'avatarColor': 'blue',
    },
    {
      'name': 'Dr. Zainab Ahmed',
      'specialty': 'Neurology',
      'experience': '7 yrs',
      'rating': 4.9,
      'fee': 'Rs.1100',
      'avatar': 'ZA',
      'avatarColor': 'amber',
    },
  ];

  final List<String> specialties = [
    'All',
    'Cardiology',
    'Neurology',
    'Dermatology',
    'Orthopedic',
  ];

  late List<Map<String, dynamic>> filteredDoctors;

  @override
  void initState() {
    super.initState();
    filteredDoctors = allDoctors;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterDoctors() {
    final searchQuery = _searchController.text.toLowerCase();

    setState(() {
      filteredDoctors = allDoctors.where((doctor) {
        final matchesSearch =
            doctor['name'].toLowerCase().contains(searchQuery) ||
            doctor['specialty'].toLowerCase().contains(searchQuery);
        final matchesSpecialty =
            _selectedSpecialty == 'All' ||
            doctor['specialty'] == _selectedSpecialty;

        return matchesSearch && matchesSpecialty;
      }).toList();
    });
  }

  void _onNavTap(int index) {
    switch (index) {
      case 0:
        // Already on home
        break;
      case 1:
        // Navigate to Chat
        Navigator.pushNamed(context, '/chat');
        break;
      case 2:
        // Navigate to ChatBot (Symptom Checker)
        Navigator.pushNamed(context, '/symptom-checker');
        break;
      case 3:
        // Navigate to Settings
        Navigator.pushNamed(context, '/settings');
        break;
    }
  }

  Color _getAvatarColor(String colorCode) {
    switch (colorCode) {
      case 'green':
        return AppTheme.primaryTealLight;
      case 'blue':
        return AppTheme.primaryBlueLight;
      case 'amber':
        return AppTheme.accentAmberLight;
      default:
        return AppTheme.primaryTealLight;
    }
  }

  Color _getAvatarTextColor(String colorCode) {
    switch (colorCode) {
      case 'green':
        return AppTheme.primaryTealDark;
      case 'blue':
        return AppTheme.primaryBlueDark;
      case 'amber':
        return AppTheme.accentAmber;
      default:
        return AppTheme.primaryTealDark;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgColor,
      body: Column(
        children: [
          // Gradient Header
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Hello Patient',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        color: Colors.white,
                        fontSize: 28,
                      ),
                    ),
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          'P',
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(color: Colors.white, fontSize: 14),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Find your doctor',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 12),
                // Search Bar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => _filterDoctors(),
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search doctors, specialists...',
                      hintStyle: Theme.of(context).textTheme.labelSmall
                          ?.copyWith(
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.white.withValues(alpha: 0.7),
                        size: 18,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Specialty Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: specialties.map((specialty) {
                  final isActive = specialty == _selectedSpecialty;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedSpecialty = specialty;
                        _filterDoctors();
                      });
                    },
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
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: isActive
                              ? Colors.white
                              : AppTheme.textSecondary,
                          fontSize: 9,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          // Doctors List
          Expanded(
            child: filteredDoctors.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person_off_outlined,
                          size: 48,
                          color: AppTheme.textTertiary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No doctors found',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    itemCount: filteredDoctors.length,
                    itemBuilder: (context, index) {
                      final doctor = filteredDoctors[index];
                      return _buildDoctorCard(doctor);
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: PatientBottomNavBar(
        currentIndex: 0,
        onTap: _onNavTap,
      ),
    );
  }

  Widget _buildDoctorCard(Map<String, dynamic> doctor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(
        children: [
          // Avatar - Larger
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _getAvatarColor(doctor['avatarColor']),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                doctor['avatar'],
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: _getAvatarTextColor(doctor['avatarColor']),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Doctor Info - Larger fonts
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doctor['name'],
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${doctor['specialty']} · ${doctor['experience']} exp',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Rating and Fee - Larger
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '★ ${doctor['rating']}',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppTheme.accentAmber,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                doctor['fee'],
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppTheme.primaryTeal,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
