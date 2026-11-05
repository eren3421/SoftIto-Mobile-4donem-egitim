import Cocoa
import FlutterMacOS
import AVFoundation

class MainFlutterWindow: NSWindow {
  private var cameraSheetController: MacCameraSheetController?

  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)

    let cameraChannel = FlutterMethodChannel(
      name: "softito/camera",
      binaryMessenger: flutterViewController.engine.binaryMessenger
    )

    cameraChannel.setMethodCallHandler { [weak self] (call, result) in
      guard let self = self else {
        result(nil)
        return
      }
      if call.method == "takePhoto" {
        self.handleTakePhoto(result: result)
      } else {
        result(FlutterMethodNotImplemented)
      }
    }

    super.awakeFromNib()
  }

  private func handleTakePhoto(result: @escaping FlutterResult) {
    let status = AVCaptureDevice.authorizationStatus(for: .video)
    switch status {
    case .authorized:
      presentCameraSheet(result: result)
    case .notDetermined:
      AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
        DispatchQueue.main.async {
          if granted {
            self?.presentCameraSheet(result: result)
          } else {
            result(
              FlutterError(
                code: "CAMERA_PERMISSION_DENIED",
                message: "Kamera izni verilmedi.",
                details: nil
              )
            )
          }
        }
      }
    default:
      result(
        FlutterError(
          code: "CAMERA_PERMISSION_DENIED",
          message: "Kamera erişimi reddedilmiş. Sistem Ayarları > Gizlilik ve Güvenlik > Kamera bölümünden izin verin.",
          details: nil
        )
      )
    }
  }

  private func presentCameraSheet(result: @escaping FlutterResult) {
    let controller = MacCameraSheetController(parentWindow: self) { [weak self] response in
      self?.cameraSheetController = nil
      result(response)
    }
    self.cameraSheetController = controller
    controller.startAndPresent()
  }
}

class MacCameraSheetController: NSObject, AVCapturePhotoCaptureDelegate {
  private weak var parentWindow: NSWindow?
  private let completion: (Any?) -> Void
  private let session = AVCaptureSession()
  private let photoOutput = AVCapturePhotoOutput()
  private var sheetWindow: NSWindow?
  private var didComplete = false

  init(parentWindow: NSWindow, completion: @escaping (Any?) -> Void) {
    self.parentWindow = parentWindow
    self.completion = completion
    super.init()
  }

