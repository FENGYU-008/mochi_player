import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import 'package:mochi_player/models/domain/media_file.dart';
import 'package:mochi_player/models/domain/media_type.dart';
import 'package:mochi_player/ui/widgets/player_controls.dart';
import 'package:window_manager/window_manager.dart';

class PlayerPage extends StatefulWidget {
  final MediaFile videoItem;
  final String url;
  final String? contextTitle; // 🟢 新增：上下文标题 (例如，剧集名称)

  const PlayerPage({
    super.key,
    required this.videoItem,
    required this.url,
    this.contextTitle,
  });

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> with WindowListener {
  late final Player _player;
  late final VideoController _videoController;

  bool _isControlsVisible = true;
  Timer? _hideControlsTimer;
  bool _isFullScreen = false;

  List<String> _subtitle = [];
  StreamSubscription<List<String>>? _subtitleSub;

  final FocusNode _focusNode = FocusNode();

  // 🟢 新增：组合标题的 Getter
  String get _displayTitle {
    if (widget.contextTitle != null &&
        widget.videoItem.mediaType == MediaType.episode) {
      final s =
          widget.videoItem.parsedSeason?.toString().padLeft(2, '0') ?? '??';
      final e =
          widget.videoItem.parsedEpisode?.toString().padLeft(2, '0') ?? '??';
      return '${widget.contextTitle} - S${s}E${e}';
    }
    return widget.videoItem.parsedTitle.isNotEmpty
        ? widget.videoItem.parsedTitle
        : widget.videoItem.fileName;
  }

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);

    _player = Player();

    _videoController = VideoController(
      _player,
      configuration: const VideoControllerConfiguration(
        enableHardwareAcceleration: true,
      ),
    );

    _player.stream.error.listen((error) {
      print("❌ 播放器错误: $error");
    });

    _player.stream.tracks.listen((tracks) {
      _autoSelectSubtitle(tracks.subtitle);
    });

    _player.stream.playing.listen((playing) {
      _startHideControlsTimer();
    });

    _subtitleSub = _player.stream.subtitle.listen((subtitle) {
      setState(() {
        _subtitle = subtitle;
      });
    });

    print("▶️ 正在播放直链: ${widget.url}");

    final media = Media(
      widget.url,
      httpHeaders: {'User-Agent': 'MochiPlayer/1.0.0'},
      extras: {
        'cache': 'yes',
        'demuxer-max-bytes': '128MiB',
        'vo-profile': 'high-quality',
        'slang': 'chi,zho,zh,chs,cht,eng',
      },
    );

    _player.open(media, play: true);
    _startHideControlsTimer();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
    });

    _checkFullScreenState();
  }

  void _checkFullScreenState() async {
    _isFullScreen = await windowManager.isFullScreen();
    setState(() {});
  }

  @override
  void onWindowEnterFullScreen() {
    setState(() {
      _isFullScreen = true;
    });
  }

  @override
  void onWindowLeaveFullScreen() {
    setState(() {
      _isFullScreen = false;
    });
  }

  void _autoSelectSubtitle(List<SubtitleTrack> tracks) {
    if (tracks.isEmpty) return;

    SubtitleTrack? targetTrack;

    try {
      targetTrack = tracks.firstWhere((t) {
        final lang = (t.language ?? '').toLowerCase();
        final title = (t.title ?? '').toLowerCase();
        return lang.contains('zh') ||
            lang.contains('chi') ||
            lang.contains('chs') ||
            title.contains('中文') ||
            title.contains('简');
      });
    } catch (e) {
      // ignore
    }

    if (targetTrack == null) {
      try {
        targetTrack = tracks.firstWhere((t) {
          final lang = (t.language ?? '').toLowerCase();
          return lang.contains('eng') || lang.contains('en');
        });
      } catch (e) {}
    }

    if (targetTrack != null) {
      print("✅ 自动切换字幕到: ${targetTrack.title ?? targetTrack.language}");
      _player.setSubtitleTrack(targetTrack);
    }
  }

  void _startHideControlsTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _isControlsVisible = false);
      }
    });
  }

  void _onPointerHover(PointerEvent event) {
    if (!_isControlsVisible) {
      setState(() => _isControlsVisible = true);
    }
    _startHideControlsTimer();
  }

  void _onPointerExit(PointerEvent event) {
    _hideControlsTimer?.cancel();
    if (mounted) {
      setState(() => _isControlsVisible = false);
    }
  }

  void _handleKeyEvent(KeyEvent event) async {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.space) {
        _player.playOrPause();
      } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        _player.seek(_player.state.position - const Duration(seconds: 10));
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        _player.seek(_player.state.position + const Duration(seconds: 10));
      } else if (event.logicalKey == LogicalKeyboardKey.escape) {
        bool isFullScreen = await windowManager.isFullScreen();
        if (isFullScreen) {
          windowManager.setFullScreen(false);
        }
      }
    }
  }

  void _toggleFullScreen() async {
    await Future.delayed(const Duration(milliseconds: 120));
    bool isFullScreen = await windowManager.isFullScreen();
    windowManager.setFullScreen(!isFullScreen);
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    _hideControlsTimer?.cancel();
    _subtitleSub?.cancel();
    _player.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Focus(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: (node, event) {
          _handleKeyEvent(event);
          return KeyEventResult.handled;
        },
        child: MouseRegion(
          onHover: _onPointerHover,
          onExit: _onPointerExit,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Video(
                controller: _videoController,
                controls: (state) => const SizedBox.shrink(),
                subtitleViewConfiguration: const SubtitleViewConfiguration(
                  style: TextStyle(fontSize: 0, color: Colors.transparent),
                ),
              ),
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    setState(() => _isControlsVisible = !_isControlsVisible);
                    if (_isControlsVisible) _startHideControlsTimer();
                    FocusScope.of(context).requestFocus(_focusNode);
                  },
                  onDoubleTap: _toggleFullScreen,
                  child: Container(color: Colors.transparent),
                ),
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                left: 20,
                right: 20,
                bottom: _isControlsVisible ? 120.0 : 20.0,
                child: IgnorePointer(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (final line in _subtitle)
                        Text(
                          line,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            height: 1.4,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                blurRadius: 2,
                                color: Colors.black,
                                offset: Offset(1, 1),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              PlayerControls(
                player: _player,
                controller: _videoController,
                title: _displayTitle, // 🟢 使用新的组合标题
                isVisible: _isControlsVisible,
                isFullScreen: _isFullScreen,
                onToggleFullScreen: _toggleFullScreen,
                onPrevious: () {},
                onNext: () {},
                onPip: () {},
                onChangeSpeed: () {},
                onChangeQuality: () {},
                // 🟢 传入回调，重置计时器
                onInteraction: _startHideControlsTimer,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
