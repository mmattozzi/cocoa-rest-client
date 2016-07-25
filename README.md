About
=================
CocoaRestClient is a Mac OS X app for testing HTTP/Restful endpoints. 

I love curl, but sometimes I need my output XML or JSON pretty printed. I want to be able to save frequent PUT and POST bodies for later and copy and paste from responses easily. Think of this as curl with a light UI. 

The goal of this project is to build a lightweight native Cocoa app for testing and debugging HTTP Restful services.
This project was greatly inspired by the Java rest-client (https://code.google.com/archive/p/rest-client). 

Official project website: http://mmattozzi.github.io/cocoa-rest-client/

Download
=================
If you're not looking to compile from source and only want to use this tool, latest releases are here:

[Download List](https://github.com/mmattozzi/cocoa-rest-client/releases)

You can also install it through [homebrew](http://brew.sh/) as a [cask](http://caskroom.io/):

```sh
# install cask if necessary
brew install caskroom/cask/brew-cask
# install CocoaRestClient
brew cask install cocoarestclient
```

Features
=================
* Make GET, PUT, POST, DELETE, HEAD calls
* Set request body to arbitrary content
* Set request headers
* Set HTTP basic & digest auth
* Auto-format (pretty print) XML, JSON, and MsgPack responses
* Some cool Ace Editor themes for syntax highlighting
* Display response headers
* Quick save requests in a handy drawer using folder organization
* Upload files and form data via multipart/form-data
* Enter POST/PUT input as raw input or key/value pairs
* Reports response latency
* Command-R reloads last request
* Lightweight: Low real memory usage
* SSL Support (including untrusted certificates)
* Optionally follows HTTP redirects
* Import and export requests

Screenshots
=================

![Screenshot 2](https://github.com/mmattozzi/cocoa-rest-client/raw/master/screenshots/cocoa-rest-client-2.png)

*Pretty print JSON content. Set and save HTTP headers.*

![Screenshot 1](https://github.com/mmattozzi/cocoa-rest-client/raw/master/screenshots/cocoa-rest-client-1.png)

*Pretty print XML content. Quick save of request URLs, body, and headers in one convenient drawer.*

![Screenshot 3](https://github.com/mmattozzi/cocoa-rest-client/raw/master/screenshots/cocoa-rest-client-3.png)

*Set HTTP Basic or Digest Auth. Displays HTTP response headers.*

![Screenshot 4](https://github.com/mmattozzi/cocoa-rest-client/raw/master/screenshots/cocoa-rest-client-4.png)

*Set HTTP request body content to a raw text blob or a list of parameters.*

![Screenshot 5](https://github.com/mmattozzi/cocoa-rest-client/raw/master/screenshots/cocoa-rest-client-5.png)

*Upload files using HTTP multipart requests. HTTP form encoding also supported.*

Source and Contributions
=================
* Source code is hosted on Github: https://github.com/mmattozzi/cocoa-rest-client
* If you would like to contribute, please fork and create a pull request on Github 
* Source uses [Cocoapods](https://cocoapods.org/) for dependencies, to get started, [install CocoaPods](http://guides.cocoapods.org/using/getting-started.html) and in the main project directory run:
    
    ```
      pod install
    ```
  * Note that you must have a github account and a public key registered with github so that CocoaPods can pull down a github-hosted dependency. 

Credits
=================
* Contains json-framework/SBJSON library (https://code.google.com/archive/p/json-framework) embedded in it, source and all
* Much guidance from Adrian Kosmaczewski blog (http://kosmaczewski.net/playing-with-http-libraries/)
* Sparkle automatic update framework (https://github.com/sparkle-project/Sparkle)
* ACEView syntax highlighting (https://github.com/ACENative/ACEView)
* Base64 encoding uses Matt Gallagher's NSData+Base64 code (http://www.cocoawithlove.com/2009/06/base64-encoding-options-on-mac-and.html)
* Code & testing contributions: Adam Venturella, Sergey Klimov, Cory Alder, Tito Ciuro, Eric Broska, Nicholas Robinson, Diego Massanti, Robert Horvath

