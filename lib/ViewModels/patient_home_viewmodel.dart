import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mediconnectcode/Models/doctor_model.dart';

class PatientHomeViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // State
  bool isLoading = false;
  String? errorMessage;
  List<DoctorModel> allDoctors = [];
  List<DoctorModel> filteredDoctors = [];
  String selectedSpecialty = 'All';
  String selectedFeeRange = 'Any';

  static const List<String> feeRanges = [
    'Any',
    'Under Rs.500',
    'Rs.500–1000',
    'Rs.1000–2000',
    'Above Rs.2000',
  ];

  // Fetch all doctors from Firestore
  Future<void> fetchDoctors() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final snapshot = await _firestore.collection('doctors').get();

      allDoctors = snapshot.docs.map((doc) {
        return DoctorModel.fromMap(doc.data(), doc.id);
      }).toList();

      filteredDoctors = allDoctors;
    } catch (e) {
      errorMessage = 'Could not load doctors. Please try again.';
    }

    isLoading = false;
    notifyListeners();
  }

  // Filter by search text, specialty, and fee range
  void filterDoctors(String searchQuery) {
    filteredDoctors = allDoctors.where((doctor) {
      // Check specialty filter
      final matchesSpecialty = selectedSpecialty == 'All' ||
          doctor.specializations.any(
            (s) => s.toLowerCase() == selectedSpecialty.toLowerCase(),
          );

      // Check search text
      final name = (doctor.name ?? '').toLowerCase();
      final specs = doctor.specializations.join(' ').toLowerCase();
      final matchesSearch = searchQuery.trim().isEmpty ||
          name.contains(searchQuery.toLowerCase()) ||
          specs.contains(searchQuery.toLowerCase());

      // Check fee range
      final fee = doctor.consultationFee;
      final matchesFee = _matchesFeeRange(fee, selectedFeeRange);

      return matchesSpecialty && matchesSearch && matchesFee;
    }).toList();

    notifyListeners();
  }

  bool _matchesFeeRange(int? fee, String range) {
    if (range == 'Any') return true;
    if (fee == null) return false;
    switch (range) {
      case 'Under Rs.500':
        return fee < 500;
      case 'Rs.500–1000':
        return fee >= 500 && fee <= 1000;
      case 'Rs.1000–2000':
        return fee > 1000 && fee <= 2000;
      case 'Above Rs.2000':
        return fee > 2000;
      default:
        return true;
    }
  }

  // Change specialty filter
  void setSpecialty(String specialty) {
    selectedSpecialty = specialty;
    filterDoctors('');
  }

  // Change fee range filter
  void setFeeRange(String range) {
    selectedFeeRange = range;
    filterDoctors('');
  }

  // Get unique specialties from all doctors (for filter chips)
  List<String> getSpecialties() {
    final Set<String> specs = {'All'};
    for (final doctor in allDoctors) {
      for (final s in doctor.specializations) {
        if (s.isNotEmpty) specs.add(s);
      }
    }
    return specs.toList();
  }

  // Get initials from doctor name
  String getInitials(String? name) {
    if (name == null || name.trim().isEmpty) return 'DR';
    return name
        .trim()
        .split(' ')
        .where((w) => w.isNotEmpty)
        .take(2)
        .map((w) => w[0].toUpperCase())
        .join();
  }

  // Cycle through avatar colors by index
  Color getAvatarColor(int index, BuildContext context) {
    const colors = [
      Color(0xFF1D9E75), // teal
      Color(0xFF378ADD), // blue
      Color(0xFFBA7517), // amber
      Color(0xFF0F6E56), // dark teal
      Color(0xFF185FA5), // dark blue
    ];
    return colors[index % colors.length];
  }
}
