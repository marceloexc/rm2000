import Foundation
import FZMetadata

let regString = /(.+)--(.+)\.(.+)/

struct Sample: Identifiable {

	var id: UUID

	let title: String
	let tags: [String]
	let url: URL
	let filename: String

	// optionals, dont process them right away on Sample(:_) initialization until they are called
	// because these are a bit slow
	// and its faster to get the durations of an array of Sample's with FZMetadata
	var description: String? {
		Sample.getDescription(fileURL: url)
	}

	var duration: Double? {
		Sample.getDuration(fileURL: url)
	}

	init?(fileURL: URL) {

		// see if this is actually a valid url
		guard Sample.passesRegex(fileURL.lastPathComponent) else {
			return nil
		}

		self.id = UUID()
		self.title = Sample.getTitle(fileURL: fileURL)
		self.tags = Sample.getTags(fileURL: fileURL)
		self.url = fileURL
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
}
