import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

void main() {
  runApp(const BilliBilliApp());
}

class BilliBilliApp extends StatelessWidget {
  const BilliBilliApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Billi Billi',
      theme: ThemeData(
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.red,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class BilliVideo {
  final String title;
  final String creator;
  final String path;
  int likes;
  bool liked;

  BilliVideo({
    required this.title,
    required this.creator,
    required this.path,
    this.likes = 0,
    this.liked = false,
  });
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ImagePicker _picker = ImagePicker();

  final List<BilliVideo> videos = [];

  int currentTab = 0;

  Future<void> pickVideo(ImageSource source) async {
    try {
      final XFile? file = await _picker.pickVideo(
        source: source,
        maxDuration: const Duration(minutes: 5),
      );

      if (file == null) return;

      setState(() {
        videos.insert(
          0,
          BilliVideo(
            title: 'मेरा नया वीडियो',
            creator: 'Billi Creator',
            path: file.path,
          ),
        );
        currentTab = 0;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('वीडियो Billi Billi में जोड़ दिया गया ✅'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('वीडियो चुनने में समस्या: $e')),
        );
      }
    }
  }

  void showUploadOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.video_library),
                title: const Text('Gallery से वीडियो चुनें'),
                onTap: () {
                  Navigator.pop(context);
                  pickVideo(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.videocam),
                title: const Text('Camera से वीडियो रिकॉर्ड करें'),
                onTap: () {
                  Navigator.pop(context);
                  pickVideo(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void showSearch() {
    showSearch(
      context: context,
      delegate: BilliSearchDelegate(videos),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      ShortsPage(videos: videos),
      const Center(child: Text('🔥 लोकप्रिय वीडियो')),
      const Center(child: Text('👥 सब्सक्राइब किए गए')),
      ProfilePage(onUpload: showUploadOptions),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Text('🐱 ', style: TextStyle(fontSize: 24)),
            Text(
              'Billi ',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'Billi',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: showSearch,
            icon: const Icon(Icons.search),
          ),
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('कोई नई notification नहीं है')),
              );
            },
            icon: const Icon(Icons.notifications_none),
          ),
        ],
      ),
      body: pages[currentTab],
      floatingActionButton: FloatingActionButton(
        onPressed: showUploadOptions,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentTab,
        onDestinationSelected: (index) {
          setState(() {
            currentTab = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.local_fire_department_outlined),
            selectedIcon: Icon(Icons.local_fire_department),
            label: 'Shorts',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Subs',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class ShortsPage extends StatefulWidget {
  final List<BilliVideo> videos;

  const ShortsPage({
    super.key,
    required this.videos,
  });

  @override
  State<ShortsPage> createState() => _ShortsPageState();
}

class _ShortsPageState extends State<ShortsPage> {
  final PageController controller = PageController();

  @override
  Widget build(BuildContext context) {
    if (widget.videos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '🎬',
              style: TextStyle(fontSize: 70),
            ),
            const SizedBox(height: 15),
            const Text(
              'अभी कोई वीडियो नहीं है',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 10),
            const Text('नीचे + दबाकर अपना वीडियो जोड़ें'),
          ],
        ),
      );
    }

    return PageView.builder(
      controller: controller,
      scrollDirection: Axis.vertical,
      itemCount: widget.videos.length,
      itemBuilder: (context, index) {
        return VideoCard(
          video: widget.videos[index],
          onChanged: () => setState(() {}),
        );
      },
    );
  }
}

class VideoCard extends StatefulWidget {
  final BilliVideo video;
  final VoidCallback onChanged;

  const VideoCard({
    super.key,
    required this.video,
    required this.onChanged,
  });

  @override
  State<VideoCard> createState() => _VideoCardState();
}

class _VideoCardState extends State<VideoCard> {
  late VideoPlayerController controller;
  bool ready = false;

  @override
  void initState() {
    super.initState();

    controller = VideoPlayerController.file(
      File(widget.video.path),
    )
      ..initialize().then((_) {
        if (!mounted) return;

        setState(() {
          ready = true;
        });

        controller
          ..setLooping(true)
          ..play();
      });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void toggleLike() {
    setState(() {
      widget.video.liked = !widget.video.liked;

      if (widget.video.liked) {
        widget.video.likes++;
      } else if (widget.video.likes > 0) {
        widget.video.likes--;
      }
    });

    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (ready)
            GestureDetector(
              onTap: () {
                setState(() {
                  if (controller.value.isPlaying) {
                    controller.pause();
                  } else {
                    controller.play();
                  }
                });
              },
              child: Center(
                child: AspectRatio(
                  aspectRatio: controller.value.aspectRatio,
                  child: VideoPlayer(controller),
                ),
              ),
            )
          else
            const Center(
              child: CircularProgressIndicator(),
            ),

          Positioned(
            right: 12,
            bottom: 100,
            child: Column(
              children: [
                IconButton(
                  onPressed: toggleLike,
                  iconSize: 42,
                  color: widget.video.liked
                      ? Colors.red
                      : Colors.white,
                  icon: Icon(
                    widget.video.liked
                        ? Icons.favorite
                        : Icons.favorite_border,
                  ),
                ),
                Text(
                  '${widget.video.likes}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 18),
                IconButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Comment feature जल्द आएगा'),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.comment,
                    size: 35,
                  ),
                ),
                const Text('Comment'),
                const SizedBox(height: 18),
                IconButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Share feature जल्द आएगा'),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.share,
                    size: 35,
                  ),
                ),
                const Text('Share'),
              ],
            ),
          ),

          Positioned(
            left: 15,
            right: 80,
            bottom: 25,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '@${widget.video.creator}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.video.title,
                  style: const TextStyle(fontSize: 17),
                ),
              ],
            ),
          ),

          if (ready)
            Positioned(
              left: 10,
              right: 10,
              bottom: 0,
              child: VideoProgressIndicator(
                controller,
                allowScrubbing: true,
              ),
            ),
        ],
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  final VoidCallback onUpload;

  const ProfilePage({
    super.key,
    required this.onUpload,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Center(
          child: CircleAvatar(
            radius: 50,
            child: Text(
              '🐱',
              style: TextStyle(fontSize: 45),
            ),
          ),
        ),
        const SizedBox(height: 15),
        const Center(
          child: Text(
            'Billi Billi Creator',
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 5),
        const Center(
          child: Text('@billi_creator • 12.5K followers'),
        ),
        const SizedBox(height: 25),
        FilledButton.icon(
          onPressed: onUpload,
          icon: const Icon(Icons.upload),
          label: const Text('Upload Video'),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Settings'),
              ),
            );
          },
          icon: const Icon(Icons.settings),
          label: const Text('Settings'),
        ),
      ],
    );
  }
}

class BilliSearchDelegate extends SearchDelegate<BilliVideo?> {
  final List<BilliVideo> videos;

  BilliSearchDelegate(this.videos);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: const Icon(Icons.clear),
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return buildList(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return buildList(context);
  }

  Widget buildList(BuildContext context) {
    final results = videos.where((video) {
      final q = query.toLowerCase();

      return video.title.toLowerCase().contains(q) ||
          video.creator.toLowerCase().contains(q);
    }).toList();

    if (results.isEmpty) {
      return const Center(
        child: Text('कोई वीडियो नहीं मिला'),
      );
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final video = results[index];

        return ListTile(
          leading: const CircleAvatar(
            child: Icon(Icons.play_arrow),
          ),
          title: Text(video.title),
          subtitle: Text(video.creator),
          onTap: () {
            close(context, video);
          },
        );
      },
    );
  }
}
