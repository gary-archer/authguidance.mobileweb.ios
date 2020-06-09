# authguidance.mobilewebview.android

### Overview

* An Android Sample using OAuth 2.0 and Open Id Connect, referenced in my blog at https://authguidance.com
* **The goal of this sample is to integrate Secured Web Content into an Open Id Connect Secured Android App**

### Details

* See the **Android WebView Overview** page for a summary and instructions on how to run the code

### Technologies

* Kotlin and Jetpack are used to develop a Single Activity App that uses web content from a Secured Cloud SPA

### Middleware Used

* The [AppAuth-Android Library](https://github.com/openid/AppAuth-Android) is used to implement the Authorization Code Flow (PKCE)
* AWS Cognito is used as a Cloud Authorization Server
* The Android Key Store is used to store encrypted tokens on the device after login
* AWS API Gateway is used to host our sample OAuth 2.0 Secured API
* AWS S3 and Cloudfront are used to serve mobile deep linking asset files and interstitial web pages
