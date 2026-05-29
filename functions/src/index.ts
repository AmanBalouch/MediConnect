import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

admin.initializeApp();
const db = admin.firestore();

export const onPendingDoctorRequestVerified = functions.firestore
  .document('pending_doctor_requests/{docId}')
  .onUpdate(async (change: functions.Change<admin.firestore.DocumentSnapshot>, context: functions.EventContext) => {
    const beforeData = change.before.exists ? (change.before.data() as admin.firestore.DocumentData) : {};
    const afterData = change.after.exists ? (change.after.data() as admin.firestore.DocumentData) : {};

    try {
      // detect transition from not-verified -> verified
      if (beforeData?.isVerified === true || afterData?.isVerified !== true) {
        // nothing to do
        functions.logger.debug('No transition to verified detected', { before: beforeData, after: afterData });
        return null;
      }

      // Normalize fields
      const normalized: any = {
        name: afterData.name || afterData.fullName || '',
        email: afterData.email || '',
        uid: afterData.uid || context.params.docId,
        pmdcLicenseNumber: afterData.pmdcLicenseNumber || afterData.pmdc || '',
        cnicNumber: afterData.cnicNumber || afterData.cnic || '',
        degree: afterData.degree || '',
        yearsOfExperience: afterData.yearsOfExperience || afterData.experience || '',
        clinicName: afterData.clinicName || '',
        clinicAddress: afterData.clinicAddress || '',
        isVerified: true,
        profileImageUrl: afterData.profileImageUrl || afterData.photoURL || null,
        rating: afterData.rating || null,
        consultationFee: afterData.consultationFee || null,
        createdAt: afterData.createdAt || admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      };

      // Specializations normalization: accept string (comma-separated) or array
      const rawSpecs = afterData.specializations ?? afterData.specialization ?? afterData.speciality ?? null;
      if (!rawSpecs) {
        normalized.specializations = [];
      } else if (Array.isArray(rawSpecs)) {
        normalized.specializations = rawSpecs.map((s: any) => String(s).trim()).filter(Boolean);
      } else if (typeof rawSpecs === 'string') {
        normalized.specializations = (rawSpecs as string)
          .split(',')
          .map((s) => s.trim())
          .filter(Boolean);
      } else {
        normalized.specializations = [];
      }

      const targetId = normalized.uid || context.params.docId;
      const targetRef = db.collection('doctors').doc(targetId);
      const pendingRef = db.collection('pending_doctor_requests').doc(context.params.docId);

      // Use transaction for idempotency and atomic create+delete
      await db.runTransaction(async (tx: admin.firestore.Transaction) => {
        const targetSnap = await tx.get(targetRef);
        if (targetSnap.exists) {
          // merge missing fields but keep existing
          tx.set(targetRef, normalized, { merge: true });
        } else {
          tx.set(targetRef, normalized, { merge: false });
        }

        // delete pending request
        tx.delete(pendingRef);
      });

      functions.logger.info('Successfully migrated pending doctor request', { docId: context.params.docId, targetId });
      return null;
    } catch (error) {
      functions.logger.error('Failed to migrate pending doctor request', { error, docId: context.params.docId });
      // write to a failed_migrations collection for manual inspection
      try {
        await db.collection('failed_migrations').doc(context.params.docId).set({
          error: String(error),
          before: beforeData,
          after: afterData,
          ts: admin.firestore.FieldValue.serverTimestamp(),
        });
      } catch (e) {
        functions.logger.error('Failed to write failed migration record', { e });
      }
      throw error;
    }
  });
