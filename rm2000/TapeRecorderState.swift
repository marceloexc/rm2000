import SwiftUI
import OSLog

class TapeRecorderState: ObservableObject, TapeRecorderDelegate {
	@Published var isRecording: Bool = false
	@Published var currentSampleFilename: String?
	@Published var showRenameDialogInMainWindow: Bool = false
	@Published var stagedSample: StagedSample?
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
			currentSampleFilename = newRecording.url.lastPathComponent
			self.activeRecording = newRecording 
			
			await recorder.startRecording(to: newRecording.url)
		}
	}
	
	func stopRecording() {
		recorder.stopRecording()
		showRenameDialogInMainWindow = true
		Logger.sharedStreamState.info("showing edit sample sheet")
	}
	
	func constructSampleFilename(from stagedSample: StagedSample) -> String {
		let title = stagedSample.title ?? "Untitled"
		let tags = stagedSample.tags ?? ""

		let formattedTags = tags.replacingOccurrences(of: " ", with: "_")

		// Construct the filename in the format "title--tag1_tag2_tag3.aac"
		let filename = "\(title)--\(formattedTags).aac"
		return filename
	}
		
//	TODO - does this belong in taperecorderstate?
//	TODO - change the args for this (from StagedSample to NewSample)
	func applySampleEdits(from stagedSample: StagedSample) {
		guard let oldFilename = currentSampleFilename else {
			Logger.sharedStreamState.error("No current recording to rename!")
			return
		}
	
		let newFilename = constructSampleFilename(from: stagedSample)
		let newURL = stagedSample.fileURL.deletingLastPathComponent().appendingPathComponent(newFilename)

		// Move the file to the new location
		
		let fileManager = FileManager.default
		do {
			try fileManager.moveItem(at: stagedSample.fileURL, to: newURL)
			Logger.sharedStreamState.info("Renamed recording from \(stagedSample.fileURL) to \(newURL)")
		} catch {
			Logger.sharedStreamState.error("Failed to rename file: \(error.localizedDescription)")
		}
		
		showRenameDialogInMainWindow = false
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
