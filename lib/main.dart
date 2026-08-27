import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const BilliBilliApp());

class BilliBilliApp extends StatefulWidget {
  const BilliBilliApp({super.key});

  @override
  State<BilliBilliApp> createState() => _BilliBilliAppState();
}

class _BilliBilliAppState extends State<BilliBilliApp> {
  String? language;

  @override
  void initState() {
    super.initState();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() => language = prefs.getString('billi_language'));
  }

  Future<void> _selectLanguage(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('billi_language', value);
    if (!mounted) return;
    setState(() => language = value);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Billi Billi',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      home: language == null
          ? LanguageSelection(onSelected: _selectLanguage)
          : Home(language: language!),
    );
  }
}

class LanguageSelection extends StatelessWidget {
  final Future<void> Function(String) onSelected;

  const LanguageSelection({super.key, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🐱', style: TextStyle(fontSize: 72)),
                const SizedBox(height: 18),
                const Text(
                  'Billi Billi',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Choose your language\nअपनी भाषा चुनें',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 20),
                ),
                const SizedBox(height: 36),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => onSelected('hi'),
                    child: const Text('🇮🇳  हिन्दी'),
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => onSelected('en'),
                    child: const Text('🇺🇸  English'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class L {
  static String t(String language, String hi, String en) =>
      language == 'hi' ? hi : en;
}

class VideoItem {
  final String title;
  final String creator;
  final String views;
  final XFile file;
  int likes;
  bool liked;

  VideoItem({
    required this.title,
    required this.creator,
    required this.views,
    required this.file,
    this.likes = 0,
    this.liked = false,
  });
}

class Home extends StatefulWidget {
  final String language;

  const Home({super.key, required this.language});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int tab = 0;

  String tr(String hi, String en) => L.t(widget.language, hi, en);
  final ImagePicker picker = ImagePicker();
  final List<VideoItem> videos = [];

  @override
  Widget build(BuildContext context) {
    final pages = [_home(), _shorts(), _subs(), _profile()];
    return Scaffold(
      appBar: AppBar(
        title: const Text.rich(
          TextSpan(children: [
            TextSpan(text: '🐱 '),
            TextSpan(text: 'Billi ', style: TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: 'Billi', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ]),
        ),
        actions: [
          IconButton(onPressed: _search, icon: const Icon(Icons.search)),
          IconButton(
            onPressed: () => _msg(tr('नोटिफिकेशन', 'Notifications')),
            icon: const Icon(Icons.notifications_none),
          ),
        ],
      ),
      body: pages[tab],
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (i) => setState(() => tab = i),
        destinations: [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: tr('होम', 'Home')),
          NavigationDestination(icon: Icon(Icons.play_circle_outline), selectedIcon: Icon(Icons.play_circle), label: tr('शॉर्ट्स', 'Shorts')),
          NavigationDestination(icon: Icon(Icons.subscriptions_outlined), selectedIcon: Icon(Icons.subscriptions), label: tr('सब्सक्रिप्शन', 'Subscriptions')),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: tr('प्रोफ़ाइल', 'Profile')),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        onPressed: _upload,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _home() {
    if (videos.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Text(
            tr('Billi Billi में आपका स्वागत है 🐱\n\nनीचे + दबाकर अपना पहला वीडियो चुनें।', 'Welcome to Billi Billi 🐱\n\nTap + below to choose your first video.'),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20),
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 90),
      children: [
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [tr('सभी', 'All'), tr('म्यूजिक', 'Music'), tr('गेमिंग', 'Gaming'), tr('लाइव', 'Live'), tr('न्यूज़', 'News'), tr('कॉमेडी', 'Comedy')]
                .map((x) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Chip(label: Text(x)),
                    ))
                .toList(),
          ),
        ),
        ...videos.map(_card),
      ],
    );
  }

  Widget _card(VideoItem v) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => _player(v),
            child: SizedBox(
              height: 210,
              width: double.infinity,
              child: VideoThumbnail(file: v.file),
            ),
          ),
          ListTile(
            leading: const CircleAvatar(child: Text('🐱')),
            title: Text(v.title, style: const TextStyle(fontWeight: FontWeight.w700)),
            subtitle: Text('${v.creator} • ${v.views}'),
            trailing: IconButton(
              onPressed: () => _msg(tr('सेव / रिपोर्ट / रुचि नहीं', 'Save / Report / Not interested')),
              icon: const Icon(Icons.more_vert),
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: () => setState(() {
                  v.liked = !v.liked;
                  v.likes += v.liked ? 1 : -1;
                }),
                icon: Icon(
                  v.liked ? Icons.favorite : Icons.favorite_border,
                  color: v.liked ? Colors.red : null,
                ),
              ),
              Text('${v.likes}'),
              IconButton(
                onPressed: () => _comments(v),
                icon: const Icon(Icons.comment_outlined),
              ),
              IconButton(
                onPressed: () => _msg('Share: ${v.title}'),
                icon: const Icon(Icons.share_outlined),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _shorts() {
    if (videos.isEmpty) {
      return const Center(child: Text('पहले + दबाकर वीडियो जोड़ें 🎬'));
    }

    return PageView.builder(
      scrollDirection: Axis.vertical,
      itemCount: videos.length,
      itemBuilder: (_, i) => ShortsVideo(item: videos[i]),
    );
  }

  Widget _subs() => Center(
        child: Text(
          tr('आपके subscribed creators यहाँ दिखेंगे', 'Your subscribed creators will appear here'),
          style: const TextStyle(fontSize: 18),
        ),
      );

  Widget _profile() => ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const CircleAvatar(
            radius: 45,
            child: Text('🐱', style: TextStyle(fontSize: 42)),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              tr('Billi Billi Creator', 'Billi Billi Creator'),
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          const Center(child: Text('@billi_creator')),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: _upload,
            icon: const Icon(Icons.upload),
            label: Text(tr('वीडियो अपलोड करें', 'Upload Video')),
          ),
          OutlinedButton.icon(
            onPressed: () => _msg(tr('सेटिंग्स', 'Settings')),
            icon: const Icon(Icons.settings),
            label: Text(tr('सेटिंग्स', 'Settings')),
          ),
        ],
      );

  Future<void> _changeLanguage() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(18),
              child: Text(
                tr('भाषा चुनें', 'Choose language'),
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: const Text('🇮🇳', style: TextStyle(fontSize: 24)),
              title: const Text('हिन्दी'),
              onTap: () => Navigator.pop(context, 'hi'),
            ),
            ListTile(
              leading: const Text('🇺🇸', style: TextStyle(fontSize: 24)),
              title: const Text('English'),
              onTap: () => Navigator.pop(context, 'en'),
            ),
          ],
        ),
      ),
    );

    if (selected == null || selected == widget.language) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('billi_language', selected);
    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => Home(language: selected)),
      (_) => false,
    );
  }

  Future<void> _upload() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(18),
              child: Text(tr('वीडियो अपलोड करें', 'Upload Video'),
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            ),
            ListTile(
              leading: const Icon(Icons.video_library),
              title: Text(tr('Gallery से वीडियो चुनें', 'Choose video from Gallery')),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.videocam),
              title: Text(tr('नया वीडियो रिकॉर्ड करें', 'Record a new video')),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    final file = await picker.pickVideo(
      source: source,
      maxDuration: const Duration(minutes: 5),
    );

    if (file == null) return;

    setState(() {
      videos.insert(
        0,
        VideoItem(
          title: tr('मेरा नया Billi Billi वीडियो', 'My new Billi Billi video'),
          creator: tr('Billi Billi Creator', 'Billi Billi Creator'),
          views: tr('0 व्यूज़', '0 views'),
          file: file,
        ),
      );
      tab = 0;
    });

    if (mounted) _msg(tr('वीडियो सफलतापूर्वक जोड़ दिया गया 🎉', 'Video added successfully 🎉'));
  }

  void _player(VideoItem v) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => VideoPlayerPage(item: v)),
    );
  }

  void _comments(VideoItem v) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SizedBox(
        height: 300,
        child: Center(child: Text(tr('टिप्पणियाँ: ${v.title}', 'Comments for ${v.title}'))),
      ),
    );
  }

  void _search() => showSearch(
        context: context,
        delegate: SearchVideos(videos),
      );

  void _msg(String s) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s)));
  }
}

