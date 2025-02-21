import Foundation
import FZMetadata

struct StagedSample {
	let id: UUID
	var fileURL: URL
	var title: String?
	var tags: String?
	var description: String?
		
	init(newRecording: NewRecording, title: String, tags: String, description: String) {
		self.id = newRecording.id
		self.fileURL = newRecording.url
		self.title = title
		self.tags = tags
		self.description = description
	}
}
