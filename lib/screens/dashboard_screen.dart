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
  String _filterStatus = 'all';

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String _getUserName() {
    final user = _authService.currentUser;
    if (user?.displayName != null && user!.displayName!.isNotEmpty) {
      return user.displayName!.split(' ')[0];
    }
    return 'there';
  }

  String _getMotivationalQuote() {
    final quotes = [
      "Every application is one step closer to your dream job!",
      "Keep applying, your opportunity is out there!",
      "Success is the sum of small efforts repeated daily!",
      "Believe in yourself and your journey!",
      "Your next big break could be one application away!",
      "Stay consistent, stay focused, stay hungry!",
      "Great things never come from comfort zones!",
      "Your career story is just beginning!",
    ];
    final index = DateTime.now().day % quotes.length;
    return quotes[index];
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'applied':
        return AppColors.info;
      case 'interview':
        return AppColors.warning;
      case 'selected':
        return AppColors.success;
      case 'rejected':
        return AppColors.error;
      default:
        return AppColors.textGrey;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'applied':
        return 'Applied';
      case 'interview':
        return 'Interview';
      case 'selected':
        return 'Selected';
      case 'rejected':
        return 'Rejected';
      default:
        return status;
    }
  }

  String _formatDate(DateTime date) {
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Row(
          children: [
            Icon(Icons.work_outline, color: AppColors.primary, size: 32),
            const SizedBox(width: 8),
            Text('HireReady.pk',
                style: GoogleFonts.sora(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 18)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.textGrey),
            onPressed: () async {
              await _authService.signOut();
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false);
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
            return _filterStatus == 'all' || j.status == _filterStatus;
          }).toList();

          final total = jobs.length;
          final interview = jobs.where((j) => j.status == 'interview').length;
          final selected = jobs.where((j) => j.status == 'selected').length;
          final rejected = jobs.where((j) => j.status == 'rejected').length;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${_getGreeting()}, ${_getUserName()}! 👋',
                          style: GoogleFonts.sora(
                              color: AppColors.textWhite,
                              fontWeight: FontWeight.bold,
                            fontSize: 16)),
                      const SizedBox(height: 4),
                      Text(_getMotivationalQuote(),
                          style: TextStyle(
                              color: AppColors.textGrey, fontSize: 12)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
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
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: ['all', 'applied', 'interview', 'selected', 'rejected']
                      .map((s) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(
                                  s == 'all' ? 'All' : _statusLabel(s),
                                  style: TextStyle(
                                      color: _filterStatus == s
                                          ? Colors.white
                                          : AppColors.textGrey)),
                              selected: _filterStatus == s,
                              onSelected: (_) =>
                                  setState(() => _filterStatus = s),
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
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: AppColors.card,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(Icons.work_outline,
                                  size: 40, color: AppColors.primary),
                            ),
                            const SizedBox(height: 16),
                            Text('No applications yet',
                                style: GoogleFonts.sora(
                                    color: AppColors.textWhite,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16)),
                            const SizedBox(height: 8),
                            Text('Tap + to add your first job application',
                                style: TextStyle(
                                    color: AppColors.textGrey,
                                    fontSize: 13)),
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
                                    builder: (_) =>
                                        JobDetailScreen(job: job))),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.card,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: _statusColor(job.status)
                                      .withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: _statusColor(job.status)
                                          .withOpacity(0.15),
                                      borderRadius:
                                          BorderRadius.circular(12),
                                    ),
                                    child: Center(
                                      child: Text(
                                        job.company[0].toUpperCase(),
                                        style: GoogleFonts.sora(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color:
                                                _statusColor(job.status)),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(job.company,
                                            style: GoogleFonts.sora(
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.textWhite)),
                                        Text(job.role,
                                            style: TextStyle(
                                                color: AppColors.textGrey,
                                                fontSize: 13)),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Applied: ${_formatDate(job.applyDate)}',
                                          style: TextStyle(
                                              color: AppColors.textGrey
                                                  .withOpacity(0.7),
                                              fontSize: 11),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _statusColor(job.status)
                                          .withOpacity(0.15),
                                      borderRadius:
                                          BorderRadius.circular(8),
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
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const AddJobScreen())),
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
