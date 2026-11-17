# Campus App - Comprehensive Architectural Refactoring Plan
## معمارية Clean Feature-First Architecture لتطبيق التواصل الجامعي "Campus"

---

## 1. التقرير التشخيصي للوضع الراهن (Codebase Diagnostic Report)

تم فحص وتحليل كامل شجرة مشروع `Campus` المكون من 29 ملفاً برمجياً في مجلد `lib/`. أظهر التحليل النقاط التشخيصية التالية:

### أبرز التحديات ونقاط الضعف الحالية:
1. **الغياب التام لنماذج البيانات (Zero Data Models):**
   - لا يحتوي المشروع حالياً على أي كلاس لتمثيل النماذج (`PostModel`, `UserModel`, `CommentModel`, `NotificationModel`, `ChatMessageModel`).
   - تعتمد كافة الشاشات والخدمات على قراءة كائنات `Map<String, dynamic>` أو `DocumentSnapshot` مباشرة، مع استخدام مفاتيح نصية مبعثرة (`data['authorName']`, `data['likes']`, `data['content']`...).
   - غياب الأمان النوعي (Type Safety)، وغياب التحقق من صحة الحقول (Validation)، وغياب نمط `copyWith` للتعديل الآمن.

2. **خدمة الفايربيس العملاقة (Monolithic God-Class):**
   - يحتوي ملف `lib/services/firestore_service.dart` على 489 سطراً ويجمع أكثر من 7 مسؤوليات متباينة في كلاس واحد:
     - إدارة المنشورات وإعجاباتها.
     - إدارة التعليقات وإعجاباتها والردود عليها.
     - إدارة الإشعارات المحلية والخارجية.
     - إدارة المحادثات والرسائل وقراءة وحذف الشات.
     - إدارة المتابعة (Follow / Unfollow).
     - إدارة الملف الشخصي وفحص توفر اسم المستخدم.
     - حساب نقاط الكارما الجامعية (Campus Karma Points).
   - هذا يخالف مبدأ المسؤولية الواحدة (Single Responsibility Principle - SRP).

3. **التكرار المفرط للأكواد (DRY Principle Violations):**
   - **بطاقة المنشور (Post Card):** أعيدت كتابة كامل كود بطاقة المنشور وتفاصيلها وDouble-tap heart animation وAction bar داخل `profile.dart` (أكثر من 180 سطراً مكرراً بالكامل)، بدلاً من إعادة استخدام `PostCardWidget`.
   - **قوائم الخيارات ومربعات الحوار (Post Options & Dialogs):** كود القائمة السفلية لخيارات البوست (تعديل / حذف / إبلاغ) ومربع حوار تأكيد الحذف ومربع حوار تعديل النص مكرر حرفياً في `main.dart` و `profile.dart`.
   - **تنسيق التواريخ والأوقات (Date/Time Formatting):** توجد 4 دوال مختلفة ومكررة لتنسيق الوقت:
     - `_formatTimeAgo` في `post_card_widget.dart`
     - `_formatTimeAgo` في `profile.dart`
     - `_formatMessageTime` و `_formatDateSeparator` في `chat_screen.dart`
     - `_formatChatTime` في `messages_drawer.dart`
   - **معالجة الصور المشفرة (Base64 Image Handling):** منطق اختيار الصورة وضغطها وتحويلها إلى Base64 مكرر في `create_post_screen.dart` و `chat_screen.dart` و `edit_profile_screen.dart`.

4. **تجاوز طبقة الخدمات (Leaky Abstractions & Direct Database Queries):**
   - بعض عناصر الواجهة تستدعي `FirebaseFirestore.instance` أو `FirebaseAuth.instance` مباشرة متجاوزة الـ Services:
     - ويدجت `DynamicUserAvatar` تستعلم مباشرة عن وثيقة المستخدم.
     - شاشة `profile.dart` تستعلم مباشرة عن بيانات الحساب.
     - شاشة `SettingsScreen` تستعلم وتعدل `showOnlineStatus` مباشرة في Firestore.
     - شاشة `SearchScreen` تستعلم مباشرة عن `collection('users')`.

