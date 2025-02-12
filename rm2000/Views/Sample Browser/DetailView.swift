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
				.listStyle(.plain)
			} else {
				ProgressView("Loading recordings...")
			}
		}
	}
}

struct SampleIndividualListItem: View {
	@Environment(\.openWindow) var openWindow
	var sampleItem: Sample
	
	var body: some View {
		HStack {
			VStack(alignment: .leading, spacing: 4) {
				Text(sampleItem.title)
					.font(.title3)
				HStack(spacing: 8) {
					ForEach(sampleItem.tags, id:\.self) { tagName in
						Text("#"+tagName)
							.font(.caption)
							.padding(2)
							.background(Color.gray.opacity(0.2))
							.cornerRadius(3)
					}
				}
			}
			
			Spacer()
			
			HStack {
				Button {
					openWindow(id: "inspector")
				} label: {
					Image(systemName: "info.circle.fill")
				}
				.buttonStyle(.automatic)
				.controlSize(.small)
			}
		}
		.contentShape(Rectangle())
		.onTapGesture(count: 2) {
			NSWorkspace.shared.open(sampleItem.url)
		}
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
