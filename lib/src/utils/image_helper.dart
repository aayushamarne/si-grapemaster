import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';

class ImageHelper {
  // Convert image file to base64 string (for Firestore storage - FREE!)
  static Future<String?> imageToBase64(
    File imageFile, {
    int maxSizeKB = 500,
  }) async {
    try {
      final bytes = await imageFile.readAsBytes();

      // Check size limit (Firestore document size limit is 1MB, we use 500KB to be safe)
      if (bytes.length > maxSizeKB * 1000) {
        return null; // Image too large
      }

      return base64Encode(bytes);
    } catch (e) {
      debugPrint('Error converting image to base64: $e');
      return null;
    }
  }

  // Convert base64 string back to image bytes
  static Uint8List? base64ToImage(String base64String) {
    try {
      return base64Decode(base64String);
    } catch (e) {
      debugPrint('Error converting base64 to image: $e');
      return null;
    }
  }

  // Check if image size is within limit
  static Future<bool> isImageSizeValid(
    File imageFile, {
    int maxSizeKB = 500,
  }) async {
    try {
      final bytes = await imageFile.readAsBytes();
      return bytes.length <= maxSizeKB * 1000;
    } catch (e) {
      return false;
    }
  }
}