5. **مخالفات لمعايير Dart القياسية ومشاكل في الـ Dependencies:**
   - شاشة الملف الشخصي سميت `class profile extends StatefulWidget` بحرف صغير (lowercase) في ملف `profile.dart`، مما يخالف اصطلاحات UpperCamelCase في دارت.
   - وجود مكتبة `material_ui: ^1.1.0` في `pubspec.yaml` غير مستخدمة إطلاقاً وتتسبب في إطلاق 30 تحذير deprecation لـ `package:flutter/material.dart` في أداة `flutter analyze`.
   - وجود تحذيرات `use_build_context_synchronously` عبر الـ async gaps في شاشة استعادة كلمة المرور `forgot_password_screen.dart`.
   - استخدام التابع القديم `.withOpacity(...)` بدلاً من الموصى به حديثاً في فلاتر `.withValues(alpha: ...)`.

---

## 2. الهيكلية المعمارية الجديدة (Feature-First Clean Architecture)

سنعتمد معمارية **Feature-First Clean Architecture**، وهي المعمارية القياسية المعتمدة في مشاريع فلاتر الإنتاجية الكبرى لضمان قابلية التوسع اللانهائي وسهولة الصيانة والاختبار.

### شجرة المجلدات المقترحة (`lib/` Directory Structure):

