import SwiftUI

@main
struct rm2000: App {
	
	@StateObject private var recordingState = TapeRecorderState()
	
    var body: some Scene {
		Window("RM2000", id:"main-window") {
				ContentView()
					.environmentObject(recordingState)
        }
		MenuBarExtra("RP2000 Portable", systemImage: "recordingtape") {
			MenuBarView()
				.environmentObject(recordingState)
		}
		
		Window("Recordings", id: "recordings-window") {
			RecordingsView()
		}
		
		Window("Welcome", id: "onboarding") {
			OnboardingView(viewModel: OnboardingViewModel())
			.frame(maxWidth: 400)
		}.windowResizability(.contentSize)
		
		Settings {
			SettingsView()
		}
    }
}
