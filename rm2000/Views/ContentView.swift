import SwiftUI
import OSLog

struct ContentView: View {
	@Environment(\.openWindow) var openWindow
	@EnvironmentObject private var recordingState: TapeRecorderState
//	@State private var sampleSavedAs: Sample
	@State private var newSampleTitle: String = ""
	@State private var newSampleTags: String = ""

	var body: some View {
		ZStack {
			Image("BodyBackgroundTemp")
				.scaledToFill()
				.ignoresSafeArea(.all) // extend under the titlebar
			VStack {
				LCDScreenView()
				
				if recordingState.isRecording {
					ZStack {
						Image("RecordButtonTemp")
						
						Button(action: stopRecording) {
							Image("RecordButtonActiveTemp")
								.renderingMode(.original)
						}
						.buttonStyle(BorderlessButtonStyle())
						.pulseEffect()
						
						let _ = Logger.sharedStreamState.info("Changing state in the main window")
					}
				} else {
					Button(action: startRecording) {
						Image("RecordButtonTemp")
						 .renderingMode(.original)
					 }.buttonStyle(BorderlessButtonStyle())
				}
				
				Button("Open recordings window") {
					openWindow(id: "recordings-window")
				}
				
				Button("Open test onboarding window") {
					openWindow(id: "onboarding")
				}
			}
			.sheet(isPresented: $recordingState.showRenameDialogInMainWindow, content: {
				EditSampleView(currentFilename: recordingState.currentSampleFilename ?? "",
						   newTitle: $newSampleTitle,
						   newTags: $newSampleTags,
						   onEdit: renameRecording)
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
		recordingState.applySampleEdits(to: newSampleTitle, newTags: newSampleTags)
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

// https:stackoverflow.com/questions/61778108/swiftui-how-to-pulsate-image-opacity
struct PulseEffect: ViewModifier {
	@State private var pulseIsInMaxState: Bool = true
	private let range: ClosedRange<Double>
	private let duration: TimeInterval

	init(range: ClosedRange<Double>, duration: TimeInterval) {
		self.range = range
		self.duration = duration
	}

	func body(content: Content) -> some View {
		content
			.opacity(pulseIsInMaxState ? range.lowerBound : range.upperBound)
			.onAppear { pulseIsInMaxState = false }
			.animation(.easeInOut(duration: duration).repeatForever(), value: pulseIsInMaxState)
	}
}

public extension View {
	func pulseEffect(range: ClosedRange<Double> = 0.1...1, duration: TimeInterval = 1) -> some View  {
		modifier(PulseEffect(range: range, duration: duration))
	}
}

#Preview {
	ContentView()
		.environmentObject(TapeRecorderState())
}
