About
=================
CocoaRestClient is a Mac OS X app for testing HTTP/Restful endpoints. 

I love curl, but sometimes I need my output XML or JSON pretty printed. I want to be able to save frequent PUT and POST bodies for later and copy and paste from responses easily. Think of this as curl with a light UI. 

The goal of this project is to build a lightweight native Cocoa app for testing and debugging HTTP Restful services.
This project was greatly inspired by the Java rest-client (http://code.google.com/p/rest-client/). 

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
* Auto-format (pretty print) XML and JSON responses
* Display response headers
* Quick save requests in a handy drawer
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

![Screenshot 1](https://github.com/mmattozzi/cocoa-rest-client/raw/master/screenshots/cocoa-rest-client-1.jpg)

*Pretty print XML content. Quick save of request URLs, body, and headers in one convenient drawer.*

![Screenshot 2](https://github.com/mmattozzi/cocoa-rest-client/raw/master/screenshots/cocoa-rest-client-2.jpg)

*Pretty print JSON content. Set and save HTTP headers.*

![Screenshot 3](https://github.com/mmattozzi/cocoa-rest-client/raw/master/screenshots/cocoa-rest-client-3.jpg)

*Set HTTP Basic or Digest Auth. Displays HTTP response headers.*

![Screenshot 4](https://github.com/mmattozzi/cocoa-rest-client/raw/master/screenshots/cocoa-rest-client-4.jpg)

*Set HTTP request body content to a raw text blob or a list of parameters.*

![Screenshot 5](https://github.com/mmattozzi/cocoa-rest-client/raw/master/screenshots/cocoa-rest-client-5.jpg)

*Upload files using HTTP multipart requests. HTTP form encoding also supported.*

Source and Contributions
=================
* Source code is hosted on Github: http://github.com/mmattozzi/cocoa-rest-client
* If you would like to contribute, please fork and create a pull request on Github 
* Downloads and issues will still be kept up to date on Google Code. I will probably keep source up to date with each release.
* I don't plan on switching from Garbage Collection to ARC until I drop 10.6 support, as there seems to be some [limitations with ARC on 10.6](http://stackoverflow.com/questions/7696201/how-to-deploy-to-snow-leopard-with-arc-enabled). I will most likely switch to ARC when OS X 10.8 is released. 
* I am not turning on AutoLayout constraints in my xib files until I drop 10.6 support.
* The main xib file is a minefield. An xcode update a year or two ago left it in a state such that it messes up the layout of the application's components every time it opens. If anybody knows how to fix this, that would be amazing. Otherwise, be wary of small changes to the UI... they require sizing all the components back to their original locations. 

Credits
=================
* Contains json-framework/SBJSON library (http://code.google.com/p/json-framework/) embedded in it, source and all
* Much guidance from Adrian Kosmaczewski blog (http://kosmaczewski.net/playing-with-http-libraries/)
* Sparkle automatic update framework (https://github.com/andymatuschak/Sparkle)
* Fragaria syntax highlighting framework (https://github.com/mugginsoft/Fragaria)
* Base64 encoding uses Matt Gallagher's NSData+Base64 code (http://www.cocoawithlove.com/2009/06/base64-encoding-options-on-mac-and.html)
* Code & testing contributions: Adam Venturella, Sergey Klimov, Cory Alder, Tito Ciuro, Eric Broska, Nicholas Robinson

