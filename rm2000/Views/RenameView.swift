import SwiftUI

struct RenameView: View {
	
	let currentFilename: String
	@Binding var newSampleFilename: String
	@Binding var newSampleTags: String
	
	var onRename: () -> Void
	
    var body: some View {
		VStack {
			Text("Rename Recording")
				.font(.headline)
			
			TextField("New Filename", text: $newSampleFilename)
			TextField("Enter Tags", text: $newSampleTags)
			Text(".aac")
				.font(.caption)
			
			Button("Rename", action: onRename)
		}
    }
}
