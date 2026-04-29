import 'package:flutter/material.dart';
import '../models/job_model.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';

class JobProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();

  List<JobModel> _jobs = [];
  String _filterStatus = 'all';
  bool _isLoading = false;

  List<JobModel> get jobs => _jobs;
  String get filterStatus => _filterStatus;
  bool get isLoading => _isLoading;

  int get totalJobs => _jobs.length;
  int get interviewJobs => _jobs.where((j) => j.status == 'interview').length;
  int get selectedJobs => _jobs.where((j) => j.status == 'selected').length;
  int get rejectedJobs => _jobs.where((j) => j.status == 'rejected').length;

  List<JobModel> get filteredJobs {
    if (_filterStatus == 'all') return _jobs;
    return _jobs.where((j) => j.status == _filterStatus).toList();
  }

  void setFilter(String status) {
    _filterStatus = status;
    notifyListeners();
  }

  Stream<List<JobModel>> getJobsStream() {
    final userId = _authService.currentUser?.uid ?? '';
    return _firestoreService.getJobs(userId)..listen((jobs) {
      _jobs = jobs;
      notifyListeners();
    });
  }

  Future<void> addJob(JobModel job) async {
    _isLoading = true;
    notifyListeners();
    await _firestoreService.addJob(job);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateJob(String jobId, Map<String, dynamic> data) async {
    await _firestoreService.updateJob(jobId, data);
  }

  Future<void> deleteJob(String jobId) async {
    await _firestoreService.deleteJob(jobId);
  }
}
