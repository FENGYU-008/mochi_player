/// 观看状态
enum WatchStatus {
  /// 未开始
  notStarted,

  /// 正在看 (0 < progress < 95%)
  watching,

  /// 已看完 (progress >= 95%)
  completed,
}
