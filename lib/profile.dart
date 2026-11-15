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
                  50.0,
                  11.0,
                  50.0,
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
                  top: 20.0,
                  left: 50.0,
                  right: 50.0,
                  bottom: 20.0,
                ), // إضافة مسافة من الأعلى واليمين واليسار

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
              Padding(
                padding: EdgeInsets.only(
                  top: 1.0,
                  bottom: 0.0,
                  right: 0.0,
                  left: 0.0,
                ), // إضافة مسافة من الأعلى

                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Image.network(
                      'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=500',
                      width:
                          MediaQuery.of(context).size.width *
                          0.33, // ✅ تحديد العرض
                      height:
                          MediaQuery.of(context).size.width *
                          0.33 *
                          1.6, // ✅ تحديد الارتفاع
                      fit: BoxFit.cover,
                    ),
                    Image.network(
                      'https://images.unsplash.com/photo-1498050108023-c5249f4df085?w=600',
                      width:
                          MediaQuery.of(context).size.width *
                          0.33, // ✅ تحديد العرض
                      height:
                          MediaQuery.of(context).size.width *
                          0.33 *
                          1.6, // ✅ تحديد الارتفاع
                      fit: BoxFit.cover,
                    ),
                    Image.network(
                      'https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=600',
                      width:
                          MediaQuery.of(context).size.width *
                          0.33, // ✅ تحديد العرض
                      height:
                          MediaQuery.of(context).size.width *
                          0.33 *
                          1.6, // ✅ تحديد الارتفاع
                      fit: BoxFit.cover,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  top: 1.0,
                  bottom: 0.0,
                  right: 0.0,
                  left: 0.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // الصورة الأولى (طبيعة وشاطئ)
                    Image.network(
                      'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800',
                      width: MediaQuery.of(context).size.width * 0.33,
                      height:
                          MediaQuery.of(context).size.width *
                          0.33 *
                          1.6, // ارتفاع متناسق وجذاب
                      fit: BoxFit.cover,
                    ),

                    // الصورة الثانية (لابتوب وقهوة وبرمجة)
                    Image.network(
                      'https://images.unsplash.com/photo-1498050108023-c5249f4df085?w=800',
                      width: MediaQuery.of(context).size.width * 0.33,
                      height: MediaQuery.of(context).size.width * 0.33 * 1.6,
                      fit: BoxFit.cover,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
