import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/navigation/transitions.dart';
import '../../../../core/widgets/dynamic_user_avatar.dart';
import '../../../posts/models/post_model.dart';
import '../../../posts/presentation/screens/post_details_screen.dart';
import '../../../profile/models/user_model.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../data/search_repository.dart';
import '../widgets/search_category_filter.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final SearchRepository _searchRepo = SearchRepository();
  int _selectedCategoryIndex = 0;

  final List<String> _categories = [
    'All',
    'Students',
    'Posts',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final queryText = _searchController.text.trim();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.navy, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
            hintText: 'Type to search students or posts...',
            hintStyle: const TextStyle(fontSize: 13.0, color: AppColors.textMuted),
            prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary, size: 20),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.textMuted),
                    onPressed: () {
                      setState(() {
                        _searchController.clear();
                      });
                    },
                  )
                : null,
            filled: true,
            fillColor: const Color(0xFFF6F8FA),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20.0),
              borderSide: BorderSide.none,
            ),
          ),
          onChanged: (val) => setState(() {}),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48.0),
          child: Column(
            children: [
              SearchCategoryFilter(
                categories: _categories,
                selectedIndex: _selectedCategoryIndex,
                onSelected: (idx) {
                  setState(() => _selectedCategoryIndex = idx);
                },
              ),
              const SizedBox(height: 6),
              const Divider(
                height: 1.0,
                thickness: 1.0,
                indent: 8,
                endIndent: 8,
                color: AppColors.borderLight,
              ),
            ],
          ),
        ),
      ),
      body: queryText.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_rounded,
                    size: 64,
                    color: AppColors.textMuted.withValues(alpha: 0.4),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Search Campus Network',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Type a student name, major, or post keyword to see results',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Students matching
                  if (_selectedCategoryIndex == 0 || _selectedCategoryIndex == 1) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                      child: Text(
                        'Students matching "$queryText"',
                        style: GoogleFonts.varelaRound(
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                    StreamBuilder<List<UserModel>>(
                      stream: _searchRepo.searchStudents(queryText),
                      builder: (context, snapshot) {
                        final students = snapshot.data ?? [];

                        if (students.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            child: Text(
                              'No students found with this search term.',
                              style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                            ),
                          );
                        }

                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: students.length,
                          separatorBuilder: (context, index) => const Divider(
                            height: 1,
                            indent: 64,
                            endIndent: 16,
                            color: AppColors.borderLight,
                          ),
                          itemBuilder: (context, index) {
                            final student = students[index];

                            return ListTile(
                              leading: DynamicUserAvatar(
                                uid: student.uid,
                                initialPhoto: student.photoUrl,
                                radius: 20,
                              ),
                              title: Text(
                                student.name,
                                style: const TextStyle(
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textDark,
                                ),
                              ),
                              subtitle: Text(
                                '${student.major} • @${student.username}',
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  color: AppColors.textMuted,
                                ),
                              ),
                              trailing: const Icon(Icons.arrow_forward_ios_rounded,
                                  size: 14, color: AppColors.textMuted),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  SlidePageTransition(
                                    page: ProfileScreen(viewUid: student.uid),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Divider(color: AppColors.borderLight),
                    ),
                  ],

                  // Posts matching
                  if (_selectedCategoryIndex == 0 || _selectedCategoryIndex == 2) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16.0, 10.0, 16.0, 8.0),
                      child: Text(
                        'Posts matching "$queryText"',
                        style: GoogleFonts.varelaRound(
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                    StreamBuilder<List<PostModel>>(
                      stream: _searchRepo.searchPosts(queryText),
                      builder: (context, snapshot) {
                        final posts = snapshot.data ?? [];

                        if (posts.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            child: Text(
                              'No posts match your search query.',
                              style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                            ),
                          );
                        }

                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: posts.length,
                          separatorBuilder: (context, index) => const Divider(
                            height: 1,
                            indent: 16,
                            endIndent: 16,
                            color: AppColors.borderLight,
                          ),
                          itemBuilder: (context, index) {
                            final post = posts[index];

                            return ListTile(
                              leading: DynamicUserAvatar(
                                uid: post.authorUid,
                                initialPhoto: post.authorPhoto,
                                radius: 20,
                              ),
                              title: Text(
                                post.authorName,
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textDark,
                                ),
                              ),
                              subtitle: Text(
                                post.content,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12.0,
                                  color: AppColors.textMuted,
                                ),
                              ),
                              trailing: const Icon(Icons.arrow_forward_ios_rounded,
                                  size: 14, color: AppColors.textMuted),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  SlidePageTransition(
                                    page: PostDetailsScreen(
                                      post: post,
                                      postId: post.id,
                                      authorName: post.authorName,
                                      authorUid: post.authorUid,
                                      content: post.content,
                                      imageUrl: post.imageUrl,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}
