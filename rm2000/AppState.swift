import Foundation
import SwiftUI
import OSLog

@MainActor final class AppState: ObservableObject {
	static let shared = AppState()
	
	@AppStorage("completedOnboarding") var hasCompletedOnboarding: Bool = false {
		didSet {
			if !hasCompletedOnboarding {
				openOnboardingWindow()
			}
		}
	}
	
	@AppStorage("sample_directory") var sampleDirectoryPath: String = ""
	@Published var sampleDirectory: URL? {
		didSet {
			sampleDirectoryPath = sampleDirectory?.path ?? ""
		}
	}
	private var openWindowAction: OpenWindowAction?
	
	init() {
		
		if !sampleDirectoryPath.isEmpty {
			sampleDirectory = URL(fileURLWithPath: sampleDirectoryPath)
		}
		Logger.appState.info("\(String(describing: sampleDirectory)) as the user directory")
	}
	
	func setOpenWindowAction(_ action: OpenWindowAction) {
		self.openWindowAction = action
		if !hasCompletedOnboarding {
			openOnboardingWindow()
		}
	}
	
	func openOnboardingWindow() {
		openWindowAction?(id: "onboarding")
	}
}
