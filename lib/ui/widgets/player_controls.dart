import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class PlayerControls extends StatefulWidget {
  final Player player;
  final VideoController controller;
  final String title;
  final bool isVisible;
  final bool isFullScreen;
  final VoidCallback onToggleFullScreen;

  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final VoidCallback? onPip;
  final List<AudioTrack> audioTracks;
  final AudioTrack? selectedAudioTrack;
  final ValueChanged<AudioTrack>? onAudioSelected;
  final List<SubtitleTrack> subtitleTracks;
  final SubtitleTrack? selectedSubtitleTrack;
  final ValueChanged<SubtitleTrack>? onSubtitleSelected;

  final VoidCallback? onInteraction;

  const PlayerControls({
    super.key,
    required this.player,
    required this.controller,
    this.title = '',
    required this.isVisible,
    required this.isFullScreen,
    required this.onToggleFullScreen,
    this.onPrevious,
    this.onNext,
    this.onPip,
    this.audioTracks = const [],
    this.selectedAudioTrack,
    this.onAudioSelected,
    this.subtitleTracks = const [],
    this.selectedSubtitleTrack,
    this.onSubtitleSelected,
    this.onInteraction,
  });

  @override
  State<PlayerControls> createState() => _PlayerControlsState();
}

class _PlayerControlsState extends State<PlayerControls> {
  // 状态
  bool _isPlaying = false;
  double _volume = 100.0;
  double _rate = 1.0;
  String _systemTime = '';

  // 资源
  Timer? _timeTimer;
  final List<StreamSubscription> _subscriptions = [];

