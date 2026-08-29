import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

void main() => runApp(const BilliBilliApp());

class BilliBilliApp extends StatelessWidget {
  const BilliBilliApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Billi Billi',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.pink,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const HomePage(),
    );
  }
}

enum MediaType { photo, video }

class MediaPost {
  const MediaPost({required this.path, required this.type, this.caption = ''});

  final String path;
  final MediaType type;
  final String caption;
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ImagePicker _picker = ImagePicker();
  final List<MediaPost> _posts = [];
  int _tab = 0;

  Future<Directory> _mediaDirectory() async {
    final root = await getApplicationDocumentsDirectory();
    final dir = Directory('${root.path}/billi_billi_media');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  Future<void> _addPhoto(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 90,
        maxWidth: 1800,
      );
      if (picked == null) return;

      final dir = await _mediaDirectory();
      final name = 'billi_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final saved = await File(picked.path).copy('${dir.path}/$name');

      if (!mounted) return;
      setState(() {
        _posts.insert(0, MediaPost(path: saved.path, type: MediaType.photo));
        _tab = 0;
      });
    } catch (e) {
      _showError('फोटो जोड़ नहीं पाए: $e');
    }
  }

  Future<void> _addVideo(ImageSource source) async {
    try {
      final picked = await _picker.pickVideo(
        source: source,
        maxDuration: const Duration(minutes: 5),
      );
      if (picked == null) return;

      final dir = await _mediaDirectory();
      final extension = picked.path.contains('.')
          ? picked.path.split('.').last.toLowerCase()
          : 'mp4';
      final name = 'billi_${DateTime.now().millisecondsSinceEpoch}.$extension';
      final saved = await File(picked.path).copy('${dir.path}/$name');

      if (!mounted) return;
      setState(() {
        _posts.insert(0, MediaPost(path: saved.path, type: MediaType.video));
        _tab = 0;
      });
    } catch (e) {
      _showError('वीडियो जोड़ नहीं पाए: $e');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _addMenu() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: Text(
                'Billi Billi में पोस्ट करें',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.video_library_outlined),
              title: const Text('Gallery से वीडियो चुनें'),
              onTap: () {
                Navigator.pop(context);
                _addVideo(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.videocam_outlined),
              title: const Text('Camera से वीडियो रिकॉर्ड करें'),
              onTap: () {
                Navigator.pop(context);
                _addVideo(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Gallery से फोटो चुनें'),
              onTap: () {
                Navigator.pop(context);
                _addPhoto(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Camera से फोटो लें'),
              onTap: () {
                Navigator.pop(context);
                _addPhoto(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _openShorts() {
    final videos = _posts.where((p) => p.type == MediaType.video).toList();
    if (videos.isEmpty) {
      _showError('पहले Gallery या Camera से एक वीडियो डालें।');
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ShortsPage(videos: videos)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final videoCount = _posts.where((p) => p.type == MediaType.video).length;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Billi Billi', style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(onPressed: _openShorts, tooltip: 'Shorts', icon: const Icon(Icons.play_circle_outline)),
          IconButton(onPressed: _addMenu, tooltip: 'Post', icon: const Icon(Icons.add_a_photo)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.favorite_border)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.chat_bubble_outline)),
        ],
      ),
      body: _tab == 0
          ? (_posts.isEmpty
              ? const _EmptyHome()
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 100),
                  itemCount: _posts.length,
                  itemBuilder: (_, i) => MediaPostCard(post: _posts[i]),
                ))
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircleAvatar(radius: 50, child: Icon(Icons.person, size: 52)),
                  const SizedBox(height: 12),
                  const Text('Billi Billi User', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text('${_posts.where((p) => p.type == MediaType.photo).length} Photos  •  $videoCount Videos'),
                  const SizedBox(height: 20),
                  FilledButton.icon(onPressed: _addMenu, icon: const Icon(Icons.add), label: const Text('Post डालें')),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addMenu,
        tooltip: 'Post',
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (v) => setState(() => _tab = v),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class _EmptyHome extends StatelessWidget {
  const _EmptyHome();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'Billi Billi में आपका स्वागत है 🐱\n\nनीचे + दबाकर फोटो या वीडियो पोस्ट करें',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}

class MediaPostCard extends StatelessWidget {
  const MediaPostCard({super.key, required this.post});

  final MediaPost post;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ListTile(
          leading: CircleAvatar(child: Icon(Icons.person)),
          title: Text('Billi Billi User', style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text('India'),
        ),
        if (post.type == MediaType.photo)
          AspectRatio(
            aspectRatio: 1,
            child: Image.file(File(post.path), fit: BoxFit.cover),
          )
        else
          VideoPost(path: post.path),
        Row(
          children: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.favorite_border)),
            IconButton(onPressed: () {}, icon: const Icon(Icons.chat_bubble_outline)),
            IconButton(onPressed: () {}, icon: const Icon(Icons.send_outlined)),
            const Spacer(),
            IconButton(onPressed: () {}, icon: const Icon(Icons.bookmark_border)),
          ],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
          child: Text(post.type == MediaType.video ? 'Billi Billi वीडियो पोस्ट' : 'Billi Billi फोटो पोस्ट'),
        ),
      ],
    );
  }
}

class VideoPost extends StatefulWidget {
  const VideoPost({super.key, required this.path});

  final String path;

  @override
  State<VideoPost> createState() => _VideoPostState();
}

class _VideoPostState extends State<VideoPost> {
  late final VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.path))
      ..initialize().then((_) {
        if (mounted) setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return const AspectRatio(
        aspectRatio: 9 / 16,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    final ratio = _controller.value.aspectRatio == 0 ? 9 / 16 : _controller.value.aspectRatio;
    return GestureDetector(
      onTap: () {
        setState(() {
          _controller.value.isPlaying ? _controller.pause() : _controller.play();
        });
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(aspectRatio: ratio, child: VideoPlayer(_controller)),
          if (!_controller.value.isPlaying)
            const CircleAvatar(radius: 30, child: Icon(Icons.play_arrow, size: 38)),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: VideoProgressIndicator(_controller, allowScrubbing: true),
          ),
        ],
      ),
    );
  }
}

