import Foundation
import SwiftUI

/*
 * The application entry point
 */
@main
struct DemoAppApp: App {

    private let orientationHandler = OrientationHandler()

    /*
     * The app's main layout
     */
    var body: some Scene {

        WindowGroup {
            AppView(model: AppViewModel())
                .environmentObject(self.orientationHandler)
                .onOpenURL(perform: { url in

                    // Claimed HTTPS scheme login / logout responses are received as deep links here
                    // self.viewRouter.handleDeepLink(url: url)
                })
                .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in

                    // Handle orientation changes in the app by updating the handler
                    // We also need to include the handler as an environment object in all views which need redrawing
                    self.orientationHandler.isLandscape = UIDevice.current.orientation.isLandscape
                }
        }
    }
}
