//
//  Extensions.swift
//  rm2000
//
//  Created by Marcelo Mendez on 9/23/24.
//

import OSLog
import Foundation
import CoreMedia
import AVFAudio

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

extension Logger {
	static let tapeRecorder = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "TapeRecorder")
	static let streamManager = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "StreamManager")
	static let audioManager = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "AudioManager")
}
