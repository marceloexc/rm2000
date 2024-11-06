import Foundation
import SwiftUI
import OSLog

struct FutureView: View {
	var body: some View {
		ZStack {
			// Background
			RoundedRectangle(cornerRadius: 20)
				.fill(LinearGradient(
					gradient: Gradient(colors: [Color(red: 0.95, green: 0.95, blue: 0.95),
												Color(red: 0.85, green: 0.85, blue: 0.85)]),
					startPoint: .top,
					endPoint: .bottom
				))
				.shadow(color: Color(white: 0.7), radius: 10, x: 0, y: 10)
			
			// Content
			VStack(spacing: 20) {
				Text("Hello, World!")
					.font(.title)
					.fontWeight(.bold)
				
				RoundedRectangle(cornerRadius: 10)
					.fill(Color(red: 0.9, green: 0.9, blue: 0.9))
					.frame(height: 100)
					.shadow(color: Color(white: 0.7), radius: 5, x: 0, y: 5)
				
				RoundedRectangle(cornerRadius: 10)
					.fill(Color(red: 0.9, green: 0.9, blue: 0.9))
					.frame(height: 100)
					.shadow(color: Color(white: 0.7), radius: 5, x: 0, y: 5)
			}
			.padding(30)
		}
		.padding(20)
	}
}

#Preview {
	FutureView()
}
