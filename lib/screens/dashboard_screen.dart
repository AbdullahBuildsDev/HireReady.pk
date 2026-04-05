import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/job_model.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';
import 'add_job_screen.dart';
import 'job_detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _authService = AuthService();
  final _firestoreService = FirestoreService();
  String _searchQuery = '';
  String _filterStatus = 'all';

  Color _statusColor(String status) {
    switch (status) {
      case 'applied': return AppColors.info;
      case 'interview': return AppColors.warning;
      case 'selected': return AppColors.success;
      case 'rejected': return AppColors.error;
      default: return AppColors.textGrey;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'applied': return 'Applied';
      case 'interview': return 'Interview';
      case 'selected': return 'Selected';
      case 'rejected': return 'Rejected';
      default: return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text('HireReady.pk',
            style: GoogleFonts.sora(
                color: AppColors.primary, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.textGrey),
            onPressed: () async {
              await _authService.signOut();
              if (mounted) {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()));
              }
            },
          ),
        ],
      ),
      body: StreamBuilder<List<JobModel>>(
        stream: _firestoreService.getJobs(user?.uid ?? ''),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.primary));
          }
          final jobs = snapshot.data ?? [];
          final filtered = jobs.where((j) {
            final matchSearch = j.company.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                j.role.toLowerCase().contains(_searchQuery.toLowerCase());
            final matchFilter = _filterStatus == 'all' || j.status == _filterStatus;
            return matchSearch && matchFilter;
          }).toList();

          final total = jobs.length;
          final interview = jobs.where((j) => j.status == 'interview').length;
          final selected = jobs.where((j) => j.status == 'selected').length;
          final rejected = jobs.where((j) => j.status == 'rejected').length;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    _statCard('Total', total, AppColors.primary),
                    const SizedBox(width: 8),
                    _statCard('Interview', interview, AppColors.warning),
                    const SizedBox(width: 8),
                    _statCard('Selected', selected, AppColors.success),
                    const SizedBox(width: 8),
                    _statCard('Rejected', rejected, AppColors.error),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  onChanged: (v) => setState(() => _searchQuery = v),
                  style: const TextStyle(color: AppColors.textWhite),
                  decoration: InputDecoration(
                    hintText: 'Company ya role search karo...',
                    hintStyle: const TextStyle(color: AppColors.textGrey),
                    prefixIcon: const Icon(Icons.search, color: AppColors.textGrey),
                    filled: true,
                    fillColor: AppColors.card,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: ['all', 'applied', 'interview', 'selected', 'rejected']
                      .map((s) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(_filterStatus == 'all' && s == 'all' ? 'Sab' : _statusLabel(s),
                                  style: TextStyle(
                                      color: _filterStatus == s
                                          ? Colors.white
                                          : AppColors.textGrey)),
                              selected: _filterStatus == s,
                              onSelected: (_) => setState(() => _filterStatus = s),
                              selectedColor: AppColors.primary,
                              backgroundColor: AppColors.card,
                              checkmarkColor: Colors.white,
                            ),
                          ))
                      .toList(),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.work_outline,
                                size: 64, color: AppColors.textGrey),
                            const SizedBox(height: 16),
                            Text('Koi application nahi',
                                style: TextStyle(color: AppColors.textGrey)),
                            const SizedBox(height: 8),
                            Text('+ button se nai job add karo',
                                style: TextStyle(
                                    color: AppColors.textGrey, fontSize: 12)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final job = filtered[index];
                          return GestureDetector(
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => JobDetailScreen(job: job))),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.card,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: AppColors.surface,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Center(
                                      child: Text(
                                        job.company[0].toUpperCase(),
                                        style: GoogleFonts.sora(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primary),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(job.company,
                                            style: GoogleFonts.sora(
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.textWhite)),
                                        Text(job.role,
                                            style: TextStyle(
                                                color: AppColors.textGrey,
                                                fontSize: 13)),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _statusColor(job.status).withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      _statusLabel(job.status),
                                      style: TextStyle(
                                          color: _statusColor(job.status),
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const AddJobScreen())),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _statCard(String label, int count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(count.toString(),
                style: GoogleFonts.sora(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: color)),
            Text(label,
                style: const TextStyle(
                    color: AppColors.textGrey, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
