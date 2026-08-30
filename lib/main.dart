import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

void main() => runApp(const BilliBilliApp());

class BilliBilliApp extends StatelessWidget {
  const BilliBilliApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Billi Billi',
    theme: ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      colorSchemeSeed: Colors.red,
    ),
    home: const HomePage(),
  );
}

class VideoItem {
  final File file;
  bool liked;
  VideoItem({required this.file, this.liked = false});
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ImagePicker _picker = ImagePicker();
  final List<VideoItem> _videos = [];
  int _selectedIndex = 0;

  Future<void> _pickVideo() async {
    final x = await _picker.pickVideo(source: ImageSource.gallery);
    if (x == null) return;
    setState(() => _videos.insert(0, VideoItem(file: File(x.path))));
  }

  Future<void> _recordVideo() async {
    final x = await _picker.pickVideo(
      source: ImageSource.camera,
      maxDuration: const Duration(minutes: 5),
    );
    if (x == null) return;
    setState(() => _videos.insert(0, VideoItem(file: File(x.path))));
  }

  void _upload() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.video_library),
              title: const Text('Gallery से वीडियो चुनें'),
              onTap: () {
                Navigator.pop(context);
                _pickVideo();
              },
            ),
            ListTile(
              leading: const Icon(Icons.videocam),
              title: const Text('Camera से वीडियो रिकॉर्ड करें'),
              onTap: () {
                Navigator.pop(context);
                _recordVideo();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _settings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SettingsPage()),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.black,
    appBar: AppBar(
      backgroundColor: Colors.black,
      title: const Text(
        'Billi Billi',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () => showSearch(
            context: context,
            delegate: BilliSearchDelegate(_videos),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          onPressed: _settings,
        ),
      ],
    ),
    body: IndexedStack(
      index: _selectedIndex,
      children: [
        _home(),
        _shorts(),
        _profile(),
      ],
    ),
    bottomNavigationBar: NavigationBar(
      backgroundColor: Colors.black,
      selectedIndex: _selectedIndex,
      onDestinationSelected: (i) => setState(() => _selectedIndex = i),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.play_circle_outline),
          selectedIcon: Icon(Icons.play_circle),
          label: 'Shorts',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    ),
    floatingActionButton: FloatingActionButton(
      backgroundColor: Colors.red,
      onPressed: _upload,
      child: const Icon(Icons.add),
    ),
  );

  Widget _home() => _videos.isEmpty
      ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.video_collection,
                size: 80,
                color: Colors.white54,
              ),
              const SizedBox(height: 20),
              const Text(
                'Billi Billi में आपका स्वागत है',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text('अपना पहला वीडियो Gallery या Camera से जोड़ें।'),
              const SizedBox(height: 25),
              ElevatedButton.icon(
                onPressed: _upload,
                icon: const Icon(Icons.video_call),
                label: const Text('वीडियो जोड़ें'),
              ),
            ],
          ),
        )
      : ListView.builder(
          padding: const EdgeInsets.only(bottom: 90),
          itemCount: _videos.length,
          itemBuilder: (_, i) => VideoCard(
            item: _videos[i],
            onLike: () => setState(
              () => _videos[i].liked = !_videos[i].liked,
            ),
          ),
        );

  Widget _shorts() => _videos.isEmpty
      ? Center(
          child: ElevatedButton.icon(
            onPressed: _upload,
            icon: const Icon(Icons.add),
            label: const Text('पहला वीडियो डालें'),
          ),
        )
      : PageView.builder(
          scrollDirection: Axis.vertical,
          itemCount: _videos.length,
          itemBuilder: (_, i) => ShortVideo(
            item: _videos[i],
            onLike: () => setState(
              () => _videos[i].liked = !_videos[i].liked,
            ),
          ),
        );

  Widget _profile() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 45,
              child: Icon(Icons.person, size: 50),
            ),
            const SizedBox(height: 15),
            const Text(
              'Billi Billi User',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${_videos.length} वीडियो',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: _settings,
              icon: const Icon(Icons.settings),
              label: const Text('Settings'),
            ),
          ],
        ),
      );
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String language = 'Hindi';
  bool notifications = true;
  bool privateAccount = false;
  bool autoplay = true;

  final languages = [
    'Hindi',
    'English',
    'Spanish',
    'Portuguese',
    'French',
    'Indonesian',
    'Arabic',
    'Bengali',
    'Japanese',
    'Korean',
  ];

  void chooseLanguage() {
    showDialog(
      context: context,
      builder: (d) => AlertDialog(
        title: const Text('Choose language'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: languages
                .map(
                  (x) => RadioListTile<String>(
                    value: x,
                    groupValue: language,
                    title: Text(x),
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() => language = v);
                      Navigator.pop(d);
                    },
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }

  void info(String text) {
    showDialog(
      context: context,
      builder: (d) => AlertDialog(
        title: const Text('Billi Billi'),
        content: Text(text),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(d),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.black,
    appBar: AppBar(
      backgroundColor: Colors.black,
      title: const Text('Settings'),
    ),
    body: ListView(
      children: [
        const _Section('Account'),
        ListTile(
          leading: const Icon(Icons.language),
          title: const Text('Language'),
          subtitle: Text(language),
          trailing: const Icon(Icons.chevron_right),
          onTap: chooseLanguage,
        ),
        ListTile(
          leading: const Icon(Icons.public),
          title: const Text('Country / Region'),
          subtitle: const Text('Global'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => info('Billi Billi International — Global'),
        ),
        const _Section('Preferences'),
        SwitchListTile(
          secondary: const Icon(Icons.notifications_outlined),
          title: const Text('Notifications'),
          value: notifications,
          onChanged: (v) => setState(() => notifications = v),
        ),
        SwitchListTile(
          secondary: const Icon(Icons.play_circle_outline),
          title: const Text('Autoplay videos'),
          value: autoplay,
          onChanged: (v) => setState(() => autoplay = v),
        ),
        const _Section('Privacy & Safety'),
        SwitchListTile(
          secondary: const Icon(Icons.lock_outline),
          title: const Text('Private account'),
          value: privateAccount,
          onChanged: (v) => setState(() => privateAccount = v),
        ),
        ListTile(
          leading: const Icon(Icons.block),
          title: const Text('Blocked users'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => info('Blocked users list is empty.'),
        ),
        ListTile(
          leading: const Icon(Icons.security),
          title: const Text('Safety & Moderation'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => info(
            'Report, Block और inappropriate-content controls.',
          ),
        ),
        const _Section('About'),
        ListTile(
          leading: const Icon(Icons.info_outline),
          title: const Text('About Billi Billi'),
          subtitle: const Text('International video sharing app'),
          onTap: () => info(
            'Billi Billi — watch, upload and share videos worldwide.',
          ),
        ),
        ListTile(
          leading: const Icon(Icons.privacy_tip_outlined),
          title: const Text('Privacy Policy'),
          onTap: () => info(
            'Privacy Policy page can be connected later.',
          ),
        ),
      ],
    ),
  );
}

class _Section extends StatelessWidget {
  final String title;

  const _Section(this.title);

  @override
  Widget build(BuildContext c) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 8),
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.redAccent,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
}

class VideoCard extends StatefulWidget {
  final VideoItem item;
  final VoidCallback onLike;

  const VideoCard({
    super.key,
    required this.item,
    required this.onLike,
  });

  @override
  State<VideoCard> createState() => _VideoCardState();
}

class _VideoCardState extends State<VideoCard> {
  late VideoPlayerController c;
  bool ready = false;

  @override
  void initState() {
    super.initState();
    c = VideoPlayerController.file(widget.item.file)
      ..initialize().then((_) {
        if (mounted) setState(() => ready = true);
      });
  }

  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Card(
        color: const Color(0xFF151515),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            if (ready)
              AspectRatio(
                aspectRatio: c.value.aspectRatio,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    VideoPlayer(c),
                    IconButton(
                      iconSize: 55,
                      onPressed: () {
                        setState(() {
                          c.value.isPlaying ? c.pause() : c.play();
                        });
                      },
                      icon: Icon(
                        c.value.isPlaying
                            ? Icons.pause_circle
                            : Icons.play_circle,
                      ),
                    ),
                  ],
                ),
              )
            else
              const AspectRatio(
                aspectRatio: 16 / 9,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            if (ready)
              VideoProgressIndicator(
                c,
                allowScrubbing: true,
                padding: EdgeInsets.zero,
              ),
            Row(
              children: [
                IconButton(
                  onPressed: widget.onLike,
                  icon: Icon(
                    widget.item.liked
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color:
                        widget.item.liked ? Colors.red : Colors.white,
                  ),
                ),
                const Text('Like'),
                const Spacer(),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.share),
                ),
                const Text('Share'),
                const SizedBox(width: 10),
              ],
            ),
          ],
        ),
      );
}

class ShortVideo extends StatefulWidget {
  final VideoItem item;
  final VoidCallback onLike;

  const ShortVideo({
    super.key,
    required this.item,
    required this.onLike,
  });

  @override
  State<ShortVideo> createState() => _ShortVideoState();
}

class _ShortVideoState extends State<ShortVideo> {
  late VideoPlayerController c;
  bool ready = false;

  @override
  void initState() {
    super.initState();

    c = VideoPlayerController.file(widget.item.file)
      ..initialize().then((_) {
        if (mounted) {
          setState(() => ready = true);
          c.setLooping(true);
          c.play();
        }
      });
  }

  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }

  void toggle() {
    setState(() => c.value.isPlaying ? c.pause() : c.play());
  }

  @override
  Widget build(BuildContext context) => Stack(
        fit: StackFit.expand,
        children: [
          Container(color: Colors.black),
          if (ready)
            GestureDetector(
              onTap: toggle,
              child: Center(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: c.value.size.width,
                    height: c.value.size.height,
                    child: VideoPlayer(c),
                  ),
                ),
              ),
            )
          else
            const Center(child: CircularProgressIndicator()),
          Positioned(
            right: 12,
            bottom: 100,
            child: Column(
              children: [
                IconButton(
                  iconSize: 38,
                  onPressed: widget.onLike,
                  icon: Icon(
                    widget.item.liked
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: widget.item.liked
                        ? Colors.red
                        : Colors.white,
                  ),
                ),
                const Text('Like'),
                const SizedBox(height: 15),
                IconButton(
                  iconSize: 35,
                  onPressed: () {},
                  icon: const Icon(
                    Icons.comment,
                    color: Colors.white,
                  ),
                ),
                const Text('Comment'),
                const SizedBox(height: 15),
                IconButton(
                  iconSize: 35,
                  onPressed: () {},
                  icon: const Icon(
                    Icons.share,
                    color: Colors.white,
                  ),
                ),
                const Text('Share'),
              ],
            ),
          ),
          Positioned(
            left: 15,
            right: 90,
            bottom: 25,
            child: Row(
              children: [
                const CircleAvatar(
                  child: Icon(Icons.person),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    '@BilliBilli',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: toggle,
                  icon: Icon(
                    c.value.isPlaying
                        ? Icons.pause
                        : Icons.play_arrow,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
}

class BilliSearchDelegate extends SearchDelegate<String> {
  final List<VideoItem> videos;

  BilliSearchDelegate(this.videos);

  @override
  List<Widget>? buildActions(BuildContext c) => [
        if (query.isNotEmpty)
          IconButton(
            onPressed: () => query = '',
            icon: const Icon(Icons.clear),
          ),
      ];

  @override
  Widget? buildLeading(BuildContext c) => IconButton(
        onPressed: () => close(c, ''),
        icon: const Icon(Icons.arrow_back),
      );

  @override
  Widget buildResults(BuildContext c) => results();

  @override
  Widget buildSuggestions(BuildContext c) => results();

  Widget results() => videos.isEmpty
      ? const Center(child: Text('कोई वीडियो नहीं मिला'))
      : ListView.builder(
          itemCount: videos.length,
          itemBuilder: (_, i) => ListTile(
            leading: const Icon(Icons.video_library),
            title: Text('Billi Billi Video ${i + 1}'),
            subtitle: const Text(
              'वीडियो खोलने के लिए टैप करें',
            ),
          ),
        );
}
