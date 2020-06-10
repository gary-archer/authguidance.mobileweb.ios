import SwiftUI

/*
* An error entity whose fields are rendered when there is a problem
*/
class UIError: Error {

    // Fields populated during error translation
    var area: String
    var errorCode: String
    var userMessage: String
    var utcTime: String
    var appAuthCode: String
    var details: String
    let stack: [String]

    /*
     * Create the error form supportable fields
     */
    init(area: String, errorCode: String, userMessage: String) {
        self.area = area
        self.errorCode = errorCode
        self.userMessage = userMessage
        self.appAuthCode = ""
        self.details = ""
        self.utcTime = ""
        self.stack = Thread.callStackSymbols
        self.utcTime = DateUtils.dateToUtcDisplayString(date: Date())
    }
}
