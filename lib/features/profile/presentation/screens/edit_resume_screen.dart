import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../models/resume_model.dart';
import '../../models/user_model.dart';
import '../../data/profile_repository.dart';

class EditResumeScreen extends StatefulWidget {
  final String uid;
  final UserModel? userProfile;
  final ResumeModel? initialResume;
  final ProfileRepository profileRepo;

  const EditResumeScreen({
    super.key,
    required this.uid,
    this.userProfile,
    this.initialResume,
    required this.profileRepo,
  });

  @override
  State<EditResumeScreen> createState() => _EditResumeScreenState();
}

class _EditResumeScreenState extends State<EditResumeScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _jobTitleController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _locationController;
  late TextEditingController _linkedinController;
  late TextEditingController _summaryController;

  final List<ResumeExperience> _experiences = [];
  final List<ResumeEducation> _educations = [];
  final List<String> _technicalSkills = [];
  final List<String> _personalSkills = [];
  final List<ResumeLanguage> _languages = [];
  final List<String> _certificates = [];

  final TextEditingController _techSkillInput = TextEditingController();
  final TextEditingController _persSkillInput = TextEditingController();
  final TextEditingController _certInput = TextEditingController();

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final r = widget.initialResume;
    final u = widget.userProfile;

    String fName = r?.firstName ?? '';
    String lName = r?.lastName ?? '';
    if (fName.isEmpty && lName.isEmpty && u?.name != null) {
      final parts = u!.name.trim().split(' ');
      fName = parts.isNotEmpty ? parts.first : '';
      lName = parts.length > 1 ? parts.sublist(1).join(' ') : '';
    }

    _firstNameController = TextEditingController(text: fName);
    _lastNameController = TextEditingController(text: lName);
    _jobTitleController = TextEditingController(text: r?.jobTitle.isNotEmpty == true ? r!.jobTitle : '${u?.major ?? "Software"} Specialist');
    _emailController = TextEditingController(text: r?.email.isNotEmpty == true ? r!.email : (u?.email ?? ''));
    _phoneController = TextEditingController(text: r?.phone ?? '');
    _locationController = TextEditingController(text: r?.location ?? '');
    _linkedinController = TextEditingController(text: r?.linkedin ?? '');
    _summaryController = TextEditingController(text: r?.summary.isNotEmpty == true ? r!.summary : (u?.bio ?? ''));

    if (r?.experiences.isNotEmpty == true) {
      _experiences.addAll(r!.experiences);
    }

    if (r?.educations.isNotEmpty == true) {
      _educations.addAll(r!.educations);
    } else {
      _educations.add(ResumeEducation(
        degree: 'Bachelor Degree',
        specialization: u?.major.isNotEmpty == true ? u!.major : 'Computer Science',
        university: 'Campus University',
        graduationYear: '2026',
      ));
    }

    if (r?.technicalSkills.isNotEmpty == true) {
      _technicalSkills.addAll(r!.technicalSkills);
    } else {
      _technicalSkills.addAll(['Flutter', 'Dart', 'Firebase', 'Git', 'REST APIs']);
    }

    if (r?.personalSkills.isNotEmpty == true) {
      _personalSkills.addAll(r!.personalSkills);
    } else {
      _personalSkills.addAll(['Communication', 'Teamwork', 'Problem Solving', 'Leadership']);
    }

    if (r?.languages.isNotEmpty == true) {
      _languages.addAll(r!.languages);
    } else {
      _languages.addAll([
        const ResumeLanguage(language: 'Arabic', level: 'Native'),
        const ResumeLanguage(language: 'English', level: 'Professional'),
      ]);
    }

    if (r?.certificates.isNotEmpty == true) {
      _certificates.addAll(r!.certificates);
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _jobTitleController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _linkedinController.dispose();
    _summaryController.dispose();
    _techSkillInput.dispose();
    _persSkillInput.dispose();
    _certInput.dispose();
    super.dispose();
  }

  // دالة مساعدة لاختيار التاريخ بنمط السنة والشهر بصيغة YYYY-MM
  Future<void> _pickMonthYear(BuildContext context, TextEditingController controller) async {
    int selectedYear = DateTime.now().year;
    int selectedMonth = DateTime.now().month;

    if (controller.text.trim().isNotEmpty) {
      final parts = controller.text.trim().split('-');
      if (parts.length == 2) {
        selectedYear = int.tryParse(parts[0]) ?? selectedYear;
        selectedMonth = int.tryParse(parts[1]) ?? selectedMonth;
      }
    }

    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(selectedYear, selectedMonth),
      firstDate: DateTime(1980),
      lastDate: DateTime(now.year + 10),
      initialDatePickerMode: DatePickerMode.year,
      helpText: 'SELECT DATE (YEAR & MONTH)',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.navy,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final monthStr = picked.month.toString().padLeft(2, '0');
      controller.text = '${picked.year}-$monthStr';
    }
  }

  // دالة مساعدة لاختيار سنة التخرج بنمط السنة فقط YYYY
  Future<void> _pickYearOnly(BuildContext context, TextEditingController controller) async {
    int selectedYear = DateTime.now().year;
    if (controller.text.trim().isNotEmpty) {
      selectedYear = int.tryParse(controller.text.trim()) ?? selectedYear;
    }

    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(selectedYear, 1),
      firstDate: DateTime(1980),
      lastDate: DateTime(now.year + 10),
      initialDatePickerMode: DatePickerMode.year,
      helpText: 'SELECT GRADUATION YEAR',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.navy,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      controller.text = '${picked.year}';
    }
  }

  void _addTechSkill() {
    final t = _techSkillInput.text.trim();
    if (t.isNotEmpty && !_technicalSkills.contains(t)) {
      setState(() {
        _technicalSkills.add(t);
        _techSkillInput.clear();
      });
    }
  }

  void _addPersSkill() {
    final t = _persSkillInput.text.trim();
    if (t.isNotEmpty && !_personalSkills.contains(t)) {
      setState(() {
        _personalSkills.add(t);
        _persSkillInput.clear();
      });
    }
  }

  void _addCert() {
    final t = _certInput.text.trim();
    if (t.isNotEmpty && !_certificates.contains(t)) {
      setState(() {
        _certificates.add(t);
        _certInput.clear();
      });
    }
  }

  // نافذة إضافة أو تعديل خبرة عمل بتصميم نظيف وعصري متوافق مع Campus
  void _openExperienceDialog({ResumeExperience? existing, int? index}) {
    final jobCtrl = TextEditingController(text: existing?.jobTitle ?? '');
    final compCtrl = TextEditingController(text: existing?.company ?? '');
    final startCtrl = TextEditingController(text: existing?.startDate ?? '');
    final endCtrl = TextEditingController(text: existing?.endDate ?? '');
    bool isCurrent = existing?.current ?? false;
    final respList = List<String>.from(existing?.responsibilities ?? []);
    final respInput = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => Dialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 22.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.work_rounded, color: AppColors.primary, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        existing == null ? 'Add Work Experience' : 'Edit Work Experience',
                        style: const TextStyle(
                          color: AppColors.navy,
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  TextFormField(
                    controller: jobCtrl,
                    decoration: _inputDec('Job Title *', icon: Icons.badge_rounded, hint: 'e.g. Marketing Manager'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: compCtrl,
                    decoration: _inputDec('Company & Location *', icon: Icons.apartment_rounded, hint: 'e.g. XYZ Corp, Sydney'),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: startCtrl,
                          readOnly: true,
                          onTap: () async {
                            await _pickMonthYear(context, startCtrl);
                            setDialogState(() {});
                          },
                          decoration: _inputDec(
                            'Start Date *',
                            icon: Icons.calendar_month_rounded,
                            hint: 'YYYY-MM',
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      if (!isCurrent)
                        Expanded(
                          child: TextFormField(
                            controller: endCtrl,
                            readOnly: true,
                            onTap: () async {
                              await _pickMonthYear(context, endCtrl);
                              setDialogState(() {});
                            },
                            decoration: _inputDec(
                              'End Date *',
                              icon: Icons.event_available_rounded,
                              hint: 'YYYY-MM',
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  InkWell(
                    borderRadius: BorderRadius.circular(8.0),
                    onTap: () => setDialogState(() => isCurrent = !isCurrent),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Row(
                        children: [
                          Checkbox(
                            value: isCurrent,
                            activeColor: AppColors.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            onChanged: (val) => setDialogState(() => isCurrent = val ?? false),
                          ),
                          const Text(
                            'I currently work here',
                            style: TextStyle(fontSize: 13.0, color: AppColors.textDark, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Responsibilities & Achievements (Bullet Points)',
                    style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold, color: AppColors.navy),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: respInput,
                          decoration: _inputDec('Add bullet item', hint: 'e.g. Led a team of 5 in digital strategies'),
                          onSubmitted: (val) {
                            if (val.trim().isNotEmpty) {
                              setDialogState(() {
                                respList.add(val.trim());
                                respInput.clear();
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        style: IconButton.styleFrom(backgroundColor: AppColors.primary),
                        icon: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
                        onPressed: () {
                          if (respInput.text.trim().isNotEmpty) {
                            setDialogState(() {
                              respList.add(respInput.text.trim());
                              respInput.clear();
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  if (respList.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    ...respList.asMap().entries.map((e) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 6.0),
                        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: Row(
                          children: [
                            const Text('• ', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                            Expanded(child: Text(e.value, style: const TextStyle(fontSize: 12.0, color: AppColors.textDark))),
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              icon: const Icon(Icons.close_rounded, size: 16, color: AppColors.textMuted),
                              onPressed: () => setDialogState(() => respList.removeAt(e.key)),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                          ),
                          onPressed: () {
                            if (jobCtrl.text.trim().isEmpty || compCtrl.text.trim().isEmpty) return;
                            final exp = ResumeExperience(
                              jobTitle: jobCtrl.text.trim(),
                              company: compCtrl.text.trim(),
                              startDate: startCtrl.text.trim(),
                              endDate: isCurrent ? '' : endCtrl.text.trim(),
                              current: isCurrent,
                              responsibilities: respList,
                            );
                            setState(() {
                              if (index != null) {
                                _experiences[index] = exp;
                              } else {
                                _experiences.add(exp);
                              }
                            });
                            Navigator.pop(ctx);
                          },
                          child: const Text('Save Experience', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // نافذة إضافة أو تعديل مؤهل تعليمي بتصميم ناعم ومطابق لهوية التطبيق
  void _openEducationDialog({ResumeEducation? existing, int? index}) {
    final degCtrl = TextEditingController(text: existing?.degree ?? '');
    final specCtrl = TextEditingController(text: existing?.specialization ?? '');
    final uniCtrl = TextEditingController(text: existing?.university ?? '');
    final yearCtrl = TextEditingController(text: existing?.graduationYear ?? '');

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 22.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.school_rounded, color: AppColors.primary, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      existing == null ? 'Add Education' : 'Edit Education',
                      style: const TextStyle(
                        color: AppColors.navy,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: degCtrl,
                  decoration: _inputDec('Degree *', icon: Icons.school_outlined, hint: 'e.g. Bachelor of Marketing'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: specCtrl,
                  decoration: _inputDec('Specialization', icon: Icons.auto_stories_rounded, hint: 'e.g. Digital Marketing'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: uniCtrl,
                  decoration: _inputDec('University / College *', icon: Icons.account_balance_rounded, hint: 'e.g. University of Sydney'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: yearCtrl,
                  readOnly: true,
                  onTap: () async {
                    await _pickYearOnly(context, yearCtrl);
                  },
                  decoration: _inputDec(
                    'Graduation Year *',
                    icon: Icons.calendar_today_rounded,
                    hint: 'Tap to select year (e.g. 2018)',
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                        ),
                        onPressed: () {
                          if (uniCtrl.text.trim().isEmpty) return;
                          final edu = ResumeEducation(
                            degree: degCtrl.text.trim(),
                            specialization: specCtrl.text.trim(),
                            university: uniCtrl.text.trim(),
                            graduationYear: yearCtrl.text.trim(),
                          );
                          setState(() {
                            if (index != null) {
                              _educations[index] = edu;
                            } else {
                              _educations.add(edu);
                            }
                          });
                          Navigator.pop(ctx);
                        },
                        child: const Text('Save Education', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // نافذة إضافة لغة بتصميم نظيف
  void _openLanguageDialog() {
    final langCtrl = TextEditingController();
    String level = 'Professional';
    final levels = ['Native', 'Fluent', 'Advanced', 'Professional', 'Intermediate', 'Beginner'];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => Dialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 22.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.language_rounded, color: AppColors.primary, size: 20),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Add Language',
                      style: TextStyle(
                        color: AppColors.navy,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                TextFormField(
                  controller: langCtrl,
                  decoration: _inputDec('Language *', icon: Icons.translate_rounded, hint: 'e.g. French'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: level,
                  decoration: _inputDec('Proficiency Level', icon: Icons.trending_up_rounded),
                  items: levels.map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
                  onChanged: (val) => setDialogState(() => level = val ?? 'Professional'),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                        ),
                        onPressed: () {
                          if (langCtrl.text.trim().isNotEmpty) {
                            setState(() {
                              _languages.add(ResumeLanguage(language: langCtrl.text.trim(), level: level));
                            });
                          }
                          Navigator.pop(ctx);
                        },
                        child: const Text('Add Language', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submitSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final model = ResumeModel(
        uid: widget.uid,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        jobTitle: _jobTitleController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        location: _locationController.text.trim(),
        linkedin: _linkedinController.text.trim(),
        summary: _summaryController.text.trim(),
        experiences: _experiences,
        educations: _educations,
        technicalSkills: _technicalSkills,
        personalSkills: _personalSkills,
        languages: _languages,
        certificates: _certificates,
      );

      await widget.profileRepo.saveResume(model);
      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('CV updated successfully 🎉'),
            backgroundColor: AppColors.navy,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving CV: $e'),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Widget _buildSectionCard({required String title, required IconData icon, required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.bold,
                  color: AppColors.navy,
                ),
              ),
            ],
          ),
          const Divider(height: 20, color: AppColors.borderLight),
          ...children,
        ],
      ),
    );
  }

  InputDecoration _inputDec(String label, {IconData? icon, String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: icon != null ? Icon(icon, size: 18, color: AppColors.navy) : null,
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
      labelStyle: const TextStyle(fontSize: 13.0, color: AppColors.navy),
      hintStyle: const TextStyle(fontSize: 12.0, color: AppColors.textMuted),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: const BorderSide(color: AppColors.borderLight)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: const BorderSide(color: AppColors.borderLight)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.navy, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Full CV / Resume',
          style: TextStyle(
            color: AppColors.navy,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _submitSave,
            child: _isSaving
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))
                : const Text('Save', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 15.0)),
          ),
          const SizedBox(width: 8),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(height: 1.0, color: AppColors.borderLight),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // 1. Personal Info
            _buildSectionCard(
              title: 'Personal Information',
              icon: Icons.person_outline_rounded,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _firstNameController,
                        decoration: _inputDec('First Name *'),
                        validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _lastNameController,
                        decoration: _inputDec('Last Name *'),
                        validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _jobTitleController,
                  decoration: _inputDec('Target Job Title *', hint: 'e.g. Senior Software Engineer'),
                  validator: (v) => v?.trim().isEmpty == true ? 'Required' : null,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: _inputDec('Email', icon: Icons.mail_outline_rounded),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s\-()]')),
                        ],
                        decoration: _inputDec('Phone', icon: Icons.phone_outlined, hint: '+1 234 567 890'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _locationController,
                        decoration: _inputDec('Location', icon: Icons.location_on_outlined, hint: 'e.g. Riyadh, SA'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _linkedinController,
                        decoration: _inputDec('LinkedIn', icon: Icons.link_rounded, hint: 'linkedin.com/in/user'),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // 2. Summary
            _buildSectionCard(
              title: 'Professional Summary',
              icon: Icons.notes_rounded,
              children: [
                TextFormField(
                  controller: _summaryController,
                  maxLines: 4,
                  decoration: _inputDec('Professional Summary', hint: 'Write a powerful summary highlighting your career achievements, core strengths, and objectives...'),
                ),
              ],
            ),

            // 3. Work Experience (مثل الريبو: Job Title, Company, Dates, Current, Responsibilities)
            _buildSectionCard(
              title: 'Work Experience',
              icon: Icons.work_outline_rounded,
              children: [
                if (_experiences.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text('No work experience added yet.', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                  )
                else
                  ..._experiences.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final exp = entry.value;
                    final dateText = exp.current
                        ? '${exp.startDate} - Present'
                        : '${exp.startDate} - ${exp.endDate}';
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10.0),
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(exp.jobTitle, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.navy, fontSize: 14.0)),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.navy),
                                onPressed: () => _openExperienceDialog(existing: exp, index: idx),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.redAccent),
                                onPressed: () => setState(() => _experiences.removeAt(idx)),
                              ),
                            ],
                          ),
                          Text('${exp.company} • $dateText', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 12.0)),
                          if (exp.responsibilities.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            ...exp.responsibilities.map((r) => Padding(
                                  padding: const EdgeInsets.only(bottom: 3.0),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('• ', style: TextStyle(color: AppColors.navy, fontWeight: FontWeight.bold)),
                                      Expanded(child: Text(r, style: const TextStyle(fontSize: 12.0, color: AppColors.textDark))),
                                    ],
                                  ),
                                )),
                          ],
                        ],
                      ),
                    );
                  }),
                const SizedBox(height: 6),
                OutlinedButton.icon(
                  onPressed: () => _openExperienceDialog(),
                  icon: const Icon(Icons.add_rounded, size: 18, color: AppColors.primary),
                  label: const Text('Add Experience', style: TextStyle(color: AppColors.navy, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),

            // 4. Education (مثل الريبو: Degree, Specialization, University, Graduation Year)
            _buildSectionCard(
              title: 'Education',
              icon: Icons.school_outlined,
              children: [
                if (_educations.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text('No education entries added.', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                  )
                else
                  ..._educations.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final edu = entry.value;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10.0),
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${edu.degree} in ${edu.specialization}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.navy, fontSize: 13.5)),
                                Text('${edu.university} • Graduated: ${edu.graduationYear}', style: const TextStyle(color: AppColors.primary, fontSize: 12.0, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 18, color: AppColors.navy),
                            onPressed: () => _openEducationDialog(existing: edu, index: idx),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.redAccent),
                            onPressed: () => setState(() => _educations.removeAt(idx)),
                          ),
                        ],
                      ),
                    );
                  }),
                const SizedBox(height: 6),
                OutlinedButton.icon(
                  onPressed: () => _openEducationDialog(),
                  icon: const Icon(Icons.add_rounded, size: 18, color: AppColors.primary),
                  label: const Text('Add Education', style: TextStyle(color: AppColors.navy, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),

            // 5. Technical Skills
            _buildSectionCard(
              title: 'Technical Skills',
              icon: Icons.psychology_outlined,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _techSkillInput,
                        decoration: _inputDec('Add Technical Skill', hint: 'e.g. Flutter, Node.js, SQL'),
                        onSubmitted: (_) => _addTechSkill(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      style: IconButton.styleFrom(backgroundColor: AppColors.primary),
                      onPressed: _addTechSkill,
                      icon: const Icon(Icons.add_rounded, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6.0,
                  runSpacing: 6.0,
                  children: _technicalSkills.map((s) {
                    return Chip(
                      label: Text(s, style: const TextStyle(fontSize: 12.0, color: AppColors.navy, fontWeight: FontWeight.bold)),
                      backgroundColor: AppColors.primaryLight,
                      deleteIcon: const Icon(Icons.close_rounded, size: 14.0, color: AppColors.primary),
                      onDeleted: () => setState(() => _technicalSkills.remove(s)),
                      side: BorderSide(color: AppColors.primary.withValues(alpha: 0.2)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    );
                  }).toList(),
                ),
              ],
            ),

            // 6. Personal Skills
            _buildSectionCard(
              title: 'Personal Skills (Soft Skills)',
              icon: Icons.emoji_people_rounded,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _persSkillInput,
                        decoration: _inputDec('Add Personal Skill', hint: 'e.g. Problem Solving, Time Management'),
                        onSubmitted: (_) => _addPersSkill(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      style: IconButton.styleFrom(backgroundColor: AppColors.primary),
                      onPressed: _addPersSkill,
                      icon: const Icon(Icons.add_rounded, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6.0,
                  runSpacing: 6.0,
                  children: _personalSkills.map((s) {
                    return Chip(
                      label: Text(s, style: const TextStyle(fontSize: 12.0, color: AppColors.navy, fontWeight: FontWeight.bold)),
                      backgroundColor: AppColors.surface,
                      deleteIcon: const Icon(Icons.close_rounded, size: 14.0, color: AppColors.primary),
                      onDeleted: () => setState(() => _personalSkills.remove(s)),
                      side: const BorderSide(color: AppColors.borderLight),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    );
                  }).toList(),
                ),
              ],
            ),

            // 7. Languages (مع مستوياتها مثل الريبو)
            _buildSectionCard(
              title: 'Languages',
              icon: Icons.language_rounded,
              children: [
                if (_languages.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text('No languages added.', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                  )
                else
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: _languages.map((l) {
                      return Chip(
                        label: Text('${l.language}: ${l.level}', style: const TextStyle(fontSize: 12.0, color: AppColors.navy, fontWeight: FontWeight.bold)),
                        backgroundColor: Colors.white,
                        deleteIcon: const Icon(Icons.close_rounded, size: 14.0, color: AppColors.primary),
                        onDeleted: () => setState(() => _languages.remove(l)),
                        side: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      );
                    }).toList(),
                  ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _openLanguageDialog,
                  icon: const Icon(Icons.add_rounded, size: 18, color: AppColors.primary),
                  label: const Text('Add Language', style: TextStyle(color: AppColors.navy, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),

            // 8. Certifications
            _buildSectionCard(
              title: 'Certifications',
              icon: Icons.verified_outlined,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _certInput,
                        decoration: _inputDec('Add Certificate', hint: 'e.g. AWS Certified Cloud Practitioner'),
                        onSubmitted: (_) => _addCert(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      style: IconButton.styleFrom(backgroundColor: AppColors.primary),
                      onPressed: _addCert,
                      icon: const Icon(Icons.add_rounded, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ..._certificates.map((c) {
                  return ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.military_tech_rounded, color: AppColors.primary, size: 20),
                    title: Text(c, style: const TextStyle(fontSize: 13.0, fontWeight: FontWeight.w600, color: AppColors.navy)),
                    trailing: IconButton(
                      icon: const Icon(Icons.close_rounded, size: 16, color: AppColors.textMuted),
                      onPressed: () => setState(() => _certificates.remove(c)),
                    ),
                  );
                }),
              ],
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
