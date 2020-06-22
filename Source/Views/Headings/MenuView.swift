import SwiftUI

/*
 * A simple menu area container
 */
struct MenuView: View {

    private let authenticator: Authenticator?
    private let onInvokeWebView: () -> Void
    private let onInvokeSystemBrowser: () -> Void

    init(
        authenticator: Authenticator?,
        onInvokeWebView: @escaping () -> Void,
        onInvokeSystemBrowser: @escaping () -> Void) {

        self.authenticator = authenticator
        self.onInvokeWebView = onInvokeWebView
        self.onInvokeSystemBrowser = onInvokeSystemBrowser
    }

    /*
     * Render the menu area
     */
    var body: some View {

        // Get sizes
        let deviceWidth = UIScreen.main.bounds.size.width
        let textFont = deviceWidth < 768 ? Font.system(.caption) : Font.system(.body)

        // The user must be logged into the app in order to pass a token to the system browser
        var isInvokeSystemBrowserDisabled = true
        if self.authenticator != nil && self.authenticator!.isLoggedIn() {
            isInvokeSystemBrowserDisabled = false
        }

        return VStack {

            // Allow the user to choose how to execute the web content
            HStack {

                Button(action: self.onInvokeWebView) {
                   Text("Run SPA in Web View")
                }
                .buttonStyle(HeaderButtonStyle(width: deviceWidth * 0.4, disabled: false))
                .disabled(false)

                Button(action: self.onInvokeSystemBrowser) {
                   Text("Run SPA in Browser")
                }
                .buttonStyle(HeaderButtonStyle(width: deviceWidth * 0.4, disabled: isInvokeSystemBrowserDisabled))
                .disabled(isInvokeSystemBrowserDisabled)
            }

            // Show some explanatory text
            HStack {

                Text("""
                    Run secured views from the Single Page Application in a WKWebView control.\n
                    The SPA will call back the mobile host to perform logins and to get tokens.
                    """)
                    .frame(width: deviceWidth * 0.4)
                    .font(textFont)
                    .padding()

                Text("""
                     Run the secured Single Page Application by opening it in the system browser.\n
                     An encrypted one time token is sent to the SPA so that login is automatic.
                     """)
                    .frame(width: deviceWidth * 0.4)
                    .font(textFont)
                    .padding()
            }
        }
    }
}
