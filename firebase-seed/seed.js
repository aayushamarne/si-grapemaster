/**
 * seed.js
 * WARNING: requires a service account JSON file called serviceAccountKey.json in the same folder.
 * Do NOT commit serviceAccountKey.json to source control.
 */

const admin = require('firebase-admin');
const fs = require('fs');

const serviceAccountPath = './serviceAccountKey.json';
if (!fs.existsSync(serviceAccountPath)) {
  console.error('Missing serviceAccountKey.json. Download from Firebase Console -> Project Settings -> Service accounts -> Generate new private key');
  process.exit(1);
}

const serviceAccount = require(serviceAccountPath);

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function seed() {
  try {
    // Sample user
    const uid = 'test-user-uid-1';
    await db.collection('users').doc(uid).set({
      name: 'Test Farmer',
      email: 'testfarmer@example.com',
      phone: '+91-9000000000',
      role: 'farmer',
      createdAt: admin.firestore.FieldValue.serverTimestamp()
    });

    // Sample farmer record
    const farmerRef = db.collection('farmers').doc();
    await farmerRef.set({
      userId: uid,
      farmName: 'Green Valley Farm',
      address: 'Village X, Taluka Y',
      location: new admin.firestore.GeoPoint(18.5204, 73.8567),
      area: 2.5,
      phone: '+91-9000000000',
      crops: [{ name: 'Grape', area: 1.5 }],
      createdAt: admin.firestore.FieldValue.serverTimestamp()
    });

    // Sample crop (top-level)
    const cropRef = db.collection('crops').doc();
    await cropRef.set({
      farmerId: farmerRef.id,
      name: 'Grape',
      variety: 'Thompson Seedless',
      plantedOn: admin.firestore.FieldValue.serverTimestamp(),
      status: 'healthy',
      area: 1.5,
      createdAt: admin.firestore.FieldValue.serverTimestamp()
    });

    // Sample diagnosis
    await db.collection('diagnoses').add({
      farmerId: farmerRef.id,
      cropId: cropRef.id,
      reportedByUid: uid,
      issue: 'Powdery mildew',
      severity: 'medium',
      notes: 'White powder on leaves; treat with recommended fungicide.',
      imageUrls: [],
      createdAt: admin.firestore.FieldValue.serverTimestamp()
    });

    // Sample product
    await db.collection('products').add({
      sellerUid: uid,
      title: 'Organic Fertilizer 500ml',
      category: 'Fertilizers',
      price: 190,
      unit: '500 millilitre',
      description: 'Organic fertilizer by GAPL',
      imageUrl: '',
      createdAt: admin.firestore.FieldValue.serverTimestamp()
    });

    console.log('Seeding completed.');
    return process.exit(0);
  } catch (err) {
    console.error('Error seeding:', err);
    process.exit(1);
  }
}

seed();
