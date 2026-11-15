import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // استدعاء مكتبة الخطوط

import 'profile.dart';

void main() {
  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: HomeScreen()));
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        leadingWidth: 120,

        leading: Row(
          children: [
            SizedBox(width: 12.0),
            IconButton(
              iconSize: 28.0,
              icon: Icon(Icons.notifications),
              color: Color.fromARGB(255, 63, 127, 218),
              onPressed: () {},
            ),
            SizedBox(width: 8.0),
            IconButton(
              icon: Icon(Icons.message),
              iconSize: 28.0,
              color: Color.fromARGB(255, 63, 127, 218),
              onPressed: () {},
            ),
          ],
        ),
        backgroundColor: Colors.white,
        actions: [
          Center(
            child: Text(
              'campus',
              style: GoogleFonts.varelaRound(
                // تطبيق الخط الشبيه بريديت
                color: const Color.fromARGB(255, 63, 127, 218), // لون النص
                fontSize: 26.0, // حجم الخط
                fontWeight: FontWeight.bold, // جعل الخط عريضاً
                letterSpacing: -0.5, // تقريب الحروف
              ),
            ),
          ),
          SizedBox(width: 20.0),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(
            height: 1.0,
            thickness: 1.0,
            indent: 8,
            endIndent: 8,
            color: Color.fromARGB(255, 225, 225, 225),
          ),
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(
                top: 10.0,
                left: 10.0,
                right: 10.0,
                bottom: 18.0,
              ),

              child: Row(
                //مستطيل الكتابة
                children: [
                  IconButton(
                    style: IconButton.styleFrom(
                      shape: CircleBorder(),
                      backgroundColor: Color.fromARGB(255, 220, 229, 242),
                    ),
                    iconSize: 33.0,
                    icon: Icon(Icons.person),
                    color: Color.fromARGB(255, 63, 127, 218),
                    onPressed: () {},
                  ),
                  SizedBox(width: 8.0),

                  Flexible(
                    fit: FlexFit.tight,
                    child: TextField(
                      decoration: InputDecoration(
                        isDense:
                            true, // لتقليص الحجم الداخلي للحقل وجعله رقيقاً
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 10.0,
                          vertical: 11.0,
                        ), // للتحكم برقة وارتفاع الحقل
                        hintText: 'what\'s on your mind?',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          borderSide: BorderSide(
                            color: Color.fromARGB(255, 63, 127, 218),
                            width: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 1.0),

                  IconButton(
                    iconSize: 33.0,
                    icon: Icon(Icons.photo),
                    color: Color.fromARGB(255, 63, 127, 218),
                    onPressed: () {},
                  ),
                ],
              ),
            ),

             SizedBox(
                width: double.infinity,
                child: Card(
                  color: Colors.white,
                  surfaceTintColor: Colors
                      .transparent, // يمنع تلوين البطاقة بالصبغة التلقائية
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                  margin: EdgeInsets.only(
                    left: 0.0,
                    right: 0.0,
                    top: 0.0,
                    bottom: 2.0,
                  ),
                  elevation: 2.0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                             IconButton(
                              style: IconButton.styleFrom(
                                shape: const CircleBorder(),
                                backgroundColor: const Color.fromARGB(
                                  255,
                                  220,
                                  229,
                                  242,
                                ),
                              ),
                              iconSize: 33.0,
                              icon: const Icon(Icons.person),
                              color: const Color.fromARGB(255, 63, 127, 218),
                              onPressed: () {},
                            ),
                            
                            const Padding(
                              padding: EdgeInsets.only(bottom: 8.0 ,left: 6),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Alex Morgan', // اسم مستخدم جديد
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '1 day ago', // وقت المنشور
                                    style: TextStyle(
                                      fontSize: 11.0,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(255, 63, 127, 218),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8.0),
                             Spacer(),
                            IconButton(
                              style: IconButton.styleFrom(
                                shape: const CircleBorder(),
                              ),
                              iconSize: 26.0,
                              icon: const Icon(Icons.more_vert),
                              color: const Color.fromARGB(255, 63, 127, 218),
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.0),
                        child: Text(
                          'Coffee and coding: the perfect morning combo! ☕💻 What are you building today?', // وصف برمجة وقهوة
                          style: TextStyle(fontSize: 14.0),
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      Image.network(
                        'https://images.unsplash.com/photo-1498050108023-c5249f4df085?w=800', // صورة لابتوب وقهوة وبرمجة
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 3.0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton.icon(
                              onPressed: () {},
                              label: const Text(
                                '512', // عدد إعجابات مختلف
                                style: TextStyle(color: Colors.black),
                              ),
                              icon: const Icon(
                                Icons.thumb_up,
                                size: 23.0,
                                color: Color.fromARGB(255, 63, 127, 218),
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () {},
                              label: const Text(
                                '42', // عدد تعليقات مختلف
                                style: TextStyle(color: Colors.black),
                              ),
                              icon: const Icon(
                                Icons.comment,
                                size: 23.0,
                                color: Color.fromARGB(255, 63, 127, 218),
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () {},
                              icon: const Icon(
                                Icons.share,
                                size: 23.0,
                                color: Color.fromARGB(255, 63, 127, 218),
                              ),
                              label: const Text(
                                '',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: Card(
                  color: Colors.white,
                  surfaceTintColor: Colors.transparent,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                  margin: const EdgeInsets.only(
                    left: 0.0,
                    right: 0.0,
                    top: 0.0,
                    bottom: 2.0,
                  ),
                  elevation: 2.0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                             IconButton(
                              style: IconButton.styleFrom(
                                shape: const CircleBorder(),
                                backgroundColor: const Color.fromARGB(
                                  255,
                                  220,
                                  229,
                                  242,
                                ),
                              ),
                              iconSize: 33.0,
                              icon: const Icon(Icons.person),
                              color: const Color.fromARGB(255, 63, 127, 218),
                              onPressed: () {},
                            ),
                            
                            const Padding(
                              padding: EdgeInsets.only(bottom: 8.0 ,left: 6),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Alex Morgan', // اسم مستخدم جديد
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '1 day ago', // وقت المنشور
                                    style: TextStyle(
                                      fontSize: 11.0,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(255, 63, 127, 218),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8.0),
                             Spacer(),
                            IconButton(
                              style: IconButton.styleFrom(
                                shape: const CircleBorder(),
                              ),
                              iconSize: 26.0,
                              icon: const Icon(Icons.more_vert),
                              color: const Color.fromARGB(255, 63, 127, 218),
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.0),
                        child: Text(
                          'Late night study session at the campus library 📚 Finals week is approaching, stay focused everyone! 💪',
                          style: TextStyle(fontSize: 14.0),
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      Image.network(
                        'https://images.unsplash.com/photo-1521587760476-6c12a4b040da?w=800', // مكتبة جامعية وكتب
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 3.0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton.icon(
                              onPressed: () {},
                              label: const Text(
                                '380',
                                style: TextStyle(color: Colors.black),
                              ),
                              icon: const Icon(
                                Icons.thumb_up,
                                size: 23.0,
                                color: Color.fromARGB(255, 63, 127, 218),
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () {},
                              label: const Text(
                                '24',
                                style: TextStyle(color: Colors.black),
                              ),
                              icon: const Icon(
                                Icons.comment,
                                size: 23.0,
                                color: Color.fromARGB(255, 63, 127, 218),
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () {},
                              icon: const Icon(
                                Icons.share,
                                size: 23.0,
                                color: Color.fromARGB(255, 63, 127, 218),
                              ),
                              label: const Text(
                                '',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: Card(
                  color: Colors.white,
                  surfaceTintColor: Colors.transparent,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                  margin: const EdgeInsets.only(
                    left: 0.0,
                    right: 0.0,
                    top: 0.0,
                    bottom: 2.0,
                  ),
                  elevation: 2.0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                     Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                             IconButton(
                              style: IconButton.styleFrom(
                                shape: const CircleBorder(),
                                backgroundColor: const Color.fromARGB(
                                  255,
                                  220,
                                  229,
                                  242,
                                ),
                              ),
                              iconSize: 33.0,
                              icon: const Icon(Icons.person),
                              color: const Color.fromARGB(255, 63, 127, 218),
                              onPressed: () {},
                            ),
                            
                            const Padding(
                              padding: EdgeInsets.only(bottom: 8.0 ,left: 6),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Alex Morgan', // اسم مستخدم جديد
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '1 day ago', // وقت المنشور
                                    style: TextStyle(
                                      fontSize: 11.0,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(255, 63, 127, 218),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8.0),
                             Spacer(),
                            IconButton(
                              style: IconButton.styleFrom(
                                shape: const CircleBorder(),
                              ),
                              iconSize: 26.0,
                              icon: const Icon(Icons.more_vert),
                              color: const Color.fromARGB(255, 63, 127, 218),
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ),
                       const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12.0),
                        child: Text(
                          'Just wrapped up the annual University Hackathon! Proud of our team for building an AI campus assistant 🥈💻',
                          style: TextStyle(fontSize: 14.0),
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      Image.network(
                        'https://images.unsplash.com/photo-1531482615713-2afd69097998?w=800', // فريق طلاب وتطوير برمجيات
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 3.0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton.icon(
                              onPressed: () {},
                              label: const Text(
                                '620',
                                style: TextStyle(color: Colors.black),
                              ),
                              icon: const Icon(
                                Icons.thumb_up,
                                size: 23.0,
                                color: Color.fromARGB(255, 63, 127, 218),
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () {},
                              label: const Text(
                                '48',
                                style: TextStyle(color: Colors.black),
                              ),
                              icon: const Icon(
                                Icons.comment,
                                size: 23.0,
                                color: Color.fromARGB(255, 63, 127, 218),
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () {},
                              icon: const Icon(
                                Icons.share,
                                size: 23.0,
                                color: Color.fromARGB(255, 63, 127, 218),
                              ),
                              label: const Text(
                                '',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
        ),
      ),

      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Color.fromARGB(
                255,
                219,
                221,
                222,
              ), // لون رمادي أغمق قليلاً للخط العلوي
              width: 1.0, // سمك الخط
            ),
          ),
        ),
        child: SizedBox(
          height: 58.0,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: BottomNavigationBar(
              iconSize: 22.0, // لتصغير حجم الأيقونات لتناسب الارتفاع الجديد
              selectedFontSize: 11.0, // لتصغير حجم خط العنصر المختار
              unselectedFontSize: 11.0, // لتصغير حجم خط العناصر غير المختارة
              backgroundColor: Colors.white, // لون خلفية الشريط
              selectedItemColor: Color(0xFF3F7FDA),
              unselectedItemColor: Colors.grey,
              onTap: (index) {
                if (index == 2) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => profile()),
                  );
                }
              },
              items: [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                BottomNavigationBarItem(
                  icon: Icon(Icons.search),
                  label: 'Search',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      ),
      // ضعه هنا في الأسفل:
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color.fromARGB(255, 63, 127, 218),
        shape: CircleBorder(),
        onPressed: () {},
        child: Icon(Icons.add, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.endFloat, // لتوسيط الزر في الأسفل
      // نهاية الـ Scaffold
    );
  }
}
