import Foundation

/*
 * A class to do the work requested from Javascript
 */
class JavascriptBridgeImpl: JavascriptBridge {
    
    /*
     * Log a Javascript message in the mobile app
     */
    func log(message: String?) {
        
        if message != nil {
            print("MobileDebug: \(message!)")
        }
    }

    /*
     * Return true if logged in
     */
    func isLoggedIn() -> String {
        return String(false)
    }
    
    /*
     * Try to return an access token
     */
    func getAccessToken() -> String {
        return "y802efhu0"
    }
    
    /*
     * Try to refresh an access token
     */
    func refreshAccessToken() -> String {
        return ""
    }
}
