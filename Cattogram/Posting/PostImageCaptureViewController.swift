//
//  PostImageCaptureViewController.swift
//  Cattogram
//
//  Created by Siraj Zaneer on 12/22/17.
//  Copyright © 2017 Siraj Zaneer. All rights reserved.
//

import UIKit
import AVFoundation

class PostImageCaptureViewController: UIViewController {
    
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var captureViewOutside: UIView!
    @IBOutlet weak var captureViewInside: UIView!
    
    var session = AVCaptureSession()
    let stillImageOutput = AVCapturePhotoOutput()
    var input: AVCaptureDeviceInput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var flash = false
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.topItem?.title = "Photo"
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        captureViewOutside.layer.cornerRadius = captureViewOutside.frame.width / 2.0
        captureViewInside.layer.cornerRadius = captureViewInside.frame.width / 2.0
        
        session.sessionPreset = .photo
        
        let device = AVCaptureDevice.default(for: .video)
        
        input = try! AVCaptureDeviceInput(device: device!)
        
        session.addInput(input!)
        
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer!.videoGravity = AVLayerVideoGravity.resizeAspectFill
        previewLayer!.frame = cameraView.layer.bounds
        cameraView.layer.addSublayer(previewLayer!)
        
        session.startRunning()
        
        if session.canAddOutput(stillImageOutput) {
            stillImageOutput.isHighResolutionCaptureEnabled = true
            session.addOutput(stillImageOutput)
        }
        
    }
    
    @IBAction func onSwitch(_ sender: Any) {
        session.beginConfiguration()
        let currentInput = session.inputs[0]
        session.removeInput(currentInput)
        
        var switchedSide: AVCaptureDevice!
        if (currentInput as! AVCaptureDeviceInput).device.position == .front {
            switchedSide = getDeviceWithPosition(position: .back)
        } else {
            switchedSide = getDeviceWithPosition(position: .front)
        }
        input = try! AVCaptureDeviceInput(device: switchedSide!)
        
        session.addInput(input!)
        session.commitConfiguration()
        
    }
    
    func getDeviceWithPosition(position: AVCaptureDevice.Position) -> AVCaptureDevice {
        
        let discoverDevices = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera, .builtInTelephotoCamera, .builtInTrueDepthCamera, .builtInWideAngleCamera], mediaType: .video, position: position)
        
        return discoverDevices.devices[0]
    }
    
    @IBAction func onFlash(_ sender: Any) {
        flash = !flash
    }
    
    @IBAction func onCapture(_ sender: Any) {
        let photoSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey : AVVideoCodecType.jpeg])
        photoSettings.isHighResolutionPhotoEnabled = true
        if self.input!.device.isFlashAvailable {
            if flash {
                photoSettings.flashMode = .on
            } else {
                photoSettings.flashMode = .off
                
            }
        }
        if !photoSettings.availablePreviewPhotoPixelFormatTypes.isEmpty {
            photoSettings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: photoSettings.availablePreviewPhotoPixelFormatTypes.first!]
        }
        stillImageOutput.capturePhoto(with: photoSettings, delegate: self)
    }
    
    @IBAction func onCancel(_ sender: Any) {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        guard let id = segue.identifier else {
            return
        }
        
        switch id {
        case "postImageTakenSegue":
            let destination = segue.destination as! PostViewController
            let image = sender as! UIImage
            destination.image = resizeAndCrop(image: image, newSize: CGSize(width: 400, height: 400))
        default:
            break
        }
    }
    
    
}

extension PostImageCaptureViewController: AVCapturePhotoCaptureDelegate {
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        if let error = error {
            print(error.localizedDescription)
        }
        
        if let sampleBuffer = photoSampleBuffer, let previewBuffer = previewPhotoSampleBuffer, let dataImage = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: sampleBuffer, previewPhotoSampleBuffer: previewBuffer) {
            performSegue(withIdentifier: "postImageTakenSegue", sender: UIImage(data: dataImage)!)
        }
        
    }
}

