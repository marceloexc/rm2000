import Foundation

struct NewRecording {
	var id: UUID
	var url: URL
	
	init() {
		self.id = UUID()
		self.url = WorkingDirectory.applicationSupportPath()
			.appendingPathComponent("\(id.uuidString).aac")
	}
}
