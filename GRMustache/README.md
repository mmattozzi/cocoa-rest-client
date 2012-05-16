GRMustache
==========

GRMustache is an Objective-C implementation of the [Mustache](http://mustache.github.com/) logic-less template language.

The Mustache syntax: http://mustache.github.com/mustache.5.html.

Breaking news on Twitter: http://twitter.com/GRMustache


How To
------

### 1. Download and add to your Xcode project

    $ git clone https://github.com/groue/GRMustache.git

- For MacOS 10.6+ development, add `include/GRMustache.h` and `lib/libGRMustache3-MacOS.a` to your project.
- For iOS3+ development, add `include/GRMustache.h` and `lib/libGRMustache3-iOS.a` to your project.

Alternatively, you may use [CocoaPods](https://github.com/CocoaPods/CocoaPods): append `dependency 'GRMustache'` to your Podfile. In its current version, CocoaPods exposes private headers that you should not rely on, because future versions of GRMustache may change them, without notice, in an incompatible fashion. Make sure you only import `GRMustache.h`.

### 2. Import "GRMustache.h" and start rendering templates

```objc
#import "GRMustache.h"

// Renders "Hello Arthur!"
NSString *rendering = [GRMustacheTemplate renderObject:[Person personWithName:@"Arthur"]
                                            fromString:@"Hello {{name}}!"
                                                 error:NULL];

// Renders from a resource
NSString *rendering = [GRMustacheTemplate renderObject:[Person personWithName:@"Arthur"]
                                          fromResource:@"Profile"  // loads `Profile.mustache`
                                                bundle:nil
                                                 error:NULL];
```


Documentation
-------------

GRMustache online documentation is provided as guides and sample code:

- [Guides/templates.md](GRMustache/blob/master/Guides/templates.md): how to parse and render templates
- [Guides/runtime.md](GRMustache/blob/master/Guides/runtime.md): how to provide data to templates
- [Guides/delegate.md](GRMustache/blob/master/Guides/delegate.md): how to hook into template rendering
- [Guides/sample_code.md](GRMustache/blob/master/Guides/sample_code.md): because some tasks are easier to do with some guidelines.


FAQ
---

- **Q: How do I render array indices?**
    
    A: Check [Guides/sample_code/counters.md](GRMustache/blob/master/Guides/sample_code/counters.md).

- **Q: How do I render default values for missing keys?**

    A: This can be done by providing your template a delegate: check [Guides/delegate.md](GRMustache/blob/master/Guides/delegate.md).

- **Q: I have a bunch of template partials that live in memory, not in the file system. How do I include them?**
    
    A: Check [Guides/template_repositories.md](GRMustache/blob/master/Guides/template_repositories.md).

- **Q: I provide false (zero) to a `{{#section}}` but it renders anyway?**
    
    A: That's because zero (the number) is not considered false by GRMustache. Consider providing an actual boolean, and checking the list of "false" values at [Guides/runtime/booleans.md](GRMustache/blob/master/Guides/runtime/booleans.md).

- **Q: What is this NSUndefinedKeyException stuff?**

    A: When GRMustache has to try several objects until it finds the one that provides a `{{key}}`, several NSUndefinedKeyException are raised and caught. Let us double guess you: it's likely that you wish Xcode would stop breaking on those exceptions. This use case is covered in [Guides/runtime/context_stack.md](GRMustache/blob/master/Guides/runtime/context_stack.md).


Contribution wish-list
----------------------

I wish somebody would review my non-native English, and clean up the guides, if you ask.


Forking
-------

Please fork. You'll learn useful information in [Guides/forking.md](GRMustache/blob/master/Guides/forking.md).


License
-------

Released under the [MIT License](http://en.wikipedia.org/wiki/MIT_License)

Copyright (c) 2012 Gwendal Roué

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

