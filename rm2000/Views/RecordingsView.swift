import Foundation
import SwiftUI

struct RecordingsView: View {
	@State private var finishedProcessing: Bool = false
	@State private var directoryContents: [URL] = []
	
	var body: some View {
		NavigationSplitView {
			List {
				Section(header: Text("Featured Servers")) {
//					ForEach(servers, id: \.0) { server in
//						HStack {
//							Image(systemName: "globe")
//							VStack(alignment: .leading) {
//								Text(server.0).bold()
//								Text(server.1).font(.subheadline).foregroundColor(.secondary)
//							}
//						}
//					}
				}
			}
			.listStyle(SidebarListStyle())
			.navigationTitle("Servers")
		} detail: {
			VStack {
				Button("Get all directories") {
					listAllRecordings()
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
	
	func passesRegex(_ pathName: String) -> Bool {
		let regString = /^([A-Za-z0-9]+)--([A-Za-z0-9_]+)--([a-f0-9]{8})\.([a-z0-9]+)$/
		
		if let result = try? regString.wholeMatch(in: pathName) {
			return true
		}
		else {
			return false
		}
	}
}

#Preview {
	RecordingsView()
}
