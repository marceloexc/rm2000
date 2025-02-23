import Foundation
import SwiftUI

// AppState.swift
@MainActor final class AppState: ObservableObject {
	static let shared = AppState()
	
	@AppStorage("completedOnboarding") var hasCompletedOnboarding: Bool = false {
		didSet {
			if !hasCompletedOnboarding {
				openOnboardingWindow()
			}
		}
	}
	@Published var sampleDirectory: URL?
	private var openWindowAction: OpenWindowAction?
	
	private func setOpenWindowAction(_ action: OpenWindowAction) {
		self.openWindowAction = action
		if !hasCompletedOnboarding {
			openOnboardingWindow()
		}
	}
	
	private func openOnboardingWindow() {
		openWindowAction?(id: "onboarding")
	}
}
