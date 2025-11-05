import 'package:cloud_firestore/cloud_firestore.dart';

class CropModel {
  final String? id;
  final String farmerId;
  final String name;
  final String variety;
  final double area;
  final String status; // 'healthy', 'diseased', 'unknown'
  final List<String> imagePaths; // Local file paths instead of URLs
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CropModel({
    this.id,
    required this.farmerId,
    required this.name,
    required this.variety,
    required this.area,
    this.status = 'unknown',
    this.imagePaths = const [],
    this.createdAt,
    this.updatedAt,
  });

  // Convert to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'farmerId': farmerId,
      'name': name,
      'variety': variety,
      'area': area,
      'status': status,
      'imagePaths': imagePaths,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  // Create from Firestore document
  factory CropModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CropModel(
      id: doc.id,
      farmerId: data['farmerId'] ?? '',
      name: data['name'] ?? '',
      variety: data['variety'] ?? '',
      area: (data['area'] ?? 0.0).toDouble(),
      status: data['status'] ?? 'unknown',
      imagePaths: List<String>.from(data['imagePaths'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  // Create a copy with updated fields
  CropModel copyWith({
    String? id,
    String? farmerId,
    String? name,
    String? variety,
    double? area,
    String? status,
    List<String>? imagePaths,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CropModel(
      id: id ?? this.id,
      farmerId: farmerId ?? this.farmerId,
      name: name ?? this.name,
      variety: variety ?? this.variety,
      area: area ?? this.area,
      status: status ?? this.status,
      imagePaths: imagePaths ?? this.imagePaths,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
