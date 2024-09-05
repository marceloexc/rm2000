import SwiftUI
import OSLog

struct ContentView: View {
	@EnvironmentObject private var recordingState: TapeRecorderState
	@State var fileDirectory: String = "/Users/marceloexc/Downloads/"
	@State var textToRecord: String = "recording.aac"
	
	var body: some View {
		VStack {
			Image(systemName: "waveform.circle.fill")
				.imageScale(.large)
				.foregroundStyle(.tint)
			Text("rm2000")
				.font(.title)
			
			TextField("Enter directory here", text: self.$fileDirectory)
				.textFieldStyle(.roundedBorder)
			
			TextField("Enter text to record", text: $textToRecord)
				.textFieldStyle(.roundedBorder)
			
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
	}
	
	private func startRecording() {
		recordingState.startRecording(filename: textToRecord, directory: fileDirectory)
	}
	
	private func stopRecording() {
		recordingState.stopRecording()
	}
}

struct MenuBarView: View {
	@EnvironmentObject private var recordingState: TapeRecorderState
	@Environment(\.openWindow) private var openWindow
	
	var body: some View {
		Text("RM2000 Public Beta")
		Divider()
		Button("Open") {
			openWindow(id: "main-window")
		}
		Button(recordingState.isRecording ? "Stop Recording" : "Start Recording") {
			if recordingState.isRecording {
				Logger.sharedStreamState.info("Changing state in the menubar")
				recordingState.stopRecording()
			} else {
				recordingState.startRecording(filename: "default.aac", directory: "/Users/marceloexc/Downloads/")
			}
		}
		Divider()
		Button("Quit RM2000") {
			NSApplication.shared.terminate(nil)
		}.keyboardShortcut("q")
	}
}

#Preview {
	ContentView()
		.environmentObject(TapeRecorderState())
}
