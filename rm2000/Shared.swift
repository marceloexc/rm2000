import Foundation

struct WorkingDirectory {
	static let appIdentifier = "com.marceloexc.rm2000"

	static func applicationSupportPath() -> URL {
		let documentURL = FileManager.default.urls(
			for: .applicationSupportDirectory, in: .userDomainMask
		).first!

		let path = documentURL.appendingPathComponent(appIdentifier)

		return path
	}
}
