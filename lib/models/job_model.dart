import 'package:cloud_firestore/cloud_firestore.dart';

class JobModel {
  final String id;
  final String userId;
  final String company;
  final String role;
  final String status;
  final DateTime applyDate;
  final String notes;
  final DateTime? deadline;
  final String? aiTips;
  final DateTime createdAt;
  final String? cvLink;
  final String? coverLetterLink;
  final String? companyRequirements;

  JobModel({
    required this.id,
    required this.userId,
    required this.company,
    required this.role,
    required this.status,
    required this.applyDate,
    required this.notes,
    this.deadline,
    this.aiTips,
    required this.createdAt,
    this.cvLink,
    this.coverLetterLink,
    this.companyRequirements,
  });

  factory JobModel.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return JobModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      company: data['company'] ?? '',
      role: data['role'] ?? '',
      status: data['status'] ?? 'applied',
      applyDate: (data['applyDate'] as Timestamp).toDate(),
      notes: data['notes'] ?? '',
      deadline: data['deadline'] != null
          ? (data['deadline'] as Timestamp).toDate()
          : null,
      aiTips: data['aiTips'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      cvLink: data['cvLink'],
      coverLetterLink: data['coverLetterLink'],
      companyRequirements: data['companyRequirements'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'company': company,
      'role': role,
      'status': status,
      'applyDate': Timestamp.fromDate(applyDate),
      'notes': notes,
      'deadline': deadline != null ? Timestamp.fromDate(deadline!) : null,
      'aiTips': aiTips,
      'createdAt': Timestamp.fromDate(createdAt),
      'cvLink': cvLink,
      'coverLetterLink': coverLetterLink,
      'companyRequirements': companyRequirements,
    };
  }

  JobModel copyWith({
    String? company,
    String? role,
    String? status,
    String? notes,
    DateTime? deadline,
    String? aiTips,
    String? cvLink,
    String? coverLetterLink,
    String? companyRequirements,
  }) {
    return JobModel(
      id: id,
      userId: userId,
      company: company ?? this.company,
      role: role ?? this.role,
      status: status ?? this.status,
      applyDate: applyDate,
      notes: notes ?? this.notes,
      deadline: deadline ?? this.deadline,
      aiTips: aiTips ?? this.aiTips,
      createdAt: createdAt,
      cvLink: cvLink ?? this.cvLink,
      coverLetterLink: coverLetterLink ?? this.coverLetterLink,
      companyRequirements: companyRequirements ?? this.companyRequirements,
    );
  }
}
