import AppKit
import SwiftUI

class WindowController: NSWindowController {
	override func windowDidLoad() {
		super.windowDidLoad()
		window?.center()
	}
}

class AppDelegate: NSObject, NSApplicationDelegate {
	var mainWindowController: WindowController?
	private var onboardingWindowController: NSWindowController?
	let recordingState = TapeRecorderState()
	
	func applicationDidFinishLaunching(_ notification: Notification) {
		registerCustomFonts()
		NSApp.dockTile.badgeLabel = "Beta 😱😱"
		if AppState.shared.hasCompletedOnboarding {
			showMainWindow()
		} else {
			showOnboardingWindow()
		}
	}
	
	func showMainWindow() {
		let window = SkeuromorphicWindow(
			contentRect: NSRect(x: 100, y: 100, width: 600, height: 400),
			styleMask: [.titled, .closable, .miniaturizable],
			backing: .buffered,
			defer: false
		)
		
		let contentView = ContentView()
			.environmentObject(self.recordingState)
			.openSettingsAccess()
		
		window.contentView = NSHostingView(rootView: contentView)
		mainWindowController = WindowController(window: window)
		mainWindowController?.showWindow(nil)
	}
	
	@MainActor private func showOnboardingWindow() {
		let hostingController = NSHostingController(
			rootView: OnboardingView(viewModel: OnboardingViewModel())
				.environmentObject(AppState.shared)
		)
		
		let window = NSWindow(
			contentRect: NSRect(x: 0, y: 0, width: 600, height: 600),
			styleMask: [.titled, .closable],
			backing: .buffered,
			defer: false
		)
		window.contentViewController = hostingController
		onboardingWindowController = NSWindowController(window: window)
		onboardingWindowController?.showWindow(nil)
		window.center()
	}
	
	/*
	 A function like this should never exist.
	 However, even after I followed all of the tutorials,
	 Xcode simply wouldn't bundle my otf fonts.
	 */
	private func registerCustomFonts() {
		let fonts = Bundle.main.urls(forResourcesWithExtension: "otf", subdirectory: nil)
		fonts?.forEach { url in
			CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
		}
	}
}
