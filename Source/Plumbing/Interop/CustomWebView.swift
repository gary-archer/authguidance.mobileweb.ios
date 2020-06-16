import SwiftUI
import WebKit

/*
 * Wrap a WKWebView and handle method calls from the SPA
 */
final class CustomWebView: NSObject, UIViewRepresentable, WKScriptMessageHandler {

    private let appConfiguration: AppConfiguration?
    private var bridge: JavascriptBridge
    private let width: CGFloat
    private let height: CGFloat
    private var webView: WKWebView?

    /*
     * Store configuration and create the bridge object
     */
    init(appConfiguration: AppConfiguration?, width: CGFloat, height: CGFloat) {

        self.appConfiguration = appConfiguration
        self.width = width
        self.height = height
        self.bridge = JavascriptBridgeImpl()
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

        if self.appConfiguration != nil {

            let webViewUrl = URL(string: self.appConfiguration!.webBaseUrl)!
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

        // Deserialize
        if let json = try? JSONSerialization.jsonObject(
            with: (message.body as? String)!.data(using: .utf8)!,
            options: []) {

            // Get fields
            if let fields = json as? [String: Any] {
                let methodName = fields["methodName"] as? String
                let callbackName = fields["callbackName"] as? String
                let logMessage = fields["message"] as? String

                // Process the request
                var result = ""
                switch methodName {

                case "isLoggedIn":
                    result = self.bridge.isLoggedIn()

                case "getAccessToken":
                    result = self.bridge.getAccessToken()

                case "refreshAccessToken":
                    result = self.bridge.refreshAccessToken()

                default:
                    self.bridge.log(message: logMessage)
                }

                // Return the result, to end the promise in the mobile app when required
                self.successResult(callbackName: callbackName, result: result)
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
    private func successResult(callbackName: String?, result: String) {

        if callbackName != nil {
            let javascript = "window['\(callbackName!)']('\(result)', null)"
            self.webView?.evaluateJavaScript(javascript, completionHandler: nil)
        }
    }

    /*
     * Return a failure result to the SPA
     */
    private func errorResult(callbackName: String?, result: String) {

        if callbackName != nil {
            let javascript = "window['\(callbackName!)'](null, '\(result)')"
            self.webView?.evaluateJavaScript(javascript, completionHandler: nil)
        }
    }
}