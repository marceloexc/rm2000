import Foundation

struct SampleFilenameStructure {
	var sampleTitle: String = ""
	var sampleTags: [String] = []
	var sampleIdentifier: UUID
	var sampleFileExtension: String = ".aac" //could be an enum?
	
	init(sampleTitle: String, sampleTags: String) {
		self.sampleTitle = sampleTitle
		self.sampleTags = sampleTags.components(separatedBy: ",")
		self.sampleIdentifier = UUID()
	}
}

func getFilenameStructure(_ filenameString: String, _ tagString: String) -> SampleFilenameStructure {
	
	return SampleFilenameStructure(sampleTitle: filenameString, sampleTags: tagString)
}

