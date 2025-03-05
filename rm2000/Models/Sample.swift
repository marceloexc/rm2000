import Foundation
import FZMetadata

let regString = /(.+)--(.+)\.(.+)/

struct Sample: Identifiable {

	var id: UUID
	let title: String
	let tags: [String]
	let fileURL: URL
	var filename: String?
	private var storedDescription: String?

	// optionals, dont process them right away on Sample(:_) initialization until they are called
	// because these are a bit slow
	// and its faster to get the durations of an array of Sample's with FZMetadata
	var description: String? {
		Sample.getDescription(fileURL: fileURL)
	}

	var duration: Double? {
		Sample.getDuration(fileURL: fileURL)
	}
	
	var metadata: MetadataItem {
		fileURL.metadata!
	}
	
	init(newRecording: NewRecording, title: String, tags: String, description: String?) {
		self.id = newRecording.id
		self.fileURL = newRecording.fileURL
		self.title = title
		self.tags = tags.components(separatedBy: "_")
		self.storedDescription = description
	}

	init?(fileURL: URL) {

		// see if this is actually a valid url
		guard Sample.passesRegex(fileURL.lastPathComponent) else {
			return nil
		}

		self.id = UUID()
		self.title = Sample.getTitle(fileURL: fileURL)
		self.tags = Sample.getTags(fileURL: fileURL)
		self.fileURL = fileURL
		self.filename = fileURL.lastPathComponent
	}

	private static func getTitle(fileURL: URL) -> String {
		if let match = try? regString.firstMatch(in: fileURL.lastPathComponent)
		{
			return String(match.1)
		}
		return ""
	}

	private static func getTags(fileURL: URL) -> [String] {
		if let match = try? regString.firstMatch(in: fileURL.lastPathComponent)
		{
			return String(match.2).components(separatedBy: "_")
		}
		return []
	}

	private static func getDescription(fileURL: URL) -> String? {

		if let metadata = fileURL.metadata {
			return metadata.description
		}
		return nil
	}

	private static func getDuration(fileURL: URL) -> Double {

		if let metadata = fileURL.metadata {
			print(metadata.duration!)
			return metadata.duration?.rawValue ?? 0
		}

		return 0
	}

	private static func passesRegex(_ pathName: String) -> Bool {
		(try? regString.wholeMatch(in: pathName)) != nil
	}
	
	private func constructSampleFilename(title: String, tags: [String]) -> String {
		let title = title
		_ = tags

//		let formattedTags = tags.replacingOccurrences(of: " ", with: "_")

		// Construct the filename in the format "title--tag1_tag2_tag3.aac"
		let filename = "\(title)--changeme.aac"
		return filename
	}
}
