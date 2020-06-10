/*
 * An interface for handling requests received from Javascript
 */
protocol JavascriptBridge {

    // Log a Javascript message in the mobile app
    func log(message: String?)

    // Return true if there are existing tokens
    func isLoggedIn() -> String

    // Try to return an access token
    func getAccessToken() -> String

    // Try to refresh an access token
    func refreshAccessToken() -> String
}
