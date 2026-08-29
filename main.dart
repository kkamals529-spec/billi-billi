import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

void main() {
  runApp(const BilliBilliApp());
}

/// वीडियो लिस्ट में बदलाव होने पर सभी स्क्रीन को अपडेट करने के लिए।
final ValueNotifier<int> videosVersion = ValueNotifier<int>(0);

/// ऐप में मौजूद वीडियो।
final List<VideoItem> videos = [];

class BilliBilliApp extends StatelessWidget {
  const BilliBilliApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Billi Billi',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepOrange,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

class VideoItem {
  final String path;
  final String title;
  int likes;

  VideoItem({
    required this.path,
    required this.title,
    this.likes = 0,
  });
}

// ============================================================
// MAIN SCREEN
// ============================================================

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int selectedIndex = 0;

  final List<Widget> pages = const [
    HomeScreen(),
    ShortsScreen(),
    ProfileScreen(),
  ];

  void openAddVideo() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      isScrollControlled: true,
      builder: (_) => const AddVideoSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: pages,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepOrange,
        onPressed: openAddVideo,
        child: const Icon(
          Icons.add,
          size: 32,
        ),
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.black,
        indicatorColor: Colors.deepOrange.withOpacity(.25),
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
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
    );
  }
}

// ============================================================
// HOME
// ============================================================

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: videosVersion,
      builder: (context, version, child) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.black,
            title: const Text(
              'Billi Billi',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  showSearch(
                    context: context,
                    delegate: BilliSearchDelegate(),
                  );
                },
              ),
            ],
          ),
          body: videos.isEmpty
              ? const EmptyHome()
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 100),
                  itemCount: videos.length,
                  itemBuilder: (context, index) {
                    return VideoCard(
                      key: ValueKey(videos[index].path),
                      video: videos[index],
                    );
                  },
                ),
        );
      },
    );
  }
}

class EmptyHome extends StatelessWidget {
  const EmptyHome({super.key});

  void openAddVideo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      builder: (_) => const AddVideoSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.video_library_outlined,
              size: 90,
              color: Colors.deepOrange.shade200,
            ),
            const SizedBox(height: 25),
            const Text(
              'Billi Billi में आपका स्वागत है',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              'अपना पहला वीडियो Gallery या Camera से जोड़ें।',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 25),
            ElevatedButton.icon(
              onPressed: () => openAddVideo(context),
              icon: const Icon(Icons.video_call),
              label: const Text('वीडियो जोड़ें'),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// ADD VIDEO
// ============================================================

class AddVideoSheet extends StatefulWidget {
  const AddVideoSheet({super.key});

  @override
  State<AddVideoSheet> createState() => _AddVideoSheetState();
}

class _AddVideoSheetState extends State<AddVideoSheet> {
  final ImagePicker picker = ImagePicker();

  bool loading = false;

  Future<void> pickVideo(ImageSource source) async {
    setState(() {
      loading = true;
    });

    try {
      final XFile? file = await picker.pickVideo(
        source: source,
        maxDuration: const Duration(minutes: 10),
      );

      if (file == null) {
        return;
      }

      final video = VideoItem(
        path: file.path,
        title: 'मेरा नया वीडियो',
      );

      videos.insert(0, video);

      // सभी स्क्रीन को अपडेट करें।
      videosVersion.value++;

      if (!mounted) return;

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'वीडियो Billi Billi में जोड़ दिया गया ✅',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'वीडियो चुनने में समस्या: $e',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'वीडियो जोड़ें',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 25),
            if (loading)
              const Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              )
            else ...[
              ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.photo_library),
                ),
                title: const Text(
                  'Gallery से वीडियो',
                ),
                subtitle: const Text(
                  'फोन में मौजूद वीडियो चुनें',
                ),
                onTap: () => pickVideo(
                  ImageSource.gallery,
                ),
              ),
              ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.camera_alt),
                ),
                title: const Text(
                  'Camera से वीडियो',
                ),
                subtitle: const Text(
                  'नया वीडियो रिकॉर्ड करें',
                ),
                onTap: () => pickVideo(
                  ImageSource.camera,
                ),
              ),
            ],
            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// VIDEO CARD
// ============================================================

class VideoCard extends StatefulWidget {
  final VideoItem video;

  const VideoCard({
    super.key,
    required this.video,
  });

  @override
  State<VideoCard> createState() => _VideoCardState();
}

class _VideoCardState extends State<VideoCard> {
  late VideoPlayerController controller;

  bool initialized = false;
  bool liked = false;

