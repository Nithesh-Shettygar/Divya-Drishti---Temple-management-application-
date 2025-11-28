import 'package:divya_drishti/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class LiveStreamPage extends StatefulWidget {
  @override
  _LiveStreamPageState createState() => _LiveStreamPageState();
}

class _LiveStreamPageState extends State<LiveStreamPage> {
  late YoutubePlayerController _controller;
  bool _isPlayerReady = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  void _initializePlayer() {
    final videoUrl = 'https://www.youtube.com/watch?v=8-lR3VWJzCg';
    final videoId = _extractVideoId(videoUrl);
    
    if (videoId == null) {
      print('Error: Could not extract video ID from URL');
      setState(() {
        _hasError = true;
      });
      return;
    }

    _controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        enableCaption: true,
        captionLanguage: 'en',
        disableDragSeek: false,
        loop: false,
        isLive: true,
        forceHD: false,
        hideControls: false,
        controlsVisibleAtStart: true,
      ),
    )..addListener(() {
        if (_isPlayerReady && mounted && !_controller.value.isFullScreen) {
          // Handle player state changes if needed
        }
      });
  }

  String? _extractVideoId(String url) {
    try {
      final regex = RegExp(
        r'^.*(?:(?:youtu\.be\/|v\/|vi\/|u\/\w\/|embed\/|shorts\/)|(?:(?:watch)?\?v(?:i)?=|\&v(?:i)?=))([^#\&\?]*).*',
        caseSensitive: false,
      );
      final match = regex.firstMatch(url);
      return match?.group(1);
    } catch (e) {
      print('Error extracting video ID: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Live Darshan',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primary, // Use your AppColors
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: _refreshPlayer,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Video Player Section
            Container(
              margin: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    height: 220,
                    child: Stack(
                      children: [
                        YoutubePlayer(
                          controller: _controller,
                          showVideoProgressIndicator: true,
                          progressIndicatorColor: AppColors.primary,
                          progressColors: ProgressBarColors(
                            playedColor: AppColors.primary,
                            handleColor: AppColors.primary,
                            backgroundColor: Colors.grey[300],
                            bufferedColor: Colors.grey[200],
                          ),
                          onReady: () {
                            setState(() {
                              _isPlayerReady = true;
                              _hasError = false;
                            });
                            print('YouTube Player is ready');
                          },
                          onEnded: (data) {
                            setState(() {
                              _hasError = true;
                            });
                            print('YouTube Player ended: $data');
                          },
                        ),
                        if (!_isPlayerReady && !_hasError)
                          Container(
                            color: Colors.black,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Loading Live Stream...',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        if (_hasError)
                          Container(
                            color: Colors.black,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: Colors.white,
                                    size: 48,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Unable to load live stream',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: _refreshPlayer,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: Text('Retry'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  
                  // Stream Info Section
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                      onTap: () {
                        // Handle additional info tap
                      },
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.live_tv,
                                size: 24,
                                color: AppColors.primary,
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Live Darshan',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: Colors.green,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Live Now',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.green,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.info_outline,
                              size: 24,
                              color: Colors.grey[600],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Additional Information Section
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About Live Darshan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Experience the divine presence through our live darshan. This stream brings you direct access to temple ceremonies and spiritual activities.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                      SizedBox(width: 8),
                      Text(
                        '24/7 Live Stream',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                      Spacer(),
                      Icon(Icons.people, size: 16, color: Colors.grey[600]),
                      SizedBox(width: 8),
                      Text(
                        '${_formatNumber(12500)} watching',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _refreshPlayer() {
    setState(() {
      _isPlayerReady = false;
      _hasError = false;
    });
    _initializePlayer();
  }

  String _formatNumber(int number) {
    if (number >= 1000) {
      double result = number / 1000;
      return '${result.toStringAsFixed(result.truncateToDouble() == result ? 0 : 1)}k';
    }
    return number.toString();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}