class ShortsPage extends StatefulWidget {
  const ShortsPage({super.key, required this.videos});

  final List<MediaPost> videos;

  @override
  State<ShortsPage> createState() => _ShortsPageState();
}

class _ShortsPageState extends State<ShortsPage> {
  late final PageController _pageController;
  int _current = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Billi Billi Shorts'),
      ),
      body: PageView.builder(
        scrollDirection: Axis.vertical,
        controller: _pageController,
        itemCount: widget.videos.length,
        onPageChanged: (i) => setState(() => _current = i),
        itemBuilder: (_, i) => ShortVideoItem(
          path: widget.videos[i].path,
          active: i == _current,
        ),
      ),
    );
  }
}

class ShortVideoItem extends StatefulWidget {
  const ShortVideoItem({super.key, required this.path, required this.active});

  final String path;
  final bool active;

  @override
  State<ShortVideoItem> createState() => _ShortVideoItemState();
}

class _ShortVideoItemState extends State<ShortVideoItem> {
  late final VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.path))
      ..setLooping(true)
      ..initialize().then((_) {
        if (mounted) {
          setState(() {});
          if (widget.active) _controller.play();
        }
      });
  }

  @override
  void didUpdateWidget(covariant ShortVideoItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_controller.value.isInitialized) return;
    if (widget.active) {
      _controller.play();
    } else {
      _controller.pause();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }
    return GestureDetector(
      onTap: () {
        setState(() {
          _controller.value.isPlaying ? _controller.pause() : _controller.play();
        });
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: _controller.value.size.width,
              height: _controller.value.size.height,
              child: VideoPlayer(_controller),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Expanded(
                  child: Text(
                    'Billi Billi User\n#BilliBilli #Shorts',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Column(
                  children: [
                    IconButton(onPressed: () {}, color: Colors.white, icon: const Icon(Icons.favorite, size: 32)),
                    IconButton(onPressed: () {}, color: Colors.white, icon: const Icon(Icons.comment, size: 30)),
                    IconButton(onPressed: () {}, color: Colors.white, icon: const Icon(Icons.share, size: 30)),
                  ],
                ),
              ],
            ),
          ),
          Positioned(left: 0, right: 0, bottom: 0, child: VideoProgressIndicator(_controller, allowScrubbing: false)),
        ],
      ),
    );
  }
}
