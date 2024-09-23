import Foundation
import SwiftUI
import OSLog

struct SidebarView: View {
	var body: some View {
		List {
			Label("Tags 1", systemImage: "tv")
			Label("Tags 1", systemImage: "tv")
			Label("Tags 1", systemImage: "tv")
			Label("Tags 1", systemImage: "tv")
		}
		.listStyle(SidebarListStyle())
	}
}
