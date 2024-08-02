import Foundation
import AVFoundation
import AVFAudio
import ScreenCaptureKit
import CoreGraphics
import VideoToolbox

class Recorder: NSObject, SCStreamDelegate, SCStreamOutput {
	
	let encodingParams: [String: Any] = [
		AVFormatIDKey: kAudioFormatMPEG4AAC,
		AVSampleRateKey: 32000,
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
		
		print("Using \(display.description) as the main display")
		
		let filter = SCContentFilter(display: display, excludingApplications: [], exceptingWindows: [])
		
		stream = SCStream(filter: filter, configuration: streamConfiguration, delegate: self)
		do {
			print("Adding stream outputs")
			try stream.addStreamOutput(self, type: .screen, sampleHandlerQueue: .global())
			try stream.addStreamOutput(self, type: .audio, sampleHandlerQueue: .global())
			print("Starting stream capture")
			try await stream.startCapture()
		} catch {
			assertionFailure("Couldn't start stream capture.")
			return
		}
	}
	
	func startRecording(filename: String, directory: String) async throws {
		
		// construct a full fileURL from the two strings
		let directoryURL = URL(fileURLWithPath: directory)
		let fileURL = directoryURL.appendingPathComponent(filename)
		
		print("Starting recording to file: \(fileURL)")
		try await self.prepareStream()
		
		// Start audio writing
		await self.audioWriter(fileURL: fileURL)
	}
	
	func stopRecording() {
		print("Stopping recording")
		if stream != nil {
			stream.stopCapture()
		}
		stream = nil
		audioFile = nil
	}
	
	func audioWriter(fileURL: URL) async {
		print("Initializing audio writer for file: \(fileURL)")
		do {
			let format = AVAudioFormat(settings: encodingParams)
			guard let format = format else {
				print("Failed to create AVAudioFormat")
				return
			}
			audioFile = try AVAudioFile(forWriting: fileURL, settings: format.settings)
		} catch {
			print("Failed to create AVAudioFile: \(error.localizedDescription)")
			return
		}
	}
	
	func stream(_ stream: SCStream, didOutputSampleBuffer sampleBuffer: CMSampleBuffer, of type: SCStreamOutputType) {
		print("Received sample buffer of type: \(type)")
		
		guard type == .audio else {
			print("Ignoring non-audio sample buffer")
			return
		}
		
		guard sampleBuffer.isValid else {
			print("Invalid sample buffer")
			return
		}
		
		guard let formatDescription = sampleBuffer.formatDescription,
			  let asbd = formatDescription.audioStreamBasicDescription else {
			print("Failed to get audio format description")
			return
		}
		
		print("Audio format: \(asbd.mSampleRate) Hz, \(asbd.mChannelsPerFrame) channels, \(asbd.mBitsPerChannel) bits")
		
		guard let samples = sampleBuffer.asPCMBuffer else {
			print("Failed to convert sample buffer to PCM buffer")
			return
		}
		
		print("Successfully converted to PCM buffer with \(samples.frameLength) frames")
		
		do {
			try audioFile?.write(from: samples)
			print("Successfully wrote \(samples.frameLength) frames to audio file")
		} catch {
			print("Couldn't write samples: \(error.localizedDescription)")
		}
	}
	
	func stream(_ stream: SCStream, didStopWithError error: Error) {
		print("Stream stopped with error: \(error.localizedDescription)")
		self.stream = nil
		self.stopRecording()
	}
}

extension CMSampleBuffer {
	var asPCMBuffer: AVAudioPCMBuffer? {
		guard let formatDescription = self.formatDescription,
			  let asbd = formatDescription.audioStreamBasicDescription else {
			print("Failed to get audio stream basic description")
			return nil
		}
		
		var mutableASBD = asbd // Create a mutable copy
		let format = AVAudioFormat(streamDescription: &mutableASBD)
		
		guard let format = format else {
			print("Failed to create AVAudioFormat")
			return nil
		}
		
		guard let pcmBuffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: UInt32(self.numSamples)) else {
			print("Failed to create PCM buffer")
			return nil
		}
		
		pcmBuffer.frameLength = pcmBuffer.frameCapacity
		
		let audioBufferList = pcmBuffer.mutableAudioBufferList
		CMSampleBufferCopyPCMDataIntoAudioBufferList(self, at: 0, frameCount: Int32(pcmBuffer.frameCapacity), into: audioBufferList)
		
		return pcmBuffer
	}
}
