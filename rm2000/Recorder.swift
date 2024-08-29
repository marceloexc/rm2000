import Foundation
import AVFoundation
import AVFAudio
import ScreenCaptureKit
import CoreGraphics
import VideoToolbox

class Recorder: NSObject, SCStreamDelegate, SCStreamOutput {
	
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
		
		print("Using \(display.description) as the main display")
		
		let filter = SCContentFilter(display: display, excludingApplications: [], exceptingWindows: [])
		
		stream = SCStream(filter: filter, configuration: streamConfiguration, delegate: self)
		do {
			print("Adding stream outputs")
//			try stream.addStreamOutput(self, type: .screen, sampleHandlerQueue: .global())
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
		
		// start audio writing
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
			audioFile = try AVAudioFile(forWriting: fileURL, settings: encodingParams, commonFormat: .pcmFormatFloat32, interleaved: false)
		} catch {
			print("Failed to create AVAudioFile: \(error.localizedDescription)")
			return
		}
	}
	
	func stream(_ stream: SCStream, didOutputSampleBuffer sampleBuffer: CMSampleBuffer, of type: SCStreamOutputType) {
		
		print("stream..")
		guard type == .audio else {
			print("recieved video type - we don't want this!")
			return
		}
		
		print("Received sample buffer of type: \(type)")
		guard sampleBuffer.isValid else {
			print("Invalid sample buffer")
			return
		}
		guard let samples = sampleBuffer.asPCMBuffer else {
			print("Failed to convert sample buffer to PCM buffer")
			return
		}
		
		do {
			try audioFile?.write(from: samples)
		} catch {
			assertionFailure("Couldn't write samples: \(error.localizedDescription)")
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
		try? self.withAudioBufferList { audioBufferList, _ -> AVAudioPCMBuffer? in
			guard let absd = self.formatDescription?.audioStreamBasicDescription else {
				print("failed absd")
				return nil
			}
			guard let format = AVAudioFormat(standardFormatWithSampleRate: absd.mSampleRate, channels: absd.mChannelsPerFrame) else{
				print("failed format")
				return nil
			}
			return AVAudioPCMBuffer(pcmFormat: format, bufferListNoCopy: audioBufferList.unsafePointer)
		}
	}
}
