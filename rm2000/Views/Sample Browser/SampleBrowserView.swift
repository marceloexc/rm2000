import Foundation
import Combine
import SwiftUI

@MainActor
struct SampleBrowserView: View {
	@StateObject private var viewModel: SampleBrowserViewModel
	@Environment(\.openURL) private var openURL
	
	@State private var totalSamples: Int = 0
	
	init() {
			_viewModel = StateObject(wrappedValue: SampleBrowserViewModel())
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

@MainActor
class SampleBrowserViewModel: ObservableObject {
	@Published var sampleArray: [Sample] = []
	@Published var indexedTags: [String] = []
	@Published var finishedProcessing: Bool = false
	@Published var selectedTag: String?
	
	private var sampleStorage: SampleStorage
	private var cancellables = Set<AnyCancellable>()
	
	@MainActor
	init(sampleStorage: SampleStorage = SampleStorage.shared) {
		self.sampleStorage = sampleStorage
		
		sampleStorage.UserDirectory.$files
			.receive(on: DispatchQueue.main)
			.sink { [weak self] newFiles in
				self?.sampleArray = newFiles
				self?.finishedProcessing = true
			}
			.store(in: &cancellables)
		
		sampleStorage.UserDirectory.$indexedTags
			.receive(on: DispatchQueue.main)
			.sink { [weak self] newTags in
				self?.indexedTags = Array(newTags).sorted()
			}
			.store(in: &cancellables)
	}
	
	func refresh() {
		// Force refresh logic
	}
}
