About
=================
CocoaRestClient is a Mac OS X app for testing HTTP/Restful endpoints.

I love curl, but sometimes I need my output XML or JSON pretty printed. I want to be able to save frequent PUT and POST bodies for later and copy and paste from responses easily. Think of this as curl with a light UI.

The goal of this project is to build a lightweight native Cocoa app for testing and debugging HTTP Restful services.
This project was greatly inspired by the Java rest-client (https://code.google.com/archive/p/rest-client).

Official project website: http://mmattozzi.github.io/cocoa-rest-client/

[![FOSSA Status](https://app.fossa.io/api/projects/git%2Bgithub.com%2Fmmattozzi%2Fcocoa-rest-client.svg?type=shield)](https://app.fossa.io/projects/git%2Bgithub.com%2Fmmattozzi%2Fcocoa-rest-client?ref=badge_shield)

Download
=================
If you're not looking to compile from source and only want to use this tool, latest releases are here:

[Download List](https://github.com/mmattozzi/cocoa-rest-client/releases)

You can also install it through [homebrew](https://brew.sh/) as a [cask](https://caskroom.github.io):

```sh
# install cask if necessary
brew tap caskroom/cask
# install CocoaRestClient
brew install --cask cocoarestclient
```

Features
=================
* Make GET, PUT, POST, DELETE, HEAD calls
* Set request body to arbitrary content
* Set request headers
* Edit URL parameters in an easy to read table
* Set HTTP basic & digest auth
* Auto-format (pretty print) XML, JSON, and MsgPack responses
* Some cool Ace Editor themes for syntax highlighting
* Display response headers
* Quick save requests in a handy sidebar using folder organization
* Upload files and form data via multipart/form-data
* Enter POST/PUT input as raw input or key/value pairs
* Reports response latency
* Command-R reloads last request
* Lightweight: Low real memory usage and < 6mb DMG
* SSL Support (including untrusted certificates)
* Optionally follows HTTP redirects
* Import and export requests
* New in version 1.4: Uses native macOS tabs and windows.
* New in version 1.4.3: Generate a unified diff between two response body tabs
* Supports native MacOS dark mode
* Mac M1/arm and intel processor support

Screenshots
=================

<img src="https://mmattozzi.github.io/cocoa-rest-client/screenshots/screenshot-1.png" width=400/>

*Pretty print JSON content. Set and save HTTP headers.*

<img src="https://mmattozzi.github.io/cocoa-rest-client/screenshots/screenshot-4.png" width=400/>

*Pretty print XML content. Quick save of request URLs, body, and headers in one convenient drawer.*

<img src="https://mmattozzi.github.io/cocoa-rest-client/screenshots/screenshot-5.png" width=400/>

*Set HTTP Basic or Digest Auth. Displays HTTP response headers.*

<img src="https://mmattozzi.github.io/cocoa-rest-client/screenshots/screenshot-2.png" width=400/>

*Upload files using HTTP multipart requests. HTTP form encoding also supported.*

<img src="https://mmattozzi.github.io/cocoa-rest-client/screenshots/screenshot-6.png" width=400/>

*Unified diff tool for comparing response bodies.*

Source and Contributions
=================
* Contributions are always welcome! Please fork and create a pull request.
* Source uses [Cocoapods](https://cocoapods.org/) for dependencies, to get started, [install CocoaPods](http://guides.cocoapods.org/using/getting-started.html) and in the main project directory run:

    ```
      pod install
    ```
  * Note that you must have a github account and a public key registered with github so that CocoaPods can pull down a github-hosted dependency.

Credits
=================
* Uses a very lightly modified fork of SBJson (https://github.com/SBJson/SBJson) for pretty printing JSON
* Much guidance from Adrian Kosmaczewski blog (http://kosmaczewski.net/playing-with-http-libraries/)
* Sparkle automatic update framework (https://github.com/sparkle-project/Sparkle)
* ACEView syntax highlighting (https://github.com/ACENative/ACEView)
* Base64 encoding uses Matt Gallagher's NSData+Base64 code (http://www.cocoawithlove.com/2009/06/base64-encoding-options-on-mac-and.html)
* Code & testing contributions: Adam Venturella, Sergey Klimov, Cory Alder, Tito Ciuro, Eric Broska, Nicholas Robinson, Diego Massanti, Robert Horvath



## License
See [LICENSE.txt](https://github.com/mmattozzi/cocoa-rest-client/blob/master/LICENSE.txt)

[![FOSSA Status](https://app.fossa.io/api/projects/git%2Bgithub.com%2Fmmattozzi%2Fcocoa-rest-client.svg?type=large)](https://app.fossa.io/projects/git%2Bgithub.com%2Fmmattozzi%2Fcocoa-rest-client?ref=badge_large)
