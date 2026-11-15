import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // استدعاء مكتبة الخطوط

class profile extends StatelessWidget {
  const profile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          'profile',

          style: GoogleFonts.varelaRound(
            // تطبيق الخط الشبيه بريديت
            color: const Color(0xFF3F7FDA), // لون النص
            fontSize: 26.0, // حجم الخط
            fontWeight: FontWeight.bold, // جعل الخط عريضاً
            letterSpacing: -0.5, // تقريب الحروف
          ),
        ),

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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Center(
                // لتوسيطها أفقياً بين اليمين واليسار
                child: Padding(
                  padding: EdgeInsets.only(
                    top: 20.0,
                    bottom: 8.0,
                  ), // إضافة مسافة من الأعلى والأسفل
                  child: CircleAvatar(
                    radius: 70.0,
                    backgroundColor: Color.fromARGB(255, 220, 229, 242),

                    child: Icon(Icons.person, size: 130, color: Colors.blue),
                  ),
                ),
              ),
              Text(
                'amine bouzouada',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF010D1D),
                ),
              ),
              Text(
                'computer science . @amine',
                style: TextStyle(
                  fontSize: 12.0,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3F7FDA),
                ),
              ),

              Padding(
                padding: EdgeInsets.fromLTRB(
                  40.0,
                  11.0,
                  40.0,
                  20.0,
                ), // إضافة مسافة من الجانبين والأعلى والأسفل
                child: Text(
                  ' illustrations, and graphic elements from the world’s best designers.Want more inspiration? Browse our search results for more great resources.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12.0,
                    height: 1.15,
                    color: Color.fromARGB(255, 156, 167, 183),
                  ),
                ),
              ),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3F7FDA), // لون خلفية الزر
                  foregroundColor: Colors.white, // لون النص
                  padding: const EdgeInsets.fromLTRB(
                    24.0,
                    10.0,
                    24.0,
                    10.0,
                  ), // الحجم
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0), // حواف دائرية
                  ),
                  elevation: 0, // زر مسطح وأنيق
                ),
                onPressed: () {
                  // ماذا يحدث عند الضغط
                },
                child: const Text(
                  'Edit Profile',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  top: 18.0,
                  left: 40.0,
                  right: 40.0,
                  bottom: 12.0,
                ), 
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      children: [
                        Text(
                          'Posts',
                          style: TextStyle(
                            fontSize: 12.0,
                            color: Color.fromARGB(255, 156, 167, 183),
                          ),
                        ),
                        Text(
                          '120',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF010D1D),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      height: 25.0,
                      width: 1.0,
                      color: const Color.fromARGB(255, 220, 225, 230),
                    ),
                    Column(
                      children: [
                        Text(
                          'Followers',
                          style: TextStyle(
                            fontSize: 12.0,
                            color: Color.fromARGB(255, 156, 167, 183),
                          ),
                        ),
                        Text(
                          '2.5K',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF010D1D),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      height: 25.0,
                      width: 1.0,
                      color: const Color.fromARGB(255, 220, 225, 230),
                    ),
                    Column(
                      children: [
                        Text(
                          'Following',
                          style: TextStyle(
                            fontSize: 12.0,
                            color: Color.fromARGB(255, 156, 167, 183),
                          ),
                        ),
                        Text(
                          '300',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF010D1D),
                          ),
                        ),
                      ],
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
      ),
    );
  }
}
