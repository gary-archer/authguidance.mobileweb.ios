import SwiftUI

/*
 * The main view of the app is a full screen web view
 */
struct AppView: View {

    @ObservedObject var model: AppViewModel
    @State private var runningInWebView = false

    init() {
        self.model = AppViewModel()
    }

    /*
     * Render a webview in the entire area
     */
    var body: some View {

        let deviceWidth = UIScreen.main.bounds.size.width
        let deviceHeight = UIScreen.main.bounds.size.height
        let enabledStyle = HeaderButtonStyle(width: deviceWidth * 0.4, disabled: false)
        let disabledStyle = HeaderButtonStyle(width: deviceWidth * 0.4, disabled: true)

        return VStack {

            // Show the header
            Text("Mobile Web Integration")
                .font(.title)
                .underline()
                .foregroundColor(Colors.lightBlue)
                .padding(.bottom)
                .onTapGesture(perform: self.onHome)

            if !runningInWebView {

                // Allow the user to choose how to execute the web content
                HStack {

                    Button(action: self.onWebView) {
                       Text("Run SPA in Web View")
                    }
                    .buttonStyle(enabledStyle)

                    Button(action: self.onSystemBrowser) {
                       Text("Run SPA in System Browser")
                    }
                    .buttonStyle(disabledStyle)
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

            // Display application level mobile errors if applicable
            if self.model.error != nil {

                ErrorSummaryView(
                    hyperlinkText: "Application Problem Encountered",
                    dialogTitle: "Application Error",
                    error: self.model.error!)
                        .padding(.bottom)
            }

            // Render the web view in the remaining space
            if self.runningInWebView {
                CustomWebView(
                    configurationAccessor: { self.model.configuration },
                    authenticatorAccessor: { self.model.authenticator },
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
     * Update state to show the web view
     */
    private func onWebView() {
        self.runningInWebView = true
    }

    /*
     * Update state to show the system browser
     */
    private func onSystemBrowser() {
        print("Invoking the SPA in the System Browser is not yet implemented")
    }

    /*
     * When the header text is clicked, reset state and show the mobile selection screen again
     */
    private func onHome() {
        self.runningInWebView = false
    }

    /*
     * Login and logout responses for claimed HTTPS schemes are received here
     */
    func handleDeepLink(url: URL) {
        self.model.handleOAuthResponse(url: url)
    }
}
