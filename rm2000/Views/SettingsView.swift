import SwiftUI
import Foundation
import OSLog

enum AudioFormat: String {
	case aac, mp3, alac, opus
}

struct SettingsView: View {
	
	@EnvironmentObject private var appState: AppState
	@State private var selectedFileType = AudioFormat.aac
	@State private var workingDirectory = WorkingDirectory.applicationSupportPath().description
	@State private var autostartAtLogin = false
	@State private var minimizeToToolbar = false
	@State private var selectedTab = "General"
		
	var body: some View {
		TabView(selection: $selectedTab) {
			Form {
				Section {
					Picker("Sample File Type", selection: $selectedFileType) {
						Text("AAC").tag(AudioFormat.aac)
						Text("MP3").tag(AudioFormat.mp3)
						Text("ALAC").tag(AudioFormat.alac)
						Text("OPUS").tag(AudioFormat.opus)

					}
					.onChange(of: selectedFileType) { newValue in
						selectedFileType = newValue}
					.pickerStyle(.menu)
					
					HStack {
						TextField("Working Directory", text: $workingDirectory)
						Button("Browse") {
							// Directory picker logic would go here
						}
					}
				}
				
				Section {
					Toggle("Start at Login", isOn: $autostartAtLogin)
						.onChange(of: autostartAtLogin) { newValue in
							autoStartAtLogin()
						}
					Toggle("Minimize to Toolbar", isOn: $minimizeToToolbar)
						.disabled(!autostartAtLogin)
				}
				
				Section {
					Toggle("Show File Extensions", isOn: .constant(true))
					Toggle("Keep unsaved samples", isOn: .constant(true))
				}
			}
			.padding()
			.frame(width: 450)
			.tabItem {
				Label("General", systemImage: "gear")
			}
			.tag("General")
		}
	}
	
	private func autoStartAtLogin() {
		Logger.viewModels.warning("Not implemented yet")
	}
}

#Preview {
	SettingsView()
}
