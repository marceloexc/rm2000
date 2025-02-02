import Foundation
import SwiftUI

struct SampleBrowserView: View {
	@StateObject private var viewModel: SampleBrowserViewModel
	@Environment(\.openURL) private var openURL
	
	init(viewModel: SampleBrowserViewModel = SampleBrowserViewModel()) {
		_viewModel = StateObject(wrappedValue: viewModel)
	}
	
	var body: some View {
		NavigationSplitView {
			SidebarView(viewModel: viewModel)
				.listStyle(SidebarListStyle())
				.navigationTitle("Recordings")
		} detail: {
			DetailView(viewModel: viewModel)
		}
		.toolbar {
			ToolbarItemGroup(placement: .automatic) {
				Button(action: {
					NSWorkspace.shared.open(WorkingDirectory.applicationSupportPath())
				}) {
					Image(systemName: "folder")
				}
			}
		}
		.onAppear {
			viewModel.listAllRecordings()
		}
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
	
	func passesRegex(_ pathName: String) -> Bool {
		(try? regString.wholeMatch(in: pathName)) != nil
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

