//
//  ContentView.swift
//  replica
//
//  Created by Marcelo Mendez on 7/13/24.
//

import SwiftUI

struct ContentView: View {
	
	@State var fileDirectory: String = "/Users/marceloexc/Downloads/"
	@State var textToRecord: String = "recording.aac"
	@State private var isRecording: Bool = false
	let recorder = Recorder()
	
	var body: some View {
		VStack {
			Image(systemName: "waveform.circle.fill")
				.imageScale(.large)
				.foregroundStyle(.tint)
			Text("REPLICA")
				.font(.title)
			
			TextField("Enter directory here", text: self.$fileDirectory)
				.textFieldStyle(.roundedBorder)
			
			TextField("Enter text to record", text: $textToRecord)
				.textFieldStyle(.roundedBorder)
			
			if isRecording {
				Button(action: stopRecording) {
					HStack {
						Image(systemName: "stop.circle")
						Text("Stop Recording")
					}
				}
				.foregroundColor(.red)
			} else {
				Button(action: startRecording) {
					HStack {
						Image(systemName: "recordingtape")
						Text("Start Recording!")
					}
				}.cornerRadius(3.0)
			}
		}
	}
	
	private func startRecording() {
		Task {
			do {
				try await recorder.startRecording(filename: textToRecord, directory: fileDirectory)
				isRecording = true
			} catch {
				print("Error starting recording: \(error)")
			}
		}
	}
	
	private func stopRecording() {
		Task {
			do {
				recorder.stopRecording()
				isRecording = false
			} catch {
				print("Error stopping recording: \(error)")
			}
		}
	}
}

#Preview {
	ContentView()
}
