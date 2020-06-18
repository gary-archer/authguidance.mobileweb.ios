import SwiftUI

/*
 * The main view of the app is a full screen web view
 */
struct AppView: View {

    @ObservedObject var model: AppViewModel

    init() {
        self.model = AppViewModel()
    }

    /*
     * Render a webview in the entire area
     */
    var body: some View {

        GeometryReader { geometry in
            VStack {
                CustomWebView(
                    configuration: self.model.configuration,
                    authenticatorAccessor: { self.model.authenticator },
                    width: geometry.size.width,
                    height: geometry.size.height)
            }
            .onAppear(perform: self.initialiseApp)
        }
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
            let uiError = ErrorHandler.fromException(error: error)
            self.handleError(error: uiError)
        }
    }

    /*
     * For this sample we will simplify and just use console output of errors
     */
    private func handleError(error: UIError) {
        ErrorConsoleReporter.output(error: error)
    }
}
