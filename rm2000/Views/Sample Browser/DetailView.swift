import SwiftUI

struct DetailView: View {
	@ObservedObject var viewModel: SampleBrowserViewModel
	
	var body: some View {
		Group {
			if let selectedTag = viewModel.selectedTag {
				TaggedRecordingsView(viewModel: viewModel, selectedTag: selectedTag)
			} else {
				AllRecordingsView(viewModel: viewModel)
			}
		}
	}
}

private struct TaggedRecordingsView: View {
	@ObservedObject var viewModel: SampleBrowserViewModel
	let selectedTag: String
	
	var body: some View {
		List(viewModel.directoryContents, id: \.self) { sampleFileURL in
			if sampleFileURL.lastPathComponent.contains(selectedTag) {
				SampleIndividualListItem(sampleFileURL: sampleFileURL)
			}
		}
	}
}

private struct AllRecordingsView: View {
	@ObservedObject var viewModel: SampleBrowserViewModel
	
	var body: some View {
		Group {
			if viewModel.finishedProcessing {
				List(viewModel.directoryContents, id: \.self) { sampleFileURL in
					if viewModel.passesRegex(sampleFileURL.lastPathComponent) {
						SampleIndividualListItem(sampleFileURL: sampleFileURL)
					}
				}
			} else {
				ProgressView("Loading recordings...")
			}
		}
	}
}

struct SampleIndividualListItem: View {
	var sampleFileURL: URL
	
	var body: some View {
		
		Text(sampleFileURL.lastPathComponent)
			.contextMenu {
				Button("Open File") {
					NSWorkspace.shared.open(sampleFileURL)
				}
			}
	}
}


#Preview("Detail View") {
	let vm = SampleBrowserViewModel()
	vm.directoryContents = [
		URL(string: "file:///sample1--drums_bass.wav")!,
		URL(string: "file:///sample2--vocals_synth.mp3")!
	]
	vm.finishedProcessing = true
	return DetailView(viewModel: vm)
}

