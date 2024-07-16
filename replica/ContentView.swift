//
//  ContentView.swift
//  replica
//
//  Created by Marcelo Mendez on 7/13/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "waveform.circle.fill")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("REPLICA")
				.font(.title)
			
			Button(action: {
				print("Feature not yet implemented!")
			}) {
				HStack{
					Image(systemName: "recordingtape")
					Text("Start Recording!")
				}
			}
			.cornerRadius(/*@START_MENU_TOKEN@*/3.0/*@END_MENU_TOKEN@*/)
			}
        }
    }


#Preview {
    ContentView()
}
