import 'package:cloud_firestore/cloud_firestore.dart';

class ResumeExperience {
  final String jobTitle;
  final String company;
  final String startDate;
  final String endDate;
  final bool current;
  final List<String> responsibilities;

  const ResumeExperience({
    this.jobTitle = '',
    this.company = '',
    this.startDate = '',
    this.endDate = '',
    this.current = false,
    this.responsibilities = const [],
  });

  factory ResumeExperience.fromMap(Map<String, dynamic> map) {
    final rawResp = map['responsibilities'];
    final respList = rawResp is List ? List<String>.from(rawResp) : <String>[];

    return ResumeExperience(
      jobTitle: map['job_title'] ?? map['title'] ?? '',
      company: map['company'] ?? map['organization'] ?? '',
      startDate: map['start_date'] ?? map['period'] ?? '',
      endDate: map['end_date'] ?? '',
      current: map['current'] == true,
      responsibilities: respList,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'job_title': jobTitle,
      'company': company,
      'start_date': startDate,
      'end_date': endDate,
      'current': current,
      'responsibilities': responsibilities,
    };
  }
}

class ResumeEducation {
  final String degree;
  final String specialization;
  final String university;
  final String graduationYear;

  const ResumeEducation({
    this.degree = '',
    this.specialization = '',
    this.university = '',
    this.graduationYear = '',
  });

  factory ResumeEducation.fromMap(Map<String, dynamic> map) {
    return ResumeEducation(
      degree: map['degree'] ?? '',
      specialization: map['specialization'] ?? map['fieldOfStudy'] ?? '',
      university: map['university'] ?? '',
      graduationYear: map['graduation_year'] ?? map['graduationYear'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'degree': degree,
      'specialization': specialization,
      'university': university,
      'graduation_year': graduationYear,
    };
  }
}

class ResumeLanguage {
  final String language;
  final String level;

  const ResumeLanguage({
    this.language = '',
    this.level = '',
  });

  factory ResumeLanguage.fromMap(Map<String, dynamic> map) {
    return ResumeLanguage(
      language: map['language'] ?? '',
      level: map['level'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'language': language,
      'level': level,
    };
  }
}

class ResumeModel {
  final String uid;
  final String firstName;
  final String lastName;
  final String jobTitle;
  final String email;
  final String phone;
  final String location;
  final String linkedin;
  final String summary;
  final List<ResumeExperience> experiences;
  final List<ResumeEducation> educations;
  final List<String> technicalSkills;
  final List<String> personalSkills;
  final List<ResumeLanguage> languages;
  final List<String> certificates;
  final DateTime? updatedAt;

  const ResumeModel({
    required this.uid,
    this.firstName = '',
    this.lastName = '',
    this.jobTitle = '',
    this.email = '',
    this.phone = '',
    this.location = '',
    this.linkedin = '',
    this.summary = '',
    this.experiences = const [],
    this.educations = const [],
    this.technicalSkills = const [],
    this.personalSkills = const [],
    this.languages = const [],
    this.certificates = const [],
    this.updatedAt,
  });

  String get fullName => ('$firstName $lastName').trim();

  bool get isEmpty =>
      fullName.isEmpty &&
      jobTitle.isEmpty &&
      summary.isEmpty &&
      experiences.isEmpty &&
      educations.isEmpty &&
      technicalSkills.isEmpty &&
      personalSkills.isEmpty;

  factory ResumeModel.fromMap(Map<String, dynamic> data, {String uid = ''}) {
    DateTime? parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is DateTime) return val;
      return null;
    }

    final rawExp = data['experiences'];
    final expList = rawExp is List
        ? rawExp.map((e) => ResumeExperience.fromMap(Map<String, dynamic>.from(e))).toList()
        : <ResumeExperience>[];

    final rawEdu = data['education'] ?? data['educations'];
    final eduList = rawEdu is List
        ? rawEdu.map((e) => ResumeEducation.fromMap(Map<String, dynamic>.from(e))).toList()
        : (rawEdu is Map<String, dynamic>
            ? [ResumeEducation.fromMap(rawEdu)]
            : <ResumeEducation>[]);

    final rawTech = data['technical_skills'] ?? data['skills'];
    final techList = rawTech is List ? List<String>.from(rawTech) : <String>[];

    final rawPers = data['personal_skills'];
    final persList = rawPers is List ? List<String>.from(rawPers) : <String>[];

    final rawLangs = data['languages'];
    final langList = rawLangs is List
        ? rawLangs.map((l) {
            if (l is String) return ResumeLanguage(language: l, level: '');
            return ResumeLanguage.fromMap(Map<String, dynamic>.from(l));
          }).toList()
        : <ResumeLanguage>[];

    final rawCerts = data['certificates'];
    final certList = rawCerts is List ? List<String>.from(rawCerts) : <String>[];

    var fName = data['first_name'] ?? '';
    var lName = data['last_name'] ?? '';
    if (fName.isEmpty && lName.isEmpty && data['fullName'] != null) {
      final parts = (data['fullName'] as String).trim().split(' ');
      fName = parts.isNotEmpty ? parts.first : '';
      lName = parts.length > 1 ? parts.sublist(1).join(' ') : '';
    }

    return ResumeModel(
      uid: uid.isNotEmpty ? uid : (data['uid'] ?? ''),
      firstName: fName,
      lastName: lName,
      jobTitle: data['job_title'] ?? data['jobTitle'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      location: data['location'] ?? data['address'] ?? '',
      linkedin: data['linkedin'] ?? data['linkedinUrl'] ?? '',
      summary: data['professional_summary'] ?? data['summary'] ?? '',
      experiences: expList,
      educations: eduList,
      technicalSkills: techList,
      personalSkills: persList,
      languages: langList,
      certificates: certList,
      updatedAt: parseDate(data['updatedAt']),
    );
  }

  factory ResumeModel.fromFirestore(DocumentSnapshot doc) {
    final data = (doc.data() as Map<String, dynamic>?) ?? {};
    return ResumeModel.fromMap(data, uid: doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'first_name': firstName,
      'last_name': lastName,
      'fullName': fullName,
      'job_title': jobTitle,
      'email': email,
      'phone': phone,
      'location': location,
      'linkedin': linkedin,
      'professional_summary': summary,
      'experiences': experiences.map((e) => e.toMap()).toList(),
      'education': educations.map((e) => e.toMap()).toList(),
      'technical_skills': technicalSkills,
      'personal_skills': personalSkills,
      'languages': languages.map((l) => l.toMap()).toList(),
      'certificates': certificates,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
