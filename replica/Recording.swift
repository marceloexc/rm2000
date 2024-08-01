//
//  Recording.swift
//  replica
//
//  Created by Marcelo Mendez on 7/16/24.
//

import Foundation
import AVFoundation
import ScreenCaptureKit
import CoreGraphics
import VideoToolbox


class RecordingManager: ObservableObject {
	
	private var stream: SCStream?
	private var assetWriter: AVAssetWriter?
	private var videoInput: AVAssetWriterInput?
	
	func startRecording(filename: String, directory: String) async throws {
		
		let fullFilename: String = directory + filename
				
		// Construct a full fileURL from the two strings
		let directoryURL = URL(fileURLWithPath: directory)
		let fileURL = directoryURL.appendingPathComponent(filename)
		// Should now look something like file:///Users/Johnny/Downloads/Now%20recording
				
		assetWriter = try AVAssetWriter(outputURL: fileURL, fileType: .mov)
		print("Successfully created AVAssetWriter for \(fileURL)")
		
		videoInput = AVAssetWriterInput(mediaType: .video, outputSettings: nil)
		
		assetWriter?.add(videoInput!)
		assetWriter?.startWriting()
		
		// Start session
		
		let now = CMClockGetTime(CMClockGetHostTimeClock())
		assetWriter?.startSession(atSourceTime: now)
		
		// Get everything ready for SCStream
		
		// Set up configuration for the stream
		let configuration = SCStreamConfiguration()
		configuration.width = 1920
		configuration.height = 1080
		configuration.minimumFrameInterval = CMTime(value: 1, timescale: 30) // 30fps for now
		configuration.pixelFormat = kCVPixelFormatType_32BGRA
		
		// Getting the main display
		
		let availableContent = try await SCShareableContent.excludingDesktopWindows(false, onScreenWindowsOnly: true)
		
		// Still learning Swift: gets mad if I don't wrap it like this. Safety is key in this language
		guard let display = availableContent.displays.first else {
			throw NSError(domain:"RecordingError", code: 1, userInfo: [NSLocalizedDescriptionKey: "No displays available"])
		}
		
		let filter = SCContentFilter(display: display, excludingWindows: [])
		
		let streamDelegate = ScreenRecorderDelegate(assetWriter: assetWriter!, videoInput: videoInput!)
		
		stream = SCStream(filter: filter, configuration: configuration, delegate: streamDelegate)
		
		// TODO: what does THIS DO?
		try stream?.addStreamOutput(streamDelegate, type: .screen, sampleHandlerQueue: DispatchQueue.global(qos: .userInitiated))
		
		try await stream!.startCapture()
		
		print("Screen recording started!")
	}
	
	func stopRecording() async throws {
		try await stream?.stopCapture()
		stream = nil
		videoInput?.markAsFinished()
		await assetWriter?.finishWriting()
		assetWriter = nil
		videoInput = nil
		print("Ordered screen recording to stop")
	}
}

class ScreenRecorderDelegate: NSObject, SCStreamDelegate, SCStreamOutput {
	var assetWriter: AVAssetWriter
	var videoInput: AVAssetWriterInput
	
	init(assetWriter: AVAssetWriter, videoInput: AVAssetWriterInput) {
		self.assetWriter = assetWriter
		self.videoInput = videoInput
	}
	
	// What does THIS do?
	func stream(_ stream: SCStream, didOutputSampleBuffer sampleBuffer: CMSampleBuffer, of type: SCStreamOutputType) {
		guard type == .screen, videoInput.isReadyForMoreMediaData else { return }
		videoInput.append(sampleBuffer)
	}
}
