import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

const _speedOptions = [1.0, 1.5, 2.0, 2.5, 3.0];

String _formatSpeed(double speed) {
  return speed == speed.roundToDouble() ? '${speed.toInt()}x' : '${speed}x';
}

String _formatDuration(Duration d) {
  final hours = d.inHours;
  final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
  final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  return hours > 0 ? '$hours:$minutes:$seconds' : '${d.inMinutes}:$seconds';
}

class MediaVideoPlayer extends StatefulWidget {
  const MediaVideoPlayer({super.key, required this.videoUrl});

  final String videoUrl;

  @override
  State<MediaVideoPlayer> createState() => _MediaVideoPlayerState();
}

class _MediaVideoPlayerState extends State<MediaVideoPlayer> {
  late final VideoPlayerController _controller;
  Timer? _autoHideTimer;
  bool _controlsVisible = true;
  bool _hasError = false;
  double _speed = 1.0;

  @override
  void initState() {
    super.initState();
    debugPrint('[MediaVideoPlayer] loading ${widget.videoUrl}');
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..addListener(_onValueChanged)
      ..initialize()
          .then((_) {
            debugPrint('[MediaVideoPlayer] initialized successfully');
            if (mounted) setState(() {});
          })
          .catchError((Object error, StackTrace stackTrace) {
            debugPrint('[MediaVideoPlayer] initialize error: $error');
            if (mounted) setState(() => _hasError = true);
          });
    _scheduleAutoHide();
  }

  void _onValueChanged() {
    if (mounted) setState(() {});
  }

  void _scheduleAutoHide() {
    _autoHideTimer?.cancel();
    _autoHideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && _controller.value.isPlaying) {
        setState(() => _controlsVisible = false);
      }
    });
  }

  void _toggleControls() {
    setState(() => _controlsVisible = !_controlsVisible);
    if (_controlsVisible) _scheduleAutoHide();
  }

  void _togglePlay() {
    if (_controller.value.isPlaying) {
      _controller.pause();
    } else {
      _controller.play();
      _scheduleAutoHide();
    }
  }

  Future<void> _setSpeed(double speed) async {
    await _controller.setPlaybackSpeed(speed);
    if (mounted) setState(() => _speed = speed);
    _scheduleAutoHide();
  }

  Future<void> _openFullscreen() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => _FullscreenVideoPage(
          controller: _controller,
          speed: _speed,
          onSpeedChanged: _setSpeed,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _autoHideTimer?.cancel();
    _controller.removeListener(_onValueChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          color: Colors.black87,
          alignment: Alignment.center,
          padding: const EdgeInsets.all(16),
          child: const Text(
            'Unable to play this video.',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    if (!_controller.value.isInitialized) {
      return const AspectRatio(
        aspectRatio: 16 / 9,
        child: ColoredBox(
          color: Colors.black87,
          child: Center(child: CircularProgressIndicator(color: Colors.white)),
        ),
      );
    }

    return AspectRatio(
      aspectRatio: _controller.value.aspectRatio,
      child: _VideoSurface(
        controller: _controller,
        controlsVisible: _controlsVisible,
        onToggleControls: _toggleControls,
        onTogglePlay: _togglePlay,
        speed: _speed,
        onSpeedChanged: _setSpeed,
        onFullscreenToggle: _openFullscreen,
        isFullscreen: false,
      ),
    );
  }
}

class _FullscreenVideoPage extends StatefulWidget {
  const _FullscreenVideoPage({
    required this.controller,
    required this.speed,
    required this.onSpeedChanged,
  });

  final VideoPlayerController controller;
  final double speed;
  final ValueChanged<double> onSpeedChanged;

  @override
  State<_FullscreenVideoPage> createState() => _FullscreenVideoPageState();
}

class _FullscreenVideoPageState extends State<_FullscreenVideoPage> {
  Timer? _autoHideTimer;
  bool _controlsVisible = true;
  late double _speed = widget.speed;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    widget.controller.addListener(_onValueChanged);
    _scheduleAutoHide();
  }

  void _onValueChanged() {
    if (mounted) setState(() {});
  }

  void _scheduleAutoHide() {
    _autoHideTimer?.cancel();
    _autoHideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && widget.controller.value.isPlaying) {
        setState(() => _controlsVisible = false);
      }
    });
  }

  void _toggleControls() {
    setState(() => _controlsVisible = !_controlsVisible);
    if (_controlsVisible) _scheduleAutoHide();
  }

  void _togglePlay() {
    if (widget.controller.value.isPlaying) {
      widget.controller.pause();
    } else {
      widget.controller.play();
      _scheduleAutoHide();
    }
  }

  Future<void> _setSpeed(double speed) async {
    await widget.controller.setPlaybackSpeed(speed);
    widget.onSpeedChanged(speed);
    if (mounted) setState(() => _speed = speed);
    _scheduleAutoHide();
  }

  Future<void> _exitFullscreen() async {
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onValueChanged);
    _autoHideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop) await _exitFullscreen();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: AspectRatio(
            aspectRatio: widget.controller.value.aspectRatio,
            child: _VideoSurface(
              controller: widget.controller,
              controlsVisible: _controlsVisible,
              onToggleControls: _toggleControls,
              onTogglePlay: _togglePlay,
              speed: _speed,
              onSpeedChanged: _setSpeed,
              onFullscreenToggle: _exitFullscreen,
              isFullscreen: true,
            ),
          ),
        ),
      ),
    );
  }
}

