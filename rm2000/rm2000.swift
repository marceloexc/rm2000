import SwiftUI

@main
struct rm2000: App {
	
	@StateObject private var recordingState = TapeRecorderState()
	
    var body: some Scene {
		WindowGroup(id:	"main-window") {
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
