const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();
const db = admin.firestore();

/**
 * 1️⃣ Kıyafet önerisi fonksiyonu
 * Flutter'dan Callable (bulut fonksiyonu) olarak çağrılır.
 */
exports.recommendOutfits = functions.https.onCall(async (data, context) => {
  const uid = context.auth?.uid;
  if (!uid) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "Bu işlemi yapmak için giriş yapmalısınız."
    );
  }

  const occasion = data.occasion || "casual";
  const limit = data.limit || 5;

  const snap = await db
    .collection("users")
    .doc(uid)
    .collection("outfits")
    .where("occasion", "==", occasion)
    .get();

  const outfits = snap.docs.map((doc) => ({
    id: doc.id,
    ...doc.data(),
  }));

  const sorted = outfits
    .map((o) => ({
      outfitId: o.id,
      title: o.title || "",
      score: (o.likes || 0) + (o.timesUsed || 0),
    }))
    .sort((a, b) => b.score - a.score)
    .slice(0, limit);

  return { data: sorted };
});

/**
 * 2️⃣ wearLogs koleksiyonuna yeni kayıt eklendiğinde tetiklenir.
 * Kullanıcının item'larının wornCount ve lastWornAt alanlarını günceller.
 */
exports.onWearLogCreate = functions.firestore
  .document("users/{uid}/wearLogs/{logId}")
  .onCreate(async (snap, context) => {
    const uid = context.params.uid;
    const data = snap.data();

    if (!data || !data.itemIds) return;

    const batch = db.batch();
    for (const itemId of data.itemIds) {
      const ref = db.doc(`users/${uid}/items/${itemId}`);
      batch.update(ref, {
        wornCount: admin.firestore.FieldValue.increment(1),
        lastWornAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
    console.log("Wear log işlendi:", data.itemIds);
  });
