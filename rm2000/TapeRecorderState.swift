import SwiftUI
import OSLog

class TapeRecorderState: ObservableObject, TapeRecorderDelegate {
	@Published var isRecording: Bool = false
	@Published var currentSampleFile: String?
	
	let recorder = TapeRecorder()
	
	init() {
		recorder.delegate = self
	}
	
	func startRecording() {
		Task {
			await MainActor.run {
				self.isRecording = true
			}
			
			let tempFilename = UUID().uuidString + ".aac"
			
			let fileManager = FileManager.default
			let appSupportURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
			let directoryURL = appSupportURL.appendingPathComponent("com.marceloexc.rm2000")
			try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true)
			let fileURL = directoryURL.appendingPathComponent(tempFilename)
			currentSampleFile = tempFilename
			
			await recorder.startRecording(to: fileURL)
		}
	}
	
	func stopRecording() {
		recorder.stopRecording()
	}
		
//	TODO - does this belong in taperecorderstate?
	func renameRecording(to newFilename: String) {
		guard let oldFilename = currentSampleFile else {
			Logger.sharedStreamState.error("No current recording to rename!")
			return
		}
		
		let fileManager = FileManager.default
		let appSupportURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
		let baseDirectory = appSupportURL.appendingPathComponent("com.marceloexc.rm2000")
		
		let oldURL = baseDirectory.appendingPathComponent(oldFilename)
		let newURL = baseDirectory.appendingPathComponent(newFilename)
		
		do {
			
			try fileManager.moveItem(at: oldURL, to: newURL)
			currentSampleFile = newFilename
			Logger.sharedStreamState.info("Renamed recording from \(oldURL) to \(newURL)")
			
		} catch {
			Logger.sharedStreamState.error("Failed to rename file")
		}
		
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
