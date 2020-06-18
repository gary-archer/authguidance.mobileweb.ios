import Foundation
import SwiftCoroutine

/*
 * Receive Javascript requests, do the mobile work, then return a Javascript response
 */
class JavascriptBridge: ObservableObject {

    private let authenticator: Authenticator

    init(authenticator: Authenticator) {
        self.authenticator = authenticator
    }

    /*
     * Handle incoming messages from Javascript
     */
    func handleMessage(requestFields: [String: Any]) throws -> CoFuture<String?> {

        let promise = CoPromise<String?>()
        var result: String?

        do {

            // Determine and call the method
            let methodName = requestFields["methodName"] as? String
            switch methodName {

            case "isLoggedIn":
                result = try self.isLoggedIn()

            case "getAccessToken":
                result = try self.getAccessToken().await()

            case "refreshAccessToken":
                result = try self.refreshAccessToken().await()
                
            default:
                self.log(message: requestFields["message"] as? String)
            }

            // Return a success result
            promise.success(result)

        } catch {

            // Return a failure result
            promise.fail(error)
        }

        return promise
    }

    /*
     * Return true if logged in
     */
    private func isLoggedIn() throws -> String {

        let isLoggedIn = self.authenticator.isLoggedIn()
        return String(isLoggedIn)
    }

    /*
     * Try to return an access token
     */
    private func getAccessToken() throws -> CoFuture<String> {

        let promise = CoPromise<String>()

        do {
            let accessToken = try self.authenticator.getAccessToken().await()
            promise.success(accessToken)

        } catch {
            promise.fail(error)
        }

        return promise
    }

    /*
     * Try to refresh an access token
     */
    private func refreshAccessToken() throws -> CoFuture<String> {

        let promise = CoPromise<String>()

        do {
            let accessToken = try self.authenticator.refreshAccessToken().await()
            promise.success(accessToken)

        } catch {
            promise.fail(error)
        }

        return promise
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
