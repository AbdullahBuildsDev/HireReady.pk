import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/job_model.dart';
import '../theme/app_theme.dart';

class AddJobScreen extends StatefulWidget {
  const AddJobScreen({super.key});

  @override
  State<AddJobScreen> createState() => _AddJobScreenState();
}

class _AddJobScreenState extends State<AddJobScreen> {
  final _companyController = TextEditingController();
  final _roleController = TextEditingController();
  final _notesController = TextEditingController();
  final _authService = AuthService();
  final _firestoreService = FirestoreService();
  String _status = 'applied';
  DateTime _applyDate = DateTime.now();
  DateTime? _deadline;
  bool _isLoading = false;

  Future<void> _pickDate({bool isDeadline = false}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        if (isDeadline) {
          _deadline = picked;
        } else {
          _applyDate = picked;
        }
      });
    }
  }

  Future<void> _saveJob() async {
    if (_companyController.text.isEmpty || _roleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Company and Role are required'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      final job = JobModel(
        id: const Uuid().v4(),
        userId: _authService.currentUser?.uid ?? '',
        company: _companyController.text.trim(),
        role: _roleController.text.trim(),
        status: _status,
        applyDate: _applyDate,
        notes: _notesController.text.trim(),
        deadline: _deadline,
        createdAt: DateTime.now(),
      );
      await _firestoreService.addJob(job);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
      );
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        iconTheme: const IconThemeData(color: AppColors.textWhite),
        title: Text('Add New Job',
            style: GoogleFonts.sora(color: AppColors.textWhite)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField(_companyController, 'Company Name', Icons.business_outlined),
            const SizedBox(height: 16),
            _buildTextField(_roleController, 'Role / Position', Icons.work_outline),
            const SizedBox(height: 16),
            Text('Status', style: TextStyle(color: AppColors.textGrey, fontSize: 14)),
            const SizedBox(height: 8),
            Row(
              children: ['applied', 'interview', 'selected', 'rejected'].map((s) {
                final isSelected = _status == s;
                Color color;
                switch (s) {
                  case 'applied': color = AppColors.info; break;
                  case 'interview': color = AppColors.warning; break;
                  case 'selected': color = AppColors.success; break;
                  default: color = AppColors.error;
                }
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
            const SizedBox(height: 16),
            _buildDateTile('Apply Date', _applyDate, () => _pickDate()),
            const SizedBox(height: 12),
            _buildDateTile(
              'Follow-up Deadline',
              _deadline,
              () => _pickDate(isDeadline: true),
              optional: true,
            ),
            const SizedBox(height: 16),
            _buildTextField(_notesController, 'Notes (optional)', Icons.notes_outlined, maxLines: 4),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveJob,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text('Save job',
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

  Widget _buildTextField(TextEditingController controller, String label,
      IconData icon, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: AppColors.textWhite),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textGrey),
        prefixIcon: Icon(icon, color: AppColors.primary),
        filled: true,
        fillColor: AppColors.card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildDateTile(String label, DateTime? date, VoidCallback onTap,
      {bool optional = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: AppColors.primary, size: 20),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: AppColors.textGrey, fontSize: 12)),
                Text(
                  date != null
                      ? '${date.day}/${date.month}/${date.year}'
                      : optional ? 'Select(optional)' : 'Select',
                  style: const TextStyle(color: AppColors.textWhite),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
