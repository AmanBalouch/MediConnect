import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:mediconnectcode/ViewModels/doctor_details_viewmodel.dart';
import 'package:mediconnectcode/main.dart';
import 'package:mediconnectcode/Views/Widgets/success_dialog.dart';
import 'package:mediconnectcode/Views/Widgets/error_dialog.dart';
import 'package:mediconnectcode/Utils/input_validator.dart';

class DoctorDetailsScreen extends StatefulWidget {
  const DoctorDetailsScreen({super.key});

  @override
  State<DoctorDetailsScreen> createState() => _DoctorDetailsScreenState();
}

class _DoctorDetailsScreenState extends State<DoctorDetailsScreen> {
  late TextEditingController _pmdcLicenseController;
  late TextEditingController _cnicController;
  late TextEditingController _experienceController;
  late TextEditingController _clinicNameController;
  late TextEditingController _clinicAddressController;
  String _selectedSpecialization = '';
  List<String> _selectedDegrees = [];

  String? _pmdcError;
  String? _cnicError;

  final List<String> _specializations = [
    'Neurologist',
    'Cardiologist',
    'Dermatologist',
    'Surgeon',
    'Pediatrician',
    'Psychiatrist',
    'Orthopedic',
    'General Practitioner',
    'Oncologist',
    'Urologist',
    'Other',
  ];

  final List<String> _degrees = [
    'MBBS',
    'MBBS + MD',
    'MBBS + FCPS',
    'MBBS + MD + FCPS',
    'BDS',
    'DPT',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _pmdcLicenseController = TextEditingController();
    _cnicController = TextEditingController();
    _experienceController = TextEditingController();
    _clinicNameController = TextEditingController();
    _clinicAddressController = TextEditingController();
  }

  @override
  void dispose() {
    _pmdcLicenseController.dispose();
    _cnicController.dispose();
    _experienceController.dispose();
    _clinicNameController.dispose();
    _clinicAddressController.dispose();
    super.dispose();
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SuccessDialog(
          title: 'Success',
          message: message,
          buttonLabel: 'OK',
          onButtonPressed: () {
            Navigator.of(context).pop();
            Navigator.of(context).pushReplacementNamed('/home');
          },
          icon: Icons.check_circle,
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ErrorDialog(
          title: 'Error',
          message: message,
          buttonLabel: 'OK',
          onButtonPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icons.error_outline,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primaryBlue,
        elevation: 0,
        title: Text(
          'Professional Details',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/settings');
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.settings_outlined,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Decorative gradient header
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppTheme.primaryBlue, AppTheme.primaryBlueDark],
                ),
              ),
              padding: EdgeInsets.fromLTRB(24, 20, 24, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Complete your profile',
                    style: GoogleFonts.dmSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            // Form Content
            Padding(
              padding: EdgeInsets.all(24),
              child: Consumer<DoctorDetailsViewModel>(
                builder: (context, viewModel, _) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Error Message
                      if (viewModel.errorMessage != null)
                        Container(
                          padding: EdgeInsets.all(12),
                          margin: EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: AppTheme.accentRed.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppTheme.accentRed.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: AppTheme.accentRed,
                                size: 20,
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  viewModel.errorMessage!,
                                  style: GoogleFonts.dmSans(
                                    fontSize: 13,
                                    color: AppTheme.accentRed,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      // PMDC License Number
                      Text(
                        'PMDC License Number *',
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      SizedBox(height: 8),
                      TextField(
                        controller: _pmdcLicenseController,
                        onChanged: (value) {
                          setState(() {
                            _pmdcError = InputValidator.getPMDCErrorMessage(
                              value,
                            );
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'e.g., 12345-P',
                          prefixIcon: Icon(Icons.badge_outlined),
                          errorText: _pmdcError?.isEmpty ?? true
                              ? null
                              : _pmdcError,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      // CNIC Number
                      Text(
                        'CNIC Number *',
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      SizedBox(height: 8),
                      TextField(
                        controller: _cnicController,
                        onChanged: (value) {
                          setState(() {
                            _cnicError = InputValidator.getCNICErrorMessage(
                              value,
                            );
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'e.g., 12345-1234567-1',
                          prefixIcon: Icon(Icons.card_membership_outlined),
                          errorText: _cnicError?.isEmpty ?? true
                              ? null
                              : _cnicError,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      // Specialization Dropdown
                      Text(
                        'Specialization *',
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedSpecialization.isEmpty
                            ? null
                            : _selectedSpecialization,
                        decoration: InputDecoration(
                          hintText: 'Select Specialization',
                          prefixIcon: Icon(Icons.medical_services_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        items: _specializations.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedSpecialization = newValue ?? '';
                          });
                        },
                      ),
                      SizedBox(height: 20),
                      // Qualification Degrees
                      Text(
                        'Qualification Degrees *',
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: AppTheme.borderColor),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: _degrees.map((degree) {
                            return CheckboxListTile(
                              title: Text(
                                degree,
                                style: GoogleFonts.dmSans(
                                  fontSize: 13,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              value: _selectedDegrees.contains(degree),
                              onChanged: (bool? value) {
                                setState(() {
                                  if (value == true) {
                                    _selectedDegrees.add(degree);
                                  } else {
                                    _selectedDegrees.remove(degree);
                                  }
                                });
                              },
                              controlAffinity: ListTileControlAffinity.leading,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      SizedBox(height: 20),
                      // Years of Experience
                      Text(
                        'Years of Experience *',
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      SizedBox(height: 8),
                      TextField(
                        controller: _experienceController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'e.g., 5',
                          prefixIcon: Icon(Icons.history_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      // Clinic Name
                      Text(
                        'Clinic/Hospital Name',
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      SizedBox(height: 8),
                      TextField(
                        controller: _clinicNameController,
                        decoration: InputDecoration(
                          hintText: 'Enter clinic or hospital name',
                          prefixIcon: Icon(Icons.business_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      // Clinic Address
                      Text(
                        'Clinic Address',
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      SizedBox(height: 8),
                      TextField(
                        controller: _clinicAddressController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Enter clinic address',
                          prefixIcon: Padding(
                            padding: EdgeInsets.only(top: 12),
                            child: Icon(Icons.location_on_outlined),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                      SizedBox(height: 32),
                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryBlue,
                            padding: EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: viewModel.isLoading
                              ? null
                              : () async {
                                  final result = await viewModel
                                      .saveDoctorDetails(
                                        pmdcLicense: _pmdcLicenseController.text
                                            .trim(),
                                        cnicNumber: _cnicController.text.trim(),
                                        specialization: _selectedSpecialization,
                                        degree: _selectedDegrees.join(', '),
                                        experience: _experienceController.text
                                            .trim(),
                                        clinicName: _clinicNameController.text
                                            .trim(),
                                        clinicAddress: _clinicAddressController
                                            .text
                                            .trim(),
                                      );

                                  if (result) {
                                    _showSuccessDialog(
                                      'Your professional details have been saved successfully!',
                                    );
                                  } else if (viewModel.errorMessage != null) {
                                    _showErrorDialog(
                                      viewModel.errorMessage ??
                                          'An error occurred',
                                    );
                                  }
                                },
                          child: viewModel.isLoading
                              ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : Text(
                                  'Complete Profile',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
