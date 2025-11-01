const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

// Trigger: when a user's photoURL changes in the 'users' collection
exports.syncProfilePhotoAcrossCollections = functions.firestore
    .document("users/{userId}")
    .onUpdate(async (change, context) => {
      const before = change.before.data();
      const after = change.after.data();

      // If photoURL didn't change, skip
      if (before.photoURL === after.photoURL) return null;

      const newPhotoURL = after.photoURL;
      const userId = context.params.userId;

      const db = admin.firestore();

      try {
      // Update all documents in 'customer_issues' with this user's UID
        const issuesSnap = await db
            .collection("customer_issues")
            .where("uid", "==", userId)
            .get();

        const batch = db.batch();

        issuesSnap.forEach((doc) => {
          batch.update(doc.ref, {photoURL: newPhotoURL});
        });

        // Update all documents in 'idea_pitched' with this user's UID
        const ideasSnap = await db
            .collection("idea_pitched")
            .where("uid", "==", userId)
            .get();

        ideasSnap.forEach((doc) => {
          batch.update(doc.ref, {photoURL: newPhotoURL});
        });

        await batch.commit();

        console.log(
            `✅ Updated photoURL 
            for user ${userId} 
            across customer_issues 
            and idea_pitched.`,
        );

        return null;
      } catch (error) {
        console.error("❌ Error updating photoURL:", error);
        return null;
      }
    });
