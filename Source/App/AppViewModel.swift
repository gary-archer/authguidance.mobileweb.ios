import Foundation
import SwiftCoroutine
import SwiftUI

/*
 * A primitive view model class to manage global objects and state
 */
class AppViewModel: ObservableObject {

    // Global objects created after construction
    private var configuration: Configuration?
    var authenticator: AuthenticatorImpl?

    // State used by the view
    @Published var isInitialised = false
    @Published var error: UIError?

    /*
     * Initialise or reinitialise global objects, including processing configuration
     */
    func initialise(onLoginRequired: @escaping () -> Void) throws {

        // Reset state flags
        self.isInitialised = false

        // Load the configuration from the embedded resource
        self.configuration = try ConfigurationLoader.load()

        // Create the global authenticator
        self.authenticator = AuthenticatorImpl(configuration: self.configuration!.oauth)

        // Indicate successful startup
        self.isInitialised = true
    }
}
