import 'package:flutter/material.dart';
import 'pages/broadcast_receiver_page.dart';
import 'pages/image_scale_page.dart';
import 'pages/video_page.dart';
import 'pages/audio_page.dart';
import 'pages/last_broadcast_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Custom Drawer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF3182bd),
        scaffoldBackgroundColor: const Color(0xFFdeebf7),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3182bd),
          primary: const Color(0xFF3182bd),
          secondary: const Color(0xFF9ecae1),
          surface: const Color(0xFFdeebf7),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF3182bd),
          foregroundColor: Colors.white,
          elevation: 2,
        ),
        drawerTheme: const DrawerThemeData(backgroundColor: Color(0xFFdeebf7)),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const BroadcastReceiverPage(),
    const LastBroadcastPage(),
    const ImageScalePage(),
    const VideoPage(),
    const AudioPage(),
  ];

  final List<String> _pageTitles = [
    'Broadcast Receiver',
    'Last Broadcast',
    'Image Scale',
    'Video',
    'Audio',
  ];

  final List<IconData> _pageIcons = [
    Icons.broadcast_on_home,
    Icons.history,
    Icons.image,
    Icons.video_library,
    Icons.audio_file,
  ];

  void _onPageSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_pageTitles[_selectedIndex]),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [colorScheme.primary, colorScheme.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Icon(
                      Icons.apps,
                      size: 40,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    'Navigation Menu',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 10),
                itemCount: _pageTitles.length,
                itemBuilder: (context, index) {
                  bool isSelected = _selectedIndex == index;
                  return Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colorScheme.secondary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: Icon(
                        _pageIcons[index],
                        color: isSelected
                            ? colorScheme.primary
                            : Colors.black54,
                        size: 28,
                      ),
                      title: Text(
                        _pageTitles[index],
                        style: TextStyle(
                          color: isSelected
                              ? colorScheme.primary
                              : Colors.black87,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          fontSize: 16,
                        ),
                      ),
                      onTap: () => _onPageSelected(index),
                    ),
                  );
                },
              ),
            ),
            const Divider(),
            Padding(padding: const EdgeInsets.all(16.0)),
          ],
        ),
      ),
      body: _pages[_selectedIndex],
    );
  }
}