class _VideoSurface extends StatelessWidget {
  const _VideoSurface({
    required this.controller,
    required this.controlsVisible,
    required this.onToggleControls,
    required this.onTogglePlay,
    required this.speed,
    required this.onSpeedChanged,
    required this.onFullscreenToggle,
    required this.isFullscreen,
  });

  final VideoPlayerController controller;
  final bool controlsVisible;
  final VoidCallback onToggleControls;
  final VoidCallback onTogglePlay;
  final double speed;
  final ValueChanged<double> onSpeedChanged;
  final VoidCallback onFullscreenToggle;
  final bool isFullscreen;

  @override
  Widget build(BuildContext context) {
    final value = controller.value;
    final position = value.position;
    final duration = value.duration;
    final sliderMax = duration.inMilliseconds > 0
        ? duration.inMilliseconds.toDouble()
        : 1.0;
    final sliderValue = position.inMilliseconds.toDouble().clamp(
      0.0,
      sliderMax,
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onToggleControls,
      child: Stack(
        fit: StackFit.expand,
        children: [
          VideoPlayer(controller),
          if (controlsVisible)
            Align(
              alignment: const Alignment(0, -0.25),
              child: IconButton(
                iconSize: 56,
                color: Colors.white,
                icon: Icon(
                  value.isPlaying
                      ? Icons.pause_circle_filled_rounded
                      : Icons.play_circle_fill_rounded,
                ),
                onPressed: onTogglePlay,
              ),
            ),
          if (controlsVisible)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.only(
                  left: 10,
                  right: 6,
                  bottom: 4,
                  top: 14,
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black87],
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      _formatDuration(position),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Expanded(
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 3,
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 6,
                          ),
                          overlayShape: const RoundSliderOverlayShape(
                            overlayRadius: 10,
                          ),
                          activeTrackColor: const Color(0xFFF97316),
                          thumbColor: const Color(0xFFF97316),
                          inactiveTrackColor: Colors.white30,
                        ),
                        child: Slider(
                          min: 0,
                          max: sliderMax,
                          value: sliderValue,
                          onChanged: (v) => controller.seekTo(
                            Duration(milliseconds: v.round()),
                          ),
                        ),
                      ),
                    ),
                    Text(
                      _formatDuration(duration),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    PopupMenuButton<double>(
                      initialValue: speed,
                      onSelected: onSpeedChanged,
                      color: const Color(0xFF2A180E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      itemBuilder: (context) => _speedOptions
                          .map(
                            (s) => PopupMenuItem<double>(
                              value: s,
                              child: Text(
                                _formatSpeed(s),
                                style: TextStyle(
                                  color: s == speed
                                      ? const Color(0xFFF97316)
                                      : Colors.white,
                                  fontWeight: s == speed
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white12,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.speed_rounded,
                              size: 14,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              _formatSpeed(speed),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    IconButton(
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(6),
                      color: Colors.white,
                      iconSize: 20,
                      icon: Icon(
                        isFullscreen
                            ? Icons.fullscreen_exit_rounded
                            : Icons.fullscreen_rounded,
                      ),
                      onPressed: onFullscreenToggle,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
