import SwiftUI

/*
 * The main view of the app is a full screen web view
 */
struct MainView: View {
    
    /*
     * Render the tree of views
     */
    var body: some View {
        
        let url = URL(string: "https://www.bbc.co.uk")
        let request = URLRequest(url: url!)
        return VStack {
            WebView(request: request)
        }
    }
}
