import Foundation
import SwiftUI

struct SampleBrowserView: View {
	@StateObject private var viewModel: SampleBrowserViewModel
	@Environment(\.openURL) private var openURL
	
	@State private var totalSamples: Int = 0
	
	init(viewModel: SampleBrowserViewModel = SampleBrowserViewModel()) {
		_viewModel = StateObject(wrappedValue: viewModel)
	}
	
	var body: some View {
		NavigationSplitView {
			SidebarView(viewModel: viewModel)
				.listStyle(SidebarListStyle())
		} detail: {
			DetailView(viewModel: viewModel)
		}
		.navigationTitle("Sample Browser")
		.navigationSubtitle(String(totalSamples))
		.toolbar {
			ToolbarItemGroup(placement: .status) {
				NewRecordingButton()
				NewCollectionButton()
				ShareButton()
				OpenInFinderButton()
			}
		}
		.task {
			viewModel.listAllRecordings()
			totalSamples = viewModel.sampleArray.count
		}
		.searchable(text: .constant(""), placement: .sidebar)
	}
}

struct OpenInFinderButton: View {
	var body: some View {
		Button(action: {
			NSWorkspace.shared.open(WorkingDirectory.applicationSupportPath())
		}) {
			Image(systemName: "folder.fill")
				.font(.system(size: 16, weight: .black))
				.foregroundColor(.blue)
				.padding(8)
				.contentShape(Rectangle())		}
		.buttonStyle(PlainButtonStyle())
		.help("Open in Finder")
	}
}

struct NewRecordingButton: View {
	var body: some View {
		Button(action: {
			let _ = print("new recording")
		}) {
			Image(systemName: "waveform.badge.plus")
				.font(.system(size: 16, weight: .black))
				.foregroundColor(.green)
				.padding(8)
				.contentShape(Rectangle())
		}
		.buttonStyle(PlainButtonStyle())
		.help("New Recording")
	}
}

struct ShareButton : View {
	var body: some View {
		Button(action: {
			let _ = print("share button")
		}) {
			Image(systemName: "square.and.arrow.up")
				.font(.system(size: 16, weight: .black))
				.foregroundColor(.orange)
				.padding(8)
				.contentShape(Rectangle())
		}
		.buttonStyle(PlainButtonStyle())
		.help("New Recording")
	}
}

struct NewCollectionButton: View {
	var body: some View {
		Button(action: {
			let _ = print("share button")
		}) {
			Image(systemName: "rectangle.stack.fill.badge.plus")
				.font(.system(size: 16, weight: .black))
				.foregroundColor(.purple)
				.padding(8)
				.contentShape(Rectangle())
		}
		.buttonStyle(PlainButtonStyle())
		.help("New Recording")
	}
}

class SampleBrowserViewModel: ObservableObject {
	@Published var finishedProcessing: Bool = false
	
	@Published var sampleArray: [Sample] = []
	@Published var indexedTags: [String] = []
	@Published var selectedTag: String?
	
	private let regString = /(.+)--(.+)\.(.+)/
	
	func listAllRecordings() {
		let path = WorkingDirectory.applicationSupportPath()
		
		do {
			let directoryContents = try FileManager.default.contentsOfDirectory(at: path, includingPropertiesForKeys: nil)
			
			for fileURL in directoryContents {
				if let sample = Sample(fileURL: fileURL) {
					sampleArray.append(sample)
				}
			}
			
			indexedTags = sampleArray.flatMap{$0.tags}
			indexedTags = Array(Set(indexedTags)).sorted()
			finishedProcessing = true
		} catch {
			print("Error listing directory contents: \(error.localizedDescription)")
			finishedProcessing = false
		}
	}
}



#Preview("Sample Browser") {
	let vm = SampleBrowserViewModel()
//	uncomment this if you need data
//	vm.directoryContents = [
//		URL(string: "file:///sample1--drums_bass.wav")!,
//		URL(string: "file:///sample2--vocals_synth.mp3")!,
//		URL(string: "file:///sample3--drums_effects.aiff")!
//	]
//	vm.indexedTags = ["drums", "bass", "vocals", "synth", "effects"]
	vm.finishedProcessing = true
	return SampleBrowserView(viewModel: vm)
}