```text
lib/
├── app.dart                               # ويدجت التطبيق الرئيسية ومحددات الـ Theme والتوجيه
├── auth_wrapper.dart                      # مراقب حالة الجلسة وتوجيه المستخدم للرئيسية أو الدخول
├── firebase_options.dart                  # إعدادات الفايربيس المولدة للمشروع
├── main.dart                              # نقطة الانطلاق: تهيئة الفايربيس وخدمات النظام و runApp
│
├── core/                                  # الطبقة الأساسية المشتركة بين كافة الميزات
│   ├── constants/
│   │   ├── app_colors.dart                # لوحة الألوان الموحدة (Primary الوردي، Navy الكحلي، إلخ)
│   │   ├── app_constants.dart             # الثوابت العامة والنصوص الافتراضية
│   │   └── campus_majors.dart             # قائمة التخصصات الجامعية المعتمدة
│   ├── theme/
│   │   └── app_theme.dart                 # مواصفات السمة (ThemeData, Fonts, AppBarTheme, Inputs)
│   ├── utils/
│   │   ├── date_time_utils.dart           # تنسيق الأوقات الموحد (Time Ago, Chat Time, Separators)
│   │   ├── image_utils.dart               # معالجة الصور وضغطها والتحويل من وإلى Base64
│   │   └── ui_helpers.dart                # مساعدات الـ SnackBar وقوائم الخيارات ومربعات الحوار
│   ├── navigation/
│   │   └── transitions.dart               # حركات الانتقال السلسة بين الشاشات (SlidePageTransition)
│   └── widgets/                           # الويدجتس العامة المشتركة
│       ├── post_image_widget.dart         # عارض الصور الذكي (يدعم Base64 و Network URLs)
│       ├── user_avatar.dart               # الأفتار الدائري الكلاسيكي الثابت
│       ├── dynamic_user_avatar.dart       # الأفتار اللحظي مع مؤشر الاتصال الوردي المتوهج
│       └── expandable_text.dart           # عرض النصوص الطويلة مع إمكانية التوسيع والطي
│
└── features/                              # ميزات التطبيق المستقلة (Feature-First)
    │
    ├── auth/                              # ميزة المصادقة وإدارة الحسابات
    │   ├── data/
    │   │   └── auth_repository.dart       # عمليات تسجيل الدخول، إنشاء الحساب، استعادة الباسورد، الخروج
    │   └── presentation/
    │       ├── screens/
    │       │   ├── login_screen.dart
    │       │   ├── signup_screen.dart
    │       │   └── forgot_password_screen.dart
    │       └── widgets/
    │           └── campus_auth_header.dart
    │
    ├── posts/                             # ميزة المنشورات والتايم لاين والتفاعلات
    │   ├── models/
    │   │   ├── post_model.dart            # نموذج المنشور الموحد مع converters و helpers
    │   │   └── comment_model.dart         # نموذج التعليق الموحد مع دعم الردود
    │   ├── data/
    │   │   └── post_repository.dart       # تدفق المنشورات، النشر، التعديل، الحذف، اللايك، التعليقات
    │   └── presentation/
    │       ├── screens/
    │       │   ├── home_feed_screen.dart  # شاشة الصفحة الرئيسية للتايم لاين
    │       │   ├── create_post_screen.dart
    │       │   └── post_details_screen.dart
    │       └── widgets/
    │           ├── post_card_widget.dart  # بطاقة المنشور الموحدة المستخدمة في الفيد والملف الشخصي
    │           ├── post_action_bar.dart   # شريط التفاعل (لايك، تعليق، مشاركة)
    │           ├── like_button_widget.dart# زر اللايك المتحرك مع التحديث التفاؤلي الفوري
    │           ├── feed_post_composer.dart# شريط كتابة المنشور السريع أعلى الصفحة الرئيسية
    │           └── post_options_dialogs.dart# نوافذ تعديل وحذف وإبلاغ المنشور الموحدة
    │
    ├── profile/                           # ميزة الملف الشخصي والإعدادات والمتابعة ونقاط الكارما
    │   ├── models/
    │   │   └── user_model.dart            # نموذج بيانات المستخدم الجامعي الشامل
    │   ├── data/
    │   │   └── profile_repository.dart    # تدفق الملف، التعديل، المتابعة، فحص اليوزر، نقاط الكارما
    │   └── presentation/
    │       ├── screens/
    │       │   ├── profile_screen.dart    # إعادة تسمية الكلاس إلى ProfileScreen بالاصطلاح الصحيح
    │       │   ├── edit_profile_screen.dart
    │       │   └── settings_screen.dart
    │       └── widgets/
    │           ├── profile_stats_row.dart # صف إحصائيات المتابعين والمنشورات ونقاط الكارما
    │           └── profile_action_bar.dart# أزرار المتابعة / تعديل الملف الشخصي
    │
    ├── chat/                              # ميزة المحادثات الفورية والرسائل
    │   ├── models/
    │   │   ├── chat_message_model.dart    # نموذج الرسالة الفردية (نص وصورة ووقت)
    │   │   └── chat_conversation_model.dart # نموذج بيانات المحادثة والرسالة الأخيرة
    │   ├── data/
    │   │   └── chat_repository.dart       # تدفق الرسائل والمحادثات، الإرسال، القراءة، الحذف
    │   └── presentation/
    │       ├── screens/
    │       │   └── chat_screen.dart       # شاشة المحادثة المباشرة مع فواصل التواريخ
    │       └── widgets/
    │           ├── messages_drawer.dart   # درج المحادثات الجانبي
    │           ├── chat_bubble.dart       # فقاعة الرسالة (مرسل / مستقبل، نصوص وصور)
    │           └── chat_input_field.dart  # شريط إدخال الرسائل واختيار الصور
    │
    ├── notifications/                     # ميزة الإشعارات والتنبيهات
    │   ├── models/
    │   │   └── notification_model.dart    # نموذج الإشعار وتصنيفاته
    │   ├── data/
    │   │   ├── notification_repository.dart # جلب وتحديث الإشعارات في الفايربيس
    │   │   └── local_notification_service.dart # منسق التنبيهات المحلية في نظام أندرويد
    │   └── presentation/
    │       └── widgets/
    │           ├── notifications_drawer.dart # درج الإشعارات الجانبي مع فلترة الأنواع
    │           └── notification_tile.dart    # عنصر عرض الإشعار مع أيقونته الملونة
    │
    ├── presence/                          # ميزة التواجد اللحظي وحالة الاتصال
    │   └── data/
    │       └── presence_service.dart      # مراقبة دورة حياة التطبيق ومزامنة حالة أونلاين
    │
    └── search/                            # ميزة البحث الجامعي المتقدم
        ├── data/
        │   └── search_repository.dart     # البحث الموحد في الطلاب والمنشورات
        └── presentation/
            ├── screens/
            │   └── search_screen.dart     # شاشة البحث مع فئات All, Students, Posts
            └── widgets/
                └── search_category_filter.dart
```

---

## 3. مواصفات النماذج الموحدة (Unified Models Specification)

