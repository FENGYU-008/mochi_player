import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:provider/provider.dart';

import 'package:mochi_player/models/domain/media_file.dart';
import 'package:mochi_player/models/domain/media_type.dart';
import 'package:mochi_player/features/playback/application/playback_session_controller.dart';
import 'package:mochi_player/features/playback/domain/playback_resume_policy.dart';
import 'package:mochi_player/features/settings/application/app_settings_provider.dart';
import 'package:mochi_player/features/library/application/media_library_provider.dart';
import 'package:mochi_player/features/settings/infrastructure/app_settings_service.dart';
import 'package:mochi_player/features/playback/presentation/widgets/player_controls.dart';
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

  late final Player _player;
  late final VideoController _videoController;
  late final MediaLibraryProvider _libraryProvider;
  late final AppSettings _playbackSettings;
  late final PlaybackSessionController _session;

  bool _isControlsVisible = true;
  Timer? _hideControlsTimer;
  Timer? _progressSaveTimer;
  bool _isFullScreen = false;
  bool _isBuffering = false;
  bool _hasRestoredPosition = false;
  bool _didAutoSelectAudio = false;
  bool _didAutoSelectSubtitle = false;
  bool _isTryingAudioFallback = false;
  bool _playerErrorIsAudioDecode = false;
  bool _showResumeNotice = false;
  bool _overrideEmbeddedSubtitleStyle = false;
  bool _windowWasFullScreenOnOpen = false;
  bool _playerUsedWindowFullScreen = false;
  bool _isDisposed = false;
  int _mediaOpenGeneration = 0;
  Future<void>? _initialWindowFullScreenCapture;
  Future<void>? _fullScreenTransition;

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
  double _lastVolumeBeforeMute = 100.0;
  String? _playerError;
  String? _resumePositionLabel;

  MediaFile get _currentItem => _session.currentItem;
  bool get _hasPrevious => _session.hasPrevious;
  bool get _hasNext => _session.hasNext;

  // 🟢 新增：组合标题的 Getter
  String get _displayTitle {
    if (widget.contextTitle != null &&
        _currentItem.mediaType == MediaType.episode) {
      final season = _currentItem.parsedSeason;
      final episode = _currentItem.parsedEpisode;
      if (season != null && episode != null) {
        return '${widget.contextTitle} - 第 $season 季 第 $episode 集';
      }
      return widget.contextTitle!;
    }
    return _currentItem.parsedTitle.isNotEmpty
        ? _currentItem.parsedTitle
        : _currentItem.fileName;
  }

  @override
  void initState() {
    super.initState();
    _libraryProvider = context.read<MediaLibraryProvider>();
    _playbackSettings = context.read<AppSettingsProvider>().settings;
    _initializeSession();
    windowManager.addListener(this);

    _player = Player(
      configuration: PlayerConfiguration(
        title: 'Mochi Player',
        bufferSize: _playbackSettings.playbackCacheMaxBytes,
        libass: true,
      ),
    );

    _videoController = VideoController(
      _player,
      configuration: VideoControllerConfiguration(
        enableHardwareAcceleration:
            _playbackSettings.enableHardwareAcceleration,
      ),
    );

    _bindPlayerStreams();
    unawaited(_openMedia(_nextMediaOpenGeneration()));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _isDisposed) return;
      FocusScope.of(context).requestFocus(_focusNode);
    });

    unawaited(_ensureInitialWindowFullScreenCaptured());
  }

  void _initializeSession() {
    final sourcePlaylist = widget.playlist.isNotEmpty
        ? widget.playlist
        : _libraryProvider.getPlaybackQueue(widget.videoItem);
    _session = PlaybackSessionController(
      libraryProvider: _libraryProvider,
      initialItem: widget.videoItem,
      queueItems: sourcePlaylist,
      initialUrl: widget.url,
    );
  }

  void _bindPlayerStreams() {
    _subscriptions.addAll([
      _player.stream.error.listen((error) {
        if (_isDisposed) return;
        debugPrint('播放器错误: $error');
        _handlePlayerError(error);
      }),
      _player.stream.tracks.listen((tracks) {
        if (_isDisposed) return;
        final audioTracks = _normalizeAudioTracks(tracks.audio);
        final subtitleTracks = _normalizeSubtitleTracks(tracks.subtitle);
        if (mounted) {
          setState(() {
            _audioTracks = audioTracks;
            _subtitleTracks = subtitleTracks;
          });
        }
        if (!_didAutoSelectAudio) {
          _autoSelectAudio(audioTracks);
        }
        if (!_didAutoSelectSubtitle) {
          _autoSelectSubtitle(subtitleTracks);
        }
      }),
      _player.stream.track.listen((track) {
        if (_isDisposed) return;
        if (mounted) {
          setState(() {
            _selectedAudioTrack = track.audio;
            _selectedSubtitleTrack = track.subtitle;
          });
        }
      }),
      _player.stream.buffering.listen((buffering) {
        if (_isDisposed) return;
        if (mounted) {
          setState(() {
            _isBuffering = buffering;
          });
        }
      }),
      _player.stream.playing.listen((playing) {
        if (_isDisposed) return;
        _startHideControlsTimer();
      }),
      _player.stream.completed.listen((completed) {
        if (_isDisposed) return;
        if (completed) {
          unawaited(_handlePlaybackCompleted());
        }
      }),
      _player.stream.subtitle.listen((subtitle) {
        if (_isDisposed) return;
        if (mounted) {
          setState(() {
            _subtitle = subtitle;
          });
        }
      }),
    ]);
  }

  int _nextMediaOpenGeneration() {
    _mediaOpenGeneration += 1;
    return _mediaOpenGeneration;
  }

  bool _canUsePlayer([int? generation]) {
    return mounted &&
        !_isDisposed &&
        (generation == null || generation == _mediaOpenGeneration);
  }

  Future<void> _openMedia(int generation) async {
    await _session.refreshCurrentItem();
    if (!_canUsePlayer(generation)) return;

    final resumePosition = _resumePosition();

    debugPrint('正在播放直链: ${_session.currentUrl}');
    await _applyPlayerSettings(generation);
    if (!_canUsePlayer(generation)) return;

    await _applySubtitleStyleMode(generation);
    if (!_canUsePlayer(generation)) return;

    final media = Media(
      _session.currentUrl,
      httpHeaders: {'User-Agent': 'MochiPlayer/1.0.0'},
      start: resumePosition,
    );

    try {
      await _player.open(media, play: true);
      if (!_canUsePlayer(generation)) return;

      await _applySubtitleStyleMode(generation);
      if (!_canUsePlayer(generation)) return;

      await _restoreProgressIfNeeded(resumePosition, generation);
      if (!_canUsePlayer(generation)) return;

      _startProgressSaveTimer();
      _startHideControlsTimer();
    } catch (error) {
      debugPrint('打开媒体失败: $error');
      if (_canUsePlayer(generation)) {
        setState(() {
          _playerError = error.toString();
          _playerErrorIsAudioDecode = _isTrueHdDecoderError(error.toString());
        });
      }
    }
  }

  Future<void> _applyPlayerSettings([int? generation]) async {
    if (!_canUsePlayer(generation)) return;

    final platform = _player.platform;
    if (platform is! NativePlayer) return;

    final properties = <String, String>{
      'cache': 'yes',
      'cache-pause': 'yes',
      'cache-pause-wait': '3',
      'cache-secs': _playbackSettings.playbackReadaheadSeconds.toString(),
      'demuxer-readahead-secs': _playbackSettings.playbackReadaheadSeconds
          .toString(),
      'demuxer-max-bytes': _playbackSettings.playbackCacheMaxBytes.toString(),
      'demuxer-max-back-bytes': (_playbackSettings.playbackCacheMaxBytes ~/ 4)
          .toString(),
      'hwdec': _playbackSettings.enableHardwareAcceleration ? 'auto' : 'no',
      'alang': _playbackSettings.normalizedAudioLanguagePriority,
      'slang': _playbackSettings.normalizedSubtitleLanguagePriority,
      'vo-profile': 'high-quality',
    };

    for (final entry in properties.entries) {
      if (!_canUsePlayer(generation)) return;
      try {
        await platform.setProperty(entry.key, entry.value);
      } catch (error) {
        debugPrint('应用播放器设置失败 ${entry.key}=${entry.value}: $error');
      }
    }
  }

  Future<void> _applySubtitleStyleMode([int? generation]) async {
    if (!_canUsePlayer(generation)) return;

    final platform = _player.platform;
    if (platform is! NativePlayer) return;

    final preserveEmbeddedStyle = !_overrideEmbeddedSubtitleStyle;
    final value = preserveEmbeddedStyle ? 'yes' : 'no';
    final properties = <String, String>{
      'sub-ass': value,
      'sub-visibility': value,
      'secondary-sub-visibility': value,
    };

    for (final entry in properties.entries) {
      if (!_canUsePlayer(generation)) return;
      try {
        await platform.setProperty(entry.key, entry.value);
      } catch (error) {
        debugPrint('应用字幕样式模式失败 ${entry.key}=${entry.value}: $error');
      }
    }
  }

  void _handlePlayerError(String error) {
    if (_isDisposed) return;

    final isAudioDecodeError = _isTrueHdDecoderError(error);
    if (mounted) {
      setState(() {
        _playerError = error;
        _playerErrorIsAudioDecode = isAudioDecodeError;
      });
    }

    if (isAudioDecodeError) {
      unawaited(_trySelectFallbackAudioTrack(fromError: true));
    }
  }

  void _startProgressSaveTimer() {
    if (_isDisposed) return;

    _progressSaveTimer?.cancel();
    _progressSaveTimer = Timer.periodic(_progressSaveInterval, (_) {
      unawaited(_saveProgress());
    });
  }

  Duration? _resumePosition() {
    return PlaybackResumePolicy.positionFor(
      _currentItem,
      hasRestoredPosition: _hasRestoredPosition,
    );
  }

  Future<void> _restoreProgressIfNeeded(
    Duration? resumePosition,
    int generation,
  ) async {
    if (_hasRestoredPosition || resumePosition == null) return;
    if (!_canUsePlayer(generation)) return;

    _hasRestoredPosition = true;
    await _player.seek(resumePosition);
    unawaited(
      Future<void>.delayed(const Duration(milliseconds: 500), () async {
        if (!_canUsePlayer(generation)) return;
        final currentPosition = _player.state.position;
        final isStillNearStart =
            currentPosition.inMilliseconds <
            resumePosition.inMilliseconds - 2000;
        if (isStillNearStart && _canUsePlayer(generation)) {
          await _player.seek(resumePosition);
        }
      }),
    );
    _showResumePositionNotice(resumePosition);
  }

  Future<void> _saveProgress({
    bool force = false,
    bool allowDisposed = false,
  }) async {
    if (_isDisposed && !allowDisposed) return;

    final positionMs = _player.state.position.inMilliseconds;
    final durationMs = _player.state.duration.inMilliseconds;
    if (positionMs <= 0 && durationMs <= 0) return;

    try {
      await _session.saveProgress(
        positionMs: positionMs,
        durationMs: durationMs,
        force: force,
      );
    } catch (error) {
      debugPrint('保存播放进度失败: $error');
    }
  }

  Future<void> _handlePlaybackCompleted() async {
    if (_isDisposed) return;

    await _saveProgress(force: true);
    if (_isDisposed) return;

    if (_hasNext) {
      await _playQueueOffset(1);
    }
  }

  Future<void> _playQueueOffset(int offset) async {
    if (_isDisposed || _session.isSwitching) return;

    final generation = _nextMediaOpenGeneration();

    if (_canUsePlayer(generation)) {
      setState(() {
        _isBuffering = true;
        _playerError = null;
        _showResumeNotice = false;
      });
    }

    final move = await _session.moveBy(
      offset,
      positionMs: _player.state.position.inMilliseconds,
      durationMs: _player.state.duration.inMilliseconds,
    );
    if (!_canUsePlayer(generation)) {
      return;
    }

    if (move == null) {
      if (mounted) setState(() => _isBuffering = false);
      return;
    }

    if (!move.isReady) {
      setState(() {
        _isBuffering = false;
        _playerError = '获取播放链接失败: ${move.item.fileName}';
      });
      return;
    }

    _resumeNoticeTimer?.cancel();
    setState(() {
      _isBuffering = false;
      _hasRestoredPosition = false;
      _didAutoSelectAudio = false;
      _didAutoSelectSubtitle = false;
      _playerErrorIsAudioDecode = false;
      _showResumeNotice = false;
      _resumePositionLabel = null;
      _playerError = null;
      _subtitle = [];
      _audioTracks = const [];
      _subtitleTracks = const [];
      _selectedAudioTrack = const AudioTrack('auto', null, null);
      _selectedSubtitleTrack = const SubtitleTrack('auto', null, null);
    });

    await _openMedia(generation);
  }

  Future<void> _ensureInitialWindowFullScreenCaptured() {
    return _initialWindowFullScreenCapture ??= () async {
      _windowWasFullScreenOnOpen = await windowManager.isFullScreen();
    }();
  }

  @override
  void onWindowEnterFullScreen() {
    // Native fullscreen can also be triggered from macOS chrome. Keep that
    // separate from the player fullscreen button.
  }

  @override
  void onWindowLeaveFullScreen() {
    if (!_isFullScreen || !_playerUsedWindowFullScreen || !mounted) return;
    setState(() {
      _isFullScreen = false;
      _playerUsedWindowFullScreen = false;
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

  bool _isAudioTrackAuto(AudioTrack track) => track.id == 'auto' && !track.uri;

  void _autoSelectAudio(List<AudioTrack> tracks) {
    final actualTracks = tracks
        .where((track) => !_isAudioTrackAuto(track) && !_isAudioTrackOff(track))
        .toList();
    if (actualTracks.isEmpty) return;

    final hasTrueHdTrack = actualTracks.any(_isTrueHdAudioTrack);
    if (!hasTrueHdTrack) {
      _didAutoSelectAudio = true;
      return;
    }

    final fallback = _findFallbackAudioTrack(tracks);
    _didAutoSelectAudio = true;
    if (fallback != null) {
      unawaited(_setAudioTrack(fallback));
    }
  }

  Future<bool> _setAudioTrack(AudioTrack track) async {
    if (_isDisposed) return false;

    if (mounted) {
      setState(() {
        _selectedAudioTrack = track;
      });
    }
    try {
      await _player.setAudioTrack(track);
    } catch (error) {
      debugPrint('切换音轨失败: $error');
      return false;
    }
    if (_isDisposed) return false;

    _startHideControlsTimer();
    return true;
  }

  Future<bool> _trySelectFallbackAudioTrack({bool fromError = false}) async {
    if (_isDisposed || _isTryingAudioFallback) return false;

    final fallback = _findFallbackAudioTrack(_audioTracks);
    if (fallback == null) return false;

    _isTryingAudioFallback = true;
    try {
      final didSwitch = await _setAudioTrack(fallback);
      if (mounted && fromError && didSwitch) {
        setState(() {
          _playerError = null;
          _playerErrorIsAudioDecode = false;
        });
      }
      return didSwitch;
    } finally {
      _isTryingAudioFallback = false;
    }
  }

  AudioTrack? _findFallbackAudioTrack(List<AudioTrack> tracks) {
    final candidates = tracks
        .where((track) => !_isAudioTrackAuto(track) && !_isAudioTrackOff(track))
        .where((track) => !_isTrueHdAudioTrack(track))
        .where((track) => track != _selectedAudioTrack)
        .toList();
    if (candidates.isEmpty) return null;

    candidates.sort(
      (a, b) =>
          _audioCompatibilityScore(b).compareTo(_audioCompatibilityScore(a)),
    );
    return candidates.first;
  }

  int _audioCompatibilityScore(AudioTrack track) {
    final text = _audioTrackText(track);
    var score = 10 + _preferredAudioLanguageScore(track);
    if (text.contains('aac')) score += 40;
    if (text.contains('eac3') ||
        text.contains('e-ac-3') ||
        text.contains('ddp') ||
        text.contains('dd+')) {
      score += 36;
    }
    if (text.contains('ac3') || text.contains('dolby digital')) score += 32;
    if (text.contains('dts')) score += 24;
    if (text.contains('stereo') || text.contains('2.0')) score += 8;
    return score;
  }

  int _preferredAudioLanguageScore(AudioTrack track) {
    final preferences = _languagePreferences(
      _playbackSettings.normalizedAudioLanguagePriority,
    );
    for (var index = 0; index < preferences.length; index++) {
      if (_trackMatchesLanguage(
        language: track.language,
        title: track.title,
        preference: preferences[index],
      )) {
        return (preferences.length - index) * 20;
      }
    }
    return 0;
  }

  bool _isTrueHdAudioTrack(AudioTrack track) {
    final text = _audioTrackText(track);
    return text.contains('truehd') ||
        text.contains('true hd') ||
        text.contains('mlp');
  }

  String _audioTrackText(AudioTrack track) {
    return [
      track.id,
      track.title,
      track.language,
      track.codec,
      track.channels,
    ].whereType<String>().join(' ').toLowerCase();
  }

  bool _isTrueHdDecoderError(String error) {
    final text = error.toLowerCase();
    return text.contains('truehd') || text.contains('true hd');
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

    final preferences = _languagePreferences(
      _playbackSettings.normalizedSubtitleLanguagePriority,
    );
    for (final preference in preferences) {
      for (final track in availableTracks) {
        if (_trackMatchesLanguage(
          language: track.language,
          title: track.title,
          preference: preference,
        )) {
          targetTrack = track;
          break;
        }
      }
      if (targetTrack != null) break;
    }

    if (targetTrack != null) {
      unawaited(_setSubtitleTrack(targetTrack));
    }
  }

  List<String> _languagePreferences(String value) {
    return value
        .split(',')
        .map((item) => item.trim().toLowerCase())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  bool _trackMatchesLanguage({
    required String? language,
    required String? title,
    required String preference,
  }) {
    final normalizedPreference = preference.toLowerCase();
    final text = [language, title].whereType<String>().join(' ').toLowerCase();

    if (text.contains(normalizedPreference)) return true;

    if (_isChineseLanguage(normalizedPreference)) {
      return text.contains('zh') ||
          text.contains('chi') ||
          text.contains('zho') ||
          text.contains('chs') ||
          text.contains('cht') ||
          text.contains('中文') ||
          text.contains('简') ||
          text.contains('繁');
    }

    if (normalizedPreference == 'ja' || normalizedPreference == 'jpn') {
      return text.contains('ja') ||
          text.contains('jpn') ||
          text.contains('japanese') ||
          text.contains('日语') ||
          text.contains('日文');
    }

    if (normalizedPreference == 'en' || normalizedPreference == 'eng') {
      return text.contains('en') ||
          text.contains('eng') ||
          text.contains('english') ||
          text.contains('英语') ||
          text.contains('英文');
    }

    return false;
  }

  bool _isChineseLanguage(String value) {
    return value == 'zh' ||
        value == 'chi' ||
        value == 'zho' ||
        value == 'chs' ||
        value == 'cht' ||
        value.startsWith('zh-');
  }

  Future<void> _setSubtitleTrack(SubtitleTrack track) async {
    if (_isDisposed) return;

    _didAutoSelectSubtitle = true;
    if (mounted) {
      setState(() {
        _selectedSubtitleTrack = track;
      });
    }
    try {
      await _player.setSubtitleTrack(track);
      await _applySubtitleStyleMode();
    } catch (error) {
      debugPrint('切换字幕失败: $error');
    }
    if (_isDisposed) return;

    _startHideControlsTimer();
  }

  void _setSubtitleStyleOverride(bool value) {
    if (_isDisposed) return;
    if (_overrideEmbeddedSubtitleStyle == value) return;

    setState(() {
      _overrideEmbeddedSubtitleStyle = value;
      _subtitle = [];
    });
    unawaited(_applySubtitleStyleMode());
    _startHideControlsTimer();
  }

  void _showResumePositionNotice(Duration position) {
    if (_isDisposed) return;

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
    if (_isDisposed) return;
    if (_subtitleTracks.isEmpty) return;

    final currentIndex = _subtitleTracks.indexOf(_selectedSubtitleTrack);
    final nextIndex = currentIndex < 0
        ? 0
        : (currentIndex + 1) % _subtitleTracks.length;
    unawaited(_setSubtitleTrack(_subtitleTracks[nextIndex]));
  }

  void _cycleAudioTrack() {
    if (_isDisposed) return;

    final tracks = _audioTracks
        .where((track) => !_isAudioTrackOff(track))
        .toList();
    if (tracks.isEmpty) return;
    final currentIndex = tracks.indexOf(_selectedAudioTrack);
    final nextIndex = currentIndex < 0 ? 0 : (currentIndex + 1) % tracks.length;
    unawaited(_setAudioTrack(tracks[nextIndex]));
  }

  void _adjustVolume(double delta) {
    if (_isDisposed) return;

    final nextVolume = (_player.state.volume + delta).clamp(0.0, 100.0);
    _player.setVolume(nextVolume);
    if (nextVolume > 0) {
      _lastVolumeBeforeMute = nextVolume;
    }
    _startHideControlsTimer();
  }

  void _toggleMute() {
    if (_isDisposed) return;

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
    if (_isDisposed) return;

    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _isControlsVisible = false);
      }
    });
  }

  void _onPointerHover(PointerEvent event) {
    if (_isDisposed) return;

    if (!_isControlsVisible) {
      setState(() => _isControlsVisible = true);
    }
    _startHideControlsTimer();
  }

  void _onPointerExit(PointerEvent event) {
    if (_isDisposed) return;

    _hideControlsTimer?.cancel();
    if (mounted) {
      setState(() => _isControlsVisible = false);
    }
  }

  void _handleKeyEvent(KeyEvent event) async {
    if (_isDisposed) return;

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
        if (_isFullScreen) {
          unawaited(_exitPlayerFullScreen());
        }
      }
    }
  }

  void _toggleFullScreen() {
    if (_isDisposed || _fullScreenTransition != null) return;

    _fullScreenTransition = _togglePlayerFullScreen().whenComplete(() {
      _fullScreenTransition = null;
    });
    unawaited(_fullScreenTransition);
  }

  Future<void> _togglePlayerFullScreen() async {
    await Future.delayed(const Duration(milliseconds: 120));
    if (_isDisposed) return;

    if (_isFullScreen) {
      await _exitPlayerFullScreen();
    } else {
      await _enterPlayerFullScreen();
    }
  }

  Future<void> _enterPlayerFullScreen() async {
    if (_isDisposed) return;

    await _ensureInitialWindowFullScreenCaptured();
    if (_isDisposed) return;

    final windowIsFullScreen = await windowManager.isFullScreen();
    if (_isDisposed) return;

    if (!windowIsFullScreen) {
      _playerUsedWindowFullScreen = true;
      await windowManager.setFullScreen(true);
    } else {
      _playerUsedWindowFullScreen = false;
    }

    if (!mounted) return;
    setState(() {
      _isFullScreen = true;
    });
  }

  Future<void> _exitPlayerFullScreen({bool updateState = true}) async {
    await _ensureInitialWindowFullScreenCaptured();
    final shouldRestoreWindow =
        _playerUsedWindowFullScreen && !_windowWasFullScreenOnOpen;

    _playerUsedWindowFullScreen = false;

    if (shouldRestoreWindow && await windowManager.isFullScreen()) {
      await windowManager.setFullScreen(false);
    }

    _isFullScreen = false;
    if (updateState && mounted) {
      setState(() {});
    }
  }

  Future<void> _handleBackPressed() async {
    await _fullScreenTransition;
    await _exitPlayerFullScreen();
    if (mounted) {
      Navigator.of(context).maybePop();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _nextMediaOpenGeneration();

    unawaited(_saveProgress(force: true, allowDisposed: true));
    unawaited(() async {
      await _fullScreenTransition;
      await _exitPlayerFullScreen(updateState: false);
    }());
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
                    actionLabel:
                        _playerErrorIsAudioDecode &&
                            _findFallbackAudioTrack(_audioTracks) != null
                        ? '切换音轨'
                        : '关闭',
                    onAction:
                        _playerErrorIsAudioDecode &&
                            _findFallbackAudioTrack(_audioTracks) != null
                        ? () {
                            unawaited(
                              _trySelectFallbackAudioTrack(fromError: true),
                            );
                          }
                        : () {
                            setState(() {
                              _playerError = null;
                              _playerErrorIsAudioDecode = false;
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
              if (_overrideEmbeddedSubtitleStyle)
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
                            style: TextStyle(
                              fontSize: _playbackSettings.subtitleFontSize,
                              height: 1.4,
                              color: Colors.white,
                              shadows: const [
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
                onBack: () {
                  unawaited(_handleBackPressed());
                },
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
                overrideEmbeddedSubtitleStyle: _overrideEmbeddedSubtitleStyle,
                onSubtitleStyleOverrideChanged: _setSubtitleStyleOverride,
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
