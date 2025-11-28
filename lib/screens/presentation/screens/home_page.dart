import 'package:divya_drishti/core/constants/app_colors.dart';
import 'package:divya_drishti/screens/presentation/screens/home/darshan_booking.dart';
import 'package:divya_drishti/screens/presentation/screens/home/darshana_ticket_booking.dart';
import 'package:divya_drishti/screens/presentation/screens/home/elderly_desabled_ticket_booking.dart';
import 'package:divya_drishti/screens/presentation/screens/home/live_stream_page.dart';
import 'package:divya_drishti/screens/presentation/widgets/home_page/piligrim_services.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class HomeContent extends StatefulWidget {
  @override
  _HomeContentState createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final List<String> imageUrls = [
    'https://picsum.photos/400/300?random=1',
    'https://picsum.photos/400/300?random=2',
    'https://picsum.photos/400/300?random=3',
    'https://picsum.photos/400/300?random=4',
  ];

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    Future.delayed(Duration(seconds: 2), () {
      if (_pageController.hasClients) {
        int nextPage = _currentPage + 1;
        if (nextPage >= imageUrls.length) {
          nextPage = 0;
        }

        _pageController.animateToPage(
          nextPage,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );

        _startAutoScroll(); // Continue the auto-scroll
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.bg,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.all(30),
                child: Column(
                  children: [
                    // Image Carousel
                    Container(
                      height: 200,
                      child: Stack(
                        children: [
                          // PageView for horizontal scrolling
                          PageView.builder(
                            controller: _pageController,
                            itemCount: imageUrls.length,
                            onPageChanged: (int page) {
                              setState(() {
                                _currentPage = page;
                              });
                            },
                            itemBuilder: (context, index) {
                              return Container(
                                margin: EdgeInsets.symmetric(horizontal: 8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 8,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Image.network(
                                    imageUrls[index],
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.grey[200],
                                        child: Icon(
                                          Icons.error,
                                          color: Colors.grey[400],
                                          size: 50,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              );
                            },
                          ),

                          // Page indicators
                          Positioned(
                            bottom: 10,
                            left: 0,
                            right: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                imageUrls.length,
                                (index) => Container(
                                  margin: EdgeInsets.symmetric(horizontal: 4),
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _currentPage == index
                                        ? AppColors.primary
                                        : Colors.grey[300],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 30),

                    // Heading above the rectangular box

                    // Rectangular Box
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primary, width: 1),

                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            blurRadius: 4,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Row(
                          children: [
                            // Circular Avatar with Icon
                            SizedBox(width: 16),

                            // Text section
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Center(
                                    child: Text(
                                      "Note:",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    "Remember to maintain silence and respect the sanctity of the temple premises.",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 30),
                    PilgrimServicesWidget(),
                    SizedBox(height: 30),
                    // In your main page where the ticket booking section is
                    Container(
  width: double.infinity,
  child: Text(
    'Ticket Booking',
    textAlign: TextAlign.center,
    style: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: AppColors.primary,
    ),
  ),
),

SizedBox(height: 15),

// Rectangular Box
Container(
  width: double.infinity,
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.25),
        blurRadius: 4,
        offset: Offset(0, 4),
      ),
    ],
  ),
  child: Padding(
    padding: EdgeInsets.all(16),
    child: Row(
      children: [
        // Option 1 - Darshan Ticket Book
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DarshanBookingPage(
                        title: 'Darshan Ticket Booking', // Add proper title
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        radius: 40,
                        child: Icon(
                          Icons.directions,
                          size: 40,
                          color: AppColors.primary,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Darshan \nTicket',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        SizedBox(width: 16),

        // Option 2 - Elder/Disabled
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DarshanBookingPage(
                        title: 'Elder/Disabled Ticket Booking', // Add proper title
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        radius: 40,
                        child: Icon(
                          Icons.accessible_forward,
                          size: 40,
                          color: AppColors.primary,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Elder/\nDisabled',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        SizedBox(width: 16),

        // Option 3 - Special Entry
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DarshanBookingPage(
                        title: 'Special Entry Booking', // Add proper title
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        radius: 40,
                        child: Icon(
                          Icons.flag,
                          size: 40,
                          color: AppColors.primary,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Special Entry',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  ),
),
                    SizedBox(height: 30),
                    // In your widget build method
                    // In your home screen widget build method
                    Container(
                      width: double.infinity,
                      child: Text(
                        'Live darshan',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),

                    SizedBox(height: 15),

                    // YouTube Live Stream Container
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            blurRadius: 4,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Video Player Section
                          _buildLiveStreamPlayer(context), // Pass context here
                          // Bottom Info Section
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(12),
                                bottomRight: Radius.circular(12),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => LiveStreamPage(),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: AppColors.primary
                                          .withOpacity(0.1),
                                      radius: 24,
                                      child: Icon(
                                        Icons.live_tv,
                                        size: 24,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Live Darshan',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            'Live Now',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.green,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      size: 16,
                                      color: AppColors.primary,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 30),
                    Container(
                      width: double.infinity,
                      child: Text(
                        'Prasad Booking',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),

                    SizedBox(height: 15),

                    // Rectangular Box
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            blurRadius: 4,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Row(
                          children: [
                            // Option 1 - Regular Prasad
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(8),
                                    onTap: () {
                                      // Handle regular prasad booking
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.all(12),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          CircleAvatar(
                                            backgroundColor: AppColors.primary
                                                .withOpacity(0.1),
                                            radius: 24,
                                            child: Icon(
                                              Icons.breakfast_dining,
                                              size: 24,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            'Regular\nPrasad',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(width: 16),

                            // Option 2 - Special Prasad
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(8),
                                    onTap: () {
                                      // Handle special prasad booking
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.all(12),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          CircleAvatar(
                                            backgroundColor: AppColors.primary
                                                .withOpacity(0.1),
                                            radius: 24,
                                            child: Icon(
                                              Icons.cake,
                                              size: 24,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            'Special\nPrasad',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 30),
                    Container(
                      width: double.infinity,
                      child: Text(
                        'Donate',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),

                    SizedBox(height: 15),

                    // Rectangular Box
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            blurRadius: 4,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            // Handle donation tap
                          },
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: AppColors.primary
                                      .withOpacity(0.1),
                                  radius: 24,
                                  child: Icon(
                                    Icons.volunteer_activism,
                                    size: 24,
                                    color: AppColors.primary,
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    'Make a Donation',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                  color: AppColors.primary,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Add these methods to your home screen widget class
Widget _buildLiveStreamPlayer(BuildContext context) {
  return Container(
    height: 200,
    decoration: BoxDecoration(
      color: Colors.black,
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(12),
        topRight: Radius.circular(12),
      ),
    ),
    child: Stack(
      children: [
        // YouTube Player
        _buildMiniYouTubePlayer(),

        // Tap to expand overlay
        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LiveStreamPage()),
                );
              },
              child: Container(
                color: Colors.transparent,
                child: Center(
                  child: Icon(
                    Icons.fullscreen,
                    color: Colors.white.withOpacity(0.7),
                    size: 40,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildMiniYouTubePlayer() {
  final videoUrl =
      'https://www.youtube.com/live/8-lR3VWJzCg?si=3x58x6sitkUwheV4';
  final videoId = _extractVideoId(videoUrl);

  if (videoId == null) {
    return _buildErrorState();
  }

  return YoutubePlayer(
    controller: YoutubePlayerController(
      initialVideoId: videoId,
      flags: YoutubePlayerFlags(
        autoPlay: true,
        mute: true, // Muted for home screen preview
        enableCaption: false,
        disableDragSeek: true,
        loop: false,
        isLive: true,
        forceHD: false,
        hideControls: true,
        controlsVisibleAtStart: false,
        showLiveFullscreenButton: false,
      ),
    ),
    showVideoProgressIndicator: true,
    progressIndicatorColor: AppColors.primary,
    progressColors: ProgressBarColors(
      playedColor: AppColors.primary,
      handleColor: AppColors.primary,
    ),
  );
}

Widget _buildErrorState() {
  return Container(
    color: Colors.black,
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.live_tv, color: Colors.white, size: 40),
          SizedBox(height: 8),
          Text(
            'Live Darshan',
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    ),
  );
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
