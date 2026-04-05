import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/job_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<JobModel>> getJobs(String userId) {
    return _db
        .collection('jobs')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final jobs = snapshot.docs
              .map((doc) => JobModel.fromFirestore(doc))
              .toList();
          jobs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return jobs;
        });
  }

  Future<void> addJob(JobModel job) async {
    await _db.collection('jobs').add(job.toMap());
  }

  Future<void> updateJob(String jobId, Map<String, dynamic> data) async {
    await _db.collection('jobs').doc(jobId).update(data);
  }

  Future<void> deleteJob(String jobId) async {
    await _db.collection('jobs').doc(jobId).delete();
  }
}
