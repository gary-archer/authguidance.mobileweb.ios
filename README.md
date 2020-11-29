# authguidance.mobileweb.ios

### Overview 

* An iOS Sample using OAuth 2.x and Open Id Connect, referenced in my blog at https://authguidance.com
* **The goal of this sample is to integrate Secured Web Content into an Open Id Connect Secured iOS App**

### Details

* See the [Overview Page](https://authguidance.com/2020/06/17/mobile-web-integration-goals/) for a summary and instructions on how to run the code
* See the post on [Coding Key Points](https://authguidance.com/2020/06/18/mobile-web-integration-coding-key-points/) for further technical details


### Technologies and Behaviour

* XCode and SwiftUI are used to develop an app that uses web content from a Secured Cloud SPA
* Secured ReactJS SPA views can be run from the mobile app, without a second login 
* SPA views can execute in a web view and call back the mobile app to get tokens
* SPA views can alternatively execute in a system browser and rely on Single Sign On cookies
### Middleware Used

* The [AppAuth-iOS Library](https://github.com/openid/AppAuth-iOS) implements Authorization Code Flow (PKCE) via a Claimed HTTPS Scheme
* AWS Cognito is used as a Cloud Authorization Server
* The iOS Keychain is used to store encrypted tokens on the device after login
* AWS API Gateway is used to host our sample OAuth Secured API
* AWS S3 and Cloudfront are used to serve mobile deep linking asset files and interstitial web pages