سيتم إنشاء 6 نماذج بيانات غير قابلة للتغيير (Immutable) تدعم:
1. البناء الكامل من `DocumentSnapshot` و `Map<String, dynamic>`.
2. التحويل الكامل إلى `Map<String, dynamic>` متوافق 100% مع Firestore.
3. التعديل الآمن عبر دالة `copyWith`.
4. التحقق التلقائي ومعالجة القيم الفارغة (Null-Safety & Default Fallbacks).

### 1. `UserModel` (`lib/features/profile/models/user_model.dart`):
```dart
class UserModel {
  final String uid;
  final String name;
  final String username;
  final String usernameLower;
  final String email;
  final String major;
  final String bio;
  final String photoUrl;
  final DateTime? createdAt;
  final int postsCount;
  final int followersCount;
  final int followingCount;
  final List<String> followers;
  final List<String> following;
  final bool isOnline;
  final bool showOnlineStatus;
  final DateTime? lastSeen;
  
  // Helpers:
  bool isFollowing(String targetUid);
  String get displayHandle => '@$username';
}
```

### 2. `PostModel` (`lib/features/posts/models/post_model.dart`):
```dart
class PostModel {
  final String id;
  final String authorName;
  final String authorUid;
  final String authorPhoto;
  final String major;
  final String content;
  final String imageUrl;
  final List<String> likes;
  final int likesCount;
  final int commentsCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  
  // Helpers:
  bool isLikedBy(String uid) => likes.contains(uid);
  bool isOwner(String uid) => authorUid == uid;
  bool get hasImage => imageUrl.isNotEmpty;
}
```

### 3. `CommentModel` (`lib/features/posts/models/comment_model.dart`):
```dart
class CommentModel {
  final String id;
  final String authorName;
  final String authorUid;
  final String authorPhoto;
  final String text;
  final String? replyToCommentId;
  final String? replyToAuthorName;
  final List<String> likes;
  final int likesCount;
  final DateTime? createdAt;
  
  // Helpers:
  bool get isReply => replyToAuthorName != null && replyToAuthorName!.isNotEmpty;
  bool isLikedBy(String uid) => likes.contains(uid);
}
```

### 4. `NotificationModel` (`lib/features/notifications/models/notification_model.dart`):
```dart
class NotificationModel {
  final String id;
  final String targetUid;
  final String title;
  final String subtitle;
  final String type; // 'like' | 'comment' | 'follow' | 'post'
  final String relatedId;
  final bool unread;
  final DateTime? createdAt;
}
```

### 5. `ChatMessageModel` (`lib/features/chat/models/chat_message_model.dart`):
```dart
class ChatMessageModel {
  final String id;
  final String senderId;
  final String senderName;
  final String text;
  final String imageUrl;
  final DateTime? createdAt;
  
  // Helpers:
  bool isMe(String currentUid) => senderId == currentUid;
  bool get hasImage => imageUrl.isNotEmpty;
  bool get hasText => text.isNotEmpty;
}
```

### 6. `ChatConversationModel` (`lib/features/chat/models/chat_conversation_model.dart`):
```dart
class ChatConversationModel {
  final String chatId;
  final String lastMessage;
  final DateTime? lastMessageTime;
  final String lastSenderId;
  final List<String> participants;
  final String? unreadBy;
  
  // Helpers:
  bool isUnreadFor(String currentUid) => unreadBy == currentUid;
  String getOtherUid(String myUid) => participants.firstWhere((id) => id != myUid, orElse: () => '');
}
```

---

## 4. تقسيم طبقة الخدمات (Modular Repositories)

بدلاً من ملف `firestore_service.dart` الأحادي، نقسم العمليات إلى 6 مستودعات متخصصة:

1. **`AuthRepository`** (`features/auth/data/auth_repository.dart`):
   - `currentUser`, `authStateChanges`.
   - `signUp(email, password, name, username, major)`.
   - `signIn(email, password)`.
   - `resetPassword(email)`.
   - `signOut()`.

2. **`PostRepository`** (`features/posts/data/post_repository.dart`):
   - `getPostsStream()` -> `Stream<List<PostModel>>`.
   - `getPostsFuture()` -> `Future<List<PostModel>>`.
   - `createPost(text, imageUrl)` (مع تحديث عداد المنشورات وإشعار المتابعين تلقائياً).
   - `updatePostText(postId, newText)`.
   - `deletePost(postId)` (مع خصم عداد المنشورات).
   - `toggleLike(postId, currentLikes, authorUid, contentSnippet)`.
   - `getCommentsStream(postId)` -> `Stream<List<CommentModel>>`.
   - `addComment(postId, text, postAuthorUid, replyToCommentId, replyToAuthorName)`.
   - `toggleCommentLike(...)`.

