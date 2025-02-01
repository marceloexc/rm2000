import Foundation
import OSLog

extension Logger {
	private static var subsystem = Bundle.main.bundleIdentifier!
	
	// logger object for taperecorder
	static let streamProcess = Logger(subsystem: subsystem, category: "taperecorder")
	
	static let sharedStreamState = Logger(subsystem: subsystem, category: "sharedstreamstate")
	
	static let viewModels = Logger(subsystem: subsystem, category: "viewmodels")
}
