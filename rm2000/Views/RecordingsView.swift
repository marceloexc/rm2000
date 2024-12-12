import Foundation
import SwiftUI

struct RecordingsView: View {
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
			.navigationTitle("Servers")
		} detail: {
			
			if let selectedTag {
				List(directoryContents, id: \.self) { directory in
					if directory.lastPathComponent.contains(selectedTag) {
						Text(directory.lastPathComponent)
							.foregroundStyle(.green)
						
						//ugly but for testing purposes only
					}
				}
					
			} else {
				VStack {
					Button("Get all directories") {
						listAllRecordings()
						indexedTags = getTagsFromSampleTitle(filename: "rescuedawn--youtube_test_pop_hypnagogic--8ae1154d.aac")
					}
					
					if finishedProcessing {
						List(directoryContents, id: \.self) { directory in
							
							if passesRegex(directory.lastPathComponent){
								Text(directory.lastPathComponent)
									.foregroundStyle(.green)
							}
							else {
								Text(directory.lastPathComponent)
									.foregroundStyle(.red)
							}
						}
					}
				}
			}
		}
	}
	
	func listAllRecordings() {
		let documentURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
		
		let path = documentURL.appendingPathComponent("com.marceloexc.rm2000")
		
		do {
			directoryContents = try FileManager.default.contentsOfDirectory(at: path, includingPropertiesForKeys: nil)
			finishedProcessing = true
		}
		catch {
			print("Error listing directory contents: \(error.localizedDescription)")
			finishedProcessing = false
		}
	}
	
	private func makeOnlyUniqueTagList(tags: [[String]]) {
		
	}
}
	
private func getTagsFromSampleTitle(filename: String) -> [String] {
	
	let regString = /(.+)--(.+)--(.+)\.(.+)/
	
	if let match = try? regString.firstMatch(in: filename) {
		let tags = String(match.2).components(separatedBy: "_")
		return tags
	} else {
		return []
	}
}
	
private func passesRegex(_ pathName: String) -> Bool {
	let regString = /^([A-Za-z0-9]+)--([A-Za-z0-9_]+)--([a-f0-9]{8})\.([a-z0-9]+)$/
	
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