3. **`ProfileRepository`** (`features/profile/data/profile_repository.dart`):
   - `getUserProfileStream(uid)` -> `Stream<UserModel?>`.
   - `getUserPostsStream(uid)` -> `Stream<List<PostModel>>`.
   - `updateProfile(name, username, major, bio, photoUrl)`.
   - `isUsernameAvailable(username, excludeUid)`.
   - `toggleFollow(targetUid)` -> `Future<bool>`.
   - `getUserPointsStream(uid)` -> `Stream<int>` (حساب نقاط الكارما الجامعية).

4. **`ChatRepository`** (`features/chat/data/chat_repository.dart`):
   - `getUserChatsStream(currentUid)` -> `Stream<List<ChatConversationModel>>`.
   - `getChatMessagesStream(chatId)` -> `Stream<List<ChatMessageModel>>`.
   - `sendMessage(chatId, recipientName, recipientUid, text, imageUrl)`.
   - `markChatAsRead(chatId, currentUid)`.
   - `deleteChat(chatId)`.

5. **`NotificationRepository`** (`features/notifications/data/notification_repository.dart`):
   - `getMyNotificationsStream(uid)` -> `Stream<List<NotificationModel>>`.
   - `markNotificationAsRead(notificationId)`.
   - `createNotification(targetUid, title, subtitle, type, relatedId)`.

6. **`SearchRepository`** (`features/search/data/search_repository.dart`):
   - `searchStudents(query)` -> `Stream<List<UserModel>>`.
   - `searchPosts(query)` -> `Stream<List<PostModel>>`.

---

## 5. خطة إزالة التكرار وتوحيد الواجهات (DRY & UI Refactoring)

1. **توحيد بطاقة المنشور (`PostCardWidget`):**
   - نقل `PostCardWidget` إلى `features/posts/presentation/widgets/post_card_widget.dart`.
   - تعديل الويدجت لتستقبل `PostModel` موحداً بدلاً من تمرير `DocumentSnapshot` وعشرات المتغيرات المنفصلة.
   - استخدام نفس الويدجت في كل من `HomeFeedScreen` و `ProfileScreen`، مما يحذف فوراً 180 سطراً مكرراً في `profile.dart`.

2. **توحيد مربعات حوار المنشورات (`PostOptionsDialogs`):**
   - استخراج القائمة السفلية للخيارات (Edit, Delete, Report) ومربع حوار تعديل المنشور ومربع حوار تأكيد الحذف في ملف مساعد موحد `features/posts/presentation/widgets/post_options_dialogs.dart`، وتوفير دالة استدعاء ثابتة:
     `PostOptionsDialogs.showPostOptions(context, post, onEdit, onDelete)`.

3. **توحيد أدوات الوقت والتاريخ (`DateTimeUtils`):**
   - إنشاء كلاس `DateTimeUtils` داخل `core/utils/date_time_utils.dart` يجمع:
     - `timeAgo(DateTime? date)` -> "Just now", "5m ago", "2h ago", "Yesterday", "3d ago".
     - `chatMessageTime(DateTime? date)` -> "10:30 AM".
     - `chatDateSeparator(DateTime date)` -> "Today", "Yesterday", "Jan 15, 2026".
     - `chatListTime(DateTime? date)` -> "10:30 AM", "Mon", "15/1".
     - `isSameDay(DateTime d1, DateTime d2)` -> مقارنة التواريخ بدقة.

4. **توحيد معالجة وضغط واختيار الصور (`ImageUtils`):**
   - إنشاء `ImageUtils` داخل `core/utils/image_utils.dart` لتوفير:
     - `pickImageFromGallery({int maxWidth, int maxHeight, int quality})` -> `Future<String?>` (Base64 Data URI جاهز).
     - `pickImageFromCamera({int maxWidth, int maxHeight, int quality})` -> `Future<String?>`.
     - `decodeBase64(String base64Uri)` -> `Uint8List`.
     - إظهار قائمة اختيار الكاميرا أو المعرض (BottomSheet موحد).

