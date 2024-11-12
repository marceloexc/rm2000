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
				Image("RecordButtonTemp")
			}
		}
	}
}


struct LCDScreenView: View {
	var body: some View {
			Image("LCDScreenTemp")
				.resizable()
				.scaledToFit()
				.frame(width: 286)
				.offset(x:0, y:0)
		}
}

#Preview {
	FutureView()
}
