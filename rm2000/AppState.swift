import Foundation
import SwiftUI

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
