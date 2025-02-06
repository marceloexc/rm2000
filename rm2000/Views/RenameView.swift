import SwiftUI

struct RenameView: View {
	
	let currentFilename: String
	@Binding var newTitle: String
	@Binding var newTags: String
	var newDescription: String?
	var onRename: () -> Void
	
	
	private var previewFilename: String {
		let metadata = SampleFilenameStructure(sampleTitle: newTitle, sampleTags: newTags)
		return metadata.generatePreviewFilename()
	}
	
	var body: some View {
		ScrollView {
			VStack(alignment: .leading, spacing: 12) {
				Text("Rename Recording")
					.font(.headline)
				
				VStack(alignment: .leading, spacing: 4) {
					Text("Title")
						.font(.caption)
						.foregroundColor(.secondary)
					TextField("New Filename", text: $newTitle)
						.textFieldStyle(RoundedBorderTextFieldStyle())
				}
				
				VStack(alignment: .leading, spacing: 4) {
					Text("Tags (comma-separated)")
						.font(.caption)
						.foregroundColor(.secondary)
					TextField("Enter Tags", text: $newTags)
						.textFieldStyle(RoundedBorderTextFieldStyle())
				}
				DisclosureGroup("Additional Settings") {
					VStack(alignment: .leading, spacing: 4) {
						Text("Description (optional)")
							.font(.caption)
							.foregroundColor(.secondary)
						TextEditor(text: .constant("Placeholder"))
							.font(.system(size: 14, weight: .medium, design: .rounded)) // Uses a rounded, medium-weight system font
							.lineSpacing(10) // Sets the line spacing to 10 points
							.border(Color.gray, width: 1)
						
						Text("Convert Format")
							.font(.caption)
							.foregroundColor(.secondary)
						Menu {
							Button {
								// do something
							} label: {
								Text("Linear")
								Image(systemName: "arrow.down.right.circle")
							}
							Button {
								// do something
							} label: {
								Text("Radial")
								Image(systemName: "arrow.up.and.down.circle")
							}
						} label: {
							Text("Style")
							Image(systemName: "tag.circle")
						}
						
					}.padding(.top, 8)
				}
				VStack(alignment: .leading, spacing: 4) {
					Text("Preview:")
						.font(.caption)
						.foregroundColor(.secondary)
					Text(previewFilename)
						.font(.system(.callout, design: .monospaced))
						.foregroundColor(.blue)
						.lineLimit(1)
						.truncationMode(.middle)
				}
				.padding(.top, 8)
				
				Button(action: onRename) {
					Text("Rename")
						.frame(maxWidth: .infinity)
						.padding(.vertical, 8)
				}
				.buttonStyle(.borderedProminent)
				.padding(.top, 8)
			}
			.padding()
			.frame(minWidth: 350, maxWidth: 400, minHeight: 400)
		}
	}
}



#Preview {
	RenameView(
		currentFilename: "SampleFile.wav",
		newTitle: .constant("NewSample"),
		newTags: .constant("tag1, tag2"), newDescription: "",
		onRename: {}
	)
}
