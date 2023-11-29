import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoDetailsScreen extends StatelessWidget {
  final String videoId;

  final String videoTitle;

  const VideoDetailsScreen(
      {super.key, required this.videoId, required this.videoTitle});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Details'),
      ),
      body: Column(
        children: [
          Center(
            child: YoutubePlayer(
              controller: YoutubePlayerController(
                initialVideoId: videoId,
                flags: const YoutubePlayerFlags(
                  autoPlay: true,
                  mute: false,
                ),
              ),
              showVideoProgressIndicator: true,
              progressIndicatorColor: Colors.blueAccent,
              progressColors: const ProgressBarColors(
                playedColor: Colors.blueAccent,
                handleColor: Colors.blueAccent,
              ),
            ),
          ),
          Container(
            color: Colors.blue.shade50,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                      child: Text(
                    videoTitle,
                    style: const TextStyle(fontSize: 20),
                    softWrap: true,
                  )),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
