// TrimmablePlayerView.swift
import SwiftUI
import AVKit
import AVFoundation

class PlayerViewModel: ObservableObject {
	@Published var playerView: AVPlayerView?
	var player: AVPlayer?
	var activeRecording: NewRecording
	
	init(activeRecording: NewRecording) {
		self.activeRecording = activeRecording
		setupPlayer()
	}
	
	fileprivate func setupPlayer() {
		let fileURL = activeRecording.url
		
		let asset = AVAsset(url: fileURL)
		let playerItem = AVPlayerItem(asset: asset)
		
		player = AVPlayer(playerItem: playerItem)
		
		let view = AVPlayerView()
		view.player = player
		view.controlsStyle = .inline
		view.showsTimecodes = true
		view.showsSharingServiceButton = false
		view.showsFrameSteppingButtons = false
		view.showsFullScreenToggleButton = false
		
		playerView = view
	}
	
	func beginTrimming() {
		guard let playerView = playerView else { return }
		
		DispatchQueue.main.async {
			playerView.beginTrimming { result in
				switch result {
				case .okButton:
					print("Trim completed")
				case .cancelButton:
					print("Trim cancelled")
				@unknown default:
					print("Unknown trim result")
				}
			}
		}
	}
}

struct TrimmablePlayerView: View {
	@StateObject private var viewModel: PlayerViewModel
	
	init(recording: NewRecording) {
		_viewModel = StateObject(wrappedValue: PlayerViewModel(activeRecording: recording))
	}
	
	var body: some View {
		VStack {
			if let playerView = viewModel.playerView {
				AudioPlayerView(playerView: playerView)
					.frame(height: 60)
			} else {
				Text("Player not available")
					.foregroundColor(.secondary)
			}
		}
	}
}

struct AudioPlayerView: NSViewRepresentable {
	let playerView: AVPlayerView
	
	func makeNSView(context: Context) -> AVPlayerView {
		Task {
			do {
				try await playerView.activateTrimming()
				playerView.hideTrimButtons()
			} catch {
				print("Failed to activate trimming: \(error)")
			}
		}
		return playerView
	}
	
	func updateNSView(_ nsView: AVPlayerView, context: Context) {}
}
