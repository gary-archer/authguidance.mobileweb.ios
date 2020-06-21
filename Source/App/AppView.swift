import SwiftUI

/*
 * The main view of the app is a full screen web view
 */
struct AppView: View {

    @ObservedObject var model: AppViewModel
    @State private var runningWebView = false

    init() {
        self.model = AppViewModel()
    }

    /*
     * Render a webview in the entire area
     */
    var body: some View {

        // Get sizes
        let deviceWidth = UIScreen.main.bounds.size.width
        let deviceHeight = UIScreen.main.bounds.size.height
        let textFont = deviceWidth < 768 ? Font.system(.caption) : Font.system(.body)

        // The user must be logged into the app in order to pass a token to the system browser
        var isInvokeSystemBrowserDisabled = true
        if self.model.authenticator != nil && self.model.authenticator!.isLoggedIn() {
            isInvokeSystemBrowserDisabled = false
        }

        // Render the
        return VStack {

            // Show the header
            Text("Mobile Web Integration")
                .font(.title)
                .underline()
                .foregroundColor(Colors.lightBlue)
                .padding(.bottom)
                .onTapGesture(perform: self.onHome)

            if self.model.isInitialised && !self.runningWebView {

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

            // Display application level errors when applicable
            if self.model.error != nil {

                ErrorSummaryView(
                    hyperlinkText: "Application Problem Encountered",
                    dialogTitle: "Application Error",
                    error: self.model.error!)
                        .padding(.bottom)
            }

            // Render the web view
            if self.runningWebView && self.model.error == nil {

                CustomWebView(
                    configurationAccessor: { self.model.configuration },
                    authenticatorAccessor: { self.model.authenticator },
                    onLoadError: self.handleError,
                    width: deviceWidth,
                    height: deviceHeight)
            }

            // Fill up the remainder of the view if needed
            Spacer()
        }
        .onAppear(perform: self.initialiseApp)
    }

    /*
     * The main startup logic occurs after the initial render
     */
    private func initialiseApp() {

        do {
            // Initialise the model, which manages mutable data
            try self.model.initialise()

        } catch {

            // Report error details
            self.model.error = ErrorHandler.fromException(error: error)
        }
    }

    /*
     * When the header text is clicked, reset state and show the mobile selection screen again
     */
    private func onHome() {

        self.model.error = nil
        self.runningWebView = false
        if !self.model.isInitialised {
            self.initialiseApp()
        }
    }

    /*
     * Update state to render the web view
     */
    private func onInvokeWebView() {
        self.runningWebView = true
    }

    /*
     * Update state to show the system browser
     */
    private func onInvokeSystemBrowser() {
    }

    /*
     * Login and logout responses for claimed HTTPS schemes are received here
     */
    func handleDeepLink(url: URL) {
        self.model.handleOAuthResponse(url: url)
    }

    /*
     * Receive errors from other parts of the app
     */
    func handleError(error: UIError) {
        self.model.error = error
    }
}
