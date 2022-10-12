import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:video_player/video_player.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // late VideoPlayerController controller;
  final ScrollController _controllerScroll = ScrollController();

  bool isComment = false;

  List<String> videos = [
    "https://assets.mixkit.co/videos/preview/mixkit-under-a-peripheral-road-with-two-avenues-on-the-sides-34560-large.mp4"
        "https://assets.mixkit.co/videos/preview/mixkit-a-girl-blowing-a-bubble-gum-at-an-amusement-park-1226-large.mp4",
    "https://assets.mixkit.co/videos/preview/mixkit-people-working-with-electronic-devices-42639-large.mp4",
  ];
  List<VideoPlayerController> _controllers = [];
  List<String> favoriteVideo = <String>[];

  @override
  void initState() {
    _playVideos();
    super.initState();
  }

  void _playVideos() {
    videos.forEach((element) {
      _controllers.add(VideoPlayerController.network(element));
    });
    for (var controller in _controllers) {
      controller.initialize().then((_) {
        setState(() {});
      });
      controller.addListener(() {
        setState(() {});
      });
      controller.setLooping(true);

      _controllerScroll.addListener(() {
        if (_controllerScroll.position.userScrollDirection ==
            ScrollDirection.idle) {
          controller.play();
        } else {
          controller.pause();
        }
      });
    }
  }

  void _showCommentSheet(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
              height: 250,
              color: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: ListView.builder(
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    return Padding(
                        padding: EdgeInsets.symmetric(vertical: 5),
                        child: Row(
                          children: [
                            Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(25)),
                                clipBehavior: Clip.hardEdge,
                                child: Image.asset(
                                  'assets/images/avt.jpeg',
                                  fit: BoxFit.cover,
                                )),
                            SizedBox(width: 10),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Emma',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                Text('Beautifull!')
                              ],
                            )
                          ],
                        ));
                  }));
        });
  }

  @override
  void dispose() {
    super.dispose();
    _controllers.forEach((controller) {
      controller.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    String? swipeDirection;

    return Scaffold(
        backgroundColor: Colors.red,
        body: Container(
          child: ListView.builder(
            controller: _controllerScroll,
            physics: const PageScrollPhysics(),
            padding: const EdgeInsets.all(0),
            itemCount: videos.length,
            itemBuilder: (context, index) {
              String video = videos[index];
              bool isSaved = favoriteVideo.contains(video);
              VideoPlayerController controller = _controllers[index];
              print(controller.value.isPlaying);

              return GestureDetector(
                  onPanUpdate: (details) {
                    swipeDirection = details.delta.dx < 0 ? 'left' : 'right';
                  },
                  onPanEnd: (details) {
                    if (swipeDirection == null) {
                      return;
                    }
                    if (swipeDirection == 'left') {
                      _showCommentSheet(context);
                    }
                    if (swipeDirection == 'right') {
                      return;
                    }
                  },
                  onTap: () {
                    if (controller.value.isPlaying) {
                      setState(() {
                        controller.pause();
                      });
                    } else {
                      setState(() {
                        controller.play();
                      });
                    }
                  },
                  onDoubleTap: () {
                    setState(() {
                      if (isSaved) {
                        favoriteVideo.remove(video);
                      } else {
                        favoriteVideo.add(video);
                      }
                    });
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: width,
                        height: height,
                        color: Colors.amber[600],
                        child: AspectRatio(
                          aspectRatio: 16 / 9,
                          child: VideoPlayer(
                            controller,
                          ),
                        ),
                      ),
                      Positioned(
                          right: 0,
                          bottom: 80,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                IconButton(
                                    icon: Icon(
                                        isSaved
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        color: isSaved
                                            ? Colors.pink[500]
                                            : Colors.white,
                                        size: 30),
                                    onPressed: () {
                                      setState(() {
                                        if (isSaved) {
                                          favoriteVideo.remove(video);
                                        } else {
                                          favoriteVideo.add(video);
                                        }
                                      });
                                    }),
                                IconButton(
                                    icon: const Icon(Icons.message_rounded,
                                        color: Colors.white, size: 30),
                                    onPressed: () =>
                                        _showCommentSheet(context)),
                              ],
                            ),
                          )),
                      // Positioned(
                      //     child: ClipOval(
                      //         child: Container(
                      //   padding: EdgeInsets.all(5),
                      //   color: Colors.black45,
                      //   child: Icon(
                      //       controller.value.isPlaying
                      //           ? Icons.pause
                      //           : Icons.play_arrow,
                      //       color: Colors.white,
                      //       size: 30),
                      // )))
                    ],
                  ));
            },
          ),
        ));
  }
}
