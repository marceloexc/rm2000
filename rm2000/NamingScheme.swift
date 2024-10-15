import Foundation

struct SampleFilenameStructure {
	var title: String = ""
	var tags: [String] = []
	var identifier: UUID
	var fileExtension: String = "aac" //could be an enum?
	
	init(sampleTitle: String, sampleTags: String) {
		self.title = sampleTitle
		self.tags = sampleTags.components(separatedBy: ",")
		self.identifier = UUID()
	}
}

func newSampleFilenameData(_ filenameString: String, _ tagString: String) -> SampleFilenameStructure {
	
	return SampleFilenameStructure(sampleTitle: filenameString, sampleTags: tagString)
}

