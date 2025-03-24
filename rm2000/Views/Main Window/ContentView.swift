import OSLog
import SwiftUI

struct ContentView: View {
	@Environment(\.openWindow) var openWindow
	@EnvironmentObject private var recordingState: TapeRecorderState

	var body: some View {
		ZStack {
			Image("BodyBackgroundTemp")
				.scaledToFill()
				.ignoresSafeArea(.all)  // extend under the titlebar
			VStack(spacing: 10) {
				LCDScreenView()
					.frame(height: 225)
					.padding(.top, -45)

				HStack(spacing: 5) {
					UtilityButtons()
				}
				.padding(.top, -5)

				if recordingState.isRecording {
					ActiveRecordButton(onPress: stopRecording)
				} else {
					StandbyRecordButton(onPress: startRecording)
				}

			}
			
			.sheet(isPresented: $recordingState.showRenameDialogInMainWindow) {
				if let newRecording = recordingState.activeRecording {
					EditSampleView(recording: newRecording) { Sample in
						
						// TODO - trainwreck. if i already have to pass in the shared.userdirectory, then this probably belongs in samplestorage itself, not sampledirectory
						SampleStorage.shared.UserDirectory.applySampleEdits(fromFile: Sample.fileURL, createdSample: Sample as! Sample)
						recordingState.showRenameDialogInMainWindow = false
					}
				}
			}
		}
	}

	private func startRecording() {
		recordingState.startRecording()
	}

	private func stopRecording() {
		recordingState.stopRecording()
	}

}

struct LCDScreenView: View {
	@EnvironmentObject private var recordingState: TapeRecorderState

	var body: some View {
		ZStack {
			Image("LCDScreenEmptyTemp")
				.resizable()
				.scaledToFit()
				.frame(width: 300)
				.offset(x: 0, y: 0)
			
			VStack(alignment: .leading) {
				HStack {
					VStack(alignment: .leading, spacing: 4) {
						Text("STEREO 44.1kHz")
							.font(Font.custom("TASAExplorer-SemiBold", size: 14))
							.foregroundColor(Color("LCDTextColor"))
						

						Text("16 BIT")
							.font(Font.custom("TASAExplorer-SemiBold", size: 14))
							.foregroundColor(Color("LCDTextColor"))
							.shadow(color: .black.opacity(0.25), radius: 1, x: 0, y: 4)
					}
					Spacer()
				}

				Text(" M4A ")
					.font(.custom("Tachyo", size: 41))
					.fontWeight(.thin)
					.foregroundColor(Color("LCDTextColor"))
					.shadow(color: .black.opacity(0.25), radius: 1, x: 0, y: 4)
					.padding(.top, 10)
					.offset(x: -15)
					.kerning(-1.5)
				
				if recordingState.isRecording {
					Text(timeString(recordingState.elapsedTimeRecording))
						.font(Font.custom("Tachyo", size: 41))
						.foregroundColor(Color("LCDTextColor"))
						.shadow(color: .black.opacity(0.25), radius: 1, x: 0, y: 4)
						.fixedSize()
						.offset(x: -15)
						.kerning(-1.5)
				} else {
					Text(" STBY ")
						.font(Font.custom("Tachyo", size: 41))
						.fontWeight(.medium)
						.foregroundColor(Color("LCDTextColor"))
						.shadow(color: .black.opacity(0.25), radius: 1, x: 0, y: 4)
						.fixedSize()
						.offset(x: -15)
						.kerning(-1.5)
				}
			}
			.frame(width: 200, height: 168)
			
			Image("LCDOuterGlow")
				.resizable()
				.frame(width: 330)
		}
	}
	
	private func timeString(_ time: TimeInterval) -> String {
		let minutes = Int(time) / 60
		let seconds = Int(time) % 60
		return String(format: " %02d:%02d ", minutes, seconds)
	}
}

#Preview("Main Window") {
	ContentView()
		.environmentObject(TapeRecorderState())
}

#Preview("LCD Screen") {
	LCDScreenView()
		.environmentObject(TapeRecorderState())
}
