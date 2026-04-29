import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  late TextEditingController _cvLinkController;
  late TextEditingController _coverLetterLinkController;
  late TextEditingController _requirementsController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _status = widget.job.status;
    _notesController = TextEditingController(text: widget.job.notes);
    _cvLinkController = TextEditingController(text: widget.job.cvLink ?? '');
    _coverLetterLinkController = TextEditingController(text: widget.job.coverLetterLink ?? '');
    _requirementsController = TextEditingController(text: widget.job.companyRequirements ?? '');
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
      'cvLink': _cvLinkController.text.trim(),
      'coverLetterLink': _coverLetterLinkController.text.trim(),
      'companyRequirements': _requirementsController.text.trim(),
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

  void _openLink(String link) {
    if (link.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No link added yet'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }
    Clipboard.setData(ClipboardData(text: link));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Link copied to clipboard!'),
        backgroundColor: AppColors.success,
      ),
    );
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
            // Company Header
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
                      color: _statusColor(_status).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        widget.job.company[0].toUpperCase(),
                        style: GoogleFonts.sora(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: _statusColor(_status)),
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
                      style: TextStyle(color: AppColors.textGrey, fontSize: 15)),
                  const SizedBox(height: 8),
                  Text(
                    'Applied: ${widget.job.applyDate.day}/${widget.job.applyDate.month}/${widget.job.applyDate.year}',
                    style: TextStyle(color: AppColors.textGrey, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Status
            Text('Update Status',
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

            // Company Requirements
            Text('Company Requirements',
                style: GoogleFonts.sora(
                    color: AppColors.textWhite,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
            const SizedBox(height: 4),
            Text('Documents or requirements requested by the company',
                style: TextStyle(color: AppColors.textGrey, fontSize: 12)),
            const SizedBox(height: 12),
            TextField(
              controller: _requirementsController,
              maxLines: 4,
              style: const TextStyle(color: AppColors.textWhite),
              decoration: InputDecoration(
                hintText: 'e.g. CNIC, Degree Certificate, Portfolio, References...',
                hintStyle: const TextStyle(color: AppColors.textGrey),
                prefixIcon: const Icon(Icons.checklist, color: AppColors.primary),
                filled: true,
                fillColor: AppColors.card,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // CV Link
            Text('Documents',
                style: GoogleFonts.sora(
                    color: AppColors.textWhite,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
            const SizedBox(height: 12),
            _buildLinkField(
              controller: _cvLinkController,
              label: 'CV / Resume Link',
              hint: 'Paste Google Drive link of your CV',
              icon: Icons.description_outlined,
              onOpen: () => _openLink(_cvLinkController.text),
            ),
            const SizedBox(height: 12),
            _buildLinkField(
              controller: _coverLetterLinkController,
              label: 'Cover Letter Link',
              hint: 'Paste Google Drive link of Cover Letter',
              icon: Icons.article_outlined,
              onOpen: () => _openLink(_coverLetterLinkController.text),
            ),
            const SizedBox(height: 24),

            // Notes
            Text('Notes',
                style: GoogleFonts.sora(
                    color: AppColors.textWhite,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              maxLines: 4,
              style: const TextStyle(color: AppColors.textWhite),
              decoration: InputDecoration(
                hintText: 'Write your notes here...',
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

            // Save Button
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

  Widget _buildLinkField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required VoidCallback onOpen,
  }) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            style: const TextStyle(color: AppColors.textWhite),
            decoration: InputDecoration(
              labelText: label,
              labelStyle: const TextStyle(color: AppColors.textGrey),
              hintText: hint,
              hintStyle: const TextStyle(color: AppColors.textGrey, fontSize: 12),
              prefixIcon: Icon(icon, color: AppColors.primary),
              filled: true,
              fillColor: AppColors.card,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: onOpen,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: const Icon(Icons.copy, color: AppColors.primary, size: 20),
          ),
        ),
      ],
    );
  }
}
