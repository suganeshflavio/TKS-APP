import 'dart:async';

import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class YoutubeVideoPlayer extends StatefulWidget {
  const YoutubeVideoPlayer({
    super.key,
    required this.videoId,
    this.autoPlay = false,
  });

  final String videoId;
  final bool autoPlay;

  @override
  State<YoutubeVideoPlayer> createState() => _YoutubeVideoPlayerState();
}

class _YoutubeVideoPlayerState extends State<YoutubeVideoPlayer> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = _buildController(widget.videoId);
  }

  @override
  void didUpdateWidget(covariant YoutubeVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoId != widget.videoId) {
      _controller.close();
      _controller = _buildController(widget.videoId);
    }
  }

  YoutubePlayerController _buildController(String videoId) {
    return YoutubePlayerController.fromVideoId(
      videoId: videoId,
      autoPlay: widget.autoPlay,
      params: const YoutubePlayerParams(
        showControls: false,
        showFullscreenButton: false,
        strictRelatedVideos: true,
        enableCaption: false,
        playsInline: true,
      ),
    );
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: YoutubePlayer(
        controller: _controller,
        aspectRatio: 16 / 9,
        controlsBuilder: (context, isFullscreen) =>
            _PlayerControls(controller: _controller, isFullscreen: isFullscreen),
      ),
    );
  }
}

class _PlayerControls extends StatefulWidget {
  const _PlayerControls({required this.controller, required this.isFullscreen});

  final YoutubePlayerController controller;
  final bool isFullscreen;

  @override
  State<_PlayerControls> createState() => _PlayerControlsState();
}

class _PlayerControlsState extends State<_PlayerControls> {
  Timer? _positionTimer;
  Timer? _autoHideTimer;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  double? _dragSeconds;
  bool _controlsVisible = true;

  @override
  void initState() {
    super.initState();
    _positionTimer = Timer.periodic(
      const Duration(milliseconds: 500),
      (_) => _refreshPosition(),
    );
    _scheduleAutoHide();
  }

  Future<void> _refreshPosition() async {
    if (!mounted) return;
    try {
      final current = await widget.controller.currentTime;
      final total = await widget.controller.duration;
      if (!mounted) return;
      setState(() {
        _position = Duration(milliseconds: (current * 1000).round());
        _duration = Duration(milliseconds: (total * 1000).round());
      });
    } catch (_) {
      // Player not ready yet; retry on the next tick.
    }
  }

  void _scheduleAutoHide() {
    _autoHideTimer?.cancel();
    _autoHideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _controlsVisible = false);
    });
  }

  void _toggleControlsVisible() {
    setState(() => _controlsVisible = !_controlsVisible);
    if (_controlsVisible) _scheduleAutoHide();
  }

  @override
  void dispose() {
    _positionTimer?.cancel();
    _autoHideTimer?.cancel();
    super.dispose();
  }

  String _format(Duration d) {
    if (d.isNegative || d == Duration.zero) return '0:00';
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return hours > 0 ? '$hours:$minutes:$seconds' : '${d.inMinutes}:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<YoutubePlayerValue>(
      stream: widget.controller.stream,
      initialData: widget.controller.value,
      builder: (context, snapshot) {
        final value = snapshot.data ?? widget.controller.value;

        if (value.hasError) {
          return Container(
            color: Colors.black87,
            alignment: Alignment.center,
            padding: const EdgeInsets.all(16),
            child: Text(
              _describeError(value.error),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white),
            ),
          );
        }

        final isPlaying = value.playerState == PlayerState.playing;
        final isBuffering = value.playerState == PlayerState.buffering;
        final isEnded = value.playerState == PlayerState.ended;
        final sliderMax = _duration.inMilliseconds > 0
            ? _duration.inMilliseconds.toDouble()
            : 1.0;
        final sliderValue = (_dragSeconds != null
                ? _dragSeconds! * 1000
                : _position.inMilliseconds.toDouble())
            .clamp(0.0, sliderMax);

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _toggleControlsVisible,
          child: Stack(
            children: [
              if (isBuffering)
                const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              if (isEnded)
                Center(
                  child: IconButton(
                    iconSize: 56,
                    color: Colors.white,
                    icon: const Icon(Icons.replay_circle_filled_rounded),
                    onPressed: () {
                      widget.controller.seekTo(seconds: 0, allowSeekAhead: true);
                      widget.controller.playVideo();
                    },
                  ),
                )
              else if (!isBuffering && _controlsVisible)
                Center(
                  child: IconButton(
                    iconSize: 56,
                    color: Colors.white,
                    icon: Icon(
                      isPlaying
                          ? Icons.pause_circle_filled_rounded
                          : Icons.play_circle_fill_rounded,
                    ),
                    onPressed: () {
                      if (isPlaying) {
                        widget.controller.pauseVideo();
                      } else {
                        widget.controller.playVideo();
                      }
                      _scheduleAutoHide();
                    },
                  ),
                ),
              if (_controlsVisible)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
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
                          _format(_position),
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                        Expanded(
                          child: SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              trackHeight: 2,
                              thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 6,
                              ),
                              overlayShape: const RoundSliderOverlayShape(
                                overlayRadius: 12,
                              ),
                              activeTrackColor: const Color(0xFFF97316),
                              thumbColor: const Color(0xFFF97316),
                              inactiveTrackColor: Colors.white30,
                            ),
                            child: Slider(
                              min: 0,
                              max: sliderMax,
                              value: sliderValue,
                              onChanged: (v) {
                                setState(() => _dragSeconds = v / 1000);
                                _scheduleAutoHide();
                              },
                              onChangeEnd: (v) {
                                widget.controller.seekTo(
                                  seconds: v / 1000,
                                  allowSeekAhead: true,
                                );
                                setState(() => _dragSeconds = null);
                              },
                            ),
                          ),
                        ),
                        Text(
                          _format(_duration),
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                        IconButton(
                          color: Colors.white,
                          icon: Icon(
                            widget.isFullscreen
                                ? Icons.fullscreen_exit_rounded
                                : Icons.fullscreen_rounded,
                          ),
                          onPressed: () {
                            widget.controller.toggleFullScreen();
                            _scheduleAutoHide();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

String _describeError(YoutubeError error) {
  switch (error) {
    case YoutubeError.notEmbeddable:
    case YoutubeError.sameAsNotEmbeddable:
    case YoutubeError.sameAsNotEmbeddable2:
      return 'This video cannot be played here — the owner has disabled embedding.';
    case YoutubeError.videoNotFound:
    case YoutubeError.cannotFindVideo:
      return 'This video is unavailable or has been removed.';
    case YoutubeError.invalidParam:
      return 'Invalid video link.';
    case YoutubeError.html5Error:
      return 'This video cannot be played on this device.';
    case YoutubeError.none:
    case YoutubeError.unknown:
      return 'Unable to play this video.';
  }
}
