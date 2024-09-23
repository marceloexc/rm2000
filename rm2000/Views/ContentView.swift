import SwiftUI
import OSLog

struct ContentView: View {
	@EnvironmentObject private var recordingState: TapeRecorderState
	@State var fileDirectory: String = "/Users/marceloexc/Downloads/"
	@State var textToRecord: String = "recording.aac"
	@State private var showingPopover = false
	@State private var showingSheet = false

	var body: some View {
		ZStack {
			Color(red: 0.999, green: 0.664, blue: 0.083)
				.ignoresSafeArea()
			VStack {
				Button("Show popup") {
					showingSheet = true
				}
				.popover(isPresented: $showingSheet, content: {
					Text("Your content here")
						.font(.headline)
						.padding()
				})
				
				Button("Show sheet") {
					showingPopover.toggle()
				}
				.sheet(isPresented: $showingPopover, content: {
					Text("Your content here")
						.font(.headline)
						.padding()
				})
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
	}
	
	private func startRecording() {
		recordingState.startRecording(filename: textToRecord, directory: fileDirectory)
	}
	
	private func stopRecording() {
		recordingState.stopRecording()
	}
}

#Preview {
	ContentView()
		.environmentObject(TapeRecorderState())
}
