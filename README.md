# authguidance.mobileweb.ios

### Overview

* An iOS Sample using OAuth 2.0 and Open Id Connect, referenced in my blog at https://authguidance.com
* **The goal of this sample is to integrate Secured Web Content into an Open Id Connect Secured iOS App**

### Details

* See the **Mobile Web Integration Overview** for a visual summary and instructions on how to run the code

### Technologies and Behaviour

* XCode and SwiftUI are used to develop an app that uses web content from a Secured Cloud SPA
* Secured ReactJS SPA views can be run from the mobile app, without a second login 
* SPA views can execute in a web view and call back the mobile app to get tokens
* SPA views can execute in the system browser using a one time token sent from the mobile app

### Middleware Used

* The [AppAuth-iOS Library](https://github.com/openid/AppAuth-iOS) is used to implement Authorization Code Flow (PKCE) via a Claimed HTTPS Scheme
* AWS Cognito is used as a Cloud Authorization Server
* The iOS Keychain is used to store encrypted tokens on the device after login
* AWS API Gateway is used to host our sample OAuth 2.0 Secured API
* AWS S3 and Cloudfront are used to serve mobile deep linking asset files and interstitial web pages
