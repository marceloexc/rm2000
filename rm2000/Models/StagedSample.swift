import Foundation
import FZMetadata


// when the sample is recording and is being held in the temporary directory (usually the supportpath atm), we still need to hold the data
// and then
struct StagedSample {
	var id: UUID
	
	var title: String?
	var tags: String?
	var description: String?
	
//	uncomment these when im ready
//	extension should be an enum
//	var extension: Extension
//	var url: URL
	
	init() {
		self.id = UUID()
	}
	
	func getFilepath() -> URL {
		let generatedFilename = self.id.uuidString + ".aac"
		
		let filePath = WorkingDirectory.applicationSupportPath().appendingPathComponent(generatedFilename)
		
		return filePath
		
	}
	
	
}
