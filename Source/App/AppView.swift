import SwiftUI

/*
 * The main view of the app is a full screen web view
 */
struct AppView: View {

    // External objects
    @EnvironmentObject var orientationHandler: OrientationHandler
    @ObservedObject var model: AppViewModel

    // Fields to control rendering state
    @State private var runningWebView = false

    /*
     * Create the model class
     */
    init() {
        self.model = AppViewModel()
    }

    /*
     * Render a webview in the entire area
     */
    var body: some View {

        let deviceWidth = UIScreen.main.bounds.size.width
        let deviceHeight = UIScreen.main.bounds.size.height
        
        return VStack {

            // Show the title area
            TitleView(onTapped: self.onHome)

            // Show the menu when applicable
            if self.model.isInitialised && !self.runningWebView {
                MenuView(
                    authenticator: self.model.authenticator,
                    onInvokeWebView: self.onInvokeWebView,
                    onInvokeSystemBrowser: self.onInvokeSystemBrowser
                )
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
     * Update state to render the SPA in our web view
     */
    private func onInvokeWebView() {
        self.runningWebView = true
    }

    /*
     * Open our SPA in the system browser
     */
    private func onInvokeSystemBrowser() {
        
        let url = URL(string: self.model.configuration!.app.webBaseUrl)!
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
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