5. **تصحيح شاشة الملف الشخصي (`ProfileScreen`):**
   - إعادة تسمية `class profile` إلى `class ProfileScreen` في ملف `profile_screen.dart`، وحذف جميع الواردات غير المستخدمة والتحذيرات.

6. **تنظيف `pubspec.yaml` والتحذيرات:**
   - إزالة حزمة `material_ui: ^1.1.0` غير المستخدمة لحل 30 تحذير deprecation فوراً.
   - استبدال `.withOpacity(...)` بـ `.withValues(alpha: ...)`.
   - معالجة `use_build_context_synchronously` عبر فحص `if (!mounted) return;` قبل أي وصول إلى `BuildContext`.

---

## 6. مصفوفة الضمان والحفاظ التام 100% على كافة الميزات (Feature Preservation Matrix)

| الميزة | الوضع الراهن | المعمارية الجديدة | حالة الضمان |
| :--- | :--- | :--- | :--- |
| **تغذية المنشورات (Home Feed)** | بطاقات مسطحة `elevation: 2`، `borderLight`، أيقونات `navy` | نفس التصميم الدقيق عبر `HomeFeedScreen` و `PostCardWidget` | **محفوظة 100%** |
| **مربع كتابة البوست السريع** | أفتار المستخدم + Textfield للقراءة فقط مع أيقونة إضافة صورة | ويدجت `FeedPostComposer` مستخرجة ومربوطة بـ `CreatePostScreen` | **محفوظة 100%** |
| **نشر بوست جديد** | نص + صورة Base64 + تحديث عداد البوستات وإشعار المتابعين | `CreatePostScreen` عبر `PostRepository.createPost` بنفس المنطق | **محفوظة 100%** |
| **تعديل وحذف المنشور** | متاح فقط لصاحب البوست مع مربعات حوار التأكيد والتعديل | `PostOptionsDialogs` موحدة بين الفيد والبروفايل مع فحص الملكية | **محفوظة 100%** |
| **الإعجاب بالمنشور (Like)** | زر تفاعلي مع أنيميشن وتحديث محلي فوري + إشعار الكاتب | `LikeButtonWidget` بمحرك الأنيميشن الأصلي والتحديث التفاؤلي | **محفوظة 100%** |
| **الدبل تاب على الصورة** | نقرتان على صورة البوست تفجر قلب وردي متوهج وتضع لايك | `PostCardWidget` مع `_triggerDoubleTapLike` وأنيميشن القلب المطاطي | **محفوظة 100%** |
| **مشاركة المنشور** | إشعار SnackBar عائم بنسخ الرابط ولون `AppColors.primary` | `UIHelpers.showSnackBar` مع المحافظة التامة على المظهر | **محفوظة 100%** |
| **تفاصيل البوست والتعليقات** | شاشة تفاصيل، استعراض الردود، والرد على تعليق محدد | `PostDetailsScreen` مع تمرير `PostModel` ودعم `replyToCommentId` | **محفوظة 100%** |
| **الإعجاب بالتعليقات** | زر لايك مخصص لكل تعليق مع إشعار كاتب التعليق | `PostRepository.toggleCommentLike` مع التحديث الفوري | **محفوظة 100%** |
| **الملف الشخصي والبروفايل** | استعراض الحساب، الأفتار، التخصص، البايو، إحصائيات المتابعة | `ProfileScreen` بربط متكامل مع `UserModel` و `ProfileRepository` | **محفوظة 100%** |
| **نظام نقاط الكارما (Campus Points)** | 3 نقاط للبوست، 1 نقطة لكل 10 لايكات، 1 نقطة لكل تعليق | `ProfileRepository.getUserPointsStream` بنفس المعادلة الحسابية تماماً | **محفوظة 100%** |
| **المتابعة الفورية (Follow/Unfollow)** | متابعة المستخدم، تحديث العدادين وإرسال إشعار متابعة | `ProfileRepository.toggleFollow` بنفس التحديث المتزامن | **محفوظة 100%** |
| **تعديل الملف الشخصي** | تعديل الاسم، اسم المستخدم الفريد، التخصص، البايو، الأفتار | `EditProfileScreen` مع فحص `isUsernameAvailable` المسبق | **محفوظة 100%** |
| **المحادثات المباشرة (Chat)** | قائمة مقلوبة `reverse: true`، نصوص وصور وفواصل الأيام | `ChatScreen` مع `ChatRepository` وعارض الصور المحدث | **محفوظة 100%** |
| **إرسال الصور في الشات** | اختيار من الكاميرا أو المعرض وإرسال Base64 وشريط تقدم | `ImageUtils` مدمج مع `ChatScreen` مع شريط التقدم الأصلي | **محفوظة 100%** |
| **درج الرسائل (Messages Drawer)** | استعراض المحادثات، الترتيب الزمني، نقطة عدم القراءة | `MessagesDrawer` مع `ChatConversationModel` | **محفوظة 100%** |
| **حذف المحادثة بالكامل** | حذف جميع رسائل الـ sub-collection ووثيقة المحادثة | `ChatRepository.deleteChat` مع رسالة تأكيد الحذف | **محفوظة 100%** |
| **درج الإشعارات والفرز** | استعراض الإشعارات، تمييز الأيقونات والألوان، التعليم كمقروء | `NotificationsDrawer` مع الانتقال الذكي لمصدر الإشعار | **محفوظة 100%** |
| **التنبيهات المحلية (Push/Local)** | تنبيهات الهاتف لأي تفاعل جديد أو رسالة عبر NotificationService | `LocalNotificationService` مع نفس إعدادات القناة والصوت | **محفوظة 100%** |
| **حالة الاتصال (Online Presence)** | متابعة حالة التطبيق، النقطة الوردية المتوهجة، إخفاء الحالة | `PresenceService` مدمج في دورة الحياة مع احترام خيار المستخدم | **محفوظة 100%** |
| **البحث الجامعي (Search)** | بحث الطلاب والمنشورات وفلترة All, Students, Posts | `SearchScreen` مع دعم الاستعلام اللحظي السريع | **محفوظة 100%** |
| **المصادقة واستعادة المرور** | دخول، تسجيل مع قائمة التخصصات، استرجاع الباسورد، جلسة دائمة | `features/auth` مع حماية الـ context وعرض الأخطاء بوضوح | **محفوظة 100%** |
| **الهوية البصرية والخطوط** | ألوان `AppColors` وخط `GoogleFonts.varelaRound` والانتقالات السلسة | الحفاظ الحرفي 100% دون أي تغيير في الألوان أو الخطوط أو المقاسات | **محفوظة 100%** |

