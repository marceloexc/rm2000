import Foundation
import AVFoundation
import AVFAudio
import ScreenCaptureKit
import CoreGraphics
import VideoToolbox
import OSLog

// MARK: - TapeRecorderDelegate

protocol TapeRecorderDelegate: AnyObject {
	func tapeRecorderDidStartRecording(_ recorder: TapeRecorder)
	func tapeRecorderDidStopRecording(_ recorder: TapeRecorder)
	func tapeRecorder(_ recorder: TapeRecorder, didEncounterError error: Error)
}

// MARK: - TapeRecorder

class TapeRecorder: NSObject {
  
	// MARK: - Properties
  
	weak var delegate: TapeRecorderDelegate?
  
	private let streamManager: StreamManager
	private let audioManager: AudioManager
  
	private(set) var isRecording: Bool = false
  
	// MARK: - Initialization
  
	override init() {
		self.streamManager = StreamManager()
		self.audioManager = AudioManager()
		super.init()
	  
		self.streamManager.delegate = self
	}
  
	// MARK: - Public Methods
  
	func startRecording(filename: String, directory: String) async {
		guard !isRecording else {
			Logger.tapeRecorder.warning("Recording is already in progress")
			return
		}
	  
		let directoryURL = URL(fileURLWithPath: directory)
		let fileURL = directoryURL.appendingPathComponent(filename)
	  
		do {
			try await streamManager.prepareStream()
			try audioManager.prepareAudioWriter(fileURL: fileURL)
			try streamManager.startCapture()
		  
			isRecording = true
			delegate?.tapeRecorderDidStartRecording(self)
			Logger.tapeRecorder.info("Started recording to file: \(fileURL)")
		} catch {
			delegate?.tapeRecorder(self, didEncounterError: error)
			Logger.tapeRecorder.error("Failed to start recording: \(error.localizedDescription)")
		}
	}
  
	func stopRecording() {
		guard isRecording else {
			Logger.tapeRecorder.warning("No active recording to stop")
			return
		}
	  
		streamManager.stopCapture()
		audioManager.stopAudioWriter()
	  
		isRecording = false
		delegate?.tapeRecorderDidStopRecording(self)
		Logger.tapeRecorder.info("Stopped recording")
	}
}

// MARK: - StreamManagerDelegate

extension TapeRecorder: StreamManagerDelegate {
	func streamManager(_ manager: StreamManager, didOutputSampleBuffer sampleBuffer: CMSampleBuffer, of type: SCStreamOutputType) {
		guard type == .audio else { return }
	  
		audioManager.writeSampleBuffer(sampleBuffer)
	}
  
	func streamManager(_ manager: StreamManager, didStopWithError error: Error) {
		stopRecording()
		delegate?.tapeRecorder(self, didEncounterError: error)
	}
}

// MARK: - StreamManager

class StreamManager: NSObject, SCStreamDelegate {
  
	// MARK: - Properties
  
	weak var delegate: StreamManagerDelegate?
	private var stream: SCStream?
  
	// MARK: - Public Methods
  
	func prepareStream() async throws {
		let streamConfiguration = SCStreamConfiguration()
		streamConfiguration.width = 2
		streamConfiguration.height = 2
		streamConfiguration.minimumFrameInterval = CMTime(value: 1, timescale: CMTimeScale.max)
		streamConfiguration.showsCursor = true
		streamConfiguration.sampleRate = 48000
		streamConfiguration.channelCount = 2
		streamConfiguration.capturesAudio = true
	  
		let availableContent = try await SCShareableContent.current
		guard let display = availableContent.displays.first(where: { $0.displayID == CGMainDisplayID() }) else {
			throw NSError(domain: "RecordingError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Can't find display with ID \(CGMainDisplayID()) in sharable content"])
		}
	  
		let filter = SCContentFilter(display: display, excludingApplications: [], exceptingWindows: [])
		stream = SCStream(filter: filter, configuration: streamConfiguration, delegate: self)
	}
  
	func startCapture() throws {
		guard let stream = stream else {
			throw NSError(domain: "RecordingError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Stream not prepared"])
		}
	  
		try stream.addStreamOutput(self, type: .audio, sampleHandlerQueue: .global())
		try stream.startCapture()
	}
  
	func stopCapture() {
		stream?.stopCapture()
		stream = nil
	}
  
	// MARK: - SCStreamDelegate
  
	func stream(_ stream: SCStream, didStopWithError error: Error) {
		delegate?.streamManager(self, didStopWithError: error)
	}
}

// MARK: - StreamManagerDelegate

protocol StreamManagerDelegate: AnyObject {
	func streamManager(_ manager: StreamManager, didOutputSampleBuffer sampleBuffer: CMSampleBuffer, of type: SCStreamOutputType)
	func streamManager(_ manager: StreamManager, didStopWithError error: Error)
}

// MARK: - SCStreamOutput

extension StreamManager: SCStreamOutput {
	func stream(_ stream: SCStream, didOutputSampleBuffer sampleBuffer: CMSampleBuffer, of type: SCStreamOutputType) {
		delegate?.streamManager(self, didOutputSampleBuffer: sampleBuffer, of: type)
	}
}

// MARK: - AudioManager

class AudioManager {
  
	// MARK: - Properties
  
	private var audioFile: AVAudioFile?
  
	private let encodingParams: [String: Any] = [
		AVFormatIDKey: kAudioFormatMPEG4AAC,
		AVSampleRateKey: 48000,
		AVNumberOfChannelsKey: 2,
		AVEncoderBitRateKey: 128000
	]
  
	// MARK: - Public Methods
  
	func prepareAudioWriter(fileURL: URL) throws {
		audioFile = try AVAudioFile(forWriting: fileURL, settings: encodingParams, commonFormat: .pcmFormatFloat32, interleaved: false)
	}
  
	func writeSampleBuffer(_ sampleBuffer: CMSampleBuffer) {
		guard sampleBuffer.isValid, let samples = sampleBuffer.asPCMBuffer else {
			Logger.audioManager.warning("Invalid sample buffer or conversion failed")
			return
		}
	  
		do {
			try audioFile?.write(from: samples)
		} catch {
			Logger.audioManager.error("Couldn't write samples: \(error.localizedDescription)")
		}
	}
  
	func stopAudioWriter() {
		audioFile = nil
	}
}

// MARK: - CMSampleBuffer Extension

extension CMSampleBuffer {
	var asPCMBuffer: AVAudioPCMBuffer? {
		try? self.withAudioBufferList { audioBufferList, _ -> AVAudioPCMBuffer? in
			guard let absd = self.formatDescription?.audioStreamBasicDescription else {
				Logger.audioManager.error("Failed setting description for basic audio stream")
				return nil
			}
			guard let format = AVAudioFormat(standardFormatWithSampleRate: absd.mSampleRate, channels: absd.mChannelsPerFrame) else {
				Logger.audioManager.error("Failed formatting the audio file with the set sample size of \(absd.mSampleRate)")
				return nil
			}
			return AVAudioPCMBuffer(pcmFormat: format, bufferListNoCopy: audioBufferList.unsafePointer)
		}
	}
}

// MARK: - Logger Extension

extension Logger {
	static let tapeRecorder = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "TapeRecorder")
	static let streamManager = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "StreamManager")
	static let audioManager = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "AudioManager")
}
