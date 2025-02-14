import SwiftUI
import OSLog

struct ContentView: View {
	@Environment(\.openWindow) var openWindow
	@EnvironmentObject private var recordingState: TapeRecorderState
	@State private var newSampleTitle: String = ""
	@State private var newSampleTags: String = ""

	var body: some View {
		ZStack {
			Image("BodyBackgroundTemp")
				.scaledToFill()
				.ignoresSafeArea(.all) // extend under the titlebar
			VStack(spacing:10) {
				LCDScreenView()
					.padding(.top, -45)
				
				HStack(spacing: 5) {
					UtilityButtons()
				}
				.padding(.top, -5)
				
				if recordingState.isRecording {
					ZStack {
						Image("RecordButtonTemp")
						
						Button(action: stopRecording) {
							Image("RecordButtonActiveTemp")
								.renderingMode(.original)
						}
						.buttonStyle(AnimatedButtonStyle())
						.pulseEffect()
						
						let _ = Logger.sharedStreamState.info("Changing state in the main window")
					}
				} else {
					Button(action: startRecording) {
						Image("RecordButtonTemp")
						 .renderingMode(.original)
					}.buttonStyle(AnimatedButtonStyle())
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
				.frame(width: 300)
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

struct UtilityButtons: View {
	@Environment(\.openWindow) var openWindow
	@State private var isPressed = false

	var body: some View {
		Button(action: {
			print("Settings Button pressed")
		}) {
			Image("SettingsButton")
		}
		.buttonStyle(AnimatedButtonStyle())
		
		Button(action: { openWindow(id: "recordings-window") }) {
			Image("FolderButton")
				.renderingMode(.original)
		}									.buttonStyle(AnimatedButtonStyle())

		Button(action: {
			print("Source Button pressed")
		}) {
			Image("SourceButton")
		}
		.buttonStyle(AnimatedButtonStyle())
	}
}

struct AnimatedButtonStyle: ButtonStyle {
	func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.background(.clear)
			.scaleEffect(configuration.isPressed ? 0.94 : 1.0)
			.animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
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
