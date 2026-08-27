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
        useMaterial3: true,
        colorSchemeSeed: Colors.red,
      ),
      home: const HomePage(),
    );
  }
}

class VideoItem {
  final File file;
  bool liked;

  VideoItem({
    required this.file,
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

  final List<VideoItem> _videos = [];

  int _selectedIndex = 0;

  Future<void> _pickVideo() async {
    final XFile? picked = await _picker.pickVideo(
      source: ImageSource.gallery,
    );

    if (picked == null) return;

    setState(() {
      _videos.insert(
        0,
        VideoItem(file: File(picked.path)),
      );
      _selectedIndex = 0;
    });
  }

  Future<void> _recordVideo() async {
    final XFile? recorded = await _picker.pickVideo(
      source: ImageSource.camera,
      maxDuration: const Duration(minutes: 5),
    );

    if (recorded == null) return;

    setState(() {
      _videos.insert(
        0,
        VideoItem(file: File(recorded.path)),
      );
      _selectedIndex = 0;
    });
  }

  void _showUploadOptions() {
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
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Billi Billi',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: BilliSearchDelegate(_videos),
              );
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _homeScreen(),
          _shortsScreen(),
          _profileScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.black,
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
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
        onPressed: _showUploadOptions,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _homeScreen() {
    if (_videos.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
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
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'अपना पहला वीडियो Gallery या Camera से जोड़ें।',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 25),
              ElevatedButton.icon(
                onPressed: _showUploadOptions,
                icon: const Icon(Icons.video_call),
                label: const Text('वीडियो जोड़ें'),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 90),
      itemCount: _videos.length,
      itemBuilder: (context, index) {
        return VideoCard(
          item: _videos[index],
          onLike: () {
            setState(() {
              _videos[index].liked = !_videos[index].liked;
            });
          },
        );
      },
    );
  }

  Widget _shortsScreen() {
    if (_videos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.play_circle_outline,
              size: 80,
              color: Colors.white54,
            ),
            const SizedBox(height: 20),
            const Text(
              'अभी कोई Short नहीं है',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _showUploadOptions,
              icon: const Icon(Icons.add),
              label: const Text('पहला वीडियो डालें'),
            ),
          ],
        ),
      );
    }

    return PageView.builder(
      scrollDirection: Axis.vertical,
      itemCount: _videos.length,
      itemBuilder: (context, index) {
        return ShortVideo(
          item: _videos[index],
          onLike: () {
            setState(() {
              _videos[index].liked = !_videos[index].liked;
            });
          },
        );
      },
    );
  }

  Widget _profileScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircleAvatar(
            radius: 45,
            child: Icon(
              Icons.person,
              size: 50,
            ),
          ),
          const SizedBox(height: 15),
          const Text(
            'Billi Billi User',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${_videos.length} वीडियो',
            style: const TextStyle(
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
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
  late VideoPlayerController _controller;
  bool _ready = false;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.file(widget.item.file)
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _ready = true;
          });
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF151515),
      margin: const EdgeInsets.only(bottom: 10),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          if (_ready)
            AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  VideoPlayer(_controller),
                  IconButton(
                    iconSize: 55,
                    color: Colors.white,
                    onPressed: () {
                      setState(() {
                        if (_controller.value.isPlaying) {
                          _controller.pause();
                        } else {
                          _controller.play();
                        }
                      });
                    },
                    icon: Icon(
                      _controller.value.isPlaying
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
          VideoProgressIndicator(
            _controller,
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
                  color: widget.item.liked ? Colors.red : Colors.white,
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
  late VideoPlayerController _controller;
  bool _ready = false;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.file(widget.item.file)
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _ready = true;
          });
          _controller
            ..setLooping(true)
            ..play();
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlay() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(color: Colors.black),
        if (_ready)
          GestureDetector(
            onTap: _togglePlay,
            child: Center(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _controller.value.size.width,
                  height: _controller.value.size.height,
                  child: VideoPlayer(_controller),
                ),
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
              const Text(
                'Like',
                style: TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 15),
              IconButton(
                iconSize: 35,
                onPressed: () {},
                icon: const Icon(
                  Icons.comment,
                  color: Colors.white,
                ),
              ),
              const Text(
                'Comment',
                style: TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 15),
              IconButton(
                iconSize: 35,
                onPressed: () {},
                icon: const Icon(
                  Icons.share,
                  color: Colors.white,
                ),
              ),
              const Text(
                'Share',
                style: TextStyle(color: Colors.white),
              ),
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
                onPressed: _togglePlay,
                icon: Icon(
                  _controller.value.isPlaying
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
}

class BilliSearchDelegate extends SearchDelegate<String> {
  final List<VideoItem> videos;

  BilliSearchDelegate(this.videos);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
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
        close(context, '');
      },
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _results();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _results();
  }

  Widget _results() {
    if (videos.isEmpty) {
      return const Center(
        child: Text('कोई वीडियो नहीं मिला'),
      );
    }

    return ListView.builder(
      itemCount: videos.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: const Icon(Icons.video_library),
          title: Text(
            'Billi Billi Video ${index + 1}',
          ),
          subtitle: const Text(
            'वीडियो खोलने के लिए टैप करें',
          ),
          onTap: () {
            close(context, '');
          },
        );
      },
    );
  }
}
