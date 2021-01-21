//
//  ScanViewController.swift
//  ReviewSchool
//
//  Created by Pham Van Minh Nhut on 1/21/21.
//

import UIKit
import AVFoundation

class ScanViewController : BaseViewController {
    @IBOutlet weak var ScanButton: UIButton!
    @IBOutlet weak var UsingImageQRLabel: UILabel!
    @IBOutlet weak var InstructionView: UIView!
    
    var captureSession = AVCaptureSession()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    @IBOutlet weak var qrCodeFrameView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        settupCameraForScan()
        settupView()
    }
    
    func settupCameraForScan(){
        // Get the back-facing camera for capturing videos
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera], mediaType: AVMediaType.video, position: .back)

        guard let captureDevice = deviceDiscoverySession.devices.first else {
            print("Failed to get the camera device")
            return
        }

        do {
            // Get an instance of the AVCaptureDeviceInput class using the previous device object.
            let input = try AVCaptureDeviceInput(device: captureDevice)

            // Set the input device on the capture session.
            captureSession.addInput(input)

        } catch {
            // If any error occurs, simply print it out and don't continue any more.
            print(error)
            return
        }
        
        // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
        let captureMetadataOutput = AVCaptureMetadataOutput()
        captureSession.addOutput(captureMetadataOutput)
        
        // Set delegate and use the default dispatch queue to execute the call back
        captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
        
        // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoPreviewLayer?.frame = view.layer.bounds
        view.layer.addSublayer(videoPreviewLayer!)
        
        // Move the message label and top bar to the front
//        view.bringSubviewToFront(messageLabel)
//        view.bringSubviewToFront(topbar)
        
        // Start video capture.
        captureSession.startRunning()

        if let qrCodeFrameView = qrCodeFrameView {
            qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
            qrCodeFrameView.layer.borderWidth = 2
            view.addSubview(qrCodeFrameView)
            view.bringSubviewToFront(qrCodeFrameView)
        }
    }
    
    func settupView(){
        ScanButton.rounded(borderWidth: 1, color: #colorLiteral(red: 0.5, green: 0.8196, blue: 1, alpha: 1), cornerRadius: 7)
        InstructionView.rounded(borderWidth: 1, color: #colorLiteral(red: 0.5, green: 0.8196, blue: 1, alpha: 1), cornerRadius: 7)
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(usingImageQROnClick(_:)))
        UsingImageQRLabel.isUserInteractionEnabled = true
        UsingImageQRLabel.addGestureRecognizer(recognizer)
    }
    @objc func usingImageQROnClick(_ sender:UITapGestureRecognizer) {
        // image picker view
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func ScanButtonOnClick(_ sender: Any) {
        // using camera now, take photo
    }
    
    func gotoAddReview( qrCode: String){
        guard let vc = storyboard?.instantiateViewController(withIdentifier: "AddEditReviewViewController")
            as? AddEditReviewViewController else {
            return
        }
        vc.qrCode = qrCode
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
}

extension ScanViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            // messageLabel.text = "No QR code is detected"
            return
        }

        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject

        if metadataObj.type == AVMetadataObject.ObjectType.qr {
            // If the found metadata is equal to the QR code metadata then update the status label's text and set the bounds
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            qrCodeFrameView?.frame = barCodeObject!.bounds

            if metadataObj.stringValue != nil {
                // messageLabel.text = metadataObj.stringValue
            }
        }
    }
}

extension ScanViewController: UIImagePickerControllerDelegate , UINavigationControllerDelegate{
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
//            imageView.contentMode = .scaleAspectFit
            
            if let features = detectQRCode(pickedImage), !features.isEmpty{
                picker.dismiss(animated: true, completion: nil)
                DispatchQueue.main.async {
                    self.gotoAddReview(qrCode : features[0])
                }
                return
            }
            let alert = UIAlertController(title: "Khong tim thay ma QR", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: {(action) in
                alert.dismiss(animated: true, completion: nil)
            }))
            self.present(alert, animated: true, completion: nil)
            return
        }
        dismiss(animated: true, completion: nil)
    }
    
    func detectQRCode(_ image: UIImage?) -> [String]? {
        if let image = image, let ciImage = CIImage.init(image: image){
            var options: [String: Any]
            let context = CIContext()
            options = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
            let qrDetector = CIDetector(ofType: CIDetectorTypeQRCode, context: context, options: options)
            if ciImage.properties.keys.contains((kCGImagePropertyOrientation as String)){
                options = [CIDetectorImageOrientation: ciImage.properties[(kCGImagePropertyOrientation as String)] ?? 1]
            } else {
                options = [CIDetectorImageOrientation: 1]
            }
            let features = qrDetector?.features(in: ciImage, options: options)
            var result : [String] = []
            for case let row as CIQRCodeFeature in features!{
                result.append(row.messageString!)
            }
            return result
        }
        return nil
    }
}
