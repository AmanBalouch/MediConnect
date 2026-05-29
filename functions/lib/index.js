"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.onPendingDoctorRequestVerified = void 0;
const functions = __importStar(require("firebase-functions"));
const admin = __importStar(require("firebase-admin"));
admin.initializeApp();
const db = admin.firestore();
exports.onPendingDoctorRequestVerified = functions.firestore
    .document('pending_doctor_requests/{docId}')
    .onUpdate(async (change, context) => {
    const beforeData = change.before.exists ? change.before.data() : {};
    const afterData = change.after.exists ? change.after.data() : {};
    try {
        if (beforeData?.isVerified === true || afterData?.isVerified !== true) {
            functions.logger.debug('No transition to verified detected', { before: beforeData, after: afterData });
            return null;
        }
        const normalized = {
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
        const rawSpecs = afterData.specializations ?? afterData.specialization ?? afterData.speciality ?? null;
        if (!rawSpecs) {
            normalized.specializations = [];
        }
        else if (Array.isArray(rawSpecs)) {
            normalized.specializations = rawSpecs.map((s) => String(s).trim()).filter(Boolean);
        }
        else if (typeof rawSpecs === 'string') {
            normalized.specializations = rawSpecs
                .split(',')
                .map((s) => s.trim())
                .filter(Boolean);
        }
        else {
            normalized.specializations = [];
        }
        const targetId = normalized.uid || context.params.docId;
        const targetRef = db.collection('doctors').doc(targetId);
        const pendingRef = db.collection('pending_doctor_requests').doc(context.params.docId);
        await db.runTransaction(async (tx) => {
            const targetSnap = await tx.get(targetRef);
            if (targetSnap.exists) {
                tx.set(targetRef, normalized, { merge: true });
            }
            else {
                tx.set(targetRef, normalized, { merge: false });
            }
            tx.delete(pendingRef);
        });
        functions.logger.info('Successfully migrated pending doctor request', { docId: context.params.docId, targetId });
        return null;
    }
    catch (error) {
        functions.logger.error('Failed to migrate pending doctor request', { error, docId: context.params.docId });
        try {
            await db.collection('failed_migrations').doc(context.params.docId).set({
                error: String(error),
                before: beforeData,
                after: afterData,
                ts: admin.firestore.FieldValue.serverTimestamp(),
            });
        }
        catch (e) {
            functions.logger.error('Failed to write failed migration record', { e });
        }
        throw error;
    }
});
//# sourceMappingURL=index.js.map