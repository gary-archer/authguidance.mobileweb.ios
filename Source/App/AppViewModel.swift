import Foundation
import SwiftCoroutine
import SwiftUI

/*
 * A primitive view model class to manage global objects and state
 */
class AppViewModel: ObservableObject {

    // The configuration data is used by views
    @Published var configuration: Configuration?

    // The authenticator does OAuth work
    @Published var authenticator: Authenticator?

    // A flag to record whether we initialised correctly
    @Published var isInitialised = false

    // Display mobile errors invoking the SPA
    @Published var error: UIError?

    /*
     * Read configuration and create global objects
     */
    func initialise() throws {

        // Reset state flags
        self.isInitialised = false

        // Load configuration and create global objects
        self.configuration = try ConfigurationLoader.load()
        self.authenticator = AuthenticatorImpl(configuration: self.configuration!.oauth)

        // Indicate successful startup
        self.isInitialised = true
    }

    /*
     * Process any claimed HTTPS scheme login / logout responses
     */
    func handleOAuthResponse(url: URL) {

        // If this is not a login or logout response, the view router handles the deep link
        if self.authenticator!.isOAuthResponse(responseUrl: url) {
            self.authenticator!.resumeOperation(responseUrl: url)
        }
    }
}
