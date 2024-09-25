import SwiftUI
import OSLog

class TapeRecorderState: ObservableObject, TapeRecorderDelegate {
	@Published var isRecording: Bool = false
	let recorder = TapeRecorder()
	
	init() {
		recorder.delegate = self
	}
	
	func startRecording() {
		Task {
			await MainActor.run {
				// Set isRecording to true immediately to update UI
				self.isRecording = true
			}
			
			let fileManager = FileManager.default
			let appSupportURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
			
			let directoryURL = appSupportURL.appendingPathComponent("com.marceloexc.rm2000")
			
			try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
			
			print(UUID().uuidString + ".aac")
			
			let fileName = UUID().uuidString + ".aac"
			
			print("The directory:", directoryURL.absoluteString)
			
			print("the filename: ", fileName)
			
			await recorder.startRecording(filename: fileName, directory: directoryURL)
		}
	}
	
	func stopRecording() {
		recorder.stopRecording()
	}
		
	func tapeRecorderDidStartRecording(_ recorder: TapeRecorder) {
		// This might not be necessary if we set isRecording to true in startRecording
	}
	
	func tapeRecorderDidStopRecording(_ recorder: TapeRecorder) {
		Task { @MainActor in
			self.isRecording = false
		}
	}
	
	func tapeRecorder(_ recorder: TapeRecorder, didEncounterError error: Error) {
		Task { @MainActor in
			self.isRecording = false
			Logger.sharedStreamState.error("Recording error: \(error.localizedDescription)")
			// You might want to update UI or show an alert here
		}
	}
}
