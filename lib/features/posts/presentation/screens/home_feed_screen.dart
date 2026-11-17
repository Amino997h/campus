import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/navigation/transitions.dart';
import '../../../notifications/presentation/widgets/notifications_drawer.dart';
import '../../../notifications/data/notification_repository.dart';
import '../../../chat/presentation/widgets/messages_drawer.dart';
import '../../../chat/data/chat_repository.dart';
import '../../../search/presentation/screens/search_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../models/post_model.dart';
import '../../data/post_repository.dart';
import '../widgets/feed_post_composer.dart';
import '../widgets/post_card_widget.dart';
import 'create_post_screen.dart';

class HomeFeedScreen extends StatefulWidget {
  const HomeFeedScreen({super.key});

  @override
  State<HomeFeedScreen> createState() => _HomeFeedScreenState();
}

// Backward-compatibility alias
typedef HomeScreen = HomeFeedScreen;

class _HomeFeedScreenState extends State<HomeFeedScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final PostRepository _postRepo = PostRepository();
  final NotificationRepository _notifRepo = NotificationRepository();
  final ChatRepository _chatRepo = ChatRepository();
  Widget _currentDrawer = const NotificationsDrawer();

  List<PostModel> _cachedPosts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    try {
      final posts = await _postRepo.getPostsFuture();
      if (mounted) {
        setState(() {
          _cachedPosts = posts;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _openDrawerWith(Widget drawerWidget) {
    setState(() {
      _currentDrawer = drawerWidget;
    });
    _scaffoldKey.currentState?.openDrawer();
  }

  Future<void> _onRefresh() async {
    await _loadPosts();
  }

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid ?? 'guest';

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      drawer: _currentDrawer,
      appBar: AppBar(
        leadingWidth: 120,
        leading: Row(
          children: [
            const SizedBox(width: 8.0),
            StreamBuilder<bool>(
              stream: _notifRepo.hasUnreadNotificationsStream(currentUid),
              builder: (context, snapshot) {
                final hasUnread = snapshot.data ?? false;
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    IconButton(
                      iconSize: 26.0,
                      icon: Icon(hasUnread ? Icons.notifications_active_rounded : Icons.notifications_outlined),
                      color: AppColors.navy,
                      onPressed: () {
                        _openDrawerWith(const NotificationsDrawer());
                      },
                    ),
                    if (hasUnread)
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          width: 9.0,
                          height: 9.0,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.5),
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(width: 4.0),
            StreamBuilder<bool>(
              stream: _chatRepo.hasUnreadMessagesStream(currentUid),
              builder: (context, snapshot) {
                final hasUnread = snapshot.data ?? false;
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    IconButton(
                      icon: Icon(hasUnread ? Icons.forum_rounded : Icons.forum_outlined),
                      iconSize: 24.0,
                      color: AppColors.navy,
                      onPressed: () {
                        _openDrawerWith(const MessagesDrawer());
                      },
                    ),
                    if (hasUnread)
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          width: 9.0,
                          height: 9.0,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.5),
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          Center(
            child: Text(
              'campus',
              style: GoogleFonts.varelaRound(
                color: AppColors.primary,
                fontSize: 26.0,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(width: 20.0),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(
            height: 1.0,
            thickness: 1.0,
            indent: 8,
            endIndent: 8,
            color: AppColors.borderLight,
          ),
        ),
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: Colors.white,
        onRefresh: _onRefresh,
        child: CustomScrollView(
          key: const PageStorageKey<String>('home_feed_scroll_key'),
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Feed composer widget as Sliver
            SliverToBoxAdapter(
              child: FeedPostComposer(
                currentUid: currentUid,
                onPostCreated: _loadPosts,
              ),
            ),

            if (_isLoading)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40.0),
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                ),
              )
            else if (_cachedPosts.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 50.0),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.forum_rounded,
                          size: 50,
                          color: AppColors.textMuted.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'No posts yet. Be the first to post!',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final post = _cachedPosts[index];
                    return PostCardWidget(
                      key: ValueKey(post.id),
                      post: post,
                      currentUid: currentUid,
                    );
                  },
                  childCount: _cachedPosts.length,
                  findChildIndexCallback: (Key key) {
                    if (key is ValueKey<String>) {
                      final index = _cachedPosts.indexWhere((p) => p.id == key.value);
                      return index >= 0 ? index : null;
                    }
                    return null;
                  },
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(
              color: AppColors.borderLight,
              width: 1.0,
            ),
          ),
        ),
        child: SizedBox(
          height: 58.0,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: BottomNavigationBar(
              iconSize: 22.0,
              selectedFontSize: 11.0,
              unselectedFontSize: 11.0,
              backgroundColor: Colors.white,
              selectedItemColor: AppColors.primary,
              unselectedItemColor: AppColors.navy.withValues(alpha: 0.65),
              onTap: (index) {
                if (index == 1) {
                  Navigator.push(
                    context,
                    SlidePageTransition(page: const SearchScreen()),
                  );
                } else if (index == 2) {
                  Navigator.push(
                    context,
                    SlidePageTransition(page: const ProfileScreen()),
                  );
                }
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home_rounded),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.search_rounded),
                  activeIcon: Icon(Icons.search_rounded),
                  label: 'Search',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline_rounded),
                  activeIcon: Icon(Icons.person_rounded),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        shape: const CircleBorder(),
        onPressed: () {
          Navigator.push(
            context,
            SlidePageTransition(page: const CreatePostScreen()),
          );
        },
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
