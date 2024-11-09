import Foundation
import SwiftUI
import OSLog

struct FutureView: View {
	
	let BodyGradient = Gradient(colors: [Color(red: 0.0, green: 0.0, blue: 0.0), Color(red: 0.5, green: 0.5, blue: 0.5), Color(red: 0.0, green: 0.0, blue: 0.0)])
	
	var body: some View {
		ZStack {
			// Background
			RoundedRectangle(cornerRadius: 20)
				.fill(LinearGradient(
					gradient: BodyGradient,
					startPoint: .top,
					endPoint: .bottom
				))
				.shadow(color: Color(white: 0.7), radius: 10, x: 0, y: 10)
			
			// Content
			VStack(spacing: 20) {
				Text("Hello, World!")
					.font(.title)
					.fontWeight(.bold)
				
				Image("RecordButtonTemp")
				
				RoundedRectangle(cornerRadius: 10)
					.fill(AngularGradient(gradient: BodyGradient, center: .bottomLeading))
							   .frame(height: 400)
							   .shadow(color: Color(white: 0.7), radius: 5, x: 0, y: 5)
							   .overlay(
								//TODO - this texture is too noisy
								Image("NoiseTexture")
									.resizable(resizingMode: .tile)
//									.imageScale(.large)
									.blendMode(.softLight)
									.opacity(0.26)
							   )
				
				LCDScreenView()
				
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


struct LCDScreenView: View {
	var body: some View {
		ZStack {
			Color(red: 0.792, green: 0.451, blue: 0.216)
				.ignoresSafeArea()
				.frame(height: 300)
			VStack {
				Image(systemName: "waveform.circle.fill")
					.imageScale(.large)
					.foregroundStyle(.tint)
				Text("rm2000")
					.font(.title)
			}
			
		}
		.overlay(
			Image("LCDInnerShadow")
				.resizable(resizingMode: .stretch)
//				.blendMode(.softLight) //experiment with this
		)
		.overlay(RoundedRectangle(cornerRadius: 15.0).strokeBorder(Color.blue, lineWidth: 10.0))
		.padding(10.0)
		.overlay(RoundedRectangle(cornerRadius: 25.0).strokeBorder(Color.red, lineWidth: 10.0))
	}
}

#Preview {
	FutureView()
}
