import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/job_model.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';

class JobDetailScreen extends StatefulWidget {
  final JobModel job;
  const JobDetailScreen({super.key, required this.job});

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  final _firestoreService = FirestoreService();
  late String _status;
  late TextEditingController _notesController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _status = widget.job.status;
    _notesController = TextEditingController(text: widget.job.notes);
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'applied': return AppColors.info;
      case 'interview': return AppColors.warning;
      case 'selected': return AppColors.success;
      case 'rejected': return AppColors.error;
      default: return AppColors.textGrey;
    }
  }

  Future<void> _updateJob() async {
    setState(() => _isLoading = true);
    await _firestoreService.updateJob(widget.job.id, {
      'status': _status,
      'notes': _notesController.text.trim(),
    });
    setState(() => _isLoading = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Job updated successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<void> _deleteJob() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text('Delete Job?',
            style: TextStyle(color: AppColors.textWhite)),
        content: Text('Are you sure you want to delete this job?',
            style: TextStyle(color: AppColors.textGrey)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: AppColors.textGrey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _firestoreService.deleteJob(widget.job.id);
      if (mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        iconTheme: const IconThemeData(color: AppColors.textWhite),
        title: Text('Job Detail',
            style: GoogleFonts.sora(color: AppColors.textWhite)),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
            onPressed: _deleteJob,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        widget.job.company[0].toUpperCase(),
                        style: GoogleFonts.sora(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(widget.job.company,
                      style: GoogleFonts.sora(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textWhite)),
                  Text(widget.job.role,
                      style: TextStyle(
                          color: AppColors.textGrey, fontSize: 15)),
                  const SizedBox(height: 8),
                  Text(
                    'Applied: ${widget.job.applyDate.day}/${widget.job.applyDate.month}/${widget.job.applyDate.year}',
                    style: TextStyle(color: AppColors.textGrey, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('Status Update Karo',
                style: GoogleFonts.sora(
                    color: AppColors.textWhite,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
            const SizedBox(height: 12),
            Row(
              children: ['applied', 'interview', 'selected', 'rejected'].map((s) {
                final isSelected = _status == s;
                final color = _statusColor(s);
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _status = s),
                    child: Container(
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? color.withOpacity(0.2) : AppColors.card,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? color : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        s[0].toUpperCase() + s.substring(1),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isSelected ? color : AppColors.textGrey,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            Text('Notes',
                style: GoogleFonts.sora(
                    color: AppColors.textWhite,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              maxLines: 5,
              style: const TextStyle(color: AppColors.textWhite),
              decoration: InputDecoration(
                hintText: 'Add any notes...',
                hintStyle: const TextStyle(color: AppColors.textGrey),
                filled: true,
                fillColor: AppColors.card,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _updateJob,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text('Save Changes',
                        style: GoogleFonts.sora(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
