import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  private static let windowButtonOffset = NSPoint(x: 12, y: -10)
  private var defaultWindowButtonContainerOrigin: NSPoint?
  private var windowButtonsConfigured = false
  private var windowControlChannel: FlutterMethodChannel?
  private var windowObserverTokens: [NSObjectProtocol] = []

  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)

    let channel = FlutterMethodChannel(
      name: "mochi_player/window_controls",
      binaryMessenger: flutterViewController.engine.binaryMessenger
    )
    channel.setMethodCallHandler { [weak self] call, result in
      guard call.method == "positionNativeWindowButtons" else {
        result(FlutterMethodNotImplemented)
        return
      }

      self?.windowButtonsConfigured = true
      self?.scheduleNativeWindowButtonPositioning()
      result(nil)
    }
    windowControlChannel = channel

    super.awakeFromNib()
    observeWindowChromeChanges()
  }

  deinit {
    for token in windowObserverTokens {
      NotificationCenter.default.removeObserver(token)
    }
  }

  override func becomeKey() {
    super.becomeKey()
    guard windowButtonsConfigured else {
      return
    }

    scheduleNativeWindowButtonPositioning()
  }

  private func observeWindowChromeChanges() {
    let exitFullScreenToken = NotificationCenter.default.addObserver(
      forName: NSWindow.didExitFullScreenNotification,
      object: self,
      queue: .main
    ) { [weak self] _ in
      guard self?.windowButtonsConfigured == true else {
        return
      }
      self?.scheduleNativeWindowButtonPositioning()
    }
    windowObserverTokens.append(exitFullScreenToken)
  }

  private func scheduleNativeWindowButtonPositioning() {
    DispatchQueue.main.async { [weak self] in
      self?.positionNativeWindowButtons()
    }
  }

  private func positionNativeWindowButtons() {
    guard
      let closeButton = standardWindowButton(.closeButton),
      let buttonContainer = closeButton.superview
    else {
      return
    }

    if defaultWindowButtonContainerOrigin == nil {
      defaultWindowButtonContainerOrigin = buttonContainer.frame.origin
    }

    guard let defaultOrigin = defaultWindowButtonContainerOrigin else {
      return
    }

    buttonContainer.setFrameOrigin(
      NSPoint(
        x: defaultOrigin.x + Self.windowButtonOffset.x,
        y: defaultOrigin.y + Self.windowButtonOffset.y
      )
    )

    buttonContainer.updateTrackingAreas()
    buttonContainer.superview?.updateTrackingAreas()
  }
}
