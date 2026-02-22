import SwiftUI

@main
struct AdzanBarApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        MenuBarExtra("AdzanBar", systemImage: "moon.fill") {
            MenuBarView()
        }
        .menuBarExtraStyle(.window)
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Hide from Dock completely
        NSApp.setActivationPolicy(.accessory)
    }
}
