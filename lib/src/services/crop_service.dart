import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../models/crop_model.dart';

class CropService {
  static final CropService instance = CropService._();
  CropService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Save image locally and return local path
  Future<String> saveImageLocally(String cropId, File imageFile) async {
    try {
      print('🔵 Saving image locally for crop $cropId...');
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) throw Exception('User not logged in');

      // Get app documents directory
      final appDir = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${cropId}_$timestamp.jpg';
      final localPath = path.join(appDir.path, 'crops', userId, fileName);

      // Create directory if it doesn't exist
      final directory = Directory(path.dirname(localPath));
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      // Copy image to local storage
      final savedImage = await imageFile.copy(localPath);

      print('✅ Image saved locally: $localPath');
      return savedImage.path;
    } catch (e) {
      print('❌ Error saving image locally: $e');
      rethrow;
    }
  }

  // Add a new crop
  Future<String> addCrop(CropModel crop) async {
    try {
      print('🔵 Adding crop to Firestore...');
      final docRef = await _firestore.collection('crops').add(crop.toMap());
      print('✅ Crop added successfully with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('❌ Error adding crop: $e');
      rethrow;
    }
  }

  // Add image path to crop document
  Future<void> addImagePathToCrop(String cropId, String imagePath) async {
    try {
      await _firestore.collection('crops').doc(cropId).update({
        'imagePaths': FieldValue.arrayUnion([imagePath]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('✅ Image path added to crop document');
    } catch (e) {
      print('❌ Error adding image path to crop: $e');
      rethrow;
    }
  }

  // Get all crops for current user
  Stream<List<CropModel>> getUserCrops() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      print('❌ No user logged in, returning empty stream');
      return Stream.value([]);
    }

    print('🔵 Getting crops for user: $userId');

    // Remove orderBy to avoid index requirement initially
    return _firestore
        .collection('crops')
        .where('farmerId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          print('✅ Received ${snapshot.docs.length} crop(s) from Firestore');
          final crops = snapshot.docs.map((doc) {
            print('  - Crop: ${doc.data()['name']} (ID: ${doc.id})');
            return CropModel.fromFirestore(doc);
          }).toList();

          // Sort in memory instead
          crops.sort((a, b) {
            if (a.createdAt == null && b.createdAt == null) return 0;
            if (a.createdAt == null) return 1;
            if (b.createdAt == null) return -1;
            return b.createdAt!.compareTo(a.createdAt!);
          });

          return crops;
        });
  }

  // Get a single crop by ID
  Future<CropModel?> getCrop(String cropId) async {
    try {
      final doc = await _firestore.collection('crops').doc(cropId).get();
      if (!doc.exists) return null;
      return CropModel.fromFirestore(doc);
    } catch (e) {
      print('❌ Error getting crop: $e');
      return null;
    }
  }

  // Update crop
  Future<void> updateCrop(String cropId, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection('crops').doc(cropId).update({
        ...updates,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('✅ Crop updated successfully');
    } catch (e) {
      print('❌ Error updating crop: $e');
      rethrow;
    }
  }

  // Delete crop
  Future<void> deleteCrop(String cropId) async {
    try {
      // Get crop to delete local images
      final crop = await getCrop(cropId);
      if (crop != null) {
        // Delete local images
        for (final imagePath in crop.imagePaths) {
          try {
            final file = File(imagePath);
            if (await file.exists()) {
              await file.delete();
              print('✅ Local image deleted: $imagePath');
            }
          } catch (e) {
            print('⚠️ Could not delete image: $imagePath - $e');
          }
        }
      }

      await _firestore.collection('crops').doc(cropId).delete();
      print('✅ Crop deleted successfully');
    } catch (e) {
      print('❌ Error deleting crop: $e');
      rethrow;
    }
  }
}