  func startAndPresent() {
    guard let device = AVCaptureDevice.default(for: .video) else {
      finish(
        with: FlutterError(
          code: "NO_CAMERA",
          message: "Bu cihazda kullanılabilir bir kamera bulunamadı.",
          details: nil
        )
      )
      return
    }

    do {
      let input = try AVCaptureDeviceInput(device: device)
      session.beginConfiguration()
      if session.canSetSessionPreset(.photo) {
        session.sessionPreset = .photo
      }
      if session.canAddInput(input) {
        session.addInput(input)
      }
      if session.canAddOutput(photoOutput) {
        session.addOutput(photoOutput)
      }
      session.commitConfiguration()
    } catch {
      finish(
        with: FlutterError(
          code: "CAMERA_INIT_ERROR",
          message: "Kamera başlatılamadı: \(error.localizedDescription)",
          details: nil
        )
      )
      return
    }

    let windowRect = NSRect(x: 0, y: 0, width: 520, height: 420)
    let panel = NSWindow(
      contentRect: windowRect,
      styleMask: [.titled],
      backing: .buffered,
      defer: false
    )
    panel.title = "Kamera"

    let contentView = NSView(frame: windowRect)
    contentView.wantsLayer = true
    contentView.layer?.backgroundColor = NSColor(calibratedRed: 0.06, green: 0.09, blue: 0.16, alpha: 1.0).cgColor

    let previewContainer = NSView(frame: NSRect(x: 16, y: 68, width: 488, height: 336))
    previewContainer.wantsLayer = true
    previewContainer.layer?.cornerRadius = 12
    previewContainer.layer?.masksToBounds = true
    previewContainer.layer?.backgroundColor = NSColor.black.cgColor

    let previewLayer = AVCaptureVideoPreviewLayer(session: session)
    previewLayer.frame = previewContainer.bounds
    previewLayer.autoresizingMask = [.layerWidthSizable, .layerHeightSizable]
    previewLayer.videoGravity = .resizeAspectFill
    if let connection = previewLayer.connection, connection.isVideoMirroringSupported {
      connection.automaticallyAdjustsVideoMirroring = false
      connection.isVideoMirrored = true
    }
    previewContainer.layer?.addSublayer(previewLayer)
    contentView.addSubview(previewContainer)

    let cancelButton = NSButton(title: "İptal", target: self, action: #selector(cancelTapped))
    cancelButton.bezelStyle = .rounded
    cancelButton.frame = NSRect(x: 150, y: 18, width: 100, height: 32)
    contentView.addSubview(cancelButton)

    let captureButton = NSButton(title: "Fotoğraf Çek", target: self, action: #selector(captureTapped))
    captureButton.bezelStyle = .rounded
    captureButton.keyEquivalent = "\r"
    captureButton.frame = NSRect(x: 270, y: 18, width: 120, height: 32)
    contentView.addSubview(captureButton)

    panel.contentView = contentView
    self.sheetWindow = panel

    DispatchQueue.global(qos: .userInitiated).async { [weak self] in
      self?.session.startRunning()
    }

    parentWindow?.beginSheet(panel, completionHandler: nil)
  }

  @objc private func cancelTapped() {
    closeSheetAndFinish(with: nil)
  }

  @objc private func captureTapped() {
    let settings = AVCapturePhotoSettings()
    photoOutput.capturePhoto(with: settings, delegate: self)
  }

  func photoOutput(
    _ output: AVCapturePhotoOutput,
    didFinishProcessingPhoto photo: AVCapturePhoto,
    error: Error?
  ) {
    if let error = error {
      closeSheetAndFinish(
        with: FlutterError(
          code: "CAPTURE_ERROR",
          message: "Fotoğraf çekilemedi: \(error.localizedDescription)",
          details: nil
        )
      )
      return
    }

    guard let data = photo.fileDataRepresentation() else {
      closeSheetAndFinish(
        with: FlutterError(
          code: "CAPTURE_ERROR",
          message: "Fotoğraf verisi alınamadı.",
          details: nil
        )
      )
      return
    }

    let fileName = "kamera_\(Int(Date().timeIntervalSince1970 * 1000)).jpg"
    let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

    do {
      if let bitmap = NSBitmapImageRep(data: data),
         let jpegData = bitmap.representation(using: .jpeg, properties: [.compressionFactor: 0.85]) {
        try jpegData.write(to: fileURL)
      } else {
        try data.write(to: fileURL)
      }
      closeSheetAndFinish(with: fileURL.path)
    } catch {
      closeSheetAndFinish(
        with: FlutterError(
          code: "FILE_SAVE_ERROR",
          message: "Fotoğraf kaydedilemedi: \(error.localizedDescription)",
          details: nil
        )
      )
    }
  }

  private func closeSheetAndFinish(with response: Any?) {
    DispatchQueue.global(qos: .userInitiated).async { [weak self] in
      if self?.session.isRunning == true {
        self?.session.stopRunning()
      }
    }
    DispatchQueue.main.async { [weak self] in
      guard let self = self else { return }
      if let sheet = self.sheetWindow, let parent = self.parentWindow {
        parent.endSheet(sheet)
      }
      self.sheetWindow = nil
      self.finish(with: response)
    }
  }

  private func finish(with response: Any?) {
    guard !didComplete else { return }
    didComplete = true
    completion(response)
  }
}