class VideoThumbnail extends StatefulWidget {
  final XFile file;
  const VideoThumbnail({super.key, required this.file});

  @override
  State<VideoThumbnail> createState() => _VideoThumbnailState();
}

class _VideoThumbnailState extends State<VideoThumbnail> {
  VideoPlayerController? controller;

  @override
  void initState() {
    super.initState();
    controller = VideoPlayerController.file(File(widget.file.path))
      ..initialize().then((_) {
        if (mounted) setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller!.value.isInitialized) {
      return const ColoredBox(
        color: Colors.black,
        child: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: controller!.value.size.width,
            height: controller!.value.size.height,
            child: VideoPlayer(controller!),
          ),
        ),
        const Center(
          child: Icon(Icons.play_circle_fill, color: Colors.white, size: 58),
        ),
      ],
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}

class ShortsVideo extends StatefulWidget {
  final VideoItem item;
  const ShortsVideo({super.key, required this.item});

  @override
  State<ShortsVideo> createState() => _ShortsVideoState();
}

class _ShortsVideoState extends State<ShortsVideo> {
  late final VideoPlayerController controller;

  @override
  void initState() {
    super.initState();
    controller = VideoPlayerController.file(File(widget.item.file.path))
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() {});
        controller.setLooping(true);
        controller.play();
      });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: controller.value.isInitialized
          ? Stack(
              fit: StackFit.expand,
              children: [
                FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: controller.value.size.width,
                    height: controller.value.size.height,
                    child: VideoPlayer(controller),
                  ),
                ),
                Positioned(
                  left: 18,
                  bottom: 30,
                  child: Text(
                    '${widget.item.creator.startsWith('@') ? widget.item.creator : '@${widget.item.creator}'}\n${widget.item.title}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Positioned(
                  right: 16,
                  bottom: 55,
                  child: Column(
                    children: [
                      IconButton(
                        onPressed: () => setState(() {
                          widget.item.liked = !widget.item.liked;
                          widget.item.likes += widget.item.liked ? 1 : -1;
                        }),
                        icon: Icon(
                          widget.item.liked
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: widget.item.liked ? Colors.red : Colors.white,
                          size: 36,
                        ),
                      ),
                      Text('${widget.item.likes}',
                          style: const TextStyle(color: Colors.white)),
                      const SizedBox(height: 12),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.comment,
                            color: Colors.white, size: 34),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.share,
                            color: Colors.white, size: 34),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 45,
                  right: 15,
                  child: IconButton(
                    onPressed: () {
                      setState(() {
                        if (controller.value.isPlaying) {
                          controller.pause();
                        } else {
                          controller.play();
                        }
                      });
                    },
                    icon: Icon(
                      controller.value.isPlaying
                          ? Icons.pause_circle
                          : Icons.play_circle,
                      color: Colors.white,
                      size: 42,
                    ),
                  ),
                ),
              ],
            )
          : const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class VideoPlayerPage extends StatefulWidget {
  final VideoItem item;
  const VideoPlayerPage({super.key, required this.item});

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late final VideoPlayerController controller;

  @override
  void initState() {
    super.initState();
    controller = VideoPlayerController.file(File(widget.item.file.path))
      ..initialize().then((_) {
        if (mounted) {
          setState(() {});
          controller.play();
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black, foregroundColor: Colors.white),
      body: Center(
        child: controller.value.isInitialized
            ? AspectRatio(
                aspectRatio: controller.value.aspectRatio,
                child: Vid
