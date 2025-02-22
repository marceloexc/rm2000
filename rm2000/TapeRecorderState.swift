import SwiftUI
import OSLog

class TapeRecorderState: ObservableObject, TapeRecorderDelegate {
	@Published var isRecording: Bool = false
	@Published var currentSampleFilename: String?
	@Published var showRenameDialogInMainWindow: Bool = false
	@Published var activeRecording: NewRecording?
	
	let recorder = TapeRecorder()
	
	init() {
		recorder.delegate = self
	}
	
	func startRecording() {
		Task {
			await MainActor.run {
				self.isRecording = true
			}
			
			let newRecording = NewRecording()
			currentSampleFilename = newRecording.fileURL.lastPathComponent
			self.activeRecording = newRecording 
			
			await recorder.startRecording(to: newRecording.fileURL)
		}
	}
	
	func stopRecording() {
		recorder.stopRecording()
		showRenameDialogInMainWindow = true
		Logger.sharedStreamState.info("showing edit sample sheet")
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