  @override
  void initState() {
    super.initState();
    _isPlaying = widget.player.state.playing;
    _volume = widget.player.state.volume;
    _rate = widget.player.state.rate;

    _subscriptions.addAll([
      widget.player.stream.playing.listen((v) {
        if (mounted) setState(() => _isPlaying = v);
      }),
      widget.player.stream.volume.listen((v) {
        if (mounted) setState(() => _volume = v);
      }),
      widget.player.stream.rate.listen((v) {
        if (mounted) setState(() => _rate = v);
      }),
    ]);

    _updateTime();
    _timeTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _updateTime(),
    );
  }

  void _updateTime() {
    if (mounted) {
      setState(() {
        _systemTime = DateFormat('HH:mm').format(DateTime.now());
      });
    }
  }

  @override
  void dispose() {
    _timeTimer?.cancel();
    for (var s in _subscriptions) {
      s.cancel();
    }
    super.dispose();
  }

  void _onTap(VoidCallback action) {
    widget.onInteraction?.call();
    action();
  }

  @override
  Widget build(BuildContext context) {
    // 统一按钮大小常量
    const double kButtonSize = 40.0;

    return AnimatedOpacity(
      opacity: widget.isVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: IgnorePointer(
        ignoring: !widget.isVisible,
        child: Stack(
          children: [
            // ================== 顶部栏 ==================
            Align(
              alignment: Alignment.topCenter,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: _GlassBox(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _ControlButton(
                          size: 32, // 顶部小按钮
                          onPressed: () =>
                              _onTap(() => Navigator.of(context).maybePop()),
                          child: const Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 8),
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.4,
                          ),
                          child: Text(
                            widget.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _systemTime,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ================== 底部栏 ==================
            Align(
              alignment: Alignment.bottomCenter,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: _GlassBox(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 进度条
                        _VideoSeekBar(
                          player: widget.player,
                          onInteraction: widget.onInteraction,
                        ),
                        const SizedBox(height: 8),

                        // 控制按钮行
                        Row(
                          children: [
                            // 1. 上一集
                            if (widget.onPrevious != null) ...[
                              _ControlButton(
                                size: kButtonSize,
                                onPressed: () => _onTap(widget.onPrevious!),
                                child: const Icon(
                                  Icons.skip_previous_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 4),
                            ],

                            // 2. 快退
                            _ControlButton(
                              size: kButtonSize,
                              onPressed: () => _onTap(
                                () => widget.player.seek(
                                  widget.player.state.position -
                                      const Duration(seconds: 10),
                                ),
                              ),
                              child: const Icon(
                                Icons.replay_10_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 4),

                            // 3. 播放/暂停 (统一大小，但保留图标视觉差异)
                            _ControlButton(
                              size: kButtonSize,
                              onPressed: () =>
                                  _onTap(widget.player.playOrPause),
                              child: Icon(
                                _isPlaying
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 30, // 图标稍大
                              ),
                            ),
                            const SizedBox(width: 4),

                            // 4. 快进
                            _ControlButton(
                              size: kButtonSize,
                              onPressed: () => _onTap(
                                () => widget.player.seek(
                                  widget.player.state.position +
                                      const Duration(seconds: 10),
                                ),
                              ),
                              child: const Icon(
                                Icons.forward_10_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),

                            // 5. 下一集
                            if (widget.onNext != null) ...[
                              const SizedBox(width: 4),
                              _ControlButton(
                                size: kButtonSize,
                                onPressed: () => _onTap(widget.onNext!),
                                child: const Icon(
                                  Icons.skip_next_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ],

                            const SizedBox(width: 16),
                            _DurationLabel(player: widget.player),

                            const Spacer(),

                            // 右侧功能区
                            if (widget.onSubtitleSelected != null &&
                                widget.subtitleTracks.isNotEmpty) ...[
                              _SubtitleMenuButton(
                                tracks: widget.subtitleTracks,
                                selectedTrack: widget.selectedSubtitleTrack,
                                onSelected: (track) {
                                  widget.onInteraction?.call();
                                  widget.onSubtitleSelected?.call(track);
                                },
                              ),
                              const SizedBox(width: 4),
                            ],

                            if (widget.onAudioSelected != null &&
                                widget.audioTracks.isNotEmpty) ...[
                              _AudioMenuButton(
                                tracks: widget.audioTracks,
                                selectedTrack: widget.selectedAudioTrack,
                                onSelected: (track) {
                                  widget.onInteraction?.call();
                                  widget.onAudioSelected?.call(track);
                                },
                              ),
                              const SizedBox(width: 4),
                            ],

                            _RateMenuButton(
                              rate: _rate,
                              onSelected: (rate) {
                                widget.onInteraction?.call();
                                widget.player.setRate(rate);
                              },
                            ),
                            const SizedBox(width: 4),

                            if (widget.onPip != null) ...[
                              _ControlButton(
                                size: kButtonSize,
                                onPressed: () => _onTap(widget.onPip!),
                                child: const Icon(
                                  Icons.picture_in_picture_alt_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 4),
                            ],

                            // 音量
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _ControlButton(
                                  size: kButtonSize,
                                  onPressed: () => _onTap(() {
                                    final newVol = _volume > 0 ? 0.0 : 100.0;
                                    widget.player.setVolume(newVol);
                                  }),
                                  child: Icon(
                                    _volume == 0
                                        ? Icons.volume_off_rounded
                                        : Icons.volume_up_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                SizedBox(
                                  width: 80,
                                  height: 20,
                                  child: SliderTheme(
                                    data: SliderThemeData(
                                      trackHeight: 2,
                                      thumbShape: const RoundSliderThumbShape(
                                        enabledThumbRadius: 6,
                                      ),
                                      overlayShape:
                                          const RoundSliderOverlayShape(
                                            overlayRadius: 10,
                                          ),
                                      activeTrackColor: Colors.white,
                                      inactiveTrackColor: Colors.white24,
                                      thumbColor: Colors.white,
                                      trackShape:
                                          const RectangularSliderTrackShape(),
                                    ),
                                    child: Slider(
                                      value: _volume.clamp(0.0, 100.0),
                                      min: 0.0,
                                      max: 100.0,
                                      onChanged: (v) {
                                        widget.onInteraction?.call();
                                        widget.player.setVolume(v);
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(width: 4),
                            _ControlButton(
                              size: kButtonSize,
                              onPressed: () =>
                                  _onTap(widget.onToggleFullScreen),
                              child: const Icon(
                                Icons.fullscreen_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RateMenuButton extends StatelessWidget {
  static const List<double> _rates = [0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0];

  final double rate;
  final ValueChanged<double> onSelected;

  const _RateMenuButton({required this.rate, required this.onSelected});

  String _labelFor(double value) {
    if (value == value.roundToDouble()) {
      return '${value.toInt()}X';
    }
    return '${value.toStringAsFixed(2).replaceAll(RegExp(r'0$'), '')}X';
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<double>(
      tooltip: '倍速',
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 120, maxWidth: 160),
      color: Colors.black.withAlpha((255 * 0.9).round()),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onSelected: onSelected,
      itemBuilder: (context) => [
        for (final value in _rates)
          PopupMenuItem<double>(
            value: value,
            height: 36,
            child: Row(
              children: [
                SizedBox(
                  width: 20,
                  child: (rate - value).abs() < 0.01
                      ? const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 18,
                        )
                      : null,
                ),
                const SizedBox(width: 8),
                Text(
                  _labelFor(value),
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ],
            ),
          ),
      ],
      child: _PopupControlButton(
        width: 56,
        child: Text(
          _labelFor(rate),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _AudioMenuButton extends StatelessWidget {
  final List<AudioTrack> tracks;
  final AudioTrack? selectedTrack;
  final ValueChanged<AudioTrack> onSelected;

  const _AudioMenuButton({
    required this.tracks,
    required this.selectedTrack,
    required this.onSelected,
  });

  bool _isAuto(AudioTrack track) => track.id == 'auto' && !track.uri;

  bool _isOff(AudioTrack track) => track.id == 'no' && !track.uri;

  String _labelFor(AudioTrack track) {
    if (_isAuto(track)) return '自动音轨';
    if (_isOff(track)) return '关闭声音';

    final title = track.title?.trim();
    final language = track.language?.trim();
    final codec = track.codec?.trim();
    final channels = track.channels?.trim();
    final parts = <String>[];
    if (title != null && title.isNotEmpty) {
      parts.add(title);
    }
    if (language != null &&
        language.isNotEmpty &&
        title?.toLowerCase() != language.toLowerCase()) {
      parts.add(language);
    }
    if (codec != null && codec.isNotEmpty) {
      parts.add(codec.toUpperCase());
    }
    if (channels != null && channels.isNotEmpty) {
      parts.add(channels);
    }
    if (parts.isEmpty) {
      parts.add('音轨 ${track.id}');
    }
    return parts.join(' / ');
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<AudioTrack>(
      tooltip: '音轨',
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 220, maxWidth: 380),
      color: Colors.black.withAlpha((255 * 0.9).round()),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onSelected: onSelected,
      itemBuilder: (context) => [
        for (final track in tracks)
          PopupMenuItem<AudioTrack>(
            value: track,
            height: 36,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 180, maxWidth: 340),
              child: Row(
                children: [
                  SizedBox(
                    width: 20,
                    child: selectedTrack == track
                        ? const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 18,
                          )
                        : null,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _labelFor(track),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
      child: _PopupControlButton(
        child: Icon(
          Icons.audiotrack_rounded,
          color: selectedTrack == null || _isAuto(selectedTrack!)
              ? Colors.white70
              : Colors.white,
          size: 20,
        ),
      ),
    );
  }
}

class _SubtitleMenuButton extends StatelessWidget {
  final List<SubtitleTrack> tracks;
  final SubtitleTrack? selectedTrack;
  final ValueChanged<SubtitleTrack> onSelected;

  const _SubtitleMenuButton({
    required this.tracks,
    required this.selectedTrack,
    required this.onSelected,
  });

  bool _isAuto(SubtitleTrack track) =>
      track.id == 'auto' && !track.uri && !track.data;

  bool _isOff(SubtitleTrack track) =>
      track.id == 'no' && !track.uri && !track.data;

  String _labelFor(SubtitleTrack track) {
    if (_isAuto(track)) return '自动字幕';
    if (_isOff(track)) return '关闭字幕';

    final title = track.title?.trim();
    final language = track.language?.trim();
    final parts = <String>[];
    if (title != null && title.isNotEmpty) {
      parts.add(title);
    }
    if (language != null &&
        language.isNotEmpty &&
        title?.toLowerCase() != language.toLowerCase()) {
      parts.add(language);
    }
    if (parts.isEmpty) {
      parts.add('字幕 ${track.id}');
    }
    return parts.join(' / ');
  }

  @override
  Widget build(BuildContext context) {
    final activeTrack = selectedTrack;
    final hasSubtitleEnabled =
        activeTrack != null && !_isAuto(activeTrack) && !_isOff(activeTrack);

    return PopupMenuButton<SubtitleTrack>(
      tooltip: '字幕',
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 220, maxWidth: 360),
      color: Colors.black.withAlpha((255 * 0.9).round()),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onSelected: onSelected,
      itemBuilder: (context) => [
        for (final track in tracks)
          PopupMenuItem<SubtitleTrack>(
            value: track,
            height: 36,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 180, maxWidth: 320),
              child: Row(
                children: [
                  SizedBox(
                    width: 20,
                    child: selectedTrack == track
                        ? const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 18,
                          )
                        : null,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _labelFor(track),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
      child: _PopupControlButton(
        child: Icon(
          Icons.closed_caption_rounded,
          color: hasSubtitleEnabled ? Colors.white : Colors.white70,
          size: 20,
        ),
      ),
    );
  }
}

class _PopupControlButton extends StatefulWidget {
  final Widget child;
  final double width;

  const _PopupControlButton({required this.child, this.width = 40});

  @override
  State<_PopupControlButton> createState() => _PopupControlButtonState();
}

class _PopupControlButtonState extends State<_PopupControlButton> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        width: widget.width,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _isHovering
              ? Colors.white.withAlpha((255 * 0.2).round())
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: widget.child,
      ),
    );
  }
}

// ================== 自适应毛玻璃 ==================
class _GlassBox extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const _GlassBox({required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withAlpha((255 * 0.5).round()),
            border: Border.all(
              color: Colors.white.withAlpha((255 * 0.1).round()),
            ),
          ),
          padding:
              padding ??
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: child,
        ),
      ),
    );
  }
}

// ================== 统一按钮 (带动画 & 修复对齐版) ==================
class _ControlButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;
  final double? size;

  const _ControlButton({
    required this.child,
    required this.onPressed,
    this.size,
  });

  @override
  State<_ControlButton> createState() => _ControlButtonState();
}

class _ControlButtonState extends State<_ControlButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  bool _isHovering = false;

  @override
  void initState() {
    super.initState();
    // 🟢 动画控制器回归
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 100),
    );
    _scaleAnim = Tween<double>(
      begin: 1.0,
      end: 0.92,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 🟢 尺寸对齐逻辑保留：
    final bool isFixed = widget.size != null;
    final double height = widget.size ?? 40.0;
    final double? width = isFixed ? widget.size : null;
    final EdgeInsetsGeometry padding = isFixed
        ? EdgeInsets.zero
        : const EdgeInsets.symmetric(horizontal: 12);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        // 🟢 动画事件绑定回归
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) {
          _controller.reverse();
          widget.onPressed();
        },
        onTapCancel: () => _controller.reverse(),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (_, child) => Transform.scale(
            scale: _scaleAnim.value, // 缩放效果
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              // 背景色渐变
              curve: Curves.easeOut,
              width: width,
              height: height,
              padding: padding,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _isHovering
                    ? Colors.white.withAlpha((255 * 0.2).round())
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(isFixed ? height / 2 : 8),
              ),
              child: child,
            ),
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

// ================== 进度条 ==================
class _VideoSeekBar extends StatefulWidget {
  final Player player;
  final VoidCallback? onInteraction;

  const _VideoSeekBar({required this.player, this.onInteraction});

  @override
  State<_VideoSeekBar> createState() => _VideoSeekBarState();
}

class _VideoSeekBarState extends State<_VideoSeekBar> {
  Duration _pos = Duration.zero;
  Duration _dur = Duration.zero;
  Duration _buf = Duration.zero;
  bool _dragging = false;
  late List<StreamSubscription> _subs;

  @override
  void initState() {
    super.initState();
    _dur = widget.player.state.duration;
    _subs = [
      widget.player.stream.position.listen((p) {
        if (!_dragging && mounted) setState(() => _pos = p);
      }),
      widget.player.stream.duration.listen((d) {
        if (mounted) setState(() => _dur = d);
      }),
      widget.player.stream.buffer.listen((b) {
        if (mounted) setState(() => _buf = b);
      }),
    ];
  }

  @override
  void dispose() {
    for (var s in _subs) {
      s.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final max = _dur.inMilliseconds.toDouble();
    final val = _pos.inMilliseconds.toDouble().clamp(0.0, max);
    final bufVal = _buf.inMilliseconds.toDouble().clamp(0.0, max);

    return SizedBox(
      height: 14,
      child: SliderTheme(
        data: SliderThemeData(
          trackHeight: 3,
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
          overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
          activeTrackColor: Theme.of(context).primaryColor,
          inactiveTrackColor: Colors.white24,
          secondaryActiveTrackColor: Colors.white38,
          thumbColor: Colors.white,
          trackShape: const RoundedRectSliderTrackShape(),
        ),
        child: Slider(
          min: 0.0,
          max: max,
          value: val,
          secondaryTrackValue: bufVal,
          onChangeStart: (_) {
            widget.onInteraction?.call();
            setState(() => _dragging = true);
          },
          onChanged: (v) {
            widget.onInteraction?.call();
            setState(() => _pos = Duration(milliseconds: v.toInt()));
          },
          onChangeEnd: (v) {
            _dragging = false;
            widget.player.seek(Duration(milliseconds: v.toInt()));
          },
        ),
      ),
    );
  }
}

// ================== 时间标签 ==================
class _DurationLabel extends StatelessWidget {
  final Player player;

  const _DurationLabel({required this.player});

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return d.inHours > 0 ? "${d.inHours}:$m:$s" : "$m:$s";
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Duration>(
      stream: player.stream.position,
      builder: (_, snap) => Text(
        "${_fmt(snap.data ?? Duration.zero)} / ${_fmt(player.state.duration)}",
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 12,
          fontFeatures: [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}