  @override
  void initState() {
    super.initState();

    controller = VideoPlayerController.file(
      File(widget.video.path),
    );

    controller.initialize().then((_) {
      if (mounted) {
        setState(() {
          initialized = true;
        });
      }
    }).catchError((error) {
      if (mounted) {
        setState(() {
          initialized = false;
        });
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void toggleLike() {
    setState(() {
      liked = !liked;

      if (liked) {
        widget.video.likes++;
      } else if (widget.video.likes > 0) {
        widget.video.likes--;
      }
    });

    videosVersion.value++;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: initialized &&
                  controller.value.aspectRatio > 0
              ? controller.value.aspectRatio
              : 16 / 9,
          child: initialized
              ? GestureDetector(
                  onTap: () {
                    setState(() {
                      if (controller.value.isPlaying) {
                        controller.pause();
                      } else {
                        controller.play();
                      }
                    });
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      VideoPlayer(controller),
                      if (!controller.value.isPlaying)
                        const CircleAvatar(
                          radius: 32,
                          backgroundColor: Colors.black54,
                          child: Icon(
                            Icons.play_arrow,
                            size: 42,
                          ),
                        ),
                    ],
                  ),
                )
              : const Center(
                  child: CircularProgressIndicator(),
                ),
        ),

        // VIDEO INFORMATION
        Padding(
          padding: const EdgeInsets.fromLTRB(
            15,
            10,
            10,
            15,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(
                backgroundColor: Colors.deepOrange,
                child: Text('🐱'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.video.title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '@Billi_Billi',
                      style: TextStyle(
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),

              // LIKE
              Column(
                children: [
                  IconButton(
                    onPressed: toggleLike,
                    icon: Icon(
                      liked
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color:
                          liked ? Colors.red : Colors.white,
                    ),
                  ),
                  Text(
                    '${widget.video.likes}',
                  ),
                ],
              ),

              // COMMENT
              IconButton(
                onPressed: () {
                  showCommentDialog(context);
                },
                icon: const Icon(
                  Icons.comment_outlined,
                ),
              ),

              // SHARE
              IconButton(
                onPressed: () {
                  showShareMessage(context);
                },
                icon: const Icon(
                  Icons.share_outlined,
                ),
              ),
            ],
          ),
        ),

        const Divider(
          height: 1,
        ),
      ],
    );
  }

  void showCommentDialog(BuildContext context) {
    final TextEditingController commentController =
        TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('कमेंट'),
          content: TextField(
            controller: commentController,
            decoration: const InputDecoration(
              hintText: 'अपना कमेंट लिखें...',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('रद्द करें'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);

                ScaffoldMessenger.of(context)
                    .showSnackBar(
                  const SnackBar(
                    content: Text(
                      'कमेंट अभी स्थानीय रूप से दिखाया गया है।',
                    ),
                  ),
                );
              },
              child: const Text('भेजें'),
            ),
          ],
        );
      },
    );
  }

  void showShareMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Share सुविधा अगले चरण में जोड़ी जा सकती है।',
        ),
      ),
    );
  }
}

// ============================================================
// SHORTS
// ============================================================

class ShortsScreen extends StatelessWidget {
  const ShortsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: videosVersion,
      builder: (context, version, child) {
        if (videos.isEmpty) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: Text(
                'अभी कोई Shorts नहीं है\n\n'
                '➕ दबाकर पहला वीडियो जोड़ें',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: Colors.black,
          body: PageView.builder(
            scrollDirection: Axis.vertical,
            itemCount: videos.length,
            itemBuilder: (context, index) {
              return ShortVideoPage(
                key: ValueKey(
                  'short-${videos[index].path}',
                ),
                video: videos[index],
              );
            },
          ),
        );
      },
    );
  }
}

// ============================================================
// SHORT VIDEO PAGE
// ============================================================

class ShortVideoPage extends StatefulWidget {
  final VideoItem video;

  const ShortVideoPage({
    super.key,
    required this.video,
  });

  @override
  State<ShortVideoPage> createState() =>
      _ShortVideoPageState();
}

class _ShortVideoPageState
    extends State<ShortVideoPage> {
  late VideoPlayerController controller;

  bool ready = false;
  bool liked = false;

  @override
  void initState() {
    super.initState();

    controller = VideoPlayerController.file(
      File(widget.video.path),
    );

    controller.initialize().then((_) {
      if (!mounted) return;

      setState(() {
        ready = true;
      });

      controller
        ..setLooping(true)
        ..play();
    }).catchError((error) {
      if (mounted) {
        setState(() {
          ready = false;
        });
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void toggleLike() {
    setState(() {
      liked = !liked;

      if (liked) {
        widget.video.likes++;
      } else if (widget.video.likes > 0) {
        widget.video.likes--;
      }
    });

    videosVersion.value++;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // VIDEO
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
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: controller.value.size.width,
                height: controller.value.size.height,
                child: VideoPlayer(controller),
              ),
            ),
          )
        else
          const Center(
            child: CircularProgressIndicator(),
          ),

        // RIGHT SIDE BUTTONS
        Positioned(
          right: 15,
          bottom: 100,
          child: Column(
            children: [
              IconButton(
                onPressed: toggleLike,
                icon: Icon(
                  liked
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: liked
                      ? Colors.red
                      : Colors.white,
                  size: 36,
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
                  showShortCommentDialog(context);
                },
                icon: const Icon(
                  Icons.comment,
                  size: 34,
  ),
),
