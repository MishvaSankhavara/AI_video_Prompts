import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../utils/colors.dart';
import 'shimmer_grid_card.dart';

class CommonVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final String thumbnailUrl;
  final bool isMuted;
  final bool isLooping;
  final bool interactivePlayPause;
  final BoxFit fit;

  const CommonVideoPlayer({
    super.key,
    required this.videoUrl,
    required this.thumbnailUrl,
    this.isMuted = true,
    this.isLooping = true,
    this.interactivePlayPause = false,
    this.fit = BoxFit.cover,
  });

  @override
  State<CommonVideoPlayer> createState() => _CommonVideoPlayerState();
}

class _CommonVideoPlayerState extends State<CommonVideoPlayer> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  @override
  void didUpdateWidget(covariant CommonVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl) {
      _disposeController();
      _initializeController();
    }
  }

  void _disposeController() {
    if (_controller != null) {
      _controller!.removeListener(_videoListener);
      _controller!.dispose();
      _controller = null;
      _isInitialized = false;
    }
  }

  void _videoListener() {
    if (mounted) {
      setState(() {});
    }
  }

  void _initializeController() {
    final encodedUrl = Uri.encodeFull(widget.videoUrl.trim());
    debugPrint("CommonVideoPlayer: Initializing video with URL: '$encodedUrl'");
    _controller = VideoPlayerController.networkUrl(Uri.parse(encodedUrl))
      ..addListener(_videoListener)
      ..initialize().then((_) {
        debugPrint("CommonVideoPlayer: Successfully initialized: '$encodedUrl'");
        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
          _controller!.setLooping(widget.isLooping);
          _controller!.setVolume(widget.isMuted ? 0.0 : 1.0);
          _controller!.play();
          debugPrint("CommonVideoPlayer: Playing video (looping: ${widget.isLooping}, muted: ${widget.isMuted})");
        }
      }).catchError((e) {
        debugPrint("CommonVideoPlayer: Error initializing video '$encodedUrl': $e");
      });
  }

  @override
  void dispose() {
    _disposeController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitialized && _controller != null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          FittedBox(
            fit: widget.fit,
            child: SizedBox(
              width: _controller!.value.size.width > 0 ? _controller!.value.size.width : 9.0,
              height: _controller!.value.size.height > 0 ? _controller!.value.size.height : 16.0,
              child: VideoPlayer(_controller!),
            ),
          ),
          if (widget.interactivePlayPause)
            GestureDetector(
              onTap: () {
                setState(() {
                  if (_controller!.value.isPlaying) {
                    _controller!.pause();
                  } else {
                    _controller!.play();
                  }
                });
              },
              child: Container(
                color: Colors.transparent,
                child: Center(
                  child: AnimatedOpacity(
                    opacity: _controller!.value.isPlaying ? 0.0 : 1.0,
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
    } else {
      return Image.network(
        Uri.encodeFull(widget.thumbnailUrl.trim()),
        fit: widget.fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const ShimmerGridCard();
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: AppColors.cardBackground,
            child: const Center(
              child: Icon(
                Icons.broken_image_outlined,
                color: AppColors.textMuted,
                size: 48,
              ),
            ),
          );
        },
      );
    }
  }
}