---

## 7. خارطة طريق التنفيذ التدريجي خطوة بخطوة (Step-by-Step Execution Roadmap)

لضمان سلامة التنفيذ وعدم انقطاع التطبيق أثناء إعادة الهيكلة، يقسم العمل إلى 7 مراحل متتالية ومنظمة:

### المرحلة 1: التهيئة الأساسية وتنظيف الاعتماديات (Core & Foundation Setup)
1. تعديل `pubspec.yaml`: إزالة الحزمة الزائدة `material_ui: ^1.1.0` وتنفيذ `flutter pub get`.
2. إنشاء مجلد `lib/core/` ونقل وتحديث الملفات المشتركة:
   - `core/constants/app_colors.dart`
   - `core/constants/campus_majors.dart`
   - `core/navigation/transitions.dart`
   - `core/theme/app_theme.dart` (توحيد السمة)
   - `core/utils/date_time_utils.dart` (تجميع دوال التواريخ والأوقات)
   - `core/utils/image_utils.dart` (تجميع أدوات الصور والـ Base64)
   - `core/utils/ui_helpers.dart` (تجميع مربعات الحوار والـ SnackBars)
   - `core/widgets/post_image_widget.dart`
   - `core/widgets/user_avatar.dart`
   - `core/widgets/dynamic_user_avatar.dart`
   - `core/widgets/expandable_text.dart` (المعدل من `expandable_post_text.dart`)

### المرحلة 2: بناء النماذج الموحدة (Unified Models Creation)
1. إنشاء `features/profile/models/user_model.dart`
2. إنشاء `features/posts/models/post_model.dart`
3. إنشاء `features/posts/models/comment_model.dart`
4. إنشاء `features/notifications/models/notification_model.dart`
5. إنشاء `features/chat/models/chat_message_model.dart`
6. إنشاء `features/chat/models/chat_conversation_model.dart`

