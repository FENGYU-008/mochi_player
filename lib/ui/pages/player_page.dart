import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:provider/provider.dart';

import 'package:mochi_player/models/domain/media_file.dart';
import 'package:mochi_player/models/domain/media_type.dart';
import 'package:mochi_player/providers/media_library_provider.dart';
import 'package:mochi_player/services/webdav_service.dart';
import 'package:mochi_player/ui/widgets/player_controls.dart';
import 'package:window_manager/window_manager.dart';

class PlayerPage extends StatefulWidget {
  final MediaFile videoItem;
  final String url;
  final String? contextTitle; // 🟢 新增：上下文标题 (例如，剧集名称)
  final List<MediaFile> playlist;

  const PlayerPage({
    super.key,
    required this.videoItem,
    required this.url,
    this.contextTitle,
    this.playlist = const [],
  });

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> with WindowListener {
  static const Duration _progressSaveInterval = Duration(seconds: 10);
  static const Duration _resumeBackoff = Duration(seconds: 5);

  late final Player _player;
  late final VideoController _videoController;
  late final MediaLibraryProvider _libraryProvider;
  late List<MediaFile> _playlist;
  late int _currentIndex;
  late MediaFile _currentItem;
  late String _currentUrl;

  bool _isControlsVisible = true;
  Timer? _hideControlsTimer;
  Timer? _progressSaveTimer;
  bool _isFullScreen = false;
  bool _isBuffering = false;
  bool _hasRestoredPosition = false;
  bool _didAutoSelectSubtitle = false;
  bool _showResumeNotice = false;
  bool _isSwitchingQueueItem = false;

  List<String> _subtitle = [];
  List<AudioTrack> _audioTracks = const [];
  List<SubtitleTrack> _subtitleTracks = const [];
  AudioTrack _selectedAudioTrack = const AudioTrack('auto', null, null);
  SubtitleTrack _selectedSubtitleTrack = const SubtitleTrack(
    'auto',
    null,
    null,
  );
  final List<StreamSubscription> _subscriptions = [];

  final FocusNode _focusNode = FocusNode();
  Timer? _resumeNoticeTimer;
  int _lastSavedPositionMs = -1;
  double _lastVolumeBeforeMute = 100.0;
  String? _playerError;
  String? _resumePositionLabel;

  bool get _hasPrevious => _currentIndex > 0;
  bool get _hasNext => _currentIndex < _playlist.length - 1;

  // 🟢 新增：组合标题的 Getter
  String get _displayTitle {
    if (widget.contextTitle != null &&
        _currentItem.mediaType == MediaType.episode) {
      final s = _currentItem.parsedSeason?.toString().padLeft(2, '0') ?? '??';
      final e = _currentItem.parsedEpisode?.toString().padLeft(2, '0') ?? '??';
      return '${widget.contextTitle} - S${s}E$e';
    }
    return _currentItem.parsedTitle.isNotEmpty
        ? _currentItem.parsedTitle
        : _currentItem.fileName;
  }

  @override
  void initState() {
    super.initState();
    _libraryProvider = context.read<MediaLibraryProvider>();
    _initializePlaylist();
    windowManager.addListener(this);

    _player = Player();

    _videoController = VideoController(
      _player,
      configuration: const VideoControllerConfiguration(
        enableHardwareAcceleration: true,
      ),
    );

    _bindPlayerStreams();
    unawaited(_openMedia());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
    });

