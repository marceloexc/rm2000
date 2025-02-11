import SwiftUI

class WindowController: NSWindowController {
	override func windowDidLoad() {
		super.windowDidLoad()
		window?.center()
	}
}

final class AppDelegate: NSObject, NSApplicationDelegate {
	
	private var windowController: WindowController?
	private let recordingState = TapeRecorderState()
	
	func applicationDidFinishLaunching(_ notification: Notification) {
		// todo - look into why this works
		let window = SkeuromorphicWindow( contentRect: NSRect(x: 100, y: 100, width: 600, height: 400),
										  styleMask: [.titled, .closable, .miniaturizable],
			backing: .buffered,
			defer: false)
		
		let contentView = ContentView()
			.environmentObject(recordingState)
		
		window.contentView = NSHostingView(rootView: contentView)
		
		windowController = WindowController(window: window)
		windowController?.showWindow(nil)
	}
}

@main
struct rm2000: App {
	@NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
	
	@StateObject private var recordingState = TapeRecorderState()
	
    var body: some Scene {
//		Window("RM2000", id:"main-window") {
//				ContentView()
//					.environmentObject(recordingState)
//        }
		MenuBarExtra("RP2000 Portable", systemImage: "recordingtape") {
			MenuBarView()
				.environmentObject(recordingState)
		}
		
		Window("Recordings", id: "recordings-window") {
			RecordingsView()
		}
		
		Window("Welcome", id: "onboarding") {
			OnboardingView(viewModel: OnboardingViewModel())
			.frame(maxWidth: 600, minHeight: 600)
			
		}
		.windowResizability(.contentSize)
		.windowStyle(.hiddenTitleBar)
		
		Settings {
			SettingsView()
		}
    }
}
