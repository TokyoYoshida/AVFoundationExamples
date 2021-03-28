//
//  FrameRecordingViewController.swift
//  RecordingVideoExample
//
//  Created by TokyoYoshida on 2021/03/27.
//

import UIKit
import AVFoundation

class FrameRecordingViewController: UIViewController {
    @IBOutlet weak var recordingButton: UIButton!
    let videoRecorder =  FrameVideoRecorder()
    
    override func viewDidLoad() {
        func setupVideoRecorder() {
            do {
                try videoRecorder.prepare()
            } catch {
                fatalError("Cannot prepare video recoreder.")
            }
        }
        func setupPreview() {
            let videoLayer : AVCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: videoRecorder.captureSession)
            videoLayer.frame = self.view.bounds
            videoLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
            self.view.layer.insertSublayer(videoLayer, at: 0)
        }
        super.viewDidLoad()
        setupVideoRecorder()
        setupPreview()
    }

    @IBAction func tappedRecordingButton(_ sender: Any) {
        func buildURL() -> URL {
            let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
            let documentsDirectory = paths[0] as String
            let filePath : String = "\(documentsDirectory)/temp.mp4"
            
            return URL(fileURLWithPath: filePath)
        }
        func displaySaveVideoMessage() {
            let alertController = UIAlertController(title: "Save",
                                               message: "Save to library.",
                                               preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK",
                                                   style: .default,
                                                   handler: nil))
            present(alertController, animated: true)
        }
        func startRecording() {
            recordingButton.setTitle("Stop", for: .normal)
            let url = buildURL()
            videoRecorder.startRecording(fileURL: url) {
                (completed ,error) in
                DispatchQueue.main.async {
                    self.recordingButton.setTitle("Record", for: .normal)
                    displaySaveVideoMessage()
                }
            }
        }
        func stopRecording() {
            self.videoRecorder.stopRecording()
        }
        if videoRecorder.isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }
}

