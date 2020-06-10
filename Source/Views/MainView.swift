import SwiftUI

/*
 * The main view of the app is a full screen web view
 */
struct MainView: View {

    private var requestUrl: URLRequest

    init() {
        let webViewUrl = URL(string: "https://web.mycompany.com/spa")!
        self.requestUrl = URLRequest(url: webViewUrl)
    }

    /*
     * Render a webview in the entire area
     */
    var body: some View {

        GeometryReader { geometry in
            VStack {
                CustomWebView(request: self.requestUrl, width: geometry.size.width, height: geometry.size.height)
            }
        }
    }
}
