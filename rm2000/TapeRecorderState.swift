import SwiftUI
import OSLog

class TapeRecorderState: ObservableObject, TapeRecorderDelegate {
	@Published var isRecording: Bool = false
	@Published var currentSampleFilename: String?
	@Published var showRenameDialogInMainWindow: Bool = false
	
	let recorder = TapeRecorder()
	
	init() {
		recorder.delegate = self
	}
	
	func startRecording() {
		Task {
			await MainActor.run {
				self.isRecording = true
			}
			
			let recording = StagedSample()
			currentSampleFilename = recording.getFilepath().lastPathComponent
			
			await recorder.startRecording(to: recording.getFilepath())
		}
	}
	
	func stopRecording() {
		recorder.stopRecording()
		showRenameDialogInMainWindow = true
	}
		
//	TODO - does this belong in taperecorderstate?
//	TODO - change the args for this (from StagedSample to NewSample)
	func applySampleEdits(to newTitle: String, newTags: String) {
		guard let oldFilename = currentSampleFilename else {
			Logger.sharedStreamState.error("No current recording to rename!")
			return
		}
		
		let newSampleMetadata = newSampleFilenameData(newTitle, newTags)
	
		Logger.sharedStreamState.info("New Sample Metadata listed as: \(newSampleMetadata.title) \(newSampleMetadata.tags) \(newSampleMetadata.fileExtension)")
		
		let stringedTagPiece = newSampleMetadata.tags.joined(separator: "_")
		
		let newFilename = "\(newSampleMetadata.title)--\(stringedTagPiece).\(newSampleMetadata.fileExtension)"
				
		let fileManager = FileManager.default
		let appSupportURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
		let baseDirectory = appSupportURL.appendingPathComponent("com.marceloexc.rm2000")
		
		let oldURL = baseDirectory.appendingPathComponent(oldFilename)
		let newURL = baseDirectory.appendingPathComponent(newFilename)
		
		do {
			try fileManager.moveItem(at: oldURL, to: newURL)
			
			currentSampleFilename = newTitle

			Logger.sharedStreamState.info("Renamed recording from \(oldURL) to \(newURL)")
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
