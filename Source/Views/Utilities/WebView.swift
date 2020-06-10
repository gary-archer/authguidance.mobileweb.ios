import SwiftUI
import WebKit

/*
 * A simple wrapper around a WKWebView
 */
struct WebView : UIViewRepresentable {
      
    let request: URLRequest
      
    /*
     * Create the view
     */
    func makeUIView(context: Context) -> WKWebView  {
        return WKWebView()
    }
    
    /*
    * Load the view
    */
    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.load(request)
    }
}
