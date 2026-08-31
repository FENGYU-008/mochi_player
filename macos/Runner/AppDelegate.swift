import Cocoa
import FlutterMacOS

/// Keeps macOS security-scoped directory grants alive and restores them after
/// relaunch using bookmarks stored by the system preferences database.
final class LocalDirectoryAccessManager {
  static let shared = LocalDirectoryAccessManager()

  private let bookmarkPrefix = "mochi_player.local_directory_bookmark."
  private var activeURLs: [String: URL] = [:]

  /// Must be called directly from NSOpenPanel's completion handler. At that
  /// point macOS still supplies the security scope for the selected URL.
  func registerSelectedDirectory(_ url: URL) throws -> Bool {
    let path = url.path
    if activeURLs[path] != nil {
      return true
    }

    guard url.startAccessingSecurityScopedResource() else {
      return false
    }

    do {
      let bookmark = try url.bookmarkData(
        options: .withSecurityScope,
        includingResourceValuesForKeys: nil,
        relativeTo: nil
      )
      UserDefaults.standard.set(bookmark, forKey: bookmarkPrefix + path)
      activeURLs[path] = url
      return true
    } catch {
      url.stopAccessingSecurityScopedResource()
      throw error
    }
  }

  func authorize(path: String) throws -> Bool {
    if activeURLs[path] != nil {
      return true
    }

    let bookmarkKey = bookmarkPrefix + path
    guard let bookmarkData = UserDefaults.standard.data(forKey: bookmarkKey) else {
      return false
    }

    var isStale = false
    let url = try URL(
      resolvingBookmarkData: bookmarkData,
      options: [.withSecurityScope, .withoutUI],
      relativeTo: nil,
      bookmarkDataIsStale: &isStale
    )

    guard url.startAccessingSecurityScopedResource() else {
      return false
    }

    if isStale {
      let bookmark = try url.bookmarkData(
        options: .withSecurityScope,
        includingResourceValuesForKeys: nil,
        relativeTo: nil
      )
      UserDefaults.standard.set(bookmark, forKey: bookmarkKey)
    }
    activeURLs[path] = url
    return true
  }
}

@main
class AppDelegate: FlutterAppDelegate {
  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return true
  }

  override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
    return true
  }
}
