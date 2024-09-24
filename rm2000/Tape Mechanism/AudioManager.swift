//
//  AudioManager.swift
//  rm2000
//
//  Created by Marcelo Mendez on 9/23/24.
//

import Foundation
import AVFAudio
import OSLog

class AudioManager {
	
	func setupAudioWriter(fileURL: URL) throws {
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
	
	private var audioFile: AVAudioFile?
  
	private let encodingParams: [String: Any] = [
		AVFormatIDKey: kAudioFormatMPEG4AAC,
		AVSampleRateKey: 48000,
		AVNumberOfChannelsKey: 2,
		AVEncoderBitRateKey: 128000
	]
}
