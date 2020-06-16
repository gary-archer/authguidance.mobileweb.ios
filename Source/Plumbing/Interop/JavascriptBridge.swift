import Foundation

/*
 * Receive Javascript requests, do the mobile work, then return a Javascript response
 */
class JavascriptBridge: ObservableObject {

    private let authenticator: Authenticator?

    init(authenticator: Authenticator?) {
        self.authenticator = authenticator
    }

    /*
     * Handle incoming messages from Javascript
     */
    func handleMessage(requestFields: [String: Any]) throws -> String? {

        var result: String?

        // Call the appropriate method based on input
        let methodName = requestFields["methodName"] as? String
        switch methodName {

        case "isLoggedIn":
            result = try self.isLoggedIn()

        case "getAccessToken":
            result = try self.getAccessToken()

        case "refreshAccessToken":
            result = try self.refreshAccessToken()

        default:
            self.log(message: requestFields["message"] as? String)
        }

        return result
    }

    /*
     * Return true if logged in
     */
    private func isLoggedIn() throws -> String {

        print("isLoggedIn called")
        if self.authenticator != nil {
            print("YAY - authenticator is not null")
        }

        return String(false)
    }

    /*
     * Try to return an access token
     */
    private func getAccessToken() throws -> String {

        throw ErrorHandler.fromMessage(message: "getAccessToken went horribly wrong")
        // return "y802efhu0"
    }

    /*
     * Try to refresh an access token
     */
    private func refreshAccessToken() throws -> String {

        throw ErrorHandler.fromMessage(message: "refreshAccessToken went horribly wrong")
        // return ""
    }

    /*
     * Log a Javascript message in the mobile app
     */
    private func log(message: String?) {

        if message != nil {
            print("MobileDebug: \(message!)")
        }
    }
}
