import Foundation

/*
 * A class to manage error translation
 */
struct ErrorHandler {

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
}
