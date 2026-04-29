import 'package:flutter_test/flutter_test.dart';
import 'package:hireready_pk/models/job_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  group('JobModel Tests', () {
    test('JobModel toMap() should return correct map', () {
      final job = JobModel(
        id: 'test-id',
        userId: 'user-123',
        company: 'Google Pakistan',
        role: 'Software Engineer Intern',
        status: 'applied',
        applyDate: DateTime(2026, 4, 1),
        notes: 'Applied via LinkedIn',
        createdAt: DateTime(2026, 4, 1),
      );

      final map = job.toMap();

      expect(map['company'], 'Google Pakistan');
      expect(map['role'], 'Software Engineer Intern');
      expect(map['status'], 'applied');
      expect(map['userId'], 'user-123');
      expect(map['notes'], 'Applied via LinkedIn');
    });

    test('JobModel status should be one of valid values', () {
      final validStatuses = ['applied', 'interview', 'selected', 'rejected'];

      final job = JobModel(
        id: 'test-id',
        userId: 'user-123',
        company: 'Systems Limited',
        role: 'Flutter Developer',
        status: 'interview',
        applyDate: DateTime(2026, 4, 1),
        notes: '',
        createdAt: DateTime(2026, 4, 1),
      );

      expect(validStatuses.contains(job.status), true);
    });

    test('JobModel copyWith should update fields correctly', () {
      final job = JobModel(
        id: 'test-id',
        userId: 'user-123',
        company: 'Netsol',
        role: 'Junior Developer',
        status: 'applied',
        applyDate: DateTime(2026, 4, 1),
        notes: 'Initial notes',
        createdAt: DateTime(2026, 4, 1),
      );

      final updated = job.copyWith(
        status: 'selected',
        notes: 'Got selected!',
      );

      expect(updated.status, 'selected');
      expect(updated.notes, 'Got selected!');
      expect(updated.company, 'Netsol');
      expect(updated.id, 'test-id');
    });

    test('JobModel deadline should be nullable', () {
      final job = JobModel(
        id: 'test-id',
        userId: 'user-123',
        company: 'Arbisoft',
        role: 'Backend Developer',
        status: 'applied',
        applyDate: DateTime(2026, 4, 1),
        notes: '',
        createdAt: DateTime(2026, 4, 1),
      );

      expect(job.deadline, null);
    });
  });
}
