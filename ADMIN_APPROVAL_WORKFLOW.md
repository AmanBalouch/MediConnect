/// Firebase Admin Approval Workflow Documentation
///
/// This file explains how the doctor verification process works with Firestore
///
/// FLOW:
/// ============================================
/// 1. Doctor fills details → Saved to 'pending_doctor_requests' collection
/// 2. Admin reviews in Firebase Console
/// 3. Admin approves → Changes 'status' field from 'pending' to 'approved'
/// 4. Cloud Function triggers → Moves data to 'doctors' collection
/// 5. Cloud Function removes from 'pending_doctor_requests'
/// 6. Doctor now has access to doctor features
///
/// ============================================
/// APP ROUTING RULES (used by login/home screens)
/// ============================================
///
/// - doctors/{uid} exists and pending_doctor_requests/{uid} does NOT exist
///   → approved doctor, send to '/doctor-home'
/// - pending_doctor_requests/{uid} exists and doctors/{uid} does NOT exist
///   → request is pending, send to '/doctor-home' and show pending message
/// - BOTH documents exist
///   → admin asked for changes, send to '/doctor-home' and show update prompt
/// - NEITHER document exists
///   → first login, send to '/doctor-details' to complete the profile
///
/// ============================================
/// FIREBASE COLLECTIONS STRUCTURE
/// ============================================
///
/// Collection: pending_doctor_requests
/// └─ Document: {uid}
///    ├─ uid: string (user ID)
///    ├─ pmdcLicenseNumber: string (e.g., "12345-P")
///    ├─ cnicNumber: string (e.g., "12345-1234567-1")
///    ├─ specialization: string (e.g., "Neurologist")
///    ├─ degree: string (e.g., "MBBS, MD, FCPS")
///    ├─ yearsOfExperience: string (e.g., "5")
///    ├─ clinicName: string (optional)
///    ├─ clinicAddress: string (optional)
///    ├─ createdAt: timestamp
///    ├─ updatedAt: timestamp
///    ├─ isVerified: boolean (false)
///    ├─ status: string ("pending" | "approved" | "rejected")
///    └─ requestSubmittedAt: timestamp
///
/// Collection: doctors (after approval)
/// └─ Document: {uid}
///    ├─ uid: string (user ID)
///    ├─ pmdcLicenseNumber: string
///    ├─ cnicNumber: string
///    ├─ specialization: string
///    ├─ degree: string
///    ├─ yearsOfExperience: string
///    ├─ clinicName: string
///    ├─ clinicAddress: string
///    ├─ createdAt: timestamp
///    ├─ updatedAt: timestamp
///    └─ isVerified: boolean (true after approval)
///
/// ============================================
/// ADMIN APPROVAL STEPS IN FIREBASE CONSOLE
/// ============================================
///
/// STEP 1: Navigate to pending_doctor_requests collection
/// - Go to Firebase Console → Firestore Database
/// - Click on 'pending_doctor_requests' collection
/// - Review the doctor's details
///
/// STEP 2: Approve the request
/// - Click on the document (uid)
/// - Find the 'status' field
/// - Change value from "pending" to "approved"
/// - Click 'Update' or press Enter
///
/// STEP 3: Cloud Function handles the rest
/// - A Cloud Function will be triggered on this update
/// - It copies all fields to 'doctors' collection
/// - It deletes from 'pending_doctor_requests'
/// - Doctor's user role is updated (if needed)
///
/// STEP 4: Reject request (optional)
/// - If you want to reject, change status to "rejected"
/// - Document stays in pending_doctor_requests
/// - Doctor can resubmit after fixing issues
///
/// ============================================
/// CLOUD FUNCTION CODE (to be deployed)
/// ============================================
/// 
/// This Cloud Function should be created in Firebase Console:
/// 
/// const functions = require('firebase-functions');
/// const admin = require('firebase-admin');
/// 
/// admin.initializeApp();
/// const db = admin.firestore();
/// 
/// exports.approveDoctorRequest = functions.firestore
///   .document('pending_doctor_requests/{uid}')
///   .onUpdate(async (change, context) => {
///     const uid = context.params.uid;
///     const newData = change.after.data();
///     const oldData = change.before.data();
///     
///     // Check if status changed to 'approved'
///     if (oldData.status !== 'approved' && newData.status === 'approved') {
///       try {
///         // Copy all doctor details to 'doctors' collection
///         await db.collection('doctors').doc(uid).set({
///           uid: newData.uid,
///           pmdcLicenseNumber: newData.pmdcLicenseNumber,
///           cnicNumber: newData.cnicNumber,
///           specialization: newData.specialization,
///           degree: newData.degree,
///           yearsOfExperience: newData.yearsOfExperience,
///           clinicName: newData.clinicName || null,
///           clinicAddress: newData.clinicAddress || null,
///           createdAt: newData.createdAt,
///           updatedAt: admin.firestore.FieldValue.serverTimestamp(),
///           isVerified: true, // Mark as verified
///           approvedAt: admin.firestore.FieldValue.serverTimestamp(),
///         });
///         
///         // Delete from pending_doctor_requests
///         await db.collection('pending_doctor_requests').doc(uid).delete();
///         
///         // Update user document (optional)
///         await db.collection('users').doc(uid).update({
///           doctorDetailsCompleted: true,
///           // role: 1 (already set by user during signup)
///         });
///         
///         console.log(`Doctor ${uid} approved successfully`);
///       } catch (error) {
///         console.error('Error approving doctor:', error);
///       }
///     }
///   });
///
/// ============================================
/// TESTING THE WORKFLOW
/// ============================================
///
/// 1. Run app and fill doctor details as a doctor user
/// 2. Check Firebase Console → pending_doctor_requests
/// 3. Find the doctor's document
/// 4. Change status from "pending" to "approved"
/// 5. Cloud Function runs automatically
/// 6. Check Firebase Console → doctors (document should appear)
/// 7. Check pending_doctor_requests (document should be deleted)
/// 8. Doctor now has access to doctor-only features
///
/// ============================================
/// REJECTION WORKFLOW
/// ============================================
///
/// If you want to reject a doctor's request:
///
/// 1. Find the pending_doctor_requests document
/// 2. Change status from "pending" to "rejected"
/// 3. Add a field 'rejectionReason' with the reason
/// 4. Doctor should be notified (implement notification later)
/// 5. Doctor can resubmit after fixing issues
///
/// ============================================
