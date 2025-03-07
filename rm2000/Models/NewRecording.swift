import Foundation

struct NewRecording {
	var id: UUID
	var fileURL: URL
	
	// TODO - hardcoded file extension string
	init() {
		self.id = UUID()
		self.fileURL = WorkingDirectory.applicationSupportPath()
			.appendingPathComponent("\(id.uuidString).aac")
	}
}
