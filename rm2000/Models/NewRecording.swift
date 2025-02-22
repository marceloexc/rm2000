import Foundation

struct NewRecording {
	var id: UUID
	var fileURL: URL
	
	init() {
		self.id = UUID()
		self.fileURL = WorkingDirectory.applicationSupportPath()
			.appendingPathComponent("\(id.uuidString).aac")
	}
}
