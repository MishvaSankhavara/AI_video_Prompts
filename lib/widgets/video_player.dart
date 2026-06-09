import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../utils/colors.dart';
import '../utils/strings.dart';
import '../utils/text_app.dart';


class CommonVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final String thumbnailUrl;
  final bool isMuted;
  final bool isLooping;
  final bool interactivePlayPause;
  final BoxFit fit;
  final bool showLoadingIndicator;
  final double? loadingTextSize;

  const CommonVideoPlayer({
    super.key,
    required this.videoUrl,
    required this.thumbnailUrl,
    this.isMuted = true,
    this.isLooping = true,
    this.interactivePlayPause = false,
    this.fit = BoxFit.cover,
    this.showLoadingIndicator = true,
    this.loadingTextSize,
  });

  @override
  State<CommonVideoPlayer> createState() => _CommonVideoPlayerState();
}

class _CommonVideoPlayerState extends State<CommonVideoPlayer> {
  VideoPlayerController? _controller;

  bool _initialized = false;
  bool _hasError = false;
  bool _isVisible = false;
  bool _isBuffering = false;
  bool _isDisposed = false;
  bool _isInitializing = false;

  Future<void> _initializeVideo() async {
    if (widget.videoUrl.isEmpty ||
        _controller != null ||
        _initialized ||
        _hasError ||
        _isInitializing) {
      return;
    }

    _isInitializing = true;

    try {
      final controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl.trim()),
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: true,
        ),
      );

      _controller = controller;

      await controller.initialize();

      if (!mounted || _isDisposed) return;

      await controller.setLooping(widget.isLooping);
      await controller.setVolume(widget.isMuted ? 0.0 : 1.0);

      controller.addListener(_onControllerUpdate);

      if (_isVisible) {
        await controller.play();
      }

      if (mounted) {
        setState(() {
          _initialized = true;
          _hasError = false;
        });
      }
    } catch (e) {
      debugPrint('Error initializing video: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    } finally {
      _isInitializing = false;
    }
  }

  void _disposeController() {
    _controller?.removeListener(_onControllerUpdate);
    _controller?.pause();
    _controller?.dispose();

    _controller = null;
    _initialized = false;
    _isBuffering = false;
  }

  void _onControllerUpdate() {
    if (_isDisposed || !mounted || _controller == null) return;

    final value = _controller!.value;

    if (_shouldAutoResume(value)) {
      _controller?.play();
    }

    if (value.hasError && _isVisible && !_isInitializing) {
      setState(() {
        _hasError = true;
        _initialized = false;
      });
      return;
    }

    _updateBufferingState(value.isBuffering);
  }

  bool _shouldAutoResume(VideoPlayerValue value) {
    return _isVisible &&
        _initialized &&
        !value.isPlaying &&
        !value.isBuffering &&
        !value.hasError;
  }

  void _updateBufferingState(bool buffering) {
    if (buffering == _isBuffering) return;

    if (buffering) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (_isDisposed ||
            !mounted ||
            _controller == null ||
            !_controller!.value.isBuffering) {
          return;
        }

        setState(() => _isBuffering = true);
      });
    } else {
      setState(() => _isBuffering = false);
    }
  }

  void _handleVisibilityChanged(VisibilityInfo info) {
    if (!mounted || _isDisposed) return;

    final wasVisible = _isVisible;
    _isVisible = info.visibleFraction > 0.5;

    if (_isVisible && wasVisible == false) {
      _onVisible();
    } else if (_isVisible == false && wasVisible) {
      _onHidden();
    }
  }

  void _onVisible() {
    if (!_initialized && !_hasError && !_isInitializing) {
      _initializeVideo();
      return;
    }

    if (_initialized && _controller != null) {
      _controller!.play();
    }
  }

  void _onHidden() {
    _disposeController();

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void didUpdateWidget(covariant CommonVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.videoUrl != oldWidget.videoUrl) {
      _disposeController();

      if (_isVisible) {
        _initializeVideo();
      }
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _disposeController();
    super.dispose();
  }

  Widget _buildThumbnail() {
    if (widget.thumbnailUrl.isEmpty) {
      return Container(color: AppColors.cardBackground);
    }

    return CachedNetworkImage(
      imageUrl: widget.thumbnailUrl,
      fit: widget.fit,
      imageBuilder: (context, imageProvider) {
        return Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: imageProvider,
              fit: widget.fit,
            ),
          ),
        );
      },
      placeholder: (context, url) => Container(color: AppColors.cardBackground),
      errorWidget: (context, url, error) => Container(
        color: Colors.grey,
        alignment: Alignment.center,
        child: const Icon(
          Icons.videocam_off,
          color: AppColors.white,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    return ClipRect(
      child: FittedBox(
        fit: widget.fit,
        child: SizedBox(
          width: _controller!.value.size.width > 0 ? _controller!.value.size.width : 9.0,
          height: _controller!.value.size.height > 0 ? _controller!.value.size.height : 16.0,
          child: VideoPlayer(_controller!),
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Positioned(
      top: 0,
      left: 0,
      child: IgnorePointer(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10.0,
            vertical: 4.0,
          ),
          decoration: BoxDecoration(
            color: AppColors.black.withValues(alpha: 0.5),
            borderRadius: const BorderRadius.only(
              bottomRight: Radius.circular(12),
            ),
          ),
          child: Text(
            AppStrings.loading,
            style: AppTextStyles.getStyle(
              fontSize: widget.loadingTextSize ?? 11,
              fontWeight: FontWeight.w500,
              color: AppColors.white,
            ),
          ),
        ),
      ),
    );
  }

  bool get _showThumbnail => !_initialized || _hasError;

  bool get _showVideo =>
      _initialized && !_hasError && _controller != null;

  bool get _showLoadingOverlay =>
      widget.showLoadingIndicator &&
      widget.videoUrl.isNotEmpty &&
      !_hasError &&
      (!_initialized || _isBuffering);

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: widget.key ?? Key(widget.videoUrl),
      onVisibilityChanged: _handleVisibilityChanged,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (_showThumbnail) _buildThumbnail(),

          if (_showVideo) ...[
            _buildVideoPlayer(),
            if (widget.interactivePlayPause)
              GestureDetector(
                onTap: () {
                  if (_controller != null) {
                    setState(() {
                      if (_controller!.value.isPlaying) {
                        _controller!.pause();
                      } else {
                        _controller!.play();
                      }
                    });
                  }
                },
                child: Container(
                  color: Colors.transparent,
                  child: Center(
                    child: AnimatedOpacity(
                      opacity: (_controller != null && _controller!.value.isPlaying) ? 0.0 : 1.0,
                      duration: const Duration(milliseconds: 300),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
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

          if (_showLoadingOverlay) _buildLoadingOverlay(),
        ],
      ),
    );
  }
}