import Foundation
import SwiftUI

class TapeRecorderState: ObservableObject {
	@Published var isRecording: Bool = false
	let recorder = TapeRecorder()
	
	func startRecording(filename: String, directory: String) {
		Task {
			do {
				try await recorder.startStream(filename: filename, directory: directory)
				DispatchQueue.main.async {
					self.isRecording = true
				}
			} catch {
				print("Error starting recording: \(error) ")
			}
		}
	}
	
	func stopRecording() {
		Task {
			recorder.stopStream()
			DispatchQueue.main.async {
				self.isRecording = false
			}
		}
	}
}
