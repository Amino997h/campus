import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/navigation/transitions.dart';
import '../../models/resume_model.dart';
import '../../models/user_model.dart';
import '../../models/project_model.dart';
import '../../data/profile_repository.dart';
import '../../data/resume_pdf_service.dart';
import '../screens/edit_resume_screen.dart';

class ResumeViewWidget extends StatelessWidget {
  final String uid;
  final bool isMe;
  final UserModel? userProfile;
  final List<ProjectModel> projects;
  final ResumeModel? resume;
  final ProfileRepository profileRepo;
  final VoidCallback? onResumeUpdated;

  const ResumeViewWidget({
    super.key,
    required this.uid,
    required this.isMe,
    this.userProfile,
    this.projects = const [],
    this.resume,
    required this.profileRepo,
    this.onResumeUpdated,
  });

  String _formatDateString(String dateStr) {
    if (dateStr.trim().isEmpty) return '';
    final parts = dateStr.trim().split('-');
    if (parts.length != 2) return dateStr;
    final year = parts[0];
    final monthInt = int.tryParse(parts[1]) ?? 0;
    const months = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    if (monthInt >= 1 && monthInt <= 12) {
      return '${months[monthInt]} $year';
    }
    return dateStr;
  }

  @override
  Widget build(BuildContext context) {
    // السيرة الذاتية التوضيحية الافتراضية المليئة بأسماء example للتأكيد على أنها مجرد نموذج تجريبي
    final effectiveResume = resume ??
        ResumeModel(
          uid: uid,
          firstName: 'Example',
          lastName: 'Candidate',
          jobTitle: 'Software Engineer Specialist (Example)',
          email: 'candidate.example@campus.edu',
          phone: '+1 555 019 2834',
          location: 'San Francisco, CA, USA',
          linkedin: 'https://linkedin.com/in/example-candidate',
          summary:
              'Dedicated and results-driven software engineering candidate with proven expertise in Flutter development, RESTful APIs, and full-stack software architecture. Experienced in leading agile student teams, delivering robust solutions, and optimizing code quality.',
          experiences: const [
            ResumeExperience(
              jobTitle: 'Senior Software Engineering Intern (Example)',
              company: 'Example Global Tech Corp, San Francisco, CA',
              startDate: '2023-06',
              endDate: '',
              current: true,
              responsibilities: [
                'Designed and developed scalable mobile features using modern state management patterns',
                'Collaborated with a cross-functional agile team of engineers and product designers',
                'Reduced application load times and memory footprint by 40 percent through caching optimizations',
              ],
            ),
            ResumeExperience(
              jobTitle: 'Junior Developer Intern (Example)',
              company: 'Example Innovations Lab, Boston, MA',
              startDate: '2022-01',
              endDate: '2023-05',
              current: false,
              responsibilities: [
                'Built and tested automated CI/CD pipeline scripts and unit tests',
                'Implemented responsive UI components conforming to strict design system standards',
                'Authored comprehensive technical documentation and API reference guides',
              ],
            ),
          ],
          educations: const [
            ResumeEducation(
              degree: 'Bachelor of Science (Example)',
              specialization: 'Computer Science & Software Engineering',
              university: 'Example University of Technology',
              graduationYear: '2024',
            ),
            ResumeEducation(
              degree: 'Associate Diploma (Example)',
              specialization: 'Information Technology & Systems',
              university: 'Example Technical Institute',
              graduationYear: '2021',
            ),
          ],
          technicalSkills: const [
            'Flutter',
            'Dart',
            'Firebase Cloud Architecture',
            'RESTful APIs',
            'Git & GitHub Workflows',
            'CI/CD Pipelines',
          ],
          personalSkills: const [
            'Agile Team Collaboration',
            'Critical Problem Solving',
            'Effective Technical Communication',
            'Project Leadership',
          ],
          languages: const [
            ResumeLanguage(language: 'English', level: 'Native / Bilingual'),
            ResumeLanguage(language: 'Arabic', level: 'Professional Working'),
            ResumeLanguage(language: 'French', level: 'Conversational'),
          ],
          certificates: const [
            'Google Certified Professional Cloud Developer - Google - 2024',
            'AWS Certified Solutions Architect (Example) - Amazon Web Services - 2023',
            'Meta Professional Mobile Developer Certificate - Coursera - 2022',
          ],
        );

    // تجميع عناصر شريط الاتصال (Contact Bar) المفصولة بـ |
    final contactItems = <String>[];
    if (effectiveResume.location.isNotEmpty) contactItems.add(effectiveResume.location);
    if (effectiveResume.phone.isNotEmpty) contactItems.add(effectiveResume.phone);
    if (effectiveResume.email.isNotEmpty) contactItems.add(effectiveResume.email);
    if (effectiveResume.linkedin.isNotEmpty) contactItems.add(effectiveResume.linkedin);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // أزرار التحكم العلوية المتناسقة مع التوجه الفني لتطبيق Campus
        if (isMe)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                    onPressed: () async {
                      final res = await Navigator.push(
                        context,
                        SlidePageTransition(
                          page: EditResumeScreen(
                            uid: uid,
                            userProfile: userProfile,
                            initialResume: resume,
                            profileRepo: profileRepo,
                          ),
                        ),
                      );
                      if (res == true) {
                        onResumeUpdated?.call();
                      }
                    },
                    icon: const Icon(Icons.edit_note_rounded, size: 20),
                    label: const Text(
                      'Edit Information',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.navy,
                      side: const BorderSide(color: AppColors.navy, width: 1.2),
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                    onPressed: () async {
                      try {
                        await ResumePdfService.printOrSavePdf(effectiveResume);
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Could not export PDF: $e'),
                              backgroundColor: AppColors.primary,
                            ),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.download_rounded, size: 19, color: AppColors.navy),
                    label: const Text(
                      'Save as PDF',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                    ),
                  ),
                ),
              ],
            ),
          ),

        // ورقة السيرة الذاتية (A4 ATS Standard Resume Sheet)
        // خلفية رمادية هادئة مثل html { background: #e5e7eb; } والورقة بيضاء نقية
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4.0),
            border: Border.all(color: const Color(0xFFD1D5DB), width: 1.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 26.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // =====================================
              // HEADER (الترويسة: Name, Job Title, Contact)
              // =====================================
              Center(
                child: Column(
                  children: [
                    if (effectiveResume.fullName.isNotEmpty)
                      Text(
                        effectiveResume.fullName,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Arial',
                          fontSize: 24.0,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827),
                          letterSpacing: 0.5,
                          height: 1.1,
                        ),
                      ),
                    if (effectiveResume.jobTitle.isNotEmpty) ...[
                      const SizedBox(height: 7.0),
                      Text(
                        effectiveResume.jobTitle,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Arial',
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827),
                        ),
                      ),
                    ],
                    if (contactItems.isNotEmpty) ...[
                      const SizedBox(height: 10.0),
                      Text(
                        contactItems.join('  |  '),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Arial',
                          fontSize: 10.0,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF111827),
                          height: 1.35,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16.0),
                    const Divider(
                      height: 2.0,
                      thickness: 2.0,
                      color: Color(0xFF111827),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18.0),

              // =====================================
              // PROFESSIONAL SUMMARY
              // =====================================
              if (effectiveResume.summary.isNotEmpty) ...[
                _buildSectionHeader('PROFESSIONAL SUMMARY'),
                const SizedBox(height: 8.0),
                Text(
                  effectiveResume.summary,
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                    fontFamily: 'Arial',
                    fontSize: 11.0,
                    height: 1.4,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 18.0),
              ],

              // =====================================
              // WORK EXPERIENCE (Title, Company, Date, Bullets)
              // =====================================
              if (effectiveResume.experiences.isNotEmpty) ...[
                _buildSectionHeader('WORK EXPERIENCE'),
                const SizedBox(height: 8.0),
                ...effectiveResume.experiences.map((exp) {
                  final start = _formatDateString(exp.startDate);
                  final end = exp.current ? 'Present' : _formatDateString(exp.endDate);
                  final dateText = (start.isNotEmpty && end.isNotEmpty)
                      ? '$start – $end'
                      : (start.isNotEmpty ? start : end);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                exp.jobTitle,
                                style: const TextStyle(
                                  fontFamily: 'Arial',
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF111827),
                                ),
                              ),
                            ),
                            if (dateText.isNotEmpty)
                              Text(
                                dateText,
                                style: const TextStyle(
                                  fontFamily: 'Arial',
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF111827),
                                ),
                              ),
                          ],
                        ),
                        if (exp.company.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 2.0),
                            child: Text(
                              exp.company,
                              style: const TextStyle(
                                fontFamily: 'Arial',
                                fontSize: 11.0,
                                fontStyle: FontStyle.italic,
                                color: Color(0xFF111827),
                              ),
                            ),
                          ),
                        if (exp.responsibilities.isNotEmpty) ...[
                          const SizedBox(height: 6.0),
                          ...exp.responsibilities.map((resp) {
                            return Padding(
                              padding: const EdgeInsets.only(left: 14.0, bottom: 4.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '• ',
                                    style: TextStyle(
                                      fontFamily: 'Arial',
                                      fontSize: 11.0,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF111827),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      resp,
                                      style: const TextStyle(
                                        fontFamily: 'Arial',
                                        fontSize: 11.0,
                                        height: 1.35,
                                        color: Color(0xFF111827),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 6.0),
              ],

              // =====================================
              // EDUCATION (Degree in Specialization, University, Year)
              // =====================================
              if (effectiveResume.educations.isNotEmpty) ...[
                _buildSectionHeader('EDUCATION'),
                const SizedBox(height: 8.0),
                ...effectiveResume.educations.map((edu) {
                  var eduTitle = edu.degree;
                  if (edu.specialization.isNotEmpty) {
                    if (eduTitle.isNotEmpty) {
                      eduTitle += ' in ${edu.specialization}';
                    } else {
                      eduTitle = edu.specialization;
                    }
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                eduTitle,
                                style: const TextStyle(
                                  fontFamily: 'Arial',
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF111827),
                                ),
                              ),
                              if (edu.university.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 2.0),
                                  child: Text(
                                    edu.university,
                                    style: const TextStyle(
                                      fontFamily: 'Arial',
                                      fontSize: 11.0,
                                      color: Color(0xFF111827),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (edu.graduationYear.isNotEmpty)
                          Text(
                            'Graduated: ${edu.graduationYear}',
                            style: const TextStyle(
                              fontFamily: 'Arial',
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF111827),
                            ),
                          ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 6.0),
              ],

              // =====================================
              // SKILLS (Technical Skills & Personal Skills)
              // =====================================
              if (effectiveResume.technicalSkills.isNotEmpty ||
                  effectiveResume.personalSkills.isNotEmpty) ...[
                _buildSectionHeader('SKILLS'),
                const SizedBox(height: 8.0),
                if (effectiveResume.technicalSkills.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6.0),
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontFamily: 'Arial',
                          fontSize: 11.0,
                          height: 1.35,
                          color: Color(0xFF111827),
                        ),
                        children: [
                          const TextSpan(
                            text: 'Technical Skills: ',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          TextSpan(text: effectiveResume.technicalSkills.join(', ')),
                        ],
                      ),
                    ),
                  ),
                if (effectiveResume.personalSkills.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6.0),
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontFamily: 'Arial',
                          fontSize: 11.0,
                          height: 1.35,
                          color: Color(0xFF111827),
                        ),
                        children: [
                          const TextSpan(
                            text: 'Personal Skills: ',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          TextSpan(text: effectiveResume.personalSkills.join(', ')),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 12.0),
              ],

              // =====================================
              // LANGUAGES (Language: Level)
              // =====================================
              if (effectiveResume.languages.isNotEmpty) ...[
                _buildSectionHeader('LANGUAGES'),
                const SizedBox(height: 8.0),
                ...effectiveResume.languages.map((l) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 5.0),
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontFamily: 'Arial',
                          fontSize: 11.0,
                          color: Color(0xFF111827),
                        ),
                        children: [
                          TextSpan(
                            text: l.language,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          if (l.level.isNotEmpty) TextSpan(text: ': ${l.level}'),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 12.0),
              ],

              // =====================================
              // CERTIFICATIONS (Bullet Points)
              // =====================================
              if (effectiveResume.certificates.isNotEmpty) ...[
                _buildSectionHeader('CERTIFICATIONS'),
                const SizedBox(height: 8.0),
                ...effectiveResume.certificates.map((cert) {
                  return Padding(
                    padding: const EdgeInsets.only(left: 14.0, bottom: 4.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '• ',
                          style: TextStyle(
                            fontFamily: 'Arial',
                            fontSize: 11.0,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF111827),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            cert,
                            style: const TextStyle(
                              fontFamily: 'Arial',
                              fontSize: 11.0,
                              height: 1.35,
                              color: Color(0xFF111827),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24.0),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Arial',
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 5.0),
        const Divider(
          height: 1.5,
          thickness: 1.5,
          color: Color(0xFF111827),
        ),
      ],
    );
  }
}
