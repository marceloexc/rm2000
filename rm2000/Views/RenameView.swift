import SwiftUI

struct RenameView: View {
	
	let currentFilename: String
	@Binding var inputNewSampleFilename: String
	@Binding var inputNewSampleTags: String
	
	var onRename: () -> Void
	
    var body: some View {
		VStack {
			Text("Rename Recording")
				.font(.headline)
			
			TextField("New Filename", text: $inputNewSampleFilename)
			TextField("Enter Tags", text: $inputNewSampleTags)
			Text(".aac")
				.font(.caption)
			
			Button("Rename", action: onRename)
		}
    }
}
