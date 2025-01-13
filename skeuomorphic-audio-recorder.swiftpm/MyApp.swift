import SwiftUI

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(maxHeight: .infinity)
                .background(
                    LinearGradient(colors: [Color(hex: 0xAAAACB), Color(hex: 0x444444)], startPoint: .topLeading, endPoint: .bottomTrailing)
                        .withNoise(opacity: 0.03)
                        .ignoresSafeArea()
                )
        }
    }
}
