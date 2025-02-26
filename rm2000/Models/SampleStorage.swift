import Combine
import FZMetadata
import Foundation
import OSLog
import SwiftUICore

@MainActor
final class SampleStorage: ObservableObject {

	let appState = AppState.shared
	static let shared = SampleStorage()

	@Published var UserDirectory: SampleDirectory
	@Published var ArchiveDirectory: SampleDirectory

	init() {
		self.UserDirectory = SampleDirectory(
			directory: appState.sampleDirectory!)
		self.ArchiveDirectory = SampleDirectory(
			directory: WorkingDirectory.applicationSupportPath())
	}
}

class SampleDirectory: ObservableObject {

	/*
	 todo when i come back -

	 this needs to index all of the files in the folder...

	 so that i can then add them via (applySampleEdits)

	 */

	@Published var files: [MetadataItem] = []
	private var directory: URL
	private var query = MetadataQuery()

	init(directory: URL) {
		self.directory = directory
		startInitialFileScan()

	}

	private func startInitialFileScan() {
		do {
			let directoryContents = try FileManager.default.contentsOfDirectory(
				at: self.directory, includingPropertiesForKeys: nil)

			for fileURL in directoryContents {
				if let fileMetadata = MetadataItem(url: fileURL) {
					files.append(fileMetadata)
				}
				
				Logger.appState.info("Added \(fileURL) to files as FZMetadata")
			}
		} catch {
			//			Logging.appState.error("Error initial listing of directory contents: \(error.localizedDescription)")
		}
	}

	func applySampleEdits(fromFile: URL, createdSample: Sample) {

		let fileManager = FileManager.default
		let appendingPathComponent = createdSample.filename

		do {
			try fileManager.moveItem(at: fromFile, to: createdSample.fileURL)

			// TODO - this is ugly
			if !((createdSample.description?.isEmpty) != nil) {
				setDescriptionFieldInFile(
					createdSample, (createdSample.description)!)
			}
		} catch {
			Logger.appState.error("Can't move file")
		}
	}

	private func setDescriptionFieldInFile(
		_ createdSample: Sample, _ description: String
	) {
		/*
			 why two file attributes that almost do the exact same thing?
			 because turns out that kMDItemFinderComment is unreliable,
			 (https://apple.stackexchange.com/questions/471023/to-copy-a-file-and-preserve-its-comment)
			 and this is a way of having redundancy.
			 */

		let attrs = [
			"com.apple.metadata:kMDItemComment",
			"com.apple.metadata:kMDItemFinderComment",
		]
		let fileURL = createdSample.fileURL

		if let descriptionData = description.data(using: .utf8) {
			do {
				try attrs.forEach { attr in
					try fileURL.setExtendedAttribute(
						data: descriptionData, forName: attr)
				}
			} catch {
				Logger.appState.error(
					"Couldn't apply xattr's to \(createdSample)")
			}
		}
	}
}
