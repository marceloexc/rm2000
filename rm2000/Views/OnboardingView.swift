import SwiftUI

enum OnboardingStep {
	case welcome
	case settings
	case complete
}

class OnboardingViewModel: ObservableObject {
	@Published var currentStep: OnboardingStep = .welcome
	@AppStorage("completedOnboarding") private var completedOnboarding: Bool = false
	
	func finishOnboarding() {
		completedOnboarding = true
	}
}

struct FinalOnboardingCompleteView: View {
	
	@ObservedObject var viewModel: OnboardingViewModel
	@Environment(\.dismiss) private var dismiss
	
	
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
	
	@ObservedObject var viewModel: OnboardingViewModel
	
	var body: some View {
		Text("settings")
		
		HStack {
			Button("Back") {
				viewModel.currentStep = .welcome
			}
			
			Button("Next") {
				viewModel.currentStep = .complete
			}
			.buttonStyle(.borderedProminent)
		}
	}
}

struct WelcomeView:View {
	
	@ObservedObject var viewModel: OnboardingViewModel
	var body: some View {
		Text("Welcome to RM2000")
			.font(.title)
		Text("Before you continue, you will have to:\n\nenable system permissions\n\nset a directory\n\nset preferred audio format (mp3 default)")
		HStack {
			TextField("Set RM2000 Sample Directory", text: /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Value@*/.constant("")/*@END_MENU_TOKEN@*/)
			Button("Browse") {
				// change me
			}
		}
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
