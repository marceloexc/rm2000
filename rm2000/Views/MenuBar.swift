import Foundation
import SwiftUI
import OSLog

struct MenuBarView: View {
	@EnvironmentObject private var recordingState: TapeRecorderState
	@Environment(\.openWindow) private var openWindow
	
	var body: some View {
		Text("RM2000 Public Beta")
		Divider()
		Button("Open") {
			openWindow(id: "main-window")
		}
		Button(recordingState.isRecording ? "Stop Recording" : "Start Recording") {
			if recordingState.isRecording {
				Logger.sharedStreamState.info("Changing state in the menubar")
				recordingState.stopRecording()
			} else {
				recordingState.startRecording(filename: "default.aac", directory: "/Users/marceloexc/Downloads/")
			}
		}
		Divider()
		Button("Quit RM2000") {
			NSApplication.shared.terminate(nil)
		}.keyboardShortcut("q")
	}
}
