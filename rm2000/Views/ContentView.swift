import SwiftUI
import OSLog

struct ContentView: View {
	@EnvironmentObject private var recordingState: TapeRecorderState
	@State private var showingRenameSheet = false
	@State private var newSampleFilename: String = ""
	@State private var newSampleTags: String = ""

	var body: some View {
		ZStack {
			Color(red: 0.999, green: 0.664, blue: 0.083)
				.ignoresSafeArea()
			VStack {
				Image(systemName: "waveform.circle.fill")
					.imageScale(.large)
					.foregroundStyle(.tint)
				Text("rm2000")
					.font(.title)

				if recordingState.isRecording {
					Button(action: stopRecording) {
						HStack {
							Image(systemName: "stop.circle")
							Text("Stop Recording")
						}
					}
					.foregroundColor(.red)
					let _ = Logger.sharedStreamState.info("Changing state in the main window")
				} else {
					Button(action: startRecording) {
						HStack {
							Image(systemName: "recordingtape")
							Text("Start Recording!")
						}
					}.cornerRadius(3.0)
				}
			}
			.sheet(isPresented: $showingRenameSheet, content: {
				RenameView(currentFilename: recordingState.currentSampleFilename ?? "", 
						   newSampleFilename: $newSampleFilename,
						   newSampleTags: $newSampleTags,
						   onRename: renameRecording)
			})
		}
	}
	
	private func startRecording() {
		recordingState.startRecording()
	}
	
	private func stopRecording() {
		recordingState.stopRecording()
		showingRenameSheet = true
	}
	
	private func renameRecording() {
		recordingState.renameRecording(to: newSampleFilename, newTags: newSampleTags)
		showingRenameSheet = false
	}
}

#Preview {
	ContentView()
		.environmentObject(TapeRecorderState())
}
