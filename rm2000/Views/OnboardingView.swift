import SwiftUI
import UserNotifications
import OSLog


enum OnboardingStep {
	case welcome
	case settings
	case complete
}

class OnboardingViewModel: ObservableObject {
	@Published var currentStep: OnboardingStep = .welcome
	@AppStorage("completedOnboarding") private var completedOnboarding: Bool = false
	
	@AppStorage("sample_directory") var userDefaultsDirectoryPath: URL = WorkingDirectory.applicationSupportPath()
	
	func finishOnboarding() {
		completedOnboarding = true
	}
}

struct FinalOnboardingCompleteView: View {
	
	@Environment(\.dismiss) var dismiss
	
	@ObservedObject var viewModel: OnboardingViewModel
	
	var body: some View {
		Text("Complete!")
		HStack {
			Button("Back") {
				viewModel.currentStep = .settings
			}
			
			Button("Finish") {
				dismiss()
			}
			.buttonStyle(.borderedProminent)
		}
	}
}

struct SettingsStepView: View {
	
	private let streamManager = StreamManager()
	
	@ObservedObject var viewModel: OnboardingViewModel
	
	@State private var showFileChooser: Bool = false
	
	var body: some View {
		Text("settings")
		HStack {
			TextField("Set RM2000 Sample Directory", text: /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Value@*/.constant("")/*@END_MENU_TOKEN@*/)
			Button("Print userDefaultsDirectoryPath") {
				print(viewModel.userDefaultsDirectoryPath)
			}
			Button("Browse") {
				showFileChooser = true
			}
			.fileImporter(isPresented: $showFileChooser, allowedContentTypes: [.directory]) {
				result in
				switch result {
				case .success(let directory):
					viewModel.userDefaultsDirectoryPath = directory
					Logger.viewModels.info("Set new userDefaultsDirectoryPath as \(directory)")
				case .failure(let error):
					Logger.viewModels.error("Could not set userDefaultsDirectoryPath: \(error)")
				}
			}
		}
		HStack {
			Button("Request Permissions") {
				Task {
					await invokeRecordingPermission()
				}
			}
		}
		HStack {
			Button("Back") {
				viewModel.currentStep = .welcome
			}
			
			Button("Next") {
				viewModel.currentStep = .complete
				print(viewModel.userDefaultsDirectoryPath)
			}
			.buttonStyle(.borderedProminent)
		}
	}
	
	private func invokeRecordingPermission() async {
		do {
			try await streamManager.setupAudioStream()
		}
		catch {
			Logger.viewModels.error("Recording permission declined")
			
			// https://stackoverflow.com/a/78740238
			// i seriously have to use NSAlert for this?
			
			let alert = showPermissionAlert()
			if alert.runModal() == . alertFirstButtonReturn {
			NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture")!)
			}
		}
	}
	
	private func showPermissionAlert() -> NSAlert {
		let alert = NSAlert()
		alert.messageText = "Permission Request"
		alert.alertStyle = .informational
		alert.informativeText = "RM2000 requires permission to record the screen in order to grab system audio."
		alert.addButton(withTitle: "Open System Settings")
		alert.addButton(withTitle: "Quit")
		return alert
	}
}

struct WelcomeView:View {
	
	@ObservedObject var viewModel: OnboardingViewModel
	var body: some View {
		Text("Welcome to RM2000")
			.font(.title)
		Text("Before you continue, you will have to:\n\nenable system permissions\n\nset a directory\n\nset preferred audio format (mp3 default)")
		HStack {
			Button("Next") {
				viewModel.currentStep = .settings
			}
			.buttonStyle(.borderedProminent)
		}
	}
}

struct OnboardingView: View {
		
	@ObservedObject var viewModel: OnboardingViewModel
	
	var body: some View {
		VStack(spacing: 20) {
			
			switch viewModel.currentStep {
			case.welcome:
				WelcomeView(viewModel: viewModel)
			case .settings:
				SettingsStepView(viewModel: viewModel)
			case .complete:
				FinalOnboardingCompleteView(viewModel: viewModel)
			}
		}
		.frame(minWidth: 200)
		.padding()
		
    }
	
}

#Preview {
	OnboardingView(viewModel: OnboardingViewModel())
}
