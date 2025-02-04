import Foundation
import AVFoundation

let regString = /(.+)--(.+)\.(.+)/


struct Sample: Identifiable {
	
	var id: UUID
	
	let title: String
	let tags: [String]
	let url: URL
	let filename: String
	let description: String?
	let duration: TimeInterval?
	
	
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
		self.description = ""
		self.duration = Sample.getDuration(fileURL: fileURL)
	}
	
	private static func getTitle(fileURL: URL) -> String {
		if let match = try? regString.firstMatch(in: fileURL.lastPathComponent) {
			return String(match.1)
		}
		return ""
	}
	
	private static func getTags(fileURL: URL) -> [String] {
		if let match = try? regString.firstMatch(in: fileURL.lastPathComponent) {
			return String(match.2).components(separatedBy: "_")
		}
		return []
	}
	
	private static func getDuration(fileURL: URL) -> TimeInterval? {
		let audioAsset = AVURLAsset(url: fileURL)
		var error: NSError? = nil
		
		let status = audioAsset.statusOfValue(forKey: "duration", error: &error)
		if status == .loaded {
			let duration = audioAsset.duration
			print(duration)
			return CMTimeGetSeconds(duration)
		}
		return nil
	}
	
	private static func passesRegex(_ pathName: String) -> Bool {
		(try? regString.wholeMatch(in: pathName)) != nil
	}
}

struct WorkingDirectory {
	static let appIdentifier = "com.marceloexc.rm2000"
	
	static func applicationSupportPath() -> URL {
		let documentURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
		
		let path = documentURL.appendingPathComponent(appIdentifier)
		
		return path
	}
}