    _checkFullScreenState();
  }

  void _initializePlaylist() {
    final sourcePlaylist = widget.playlist.isNotEmpty
        ? widget.playlist
        : _libraryProvider.getPlaybackQueue(widget.videoItem);
    _playlist = _deduplicatePlaylist(sourcePlaylist);

    _currentIndex = _playlist.indexWhere(_isInitialFile);
    if (_currentIndex < 0) {
      _playlist = [widget.videoItem, ..._playlist];
      _currentIndex = 0;
    }

    _currentItem = _playlist[_currentIndex];
    _currentUrl = widget.url;
  }

  bool _isInitialFile(MediaFile file) =>
      file.id == widget.videoItem.id || file.path == widget.videoItem.path;

  List<MediaFile> _deduplicatePlaylist(List<MediaFile> playlist) {
    final result = <MediaFile>[];
    final seenPaths = <String>{};
    for (final file in playlist) {
      if (seenPaths.add(file.path)) {
        result.add(file);
      }
    }
    return result.isEmpty ? [widget.videoItem] : result;
  }

  void _bindPlayerStreams() {
    _subscriptions.addAll([
      _player.stream.error.listen((error) {
        debugPrint('播放器错误: $error');
        if (mounted) {
          setState(() {
            _playerError = error;
          });
        }
      }),
      _player.stream.tracks.listen((tracks) {
        final audioTracks = _normalizeAudioTracks(tracks.audio);
        final subtitleTracks = _normalizeSubtitleTracks(tracks.subtitle);
        if (mounted) {
          setState(() {
            _audioTracks = audioTracks;
            _subtitleTracks = subtitleTracks;
          });
        }
        if (!_didAutoSelectSubtitle) {
          _autoSelectSubtitle(subtitleTracks);
        }
      }),
      _player.stream.track.listen((track) {
        if (mounted) {
          setState(() {
            _selectedAudioTrack = track.audio;
            _selectedSubtitleTrack = track.subtitle;
          });
        }
      }),
      _player.stream.buffering.listen((buffering) {
        if (mounted) {
          setState(() {
            _isBuffering = buffering;
          });
        }
      }),
      _player.stream.playing.listen((playing) {
        _startHideControlsTimer();
      }),
      _player.stream.completed.listen((completed) {
        if (completed) {
          unawaited(_handlePlaybackCompleted());
        }
      }),
      _player.stream.subtitle.listen((subtitle) {
        if (mounted) {
          setState(() {
            _subtitle = subtitle;
          });
        }
      }),
    ]);
  }

  Future<void> _openMedia() async {
    debugPrint('正在播放直链: $_currentUrl');

    final media = Media(
      _currentUrl,
      httpHeaders: {'User-Agent': 'MochiPlayer/1.0.0'},
      extras: {
        'cache': 'yes',
        'demuxer-max-bytes': '128MiB',
        'vo-profile': 'high-quality',
        'slang': 'chi,zho,zh,chs,cht,eng',
      },
    );

    try {
      await _player.open(media, play: true);
      await _restoreProgressIfNeeded();
      _startProgressSaveTimer();
      _startHideControlsTimer();
    } catch (error) {
      debugPrint('打开媒体失败: $error');
    }
  }

  void _startProgressSaveTimer() {
    _progressSaveTimer?.cancel();
    _progressSaveTimer = Timer.periodic(_progressSaveInterval, (_) {
      unawaited(_saveProgress());
    });
  }

  Future<void> _restoreProgressIfNeeded() async {
    if (_hasRestoredPosition || _currentItem.position <= 0) return;

    final savedPositionMs = _currentItem.position;
    final savedDurationMs = _currentItem.duration;
    if (savedDurationMs > 0 && savedPositionMs >= savedDurationMs * 0.95) {
      return;
    }

    _hasRestoredPosition = true;
    final resumePosition = Duration(
      milliseconds: (savedPositionMs - _resumeBackoff.inMilliseconds).clamp(
        0,
        savedPositionMs,
      ),
    );
    await _player.seek(resumePosition);
    _showResumePositionNotice(resumePosition);
  }

  Future<void> _saveProgress({bool force = false}) async {
    final positionMs = _player.state.position.inMilliseconds;
    final durationMs = _player.state.duration.inMilliseconds;
    if (positionMs <= 0 && durationMs <= 0) return;

    final delta = (positionMs - _lastSavedPositionMs).abs();
    if (!force && _lastSavedPositionMs >= 0 && delta < 5000) return;

    _lastSavedPositionMs = positionMs;
    try {
      await _libraryProvider.updateProgress(
        _currentItem,
        positionMs,
        duration: durationMs > 0 ? durationMs : null,
      );
    } catch (error) {
      debugPrint('保存播放进度失败: $error');
    }
  }

  Future<void> _handlePlaybackCompleted() async {
    await _saveProgress(force: true);
    if (_hasNext) {
      await _playQueueOffset(1);
    }
  }

  Future<void> _playQueueOffset(int offset) async {
    if (_isSwitchingQueueItem) return;
    final targetIndex = _currentIndex + offset;
    if (targetIndex < 0 || targetIndex >= _playlist.length) return;

    _isSwitchingQueueItem = true;
    await _saveProgress(force: true);
    final targetItem = _playlist[targetIndex];

    if (mounted) {
      setState(() {
        _isBuffering = true;
        _playerError = null;
        _showResumeNotice = false;
      });
    }

    final directLink = await WebDavService().getDirectLink(targetItem.path);
    if (!mounted) {
      _isSwitchingQueueItem = false;
      return;
    }

    if (directLink == null) {
      setState(() {
        _isBuffering = false;
        _playerError = '获取播放链接失败: ${targetItem.fileName}';
      });
      _isSwitchingQueueItem = false;
      return;
    }

    _resumeNoticeTimer?.cancel();
    setState(() {
      _currentIndex = targetIndex;
      _currentItem = targetItem;
      _currentUrl = directLink;
      _isBuffering = false;
      _hasRestoredPosition = false;
      _didAutoSelectSubtitle = false;
      _showResumeNotice = false;
      _resumePositionLabel = null;
      _playerError = null;
      _subtitle = [];
      _audioTracks = const [];
      _subtitleTracks = const [];
      _selectedAudioTrack = const AudioTrack('auto', null, null);
      _selectedSubtitleTrack = const SubtitleTrack('auto', null, null);
      _lastSavedPositionMs = -1;
    });

    try {
      await _openMedia();
    } finally {
      _isSwitchingQueueItem = false;
    }
  }

  void _checkFullScreenState() async {
    _isFullScreen = await windowManager.isFullScreen();
    if (mounted) setState(() {});
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

  List<SubtitleTrack> _normalizeSubtitleTracks(List<SubtitleTrack> tracks) {
    final orderedTracks = [
      const SubtitleTrack('auto', null, null),
      const SubtitleTrack('no', null, null),
      ...tracks,
    ];
    final result = <SubtitleTrack>[];
    for (final track in orderedTracks) {
      if (!result.contains(track)) {
        result.add(track);
      }
    }
    return result;
  }

  List<AudioTrack> _normalizeAudioTracks(List<AudioTrack> tracks) {
    final orderedTracks = [const AudioTrack('auto', null, null), ...tracks];
    final result = <AudioTrack>[];
    for (final track in orderedTracks) {
      if (!result.contains(track)) {
        result.add(track);
      }
    }
    return result;
  }

  bool _isAudioTrackOff(AudioTrack track) => track.id == 'no' && !track.uri;

  Future<void> _setAudioTrack(AudioTrack track) async {
    if (mounted) {
      setState(() {
        _selectedAudioTrack = track;
      });
    }
    try {
      await _player.setAudioTrack(track);
    } catch (error) {
      debugPrint('切换音轨失败: $error');
    }
    _startHideControlsTimer();
  }

  bool _isSubtitleTrackAuto(SubtitleTrack track) =>
      track.id == 'auto' && !track.uri && !track.data;

  bool _isSubtitleTrackOff(SubtitleTrack track) =>
      track.id == 'no' && !track.uri && !track.data;

  void _autoSelectSubtitle(List<SubtitleTrack> tracks) {
    final availableTracks = tracks
        .where(
          (track) =>
              !_isSubtitleTrackAuto(track) && !_isSubtitleTrackOff(track),
        )
        .toList();
    if (availableTracks.isEmpty) return;

    SubtitleTrack? targetTrack;

    for (final track in availableTracks) {
      final lang = (track.language ?? '').toLowerCase();
      final title = (track.title ?? '').toLowerCase();
      if (lang.contains('zh') ||
          lang.contains('chi') ||
          lang.contains('chs') ||
          title.contains('中文') ||
          title.contains('简')) {
        targetTrack = track;
        break;
      }
    }

    if (targetTrack == null) {
      for (final track in availableTracks) {
        final lang = (track.language ?? '').toLowerCase();
        if (lang.contains('eng') || lang.contains('en')) {
          targetTrack = track;
          break;
        }
      }
    }

    if (targetTrack != null) {
      unawaited(_setSubtitleTrack(targetTrack));
    }
  }

  Future<void> _setSubtitleTrack(SubtitleTrack track) async {
    _didAutoSelectSubtitle = true;
    if (mounted) {
      setState(() {
        _selectedSubtitleTrack = track;
      });
    }
    try {
      await _player.setSubtitleTrack(track);
    } catch (error) {
      debugPrint('切换字幕失败: $error');
    }
    _startHideControlsTimer();
  }

  void _showResumePositionNotice(Duration position) {
    _resumeNoticeTimer?.cancel();
    if (mounted) {
      setState(() {
        _showResumeNotice = true;
        _resumePositionLabel = _formatDuration(position);
      });
    }
    _resumeNoticeTimer = Timer(const Duration(seconds: 6), () {
      if (mounted) {
        setState(() {
          _showResumeNotice = false;
        });
      }
    });
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return hours > 0 ? '$hours:$minutes:$seconds' : '$minutes:$seconds';
  }

  void _cycleSubtitleTrack() {
    if (_subtitleTracks.isEmpty) return;
    final currentIndex = _subtitleTracks.indexOf(_selectedSubtitleTrack);
    final nextIndex = currentIndex < 0
        ? 0
        : (currentIndex + 1) % _subtitleTracks.length;
    unawaited(_setSubtitleTrack(_subtitleTracks[nextIndex]));
  }

  void _cycleAudioTrack() {
    final tracks = _audioTracks
        .where((track) => !_isAudioTrackOff(track))
        .toList();
    if (tracks.isEmpty) return;
    final currentIndex = tracks.indexOf(_selectedAudioTrack);
    final nextIndex = currentIndex < 0 ? 0 : (currentIndex + 1) % tracks.length;
    unawaited(_setAudioTrack(tracks[nextIndex]));
  }

  void _adjustVolume(double delta) {
    final nextVolume = (_player.state.volume + delta).clamp(0.0, 100.0);
    _player.setVolume(nextVolume);
    if (nextVolume > 0) {
      _lastVolumeBeforeMute = nextVolume;
    }
    _startHideControlsTimer();
  }

  void _toggleMute() {
    final currentVolume = _player.state.volume;
    if (currentVolume > 0) {
      _lastVolumeBeforeMute = currentVolume;
      _player.setVolume(0.0);
    } else {
      _player.setVolume(
        _lastVolumeBeforeMute <= 0 ? 100.0 : _lastVolumeBeforeMute,
      );
    }
    _startHideControlsTimer();
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
      } else if (event.logicalKey == LogicalKeyboardKey.keyK) {
        _player.playOrPause();
      } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        _player.seek(_player.state.position - const Duration(seconds: 10));
      } else if (event.logicalKey == LogicalKeyboardKey.keyJ) {
        _player.seek(_player.state.position - const Duration(seconds: 10));
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        _player.seek(_player.state.position + const Duration(seconds: 10));
      } else if (event.logicalKey == LogicalKeyboardKey.keyL) {
        _player.seek(_player.state.position + const Duration(seconds: 10));
      } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        _adjustVolume(5);
      } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        _adjustVolume(-5);
      } else if (event.logicalKey == LogicalKeyboardKey.keyM) {
        _toggleMute();
      } else if (event.logicalKey == LogicalKeyboardKey.keyF) {
        _toggleFullScreen();
      } else if (event.logicalKey == LogicalKeyboardKey.keyC) {
        _cycleSubtitleTrack();
      } else if (event.logicalKey == LogicalKeyboardKey.keyA) {
        _cycleAudioTrack();
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
    unawaited(_saveProgress(force: true));
    windowManager.removeListener(this);
    _hideControlsTimer?.cancel();
    _progressSaveTimer?.cancel();
    _resumeNoticeTimer?.cancel();
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
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
              if (_isBuffering)
                const Center(
                  child: SizedBox(
                    width: 44,
                    height: 44,
                    child: CircularProgressIndicator(strokeWidth: 3),
                  ),
                ),
              if (_playerError != null)
                Positioned(
                  left: 24,
                  right: 24,
                  top: 72,
                  child: _PlayerMessage(
                    icon: Icons.error_outline_rounded,
                    message: _playerError!,
                    actionLabel: '关闭',
                    onAction: () {
                      setState(() {
                        _playerError = null;
                      });
                    },
                  ),
                ),
              if (_showResumeNotice && _playerError == null)
                Positioned(
                  left: 24,
                  right: 24,
                  top: 72,
                  child: _PlayerMessage(
                    icon: Icons.history_rounded,
                    message: '已从 ${_resumePositionLabel ?? '上次进度'} 继续播放',
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
                onPrevious: _hasPrevious
                    ? () {
                        unawaited(_playQueueOffset(-1));
                      }
                    : null,
                onNext: _hasNext
                    ? () {
                        unawaited(_playQueueOffset(1));
                      }
                    : null,
                audioTracks: _audioTracks,
                selectedAudioTrack: _selectedAudioTrack,
                onAudioSelected: (track) {
                  unawaited(_setAudioTrack(track));
                },
                subtitleTracks: _subtitleTracks,
                selectedSubtitleTrack: _selectedSubtitleTrack,
                onSubtitleSelected: (track) {
                  unawaited(_setSubtitleTrack(track));
                },
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

class _PlayerMessage extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _PlayerMessage({
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 560),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.black.withAlpha((255 * 0.72).round()),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.white.withAlpha((255 * 0.12).round()),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                message,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(width: 12),
              TextButton(
                onPressed: onAction,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  minimumSize: const Size(0, 32),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
