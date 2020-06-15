import Foundation

/*
 * A class to manage error translation
 */
struct ErrorHandler {

    static let AppAuthNamespace = "org.openid.appauth."

    /*
     * Return a typed error from a general UI exception
     */
    static func fromException (error: Error) -> UIError {

        // Already handled
        var uiError = error as? UIError
        if uiError != nil {
            return uiError!
        }

        // Create the error
        uiError = UIError(
            area: "Mobile UI",
            errorCode: ErrorCodes.generalUIError,
            userMessage: "A technical problem was encountered in the UI")

        // Update from the caught exception
        ErrorHandler.updateFromException(error: error, uiError: uiError!)
        return uiError!
    }

    /*
     * Used to throw programming level errors that should not occur
     * Equivalent to throwing a RuntimeException in Android
     */
    static func fromMessage(message: String) -> UIError {

        return UIError(
            area: "Mobile UI",
            errorCode: ErrorCodes.generalUIError,
            userMessage: message)
    }

    /*
     * Return an error to short circuit execution
     */
    static func fromLoginRequired() -> UIError {

        return UIError(
            area: "Login",
            errorCode: ErrorCodes.loginRequired,
            userMessage: "A login is required so the API call was aborted")
    }

    /*
     * Return an error to indicate that the Safari View Controller window was closed
     */
    static func fromRedirectCancelled() -> UIError {

        return UIError(
            area: "Redirect",
            errorCode: ErrorCodes.redirectCancelled,
            userMessage: "The redirect request was cancelled")
    }

    /*
     * Handle errors triggering login requests
     */
    static func fromLoginRequestError(error: Error) -> UIError {

        // Already handled
        var uiError = error as? UIError
        if uiError != nil {
            return uiError!
        }

        uiError = UIError(
            area: "Login",
            errorCode: ErrorCodes.loginRequestFailed,
            userMessage: "A technical problem occurred during login processing"
        )

        // Update it from the expcetion
        if ErrorHandler.isAppAuthError(error: error) {
            ErrorHandler.updateFromAppAuthException(error: error, uiError: uiError!)
        } else {
            ErrorHandler.updateFromException(error: error, uiError: uiError!)
        }

        return uiError!
    }

    /*
     * Handle errors processing login responses
     */
    static func fromLoginResponseError(error: Error) -> UIError {

        // Already handled
        var uiError = error as? UIError
        if uiError != nil {
            return uiError!
        }

        uiError = UIError(
            area: "Login",
            errorCode: ErrorCodes.loginResponseFailed,
            userMessage: "A technical problem occurred during login processing"
        )

        // Update it from the expcetion
        if ErrorHandler.isAppAuthError(error: error) {
            ErrorHandler.updateFromAppAuthException(error: error, uiError: uiError!)
        } else {
            ErrorHandler.updateFromException(error: error, uiError: uiError!)
        }

        return uiError!
    }

    /*
     * Handle logout errors
     */
    static func fromLogoutRequestError(error: Error) -> UIError {

        // Already handled
        var uiError = error as? UIError
        if uiError != nil {
            return uiError!
        }

        // Create the error
        uiError = UIError(
            area: "Logout",
            errorCode: ErrorCodes.logoutRequestFailed,
            userMessage: "A technical problem occurred during logout processing")

        // Update it from the expcetion
        if ErrorHandler.isAppAuthError(error: error) {
            ErrorHandler.updateFromAppAuthException(error: error, uiError: uiError!)
        } else {
            ErrorHandler.updateFromException(error: error, uiError: uiError!)
        }

        return uiError!
    }

    /*
     * Handle token related errors
     */
    static func fromTokenError(error: Error, errorCode: String) -> UIError {

        // Already handled
        var uiError = error as? UIError
        if uiError != nil {
            return uiError!
        }

        // Create the error
        uiError = UIError(
            area: "Token",
            errorCode: errorCode,
            userMessage: "A technical problem occurred during token processing")

        // Update it from the expcetion
        if ErrorHandler.isAppAuthError(error: error) {
            ErrorHandler.updateFromAppAuthException(error: error, uiError: uiError!)
        } else {
            ErrorHandler.updateFromException(error: error, uiError: uiError!)
        }

        return uiError!
    }

    /*
     * See if the error was returned from AppAuth libraries
     */
    private static func isAppAuthError(error: Error) -> Bool {

        let authError = error as NSError
        return authError.domain.contains(ErrorHandler.AppAuthNamespace)
    }

    /*
     * Get details from the AppAuth error
     */
    private static func updateFromAppAuthException(error: Error, uiError: UIError) {

        let authError = error as NSError

        // Get the AppAuth error category from the domain field and shorten it for readability
        let category = ErrorHandler.getAppAuthCategory(domain: authError.domain)

        // Set other fields from the AppAuth error and extract the error code
        uiError.details = authError.localizedDescription
        uiError.appAuthCode = "\(category) / \(authError.code)"
    }

    /*
     * Get details from the exception
     */
    private static func updateFromException(error: Error, uiError: UIError) {
        uiError.details = error.localizedDescription
    }

    /*
     * Translate the error category to a readable form
     */
    private static func getAppAuthCategory(domain: String) -> String {

        // Remove the namespace
        let category = domain.replacingOccurrences(
            of: ErrorHandler.AppAuthNamespace,
            with: "")
                .uppercased()

        // Remove the OAUTH prefix, to form a value such as 'TOKEN'
        return category.replacingOccurrences(
            of: "OAUTH_",
            with: "")
                .uppercased()
    }
}
