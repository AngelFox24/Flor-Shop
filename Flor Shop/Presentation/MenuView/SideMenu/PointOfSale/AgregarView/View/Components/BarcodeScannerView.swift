import SwiftUI
import AVFoundation

struct BarcodeScannerView: UIViewControllerRepresentable {
    class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        var parent: BarcodeScannerView
        private var lastScanDate: Date?
        private let cooldown: TimeInterval = 1.5 // segundos
        init(parent: BarcodeScannerView) {
            self.parent = parent
        }

        func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
            guard let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
                  let stringValue = metadataObject.stringValue else {
                return
            }
            let now = Date()
            if let last = lastScanDate, now.timeIntervalSince(last) < cooldown {
                return
            }
            lastScanDate = now
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            parent.didFindCode(stringValue)
        }
    }

    var didFindCode: (String) -> Void

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()

        let captureSession = AVCaptureSession()

        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return viewController }
        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return viewController
        }

        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            return viewController
        }

        let metadataOutput = AVCaptureMetadataOutput()
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)

            metadataOutput.setMetadataObjectsDelegate(context.coordinator, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.ean13, .ean8, .code128] // Agrega los tipos de código de barras que quieras escanear
        } else {
            return viewController
        }

        // Crear la capa de vista previa
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        viewController.view.layer.addSublayer(previewLayer)
        
        // Configurar las dimensiones del área de vista previa y del área de escaneo
        let previewWidth: CGFloat = viewController.view.frame.width * 0.8 // 80% de la pantalla ancho
        let previewHeight: CGFloat = viewController.view.frame.height * 0.2// 20% de la pantalla alto
        let previewX: CGFloat = (viewController.view.frame.width - previewWidth) / 2
        let previewY: CGFloat = viewController.view.frame.height * 0.05 // 5% de topMargin de la pantalla de alto
        
        previewLayer.frame = CGRect(x: previewX, y: previewY, width: previewWidth, height: previewHeight)
        DispatchQueue.global(qos: .userInitiated).async {
            captureSession.startRunning()
        }
        print("previewWidth: \(previewWidth), previewHeight: \(previewHeight), previewX: \(previewX), previewY: \(previewY)")
        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

struct TestViewnContent: View {
    @State private var scannedCode: String?
    var body: some View {
        VStack {
            if let scannedCode = scannedCode {
                Text("Código escaneado: \(scannedCode)")
            } else {
                BarcodeScannerView { code in
                    self.scannedCode = code
                }
                .edgesIgnoringSafeArea(.all)
            }
        }
    }
}

#Preview {
    TestViewnContent()
}
