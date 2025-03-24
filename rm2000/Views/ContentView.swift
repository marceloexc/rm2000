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

struct UtilityButtons: View {
	@Environment(\.openWindow) var openWindow
	@Environment(\.openSettingsLegacy) private var openSettingsLegacy
	@State private var isPressed = false

	var body: some View {
		Button(action: { try? openSettingsLegacy() }) {
			Image("SettingsButton")
		}
		.buttonStyle(AnimatedButtonStyle())

		Button(action: { openWindow(id: "recordings-window") }) {
			Image("FolderButton")
				.renderingMode(.original)
		}.buttonStyle(AnimatedButtonStyle())

		Button(action: { print("Source Button pressed") }) {
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
			.animation(
				.spring(response: 0.3, dampingFraction: 0.6),
				value: configuration.isPressed)
	}
}

struct StandbyRecordButton: View {
	var onPress: () -> Void

	var body: some View {
		ZStack {
			Image("RecordButtonIndent")
			Image("RecordButtonTemp")
			Image("RecordButtonGlow")

			Button(action: onPress) {
				Rectangle()
					// stupid fucking hack below
					// i cant have opactiy(0) on a button, because then that disables it completely
					// it needs to be transparent becuase the images _are_ the buttons.

					// i still think having assets in lieu of skeuemorphic elements are really cheap
					// (hinders actual reactivity and im at the mercy of exporting everything from sketch),
					// but i still havent learned core animation / CALayers yet, so this will do...
					.fill(Color.white.opacity(0.001))
					.frame(width: 70, height: 70)
			}
			.buttonStyle(AnimatedButtonStyle())
		}
		.frame(height: 80)
	}
}

struct ActiveRecordButton: View {
	var onPress: () -> Void

	var body: some View {
		ZStack {
			Image("RecordButtonIndent")
			Image("RecordButtonTemp")
			Image("RecordButtonActiveTemp")
				.pulseEffect()
			Image("RecordButtonGlow")

			Button(action: onPress) {
				Rectangle()
					.fill(Color.white.opacity(0.001))  //stupid hack again
					.frame(width: 70, height: 70)
			}
			.buttonStyle(AnimatedButtonStyle())
		}
		.frame(height: 80)
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
			.animation(
				.easeInOut(duration: duration).repeatForever(),
				value: pulseIsInMaxState)
	}
}

extension View {
	public func pulseEffect(
		range: ClosedRange<Double> = 0.1...1, duration: TimeInterval = 1
	) -> some View {
		modifier(PulseEffect(range: range, duration: duration))
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
