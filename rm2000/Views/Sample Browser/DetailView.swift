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
		List(viewModel.sampleArray) { sample in
			if sample.filename.contains(selectedTag) {
				SampleIndividualListItem(sampleItem: sample)
			}
		}
	}
}

struct AllRecordingsView: View {
	@ObservedObject var viewModel: SampleBrowserViewModel
	
	var body: some View {
		Group {
			if viewModel.finishedProcessing {
				List(viewModel.sampleArray) { sample in
					SampleIndividualListItem(sampleItem: sample)
				}
			} else {
				ProgressView("Loading recordings...")
			}
		}
	}
}

struct SampleIndividualListItem: View {
	var sampleItem: Sample
	
	var body: some View {
		
		Text(sampleItem.filename)
			.contextMenu {
				Button("Open File") {
					NSWorkspace.shared.open(sampleItem.url)
				}
			}
	}
}


#Preview("Detail View") {
	let vm = SampleBrowserViewModel()
//	vm.directoryContents = [
//		URL(string: "file:///sample1--drums_bass.wav")!,
//		URL(string: "file:///sample2--vocals_synth.mp3")!
//	]
	vm.finishedProcessing = true
	return DetailView(viewModel: vm)
}

