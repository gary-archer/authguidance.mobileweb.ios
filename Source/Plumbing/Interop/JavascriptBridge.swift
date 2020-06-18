import Foundation
import SwiftUI
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

            case "login":
                result = try self.login().await()

            case "logout":
                result = try self.logout().await()

            case "expireAccessToken":
                result = try self.expireAccessToken()

            case "expireRefreshToken":
                result = try self.expireRefreshToken()

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
     * Handle SPA requests to get an access token
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
     * Handle SPA requests to refresh an access token
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
     * Handle SPA requests to trigger a login redirect
     */
    private func login() throws -> CoFuture<String> {

        let promise = CoPromise<String>()

        // Run async operations in a coroutine
        DispatchQueue.main.startCoroutine {

            do {
                // Do the login redirect on the UI thread
                let response = try self.authenticator.startLogin(viewController: self.getHostingViewController())
                    .await()

                // Do the code exchange on a background thread
                try DispatchQueue.global().await {
                    try self.authenticator.finishLogin(authResponse: response)
                        .await()
                }

                // Indicate success
                promise.success("")

            } catch {

                // Indicate failure
                promise.fail(error)
            }
        }

        return promise
    }

    /*
     * Handle SPA requests to trigger a logout redirect
     */
    private func logout() throws -> CoFuture<String> {

        let promise = CoPromise<String>()

        // Run async operations in a coroutine
        DispatchQueue.main.startCoroutine {

            do {
                // Do the login redirect on the UI thread
                try self.authenticator.logout(viewController: self.getHostingViewController())
                    .await()

                // Indicate success
                promise.success("")

            } catch {

                // Indicate failure
                promise.fail(error)
            }
        }

        return promise
    }

    /*
     * Handle test requests from the SPA to expire the access token
     */
    private func expireAccessToken() throws -> String {

        self.authenticator.expireAccessToken()
        return ""
    }

    /*
     * Handle test requests from the SPA to expire the access token
     */
    private func expireRefreshToken() throws -> String {

        self.authenticator.expireRefreshToken()
        return ""
    }

    /*
     * A helper method to get the scene delegate, on which the login response is received
     */
    private func getHostingViewController() -> UIViewController {

        let scene = UIApplication.shared.connectedScenes.first
        return (scene!.delegate as? SceneDelegate)!.window!.rootViewController!
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