### المرحلة 3: بناء طبقة المستودعات المتخصصة (Modular Repositories)
1. إنشاء `features/auth/data/auth_repository.dart`
2. إنشاء `features/posts/data/post_repository.dart`
3. إنشاء `features/profile/data/profile_repository.dart`
4. إنشاء `features/chat/data/chat_repository.dart`
5. إنشاء `features/notifications/data/notification_repository.dart` و `local_notification_service.dart`
6. إنشاء `features/search/data/search_repository.dart`
7. تحديث `features/presence/data/presence_service.dart`

### المرحلة 4: إعادة هيكلة الويدجتس التفاعلية الموحدة (Shared Feature Widgets)
1. تحديث `features/posts/presentation/widgets/like_button_widget.dart`
2. تحديث `features/posts/presentation/widgets/post_action_bar.dart`
3. نقل وبناء `features/posts/presentation/widgets/post_card_widget.dart` الموحد الذي يتعامل مع `PostModel`
4. إنشاء `features/posts/presentation/widgets/post_options_dialogs.dart`

### المرحلة 5: ترحيل الميزات إلى هيكليتها الجديدة (Feature-by-Feature Migration)
1. **ميزة المصادقة (Auth):**
   - نقل وتحديث `login_screen.dart`, `signup_screen.dart`, `forgot_password_screen.dart` في `features/auth/presentation/screens/`.
   - حل تحذيرات `use_build_context_synchronously`.
2. **ميزة المنشورات (Posts):**
   - نقل وتحديث `create_post_screen.dart` و `post_details_screen.dart` في `features/posts/presentation/screens/`.
   - إنشاء `home_feed_screen.dart` (المستخرجة من `main.dart`) واستخدام `PostCardWidget` و `FeedPostComposer`.
3. **ميزة الملف الشخصي (Profile):**
   - إعادة تسمية `profile.dart` إلى `profile_screen.dart` وتسمية الكلاس `ProfileScreen`.
   - استبدال كود كرت البوست المكرر بـ `PostCardWidget` واستبدال حوارات الحذف والتعديل بـ `PostOptionsDialogs`.
   - نقل `edit_profile_screen.dart` و `settings_screen.dart` إلى `features/profile/presentation/screens/`.
4. **ميزة المحادثات (Chat):**
   - نقل وتحديث `chat_screen.dart` في `features/chat/presentation/screens/`.
   - نقل وتحديث `messages_drawer.dart` في `features/chat/presentation/widgets/`.
5. **ميزة الإشعارات (Notifications):**
   - نقل وتحديث `notifications_drawer.dart` في `features/notifications/presentation/widgets/`.
6. **ميزة البحث (Search):**
   - نقل وتحديث `search_screen.dart` في `features/search/presentation/screens/`.

### المرحلة 6: ربط نقطة انطلاق التطبيق (Main & App Shell)
1. إنشاء `lib/app.dart` لتعريف `MaterialApp` والسمة العامة.
2. تحديث `lib/auth_wrapper.dart` ليعتمد على `HomeFeedScreen` و `LoginScreen` بالمسارات الجديدة.
3. تبسيط `lib/main.dart` ليحتوي فقط على التهيئة الأولية:
   - `WidgetsFlutterBinding.ensureInitialized()`
   - `Firebase.initializeApp()`
   - `PresenceService().init()`
   - `LocalNotificationService().init()`
   - `runApp(const CampusApp())`
4. حذف الملفات القديمة المكررة في المجلد الجذري `lib/` بعد التأكد من اكتمال النقل.

### المرحلة 7: الفحص والاختبار وضمان الجودة (Verification & Static Analysis)
1. تشغيل `flutter analyze` والتحقق من وصول التحذيرات والأخطاء إلى **0 issues**.
2. فحص استيرادات الحزم والملفات للتأكد من عدم وجود واردات مكسورة.
3. التأكد من تطابق كامل الميزات البصرية والوظيفية.

---

جاهز للتطبيق الكامل خطوة بخطوة عبر الإيجنت المنفذ التالي.
