//
//  VideoRecorder.swift
//  RecordingVideoExample
//
//  Created by TokyoYoshida on 2021/03/27.
//

import Foundation
import AVFoundation
import Photos

class FrameVideoRecorder: NSObject {
    fileprivate let videoDevice = AVCaptureDevice.default(for: AVMediaType.video)
    fileprivate let audioDevice = AVCaptureDevice.default(for: AVMediaType.audio)
    let captureSession = AVCaptureSession()
    fileprivate let fileOutput = AVCaptureMovieFileOutput()
    fileprivate var completionHandler: ((Bool, Error?) -> Void)?
    var isRecording: Bool {
        get {
            fileOutput.isRecording
        }
    }
    
    func prepare() throws {
        func connectInputAndOutput() throws {
            let videoInput = try AVCaptureDeviceInput(device: videoDevice!)
            captureSession.addInput(videoInput)
            
            let audioInput = try AVCaptureDeviceInput(device: audioDevice!)
                captureSession.addInput(audioInput)
        }
        func setCameraImageQuality() {
            captureSession.sessionPreset = AVCaptureSession.Preset.photo
        }
        if videoDevice == nil || audioDevice == nil {
            fatalError("Device cannot initialize.")
        }
        
        try connectInputAndOutput()
        setCameraImageQuality()
        captureSession.addOutput(fileOutput)
        captureSession.startRunning()
    }
    
    func startRecording(fileURL: URL, completionHandler: @escaping ((Bool, Error?) -> Void)) {
        self.completionHandler = completionHandler
        fileOutput.startRecording(to: fileURL as URL, recordingDelegate: self)
    }
    
    func stopRecording() {
        fileOutput.stopRecording()
    }
}

extension FrameVideoRecorder: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        func saveToLibrary() {
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputFileURL)
            }) { [weak self] completed, error in
                self?.completionHandler?(completed ,error)
            }
        }
        saveToLibrary()
    }
}
