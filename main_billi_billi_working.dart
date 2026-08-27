
import 'package:flutter/material.dart';

void main() => runApp(const BilliBilliApp());

class BilliBilliApp extends StatelessWidget {
  const BilliBilliApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Billi Billi',
    theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.red), useMaterial3: true),
    home: const Home(),
  );
}

class Video {
  final String title, creator, emoji, views;
  int likes;
  bool liked;
  Video(this.title, this.creator, this.emoji, this.views, this.likes, {this.liked = false});
}

class Home extends StatefulWidget {
  const Home({super.key});
  @override State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int tab = 0;
  final videos = <Video>[
    Video('बिल्ली की मजेदार कहानी', 'Billi Stories', '🐱', '2.4M views', 18400),
    Video('भारत की खूबसूरत जगहें', 'Travel India', '🏔️', '1.8M views', 12100),
    Video('Funny Cats Compilation', 'Billi Shorts', '😂', '5.6M views', 30200),
    Video('आज का वायरल वीडियो', 'Billi Creator', '🔥', '920K views', 7600),
  ];

  @override
  Widget build(BuildContext context) {
    final pages = [_home(), _shorts(), _subs(), _profile()];
    return Scaffold(
      appBar: AppBar(
        title: const Row(children: [
          Text('🐱 ', style: TextStyle(fontSize: 25)),
          Text('Billi ', style: TextStyle(fontWeight: FontWeight.bold)),
          Text('Billi', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        ]),
        actions: [
          IconButton(onPressed: _search, icon: const Icon(Icons.search)),
          IconButton(onPressed: () => _msg('Notifications'), icon: const Icon(Icons.notifications_none)),
        ],
      ),
      body: pages[tab],
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (i) => setState(() => tab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.play_circle_outline), selectedIcon: Icon(Icons.play_circle), label: 'Shorts'),
          NavigationDestination(icon: Icon(Icons.subscriptions_outlined), selectedIcon: Icon(Icons.subscriptions), label: 'Subscriptions'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'You'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red, foregroundColor: Colors.white,
        onPressed: _upload, child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _home() => ListView(
    padding: const EdgeInsets.fromLTRB(12, 8, 12, 90),
    children: [
      SizedBox(height: 44, child: ListView(
        scrollDirection: Axis.horizontal,
        children: ['All','Music','Gaming','Live','News','Comedy'].map(
          (x) => Padding(padding: const EdgeInsets.only(right: 8), child: Chip(label: Text(x)))
        ).toList(),
      )),
      ...videos.map(_card),
    ],
  );

  Widget _card(Video v) => Card(
    margin: const EdgeInsets.only(bottom: 14),
    clipBehavior: Clip.antiAlias,
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      InkWell(
        onTap: () => _player(v),
        child: Container(height: 190, width: double.infinity, color: Colors.black12,
          alignment: Alignment.center, child: Text(v.emoji, style: const TextStyle(fontSize: 82))),
      ),
      ListTile(
        leading: CircleAvatar(child: Text(v.emoji)),
        title: Text(v.title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text('${v.creator} • ${v.views}'),
        trailing: IconButton(onPressed: () => _msg('Save / Report / Not interested'), icon: const Icon(Icons.more_vert)),
      ),
      Row(children: [
        IconButton(onPressed: () => setState(() {v.liked=!v.liked; v.likes += v.liked ? 1 : -1;}),
          icon: Icon(v.liked ? Icons.favorite : Icons.favorite_border, color: v.liked ? Colors.red : null)),
        Text('${v.likes}'),
        IconButton(onPressed: () => _comments(v), icon: const Icon(Icons.comment_outlined)),
        IconButton(onPressed: () => _msg('Share: ${v.title}'), icon: const Icon(Icons.share_outlined)),
      ]),
    ]),
  );

  Widget _shorts() => PageView.builder(
    scrollDirection: Axis.vertical, itemCount: videos.length,
    itemBuilder: (_, i) => GestureDetector(
      onTap: () => _player(videos[i]),
      child: Container(color: Colors.black, child: Stack(children: [
        Center(child: Text(videos[i].emoji, style: const TextStyle(fontSize: 130))),
        Positioned(left: 20, bottom: 35, child: Text('@${videos[i].creator} #shorts',
          style: const TextStyle(color: Colors.white, fontSize: 18))),
        const Positioned(right: 18, bottom: 65, child: Column(children: [
          Icon(Icons.favorite, color: Colors.white, size: 34), SizedBox(height: 18),
          Icon(Icons.comment, color: Colors.white, size: 34), SizedBox(height: 18),
          Icon(Icons.share, color: Colors.white, size: 34),
        ])),
      ])),
    ),
  );

  Widget _subs() => const Center(child: Text('आपके subscribed creators यहाँ दिखेंगे', style: TextStyle(fontSize: 18)));

  Widget _profile() => ListView(padding: const EdgeInsets.all(20), children: [
    const CircleAvatar(radius: 45, child: Text('🐱', style: TextStyle(fontSize: 42))),
    const SizedBox(height: 12),
    const Center(child: Text('Billi Billi Creator', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
    const Center(child: Text('@billi_creator • 12.5K followers')),
    const SizedBox(height: 20),
    FilledButton.icon(onPressed: _upload, icon: const Icon(Icons.upload), label: const Text('Upload Video')),
    OutlinedButton.icon(onPressed: () => _msg('Settings'), icon: const Icon(Icons.settings), label: const Text('Settings')),
  ]);

  void _player(Video v) => showModalBottomSheet(
    context: context, isScrollControlled: true, backgroundColor: Colors.black,
    builder: (_) => SizedBox(height: MediaQuery.of(context).size.height*.85, child: Column(children: [
      const Spacer(), Text(v.emoji, style: const TextStyle(fontSize: 130)),
      const Text('VIDEO PLAYER', style: TextStyle(color: Colors.white)),
      Padding(padding: const EdgeInsets.all(20), child: Text(v.title,
        style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold))),
      const Icon(Icons.play_circle_fill, color: Colors.white, size: 70), const Spacer(),
    ])),
  );

  void _upload() => showModalBottomSheet(
    context: context, showDragHandle: true,
    builder: (_) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Padding(padding: EdgeInsets.all(18), child: Text('वीडियो अपलोड करें',
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
      ListTile(leading: const Icon(Icons.video_library), title: const Text('Gallery से वीडियो चुनें'),
        onTap: () {Navigator.pop(context); _msg('Gallery picker: backend integration बाकी है');}),
      ListTile(leading: const Icon(Icons.videocam), title: const Text('नया वीडियो रिकॉर्ड करें'),
        onTap: () {Navigator.pop(context); _msg('Camera: backend integration बाकी है');}),
    ])),
  );

  void _comments(Video v) => showModalBottomSheet(
    context: context, builder: (_) => SizedBox(height: 300, child: Center(child: Text('Comments for ${v.title}'))));
  void _search() => showSearch(context: context, delegate: SearchVideos(videos));
  void _msg(String s) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s)));
}

class SearchVideos extends SearchDelegate<Video?> {
  final List<Video> videos;
  SearchVideos(this.videos);
  @override List<Widget>? buildActions(BuildContext c) => [IconButton(onPressed: () => query='', icon: const Icon(Icons.clear))];
  @override Widget? buildLeading(BuildContext c) => IconButton(onPressed: () => close(c, null), icon: const Icon(Icons.arrow_back));
  @override Widget buildResults(BuildContext c) => _list();
  @override Widget buildSuggestions(BuildContext c) => _list();
  Widget _list() {
    final r = videos.where((v) => v.title.toLowerCase().contains(query.toLowerCase()) || v.creator.toLowerCase().contains(query.toLowerCase())).toList();
    return ListView(children: r.map((v) => ListTile(
      leading: Text(v.emoji, style: const TextStyle(fontSize: 30)),
      title: Text(v.title), subtitle: Text(v.creator),
      onTap: () => close(context, v),
    )).toList());
  }
}
