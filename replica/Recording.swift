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
	private var streamOutput: SCStreamOutput?
	
	func startRecording(filename: String, directory: String) async throws {
		
		// construct a full fileURL from the two strings
		let directoryURL = URL(fileURLWithPath: directory)
		let fileURL = directoryURL.appendingPathComponent(filename)
		
		// should now look something like file:///Users/Johnny/Downloads/Now%20recording
		assetWriter = try AVAssetWriter(outputURL: fileURL, fileType: .mov)
		print("Successfully created AVAssetWriter for \(fileURL)")
		
		let videoSettings: [String: Any] = [
			AVVideoCodecKey: AVVideoCodecType.h264,
			AVVideoWidthKey: 1920,
			AVVideoHeightKey: 1080,
			AVVideoCompressionPropertiesKey: [
				AVVideoAverageBitRateKey: 6000000,
				AVVideoProfileLevelKey: AVVideoProfileLevelH264HighAutoLevel
			]
		]
		
		videoInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings)
		
		guard assetWriter!.canAdd(videoInput!) else {
			print("Cannot add video input to asset writer")
			return
		}
		
		assetWriter?.add(videoInput!)
		
		assetWriter?.startWriting()
		
		// start session
		let now = CMClockGetTime(CMClockGetHostTimeClock())
		assetWriter?.startSession(atSourceTime: now)
		
		// set up configuration for the stream
		let configuration = SCStreamConfiguration()
		configuration.width = 1920
		configuration.height = 1080
		configuration.minimumFrameInterval = CMTime(value: 1, timescale: 30) // 30fps for now
		configuration.pixelFormat = kCVPixelFormatType_32BGRA
		
		// getting the main display
		
		// sometimes, this will never execute nor return an error code or anything.
		// to fix this, i have to kill `replayd` from activity monitor
		// and then on the next run it will start working.
		// i have no idea why this happens
		
		let availableContent = try await SCShareableContent.current
		guard let display = availableContent.displays.first(where: { $0.displayID == CGMainDisplayID() }) else {
			throw NSError(domain:"RecordingError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Can't find display with ID \(CGMainDisplayID() ) in sharable content"])
		}
		
		print("Using \(display.description) as the main display")
		
		let filter = SCContentFilter(display: display, excludingWindows: [])
		
		let streamDelegate = ScreenRecorderDelegate(assetWriter: assetWriter!, videoInput: videoInput!)
		
		stream = SCStream(filter: filter, configuration: configuration, delegate: streamDelegate)
		
		try stream?.addStreamOutput(streamDelegate, type: .screen, sampleHandlerQueue: DispatchQueue.global(qos: .userInitiated))
		
		try await stream?.startCapture()
		
		print("Screen recording started!")
	}
	
	func stopRecording() async throws {
		try await stream?.stopCapture()
		stream = nil
		videoInput?.markAsFinished()
		assetWriter?.endSession(atSourceTime: <#T##CMTime#>)
		await assetWriter?.finishWriting()
		assetWriter = nil
		videoInput = nil
		print("Ordered screen recording to stop")
	}
}

class ScreenRecorderDelegate: NSObject, SCStreamDelegate, SCStreamOutput {
	var assetWriter: AVAssetWriter
	var videoInput: AVAssetWriterInput
//	var lastSampleBuffer: CMSampleBuffer?
	
	init(assetWriter: AVAssetWriter, videoInput: AVAssetWriterInput) {
		self.assetWriter = assetWriter
		self.videoInput = videoInput
	}
	
	func stream(_ stream: SCStream, didOutputSampleBuffer sampleBuffer: CMSampleBuffer, of type: SCStreamOutputType) {
		guard type == .screen, videoInput.isReadyForMoreMediaData else { return }
		if !videoInput.append(sampleBuffer) {
			print("Failed to append sample buffer")
		}
	}
}
