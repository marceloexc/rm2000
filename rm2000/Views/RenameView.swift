//
//  RenameView.swift
//  rm2000
//
//  Created by Marcelo Mendez on 10/1/24.
//

import SwiftUI

struct RenameView: View {
	
	let currentFilename: String
	@Binding var newFilename: String
	var onRename: () -> Void
	
    var body: some View {
		VStack {
			Text("Rename Recording")
				.font(.headline)
			
			TextField("New Filename", text: $newFilename)
			
			Button("Rename", action: onRename)
		}
    }
}

//#Preview {
//	RenameView()
//}
