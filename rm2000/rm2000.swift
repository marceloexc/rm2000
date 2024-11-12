import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
	func applicationDidFinishLaunching(_ notification: Notification) {
		NSWindow.allowsAutomaticWindowTabbing = false
	}
}

@main
struct rm2000: App {
	
	@NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
	
	@StateObject private var recordingState = TapeRecorderState()
	
    var body: some Scene {
		Window("RM2000 Tape Recorder", id:	"main-window") {
			NavigationSplitView {
				SidebarView()
			} detail: {
				ContentView()
					.environmentObject(recordingState)
			}
        }
		MenuBarExtra("RP2000 Portable", systemImage: "recordingtape") {
			MenuBarView()
				.environmentObject(recordingState)
		}
    }
}
