import SwiftUI
import SettingsAccess

class WindowController: NSWindowController {
	override func windowDidLoad() {
		super.windowDidLoad()
		window?.center()
	}
}

final class AppDelegate: NSObject, NSApplicationDelegate {
	private var mainWindowController: WindowController?
	private var onboardingWindowController: NSWindowController?
	let recordingState = TapeRecorderState()
	
	func applicationDidFinishLaunching(_ notification: Notification) {
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
			.environmentObject(recordingState)
			.openSettingsAccess()
		
		window.contentView = NSHostingView(rootView: contentView)
		mainWindowController = WindowController(window: window)
		mainWindowController?.showWindow(nil)
	}
	
	private func showOnboardingWindow() {
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
}

@main
struct rm2000: App {
	@NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
	
	@StateObject private var recordingState = TapeRecorderState()
	@StateObject private var appState = AppState.shared
	
    var body: some Scene {
		MenuBarExtra("RP2000 Portable", systemImage: "recordingtape") {
			MenuBarView()
				.environmentObject(appDelegate.recordingState)
		}
		
		Window("Recordings", id: "recordings-window") {
			SampleBrowserView()
		}.windowToolbarStyle(.unifiedCompact)

		WindowGroup("Welcome", id: "onboarding") {
			OnboardingView(viewModel: OnboardingViewModel())
			.frame(maxWidth: 600, minHeight: 600)
			.environmentObject(appState)
		}
		WindowGroup("Inspector", id: "inspector") {
			InspectorView()
		}
		.windowResizability(.contentSize)
		.windowStyle(.hiddenTitleBar)
		
		Settings {
			SettingsView()
				.environmentObject(appState)
		}
    }
}
