import SwiftUI
import OSLog

struct ContentView: View {
	@EnvironmentObject private var recordingState: TapeRecorderState
	@State private var newSampleTitle: String = ""
	@State private var newSampleTags: String = ""

	var body: some View {
		ZStack {
			Image("BodyBackgroundTemp")
				.scaledToFill()
			VStack {
				LCDScreenView()
				if recordingState.isRecording {
								Button(action: stopRecording) {
									Image("RecordButtonActiveTemp")
										.renderingMode(.original)
								}
								.buttonStyle(BorderlessButtonStyle())
								let _ = Logger.sharedStreamState.info("Changing state in the main window")
				} else {
					Button(action: startRecording) {
						Image("RecordButtonTemp")
					 .renderingMode(.original)
				 }.buttonStyle(BorderlessButtonStyle())
				}
			}
			.sheet(isPresented: $recordingState.showRenameDialogInMainWindow, content: {
				RenameView(currentFilename: recordingState.currentSampleFilename ?? "",
						   inputNewSampleFilename: $newSampleTitle,
						   inputNewSampleTags: $newSampleTags,
						   onRename: renameRecording)
			})
		}
	}
	
	private func startRecording() {
		recordingState.startRecording()
	}
	
	private func stopRecording() {
		recordingState.stopRecording()
	}
	
	private func renameRecording() {
		recordingState.renameRecording(to: newSampleTitle, newTags: newSampleTags)
	}
}

struct LCDScreenView: View {
	@EnvironmentObject private var recordingState: TapeRecorderState

	var body: some View {
		ZStack {
			Image("LCDScreenEmptyTemp")
				.resizable()
				.scaledToFit()
				.frame(width: 286)
				.offset(x:0, y:0)

			VStack {
				if recordingState.isRecording {
					Text("Recording!")
						.font(Font.custom("TINY5x3-100", size: 24))
						.foregroundColor(Color("LCDTextColor"))
				}
				Text("RM2000")
					.font(Font.custom("TINY5x3-100", size: 24))
					.foregroundColor(Color("LCDTextColor"))
				
				Text("00:00")
					.font(Font.custom("Tachyo", size: 50))
					.foregroundColor(Color("LCDTextColor"))
				
				Text("AAC Format 44.1/k")
					.font(Font.custom("TINY5x3-100", size: 20))
					.foregroundColor(Color("LCDTextColor"))
			}
		}
	}
}

#Preview {
	ContentView()
		.environmentObject(TapeRecorderState())
}
