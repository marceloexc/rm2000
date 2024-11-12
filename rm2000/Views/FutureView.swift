import Foundation
import SwiftUI
import OSLog

struct FutureView: View {
	
	
	
	var body: some View {
		ZStack {
			Image("BodyBackgroundTemp")
				.scaledToFill()
			VStack {
				LCDScreenView()
				//					.position(x: 300, y: 150)
				//^ cant get that to accurately put the LCD screen where I want it
				Button(action: {
					print("Recording Button Pressed!")
					
				}) {
					Image("RecordButtonTemp")
					.renderingMode(.original)
				}.buttonStyle(BorderlessButtonStyle())
			}
		}
	}
}

struct LCDScreenView: View {
	var body: some View {
		ZStack {
			Image("LCDScreenEmptyTemp")
				.resizable()
				.scaledToFit()
				.frame(width: 286)
				.offset(x:0, y:0)

			VStack {
				Text("RM2000")
					.font(Font.custom("TINY5x3-100", size: 24))
					.foregroundColor(Color("LCDTextColor"))
				
				Text("00:00")
					.font(Font.custom("Tachyo", size: 50))
					.foregroundColor(Color("LCDTextColor"))
				
				Text("AAC Format 44.1/k")
					.font(Font.custom("TINY5x3-100", size: 20))
					.foregroundColor(Color("LCDTextColor"))
			}
		}
	}
}

#Preview {
	FutureView()
}
