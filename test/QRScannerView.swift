//
//  QRScannerView.swift
//  App Sitemana
//
//  Created by Developer01 on 12/3/24.
//
import AVFoundation
import SwiftUI

struct QRScannerView: UIViewControllerRepresentable {
    @Binding var result: String?
    var onFound: (String) -> Void

    class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        var parent: QRScannerView

        init(parent: QRScannerView) {
            self.parent = parent
        }

        func metadataOutput(
            _ output: AVCaptureMetadataOutput,
            didOutput metadataObjects: [AVMetadataObject],
            from connection: AVCaptureConnection
        ) {
            if let metadataObject = metadataObjects.first {
                guard
                    let readableObject = metadataObject
                        as? AVMetadataMachineReadableCodeObject
                else { return }
                guard let stringValue = readableObject.stringValue else {
                    return
                }
                AudioServicesPlaySystemSound(
                    SystemSoundID(kSystemSoundID_Vibrate))
                parent.result = stringValue
                parent.onFound(stringValue)  // Procesar el resultado del escaneo
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        let captureSession = AVCaptureSession()

        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video)
        else { return viewController }
        let videoDeviceInput: AVCaptureDeviceInput

        do {
            videoDeviceInput = try AVCaptureDeviceInput(
                device: videoCaptureDevice)
        } catch {
            return viewController
        }

        if captureSession.canAddInput(videoDeviceInput) {
            captureSession.addInput(videoDeviceInput)
        } else {
            return viewController
        }

        let metadataOutput = AVCaptureMetadataOutput()

        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)

            metadataOutput.setMetadataObjectsDelegate(
                context.coordinator, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]  // Solo escanear códigos QR
        } else {
            return viewController
        }

        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = viewController.view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        viewController.view.layer.addSublayer(previewLayer)

        captureSession.startRunning()

        return viewController
    }

    func updateUIViewController(
        _ uiViewController: UIViewController, context: Context
    ) {}
}
