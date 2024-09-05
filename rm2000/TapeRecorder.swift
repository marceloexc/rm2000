import Foundation
import AVFoundation
import AVFAudio
import ScreenCaptureKit
import CoreGraphics
import VideoToolbox
import OSLog

class TapeRecorder: NSObject, SCStreamDelegate, SCStreamOutput {
	
	let encodingParams: [String: Any] = [
		AVFormatIDKey: kAudioFormatMPEG4AAC,
		AVSampleRateKey: 48000,	
		AVNumberOfChannelsKey: 2,
		AVEncoderBitRateKey: 128000
	]
	
	private var stream: SCStream!
	private var audioFile: AVAudioFile!
	var sessionStarted: Bool = false
	
	private func prepareStream() async throws {
		let streamConfiguration = SCStreamConfiguration()
		
		// every time we record the audio we also record the screen
		// so just make it the absolute bare minimum in terms of video quality
		streamConfiguration.width = 2
		streamConfiguration.height = 2
		
		streamConfiguration.minimumFrameInterval = CMTime(value: 1, timescale: CMTimeScale.max)
		streamConfiguration.showsCursor = true
		streamConfiguration.sampleRate = encodingParams["AVSampleRateKey"] as! Int
		streamConfiguration.channelCount = encodingParams["AVNumberOfChannelsKey"] as! Int
		streamConfiguration.capturesAudio = true
		
		let availableContent = try await SCShareableContent.current
		guard let display = availableContent.displays.first(where: { $0.displayID == CGMainDisplayID() }) else {
			throw NSError(domain: "RecordingError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Can't find display with ID \(CGMainDisplayID()) in sharable content"])
		}
		
		Logger.streamProcess.info("Using \(display.description) as the main display")
		
		let filter = SCContentFilter(display: display, excludingApplications: [], exceptingWindows: [])
		
		stream = SCStream(filter: filter, configuration: streamConfiguration, delegate: self)
		do {
			try stream.addStreamOutput(self, type: .audio, sampleHandlerQueue: .global())
			Logger.streamProcess.info("Starting stream capture")
			try await stream.startCapture()
		} catch {
			assertionFailure("Couldn't start stream capture.")
			return
		}
	}
	
	func startStream(filename: String, directory: String) async throws {
		
		// construct a full fileURL from the two strings
		let directoryURL = URL(fileURLWithPath: directory)
		let fileURL = directoryURL.appendingPathComponent(filename)
		
		Logger.streamProcess.info("Starting recording to file: \(fileURL)")
		try await self.prepareStream()
		
		// start audio writing
		await self.audioWriter(fileURL: fileURL)
	}
	
	func stopStream() {
		Logger.streamProcess.info("Stopping recording")
		if stream != nil {
			stream.stopCapture()
		}
		stream = nil
		audioFile = nil
	}
	
	func audioWriter(fileURL: URL) async {
		Logger.streamProcess.info("Initializing audio writer for file: \(fileURL)")
		do {
			audioFile = try AVAudioFile(forWriting: fileURL, settings: encodingParams, commonFormat: .pcmFormatFloat32, interleaved: false)
		} catch {
			Logger.streamProcess.error("Failed to create AVAudioFile: \(error.localizedDescription)")
			return
		}
	}
	
	func stream(_ stream: SCStream, didOutputSampleBuffer sampleBuffer: CMSampleBuffer, of type: SCStreamOutputType) {
		
		guard type == .audio else {
			Logger.streamProcess.warning("Recieved incompatible VIDEO stream type.")
			return
		}
		
//		Logger.streamProcess.debug("Received sample buffer of type: \(type.rawValue)")
		guard sampleBuffer.isValid else {
			Logger.streamProcess.warning("Invalid sample buffer")
			return
		}
		guard let samples = sampleBuffer.asPCMBuffer else {
			Logger.streamProcess.warning("Failed to convert sample buffer to PCM buffer")
			return
		}
		
		do {
			try audioFile?.write(from: samples)
		} catch {
			assertionFailure("Couldn't write samples: \(error.localizedDescription)")
		}
	}
	
	func stream(_ stream: SCStream, didStopWithError error: Error) {
		Logger.streamProcess.error("Stream stopped with error: \(error.localizedDescription)")
		self.stream = nil
		self.stopStream()
	}
}

extension CMSampleBuffer {
	var asPCMBuffer: AVAudioPCMBuffer? {
		try? self.withAudioBufferList { audioBufferList, _ -> AVAudioPCMBuffer? in
			guard let absd = self.formatDescription?.audioStreamBasicDescription else {
				Logger.streamProcess.error("Failed setting description for basic audio stream")
				return nil
			}
			guard let format = AVAudioFormat(standardFormatWithSampleRate: absd.mSampleRate, channels: absd.mChannelsPerFrame) else{
				Logger.streamProcess.error("Failed formatting the audio file with the set sample size of  \(absd.mSampleRate)")
				return nil
			}
			return AVAudioPCMBuffer(pcmFormat: format, bufferListNoCopy: audioBufferList.unsafePointer)
		}
	}
}
