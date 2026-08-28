import 'package:flutter/material.dart';

void main() {
  runApp(const BilliBilliApp());
}

class BilliBilliApp extends StatelessWidget {
  const BilliBilliApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'बिल्ली बिल्ली',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.orange,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const BottomNavScreen(),
    );
  }
}

class BottomNavScreen extends StatefulWidget {
  const BottomNavScreen({super.key});

  @override
  State<BottomNavScreen> createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const ReelsScreen(),
    const Center(child: Text('अपलोड स्क्रीन', style: TextStyle(fontSize: 22))),
    const Center(child: Text('एक्सप्लोर', style: TextStyle(fontSize: 22))),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'होम'),
          NavigationDestination(icon: Icon(Icons.video_collection_outlined), selectedIcon: Icon(Icons.video_collection), label: 'रील्स'),
          NavigationDestination(icon: Icon(Icons.add_box_outlined), selectedIcon: Icon(Icons.add_box), label: 'अपलोड'),
          NavigationDestination(icon: Icon(Icons.search), selectedIcon: Icon(Icons.search), label: 'खोज'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'प्रोफाइल'),
        ],
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('बिल्ली बिल्ली', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.favorite_border)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.send_outlined)),
        ],
      ),
      body: ListView(
        children: [
          SizedBox(
            height: 110,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              itemCount: 8,
              itemBuilder: (context, index) {
                return StoryCircle(
                  name: index == 0 ? 'आपकी स्टोरी' : 'बिल्ली $index',
                  isYourStory: index == 0,
                );
              },
            ),
          ),
          const Divider(height: 1),
          ...List.generate(6, (index) => PostCard(index: index)),
        ],
      ),
    );
  }
}

class StoryCircle extends StatelessWidget {
  final String name;
  final bool isYourStory;

  const StoryCircle({super.key, required this.name, this.isYourStory = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: isYourStory
                  ? null
                  : const LinearGradient(colors: [Colors.orange, Colors.pink, Colors.purple]),
            ),
            child: CircleAvatar(
              radius: 32,
              backgroundColor: Colors.orange.shade100,
              child: isYourStory
                  ? const Icon(Icons.add, size: 30)
                  : const Text('🐱', style: TextStyle(fontSize: 28)),
            ),
          ),
          const SizedBox(height: 4),
          Text(name, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

class PostCard extends StatelessWidget {
  final int index;
  const PostCard({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.orange.shade200,
            child: const Text('🐱', style: TextStyle(fontSize: 22)),
          ),
          title: Text('बिल्ली_लवर_$index', style: const TextStyle(fontWeight: FontWeight.bold)),
          trailing: IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
        ),
        Container(
          height: 320,
          width: double.infinity,
          color: Colors.orange.shade50,
          child: const Center(
            child: Text('🐱\nकैट फोटो', textAlign: TextAlign.center, style: TextStyle(fontSize: 40)),
          ),
        ),
        Row(
          children: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.favorite_border)),
            IconButton(onPressed: () {}, icon: const Icon(Icons.chat_bubble_outline)),
            IconButton(onPressed: () {}, icon: const Icon(Icons.send_outlined)),
            const Spacer(),
            IconButton(onPressed: () {}, icon: const Icon(Icons.bookmark_border)),
          ],
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text('1,234 पसंद', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
          child: RichText(
            text: TextSpan(
              style: const TextStyle(color: Colors.black),
              children: [
                TextSpan(text: 'बिल्ली_लवर_$index ', style: const TextStyle(fontWeight: FontWeight.bold)),
                const TextSpan(text: 'मेरी प्यारी बिल्ली 😻 #cat #बिल्ली'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class ReelsScreen extends StatelessWidget {
  const ReelsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        scrollDirection: Axis.vertical,
        itemCount: 8,
        itemBuilder: (context, index) {
          return Stack(
            fit: StackFit.expand,
            children: [
              Container(
                color: Colors.grey.shade900,
                child: Center(
                  child: Text(
                    '🎬\nरील ${index + 1}',
                    style: const TextStyle(color: Colors.white, fontSize: 32),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Positioned(
                right: 12,
                bottom: 100,
                child: Column(
                  children: [
                    IconButton(onPressed: () {}, icon: const Icon(Icons.favorite, color: Colors.white, size: 32)),
                    const Text('12.5K', style: TextStyle(color: Colors.white)),
                    const SizedBox(height: 16),
                    IconButton(onPressed: () {}, icon: const Icon(Icons.chat_bubble, color: Colors.white, size: 32)),
                    const Text('842', style: TextStyle(color: Colors.white)),
                    const SizedBox(height: 16),
                    IconButton(onPressed: () {}, icon: const Icon(Icons.send, color: Colors.white, size: 32)),
                  ],
                ),
              ),
              Positioned(
                left: 16,
                bottom: 40,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('@बिल्ली_क्रिएटर_$index', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    const Text('मेरी बिल्ली का क्यूट डांस 😻', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('बिल्ली_लवर_01', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.menu))],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            const CircleAvatar(radius: 50, child: Text('🐱', style: TextStyle(fontSize: 50))),
            const SizedBox(height: 12),
            const Text('बिल्ली प्रेमी', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Text('मेरी प्यारी बिल्लियों की दुनिया 😻'),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                _Stat(title: 'पोस्ट', value: '42'),
                _Stat(title: 'फॉलोअर्स', value: '1.2K'),
                _Stat(title: 'फॉलोइंग', value: '180'),
              ],
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(child: OutlinedButton(onPressed: () {}, child: const Text('एडिट प्रोफाइल'))),
                  const SizedBox(width: 8),
                  Expanded(child: OutlinedButton(onPressed: () {}, child: const Text('शेयर प्रोफाइल'))),
                ],
              ),
            ),
            const SizedBox(height: 20),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(2),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 2,
                mainAxisSpacing: 2,
              ),
              itemCount: 9,
              itemBuilder: (context, index) {
                return Container(
                  color: Colors.orange.shade100,
                  child: const Center(
                    child: Text('🐱', style: TextStyle(fontSize: 30)),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String title;
  final String value;

  const _Stat({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(title),
      ],
    );
  }
}
