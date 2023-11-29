import 'package:flutter/material.dart';
import 'package:flutter_youtube/video_details_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_youtube/keys.dart';
// import 'download.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'YouTube Clone',
      home: HomeScreen(), // Start with the HomeScreen as the first screen
    );
  }
}
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<VideoItem> _videos = [];
  late TextEditingController _searchController;
  late ScrollController _scrollController;
  String? _nextPageToken;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _scrollController = ScrollController();
    _loadVideos();

    // Add a listener to scroll events
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadVideos() async {
    // Check if loading is already in progress
    if (_isLoading) return;

    // Set loading flag to true to prevent multiple simultaneous requests
    setState(() {
      _isLoading = true;
    });

    const apiKey = API_KEY;
    final query = _searchController.text.trim();
    const baseUrl = 'https://www.googleapis.com/youtube/v3/search';
    const part = 'snippet';
    const type = 'video';
    const chart = 'mostPopular'; // Trending videos
    const maxResults = 10; // Number of videos to fetch

    var url = '$baseUrl?part=$part&q=$query&chart=$chart&type=$type&maxResults=$maxResults&key=$apiKey';

    if (_nextPageToken != null) {
      url += '&pageToken=$_nextPageToken';
    }

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final videos = data['items'] as List;

      setState(() {
        // Append new videos to the existing list
        _videos.addAll(videos.map((video) => VideoItem.fromJson(video)).toList());
        _nextPageToken = data['nextPageToken']; // Get the next page token
        _isLoading = false; // Reset loading flag
      });
    } else {
      // Handle error
      print('Error fetching videos: ${response.statusCode}');
      setState(() {
        _isLoading = false; // Reset loading flag
      });
    }
  }

  // Scroll event listener
  void _scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      _loadVideos(); // Load more videos when reaching the end of the list
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('YouTube Clone'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search YouTube',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    // Reset the list and page when doing a new search
                    setState(() {
                      _videos.clear();
                      _nextPageToken = null;
                    });
                    _loadVideos();
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController, // Set the scroll controller
              itemCount: _videos.length + 1, // Add 1 to account for loading indicator
              itemBuilder: (context, index) {
                if (index < _videos.length) {
                  var video = _videos[index];
                  return ListTile(
                    leading: Image.network(video.thumbnailUrl),
                    title: Text(video.title),
                    subtitle: Text(video.channelTitle),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VideoDetailsScreen(videoId: video.videoId,videoTitle: video.title,),
                        ),
                      );
                    },
                  );
                } else {
                  // Show a loading indicator at the end of the list
                  return _isLoading
                      ? Center(child: CircularProgressIndicator())
                      : Container();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class VideoItem {
  final String videoId;
  final String title;
  final String channelTitle;
  final String thumbnailUrl;

  VideoItem({
    required this.videoId,
    required this.title,
    required this.channelTitle,
    required this.thumbnailUrl,
  });

  factory VideoItem.fromJson(Map<String, dynamic> json) {
    return VideoItem(
      videoId: json['id']['videoId'],
      title: json['snippet']['title'],
      channelTitle: json['snippet']['channelTitle'],
      thumbnailUrl: json['snippet']['thumbnails']['default']['url'],
    );
  }
}
