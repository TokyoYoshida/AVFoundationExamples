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
    let recordingQueue =  DispatchQueue(label: "FrameRecordingQueue")
    
    var isRecording: Bool {
        get {
            fileOutput.isRecording
        }
    }
    
    func prepare() throws {
        func connectInput() throws {
            let videoInput = try AVCaptureDeviceInput(device: videoDevice!)
            captureSession.addInput(videoInput)
            
            let audioInput = try AVCaptureDeviceInput(device: audioDevice!)
                captureSession.addInput(audioInput)
        }
        func connectOutput() {
            let videoDataOutput = AVCaptureVideoDataOutput()
            videoDataOutput.setSampleBufferDelegate(self, queue: self.recordingQueue)
            videoDataOutput.alwaysDiscardsLateVideoFrames = true
            videoDataOutput.videoSettings = [
                kCVPixelBufferPixelFormatTypeKey as String : kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange
            ]
            self.captureSession.addOutput(videoDataOutput)
            
            let audioDataOutput = AVCaptureAudioDataOutput()
            audioDataOutput.setSampleBufferDelegate(self, queue: self.recordingQueue)
            self.captureSession.addOutput(audioDataOutput)

            self.captureSession.startRunning()
        }
        func setCameraImageQuality() {
            captureSession.sessionPreset = AVCaptureSession.Preset.photo
        }
        if videoDevice == nil || audioDevice == nil {
            fatalError("Device cannot initialize.")
        }
        
        try connectInput()
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


extension FrameVideoRecorder: AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate {
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!) {
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
