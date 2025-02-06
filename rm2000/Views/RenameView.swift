import SwiftUI

struct RenameView: View {
	
	let currentFilename: String
	@Binding var inputNewSampleFilename: String
	@Binding var inputNewSampleTags: String
	var inputNewSampleDescription: String?
	var onRename: () -> Void
	
	
	private var previewFilename: String {
		let metadata = SampleFilenameStructure(sampleTitle: inputNewSampleFilename, sampleTags: inputNewSampleTags)
		return metadata.generatePreviewFilename()
	}
	
	var body: some View {
			VStack(alignment: .leading, spacing: 12) {
				Text("Rename Recording")
					.font(.headline)
				
				VStack(alignment: .leading, spacing: 4) {
					Text("Title")
						.font(.caption)
						.foregroundColor(.secondary)
					TextField("New Filename", text: $inputNewSampleFilename)
						.textFieldStyle(RoundedBorderTextFieldStyle())
				}
				
				VStack(alignment: .leading, spacing: 4) {
					Text("Tags (comma-separated)")
						.font(.caption)
						.foregroundColor(.secondary)
					TextField("Enter Tags", text: $inputNewSampleTags)
						.textFieldStyle(RoundedBorderTextFieldStyle())
				}
				
				VStack(alignment: .leading, spacing: 4) {
					Text("Description (optional)")
						.font(.caption)
						.foregroundColor(.secondary)
					TextEditor(text: .constant("Placeholder"))
						.font(.system(size: 14, weight: .medium, design: .rounded)) // Uses a rounded, medium-weight system font
						.lineSpacing(10) // Sets the line spacing to 10 points
						.border(Color.gray, width: 1)
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
			.frame(maxWidth: 400)
		}
}

#Preview {
	RenameView(
		currentFilename: "SampleFile.wav",
		inputNewSampleFilename: .constant("NewSample"),
		inputNewSampleTags: .constant("tag1, tag2"), inputNewSampleDescription: "",
		onRename: {}
	)
}
