import SwiftUI
import WebKit

/*
 * Wrap a WKWebView and handle method calls from the SPA
 */
final class CustomWebView: NSObject, UIViewRepresentable, WKScriptMessageHandler {

    private let configuration: Configuration?
    private let authenticatorAccessor: () -> Authenticator?
    private let width: CGFloat
    private let height: CGFloat
    private var webView: WKWebView?

    /*
     * Store configuration and create the bridge object
     */
    init(configuration: Configuration?,
         authenticatorAccessor: @escaping () -> Authenticator?,
         width: CGFloat,
         height: CGFloat) {

        self.configuration = configuration
        self.authenticatorAccessor = authenticatorAccessor
        self.width = width
        self.height = height
    }

    /*
     * Create the WKWebView and wire up behaviour
     */
    func makeUIView(context: Context) -> WKWebView {

        // First enable Javascript
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true

        // Make a bridge to the mobile app available to our SPA
        let configuration = WKWebViewConfiguration()
        configuration.userContentController.add(self, name: "mobileBridge")
        configuration.userContentController.addUserScript(self.createConsoleLogUserScript())
        configuration.preferences = preferences

        // Create and return the web view
        let rect = CGRect(x: 0, y: 0, width: self.width, height: self.height)
        self.webView = WKWebView(frame: rect, configuration: configuration)
        return self.webView!
    }

    /*
     * Load the view's content
     */
    func updateUIView(_ webview: WKWebView, context: Context) {

        if self.configuration != nil {

            let webViewUrl = URL(string: self.configuration!.app.webBaseUrl)!
            let request = URLRequest(url: webViewUrl)
            webview.load(request)
        }
    }

    /*
     * Handle incoming calls from Javascript by deferring to the Javascript bridge
     */
    func userContentController(
        _ userContentController: WKUserContentController,
        didReceive message: WKScriptMessage) {

        // Get the JSON request data
        let data = (message.body as? String)!.data(using: .utf8)!
        if let requestJson = try? JSONSerialization.jsonObject(with: data, options: []) {

            // Get a collection of top level fields
            if let requestFields = requestJson as? [String: Any] {

                let callbackName = requestFields["callbackName"] as? String
                do {

                    // Handle the request
                    let bridge = JavascriptBridge(authenticator: self.authenticatorAccessor()!)
                    let data = try bridge.handleMessage(requestFields: requestFields)

                    // Return a success response, to resolve the promise in the calling Javascript
                    if data != nil {
                        self.successResult(callbackName: callbackName!, result: data!)
                    }

                } catch {

                    // Return an error response, to reject the promise in the calling Javascript
                    let uiError = ErrorHandler.fromException(error: error)
                    self.errorResult(callbackName: callbackName!, errorJson: uiError.toJson())
                }
            }
        }
    }

    /*
     * Route SPA console.log statements to the mobile app's handler
     */
    private func createConsoleLogUserScript() -> WKUserScript {

        let script = """
            var console = {
                log: function(msg) {
                    const data = {
                        methodName: 'log',
                        message: `${msg}`,
                    };
                    window.webkit.messageHandlers.mobileBridge.postMessage(JSON.stringify(data));
                }
            };
        """

        return WKUserScript(
            source: script,
            injectionTime: WKUserScriptInjectionTime.atDocumentStart,
            forMainFrameOnly: false
        )
    }

    /*
     * Return a success result to the SPA
     */
    private func successResult(callbackName: String, result: String) {

        let javascript = "window['\(callbackName)']('\(result)', null)"
        self.webView?.evaluateJavaScript(javascript, completionHandler: nil)
    }

    /*
     * Return a failure result to the SPA
     */
    private func errorResult(callbackName: String, errorJson: String) {

        let javascript = "window['\(callbackName)'](null, '\(errorJson)')"
        self.webView?.evaluateJavaScript(javascript, completionHandler: nil)
    }
}
