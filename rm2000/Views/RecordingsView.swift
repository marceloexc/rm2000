import Foundation
import SwiftUI

let regString = /(.+)--(.+)\.(.+)/

struct RecordingsView: View {
	
	@Environment(\.openURL) private var openURL
	
	@State private var finishedProcessing: Bool = false
	@State private var directoryContents: [URL] = []
	@State private var indexedTags: [String] = []
	
	@State private var selectedTag: String?
	
	var body: some View {
		NavigationSplitView {
			List(selection: $selectedTag) {
				Section(header: Text("Available tags")) {
					if finishedProcessing {
						ForEach(indexedTags, id:\.self) { tag in
							NavigationLink(value: tag) {
								HStack{
									Image(systemName:"waveform.path")
									VStack(alignment: .leading, content: {
										Text(tag)
									})
								}
							}
						}
					}
				}
			}
			.listStyle(SidebarListStyle())
			.navigationTitle("Recordings")
		} detail: {
			
			if let selectedTag {
				List(directoryContents, id: \.self) { sampleFileURL in
					if sampleFileURL.lastPathComponent.contains(selectedTag) {
						SampleRepresentedAsList(sampleFileURL: sampleFileURL)
					}
				}
			} else {
				VStack {
					Button("Get all directories") {
						listAllRecordings()
						
						for sampleFileURL in directoryContents {
							indexedTags += getTagsFromSampleTitle(filename: sampleFileURL)
						}
						
						// get only unique items
						indexedTags = Array(Set(indexedTags))
					}
					
					if finishedProcessing {
						List(directoryContents, id: \.self) { sampleFileURL in
							
							if passesRegex(sampleFileURL.lastPathComponent) {
								SampleRepresentedAsList(sampleFileURL: sampleFileURL)
							} else {
								let _ = print("\(sampleFileURL) did not pass RegEx")
							}
						}
					}
				}
			}
		}
		.toolbar {
			ToolbarItemGroup(placement: .automatic) {
				Button(action: {
					NSWorkspace.shared.open(WorkingDirectory.applicationSupportPath())
				}) {
					Image(systemName: "folder")
				}
			}
		}
	}
	
	func listAllRecordings() {
		let path = WorkingDirectory.applicationSupportPath()
		
		do {
			directoryContents = try FileManager.default.contentsOfDirectory(at: path, includingPropertiesForKeys: nil)
			finishedProcessing = true
		}
		catch {
			print("Error listing directory contents: \(error.localizedDescription)")
			finishedProcessing = false
		}
	}
}

struct SampleRepresentedAsList: View {
	
	var sampleFileURL: URL
	
	var body: some View {
		Text(sampleFileURL.lastPathComponent)
			.foregroundStyle(.green)
			.contextMenu {
				Button("Open File") {
					NSWorkspace.shared.open(sampleFileURL)
				}
			}
	}
}
	
private func getTagsFromSampleTitle(filename: URL) -> [String] {
	if let match = try? regString.firstMatch(in: filename.lastPathComponent) {
		let tags = String(match.2).components(separatedBy: "_")
		return tags
	} else {
		return []
	}
}
	
private func passesRegex(_ pathName: String) -> Bool {
	if (try? regString.wholeMatch(in: pathName)) != nil {
		return true
	}
	else {
		return false
	}
}

#Preview {
	RecordingsView()
}
