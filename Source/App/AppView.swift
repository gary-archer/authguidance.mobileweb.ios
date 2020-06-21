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

        // Get dimensions
        let deviceWidth = UIScreen.main.bounds.size.width
        let deviceHeight = UIScreen.main.bounds.size.height

        // Get styles for buttons
        let enabledButtonStyle = HeaderButtonStyle(width: deviceWidth * 0.4, disabled: false)
        let disabledButtonStyle = HeaderButtonStyle(width: deviceWidth * 0.4, disabled: true)

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
                    .buttonStyle(enabledButtonStyle)

                    Button(action: self.onInvokeSystemBrowser) {
                       Text("Run SPA in System Browser")
                    }
                    .buttonStyle(self.model.authenticator!.isLoggedIn() ? enabledButtonStyle : disabledButtonStyle)
                }

                // Show some explanatory text
                HStack {

                    Text("""
                        Run secured views from the Single Page Application in a WKWebView control.
                        The SPA will call back the mobile host to perform logins and to get tokens.
                        """)
                        .frame(width: deviceWidth * 0.4)
                        .font(Font.system(.caption))
                        .padding()

                    Text("""
                         Run the secured Single Page Application by opening it in the system browser.
                         An encrypted one time token is sent to the SPA so that login is automatic.
                         """)
                        .frame(width: deviceWidth * 0.4)
                        .font(Font.system(.caption))
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

            // Render the web view in the remaining space
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

        // In case there was a startup problem, retry when the header text is clicked
        if !self.model.isInitialised {
            self.initialiseApp()
        }

        self.model.error = nil
        self.runningWebView = false
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
