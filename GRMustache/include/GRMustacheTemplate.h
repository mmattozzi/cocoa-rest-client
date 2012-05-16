// The MIT License
// 
// Copyright (c) 2012 Gwendal Roué
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <Foundation/Foundation.h>
#import "GRMustacheAvailabilityMacros.h"
#import "GRMustacheTemplateDelegate.h"
#import "GRMustache.h"

/**
 The GRMustacheTemplate class provides with Mustache template rendering services.
 
 @since v1.0
 */
@interface GRMustacheTemplate: NSObject {
@private
    NSArray *_elems;
    id<GRMustacheTemplateDelegate> _delegate;
}

@property (nonatomic, assign) id<GRMustacheTemplateDelegate> delegate AVAILABLE_GRMUSTACHE_VERSION_3_0_AND_LATER;


//////////////////////////////////////////////////////////////////////////////////////////
/// @name Parsing and Rendering Template Strings
//////////////////////////////////////////////////////////////////////////////////////////

/**
 Parses a template string, and returns a compiled template.
 
 The behavior of the returned template is determined by [GRMustache defaultTemplateOptions].
 
 @return A GRMustacheTemplate instance
 @param templateString The template string
 @param outError If there is an error loading or parsing template and partials, upon return contains an NSError object that describes the problem.
 @see [GRMustache defaultTemplateOptions]
 @since v1.11
 */
+ (id)templateFromString:(NSString *)templateString error:(NSError **)outError AVAILABLE_GRMUSTACHE_VERSION_3_0_AND_LATER;

/**
 Renders a context object from a template string.
 
 @return A string containing the rendered template
 @param object A context object used for interpreting Mustache tags
 @param templateString The template string
 @param outError If there is an error loading or parsing template and partials, upon return contains an NSError object that describes the problem.
 
 @since v1.0
 */
+ (NSString *)renderObject:(id)object fromString:(NSString *)templateString error:(NSError **)outError AVAILABLE_GRMUSTACHE_VERSION_3_0_AND_LATER;


//////////////////////////////////////////////////////////////////////////////////////////
/// @name Parsing and Rendering Files
//////////////////////////////////////////////////////////////////////////////////////////

/**
 Parses a template file, and returns a compiled template.
 
 @return A GRMustacheTemplate instance
 @param path The path of the template
 @param outError If there is an error loading or parsing template and partials, upon return contains an NSError object that describes the problem.
 
 The template at path must be encoded in UTF8. See the GRMustacheTemplateRepository class for more encoding options.
 
 @since v1.11
 */
+ (id)templateFromContentsOfFile:(NSString *)path error:(NSError **)outError AVAILABLE_GRMUSTACHE_VERSION_3_0_AND_LATER;

#if !TARGET_OS_IPHONE || __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000

/**
 Parses a template file, and returns a compiled template.
 
 @return A GRMustacheTemplate instance
 @param url The URL of the template
 @param outError If there is an error loading or parsing template and partials, upon return contains an NSError object that describes the problem.
 
 The template at url must be encoded in UTF8. See the GRMustacheTemplateRepository class for more encoding options.
 
 @since v1.11
 */
+ (id)templateFromContentsOfURL:(NSURL *)url error:(NSError **)outError AVAILABLE_GRMUSTACHE_VERSION_3_0_AND_LATER;

#endif /* if !TARGET_OS_IPHONE || __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000 */

/**
 Renders a context object from a file template.
 
 @return A string containing the rendered template
 @param object A context object used for interpreting Mustache tags
 @param path The path of the template
 @param outError If there is an error loading or parsing template and partials, upon return contains an NSError object that describes the problem.
 
 The template at path must be encoded in UTF8. See the GRMustacheTemplateRepository class for more encoding options.
 
 @since v1.4
 */
+ (NSString *)renderObject:(id)object fromContentsOfFile:(NSString *)path error:(NSError **)outError AVAILABLE_GRMUSTACHE_VERSION_3_0_AND_LATER;


#if !TARGET_OS_IPHONE || __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000

/**
 Renders a context object from a file template.
 
 @return A string containing the rendered template
 @param object A context object used for interpreting Mustache tags
 @param url The URL of the template
 @param outError If there is an error loading or parsing template and partials, upon return contains an NSError object that describes the problem.
 
 The template at url must be encoded in UTF8. See the GRMustacheTemplateRepository class for more encoding options.
 
 @since v1.0
 */
+ (NSString *)renderObject:(id)object fromContentsOfURL:(NSURL *)url error:(NSError **)outError AVAILABLE_GRMUSTACHE_VERSION_3_0_AND_LATER;

#endif /* if !TARGET_OS_IPHONE || __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000 */


//////////////////////////////////////////////////////////////////////////////////////////
/// @name Parsing and Rendering NSBundle Resources
//////////////////////////////////////////////////////////////////////////////////////////

/**
 Parses a bundle resource template, and returns a compiled template.
 
 @return A GRMustacheTemplate instance
 @param name The name of a bundle resource of extension "mustache"
 @param bundle The bundle where to look for the template resource
 @param outError If there is an error loading or parsing template and partials, upon return contains an NSError object that describes the problem.
 
 If you provide nil as a bundle, the resource will be looked in the main bundle.
 
 The template resource must be encoded in UTF8. See the GRMustacheTemplateRepository class for more encoding options.
 
 @since v1.11
 */
+ (id)templateFromResource:(NSString *)name bundle:(NSBundle *)bundle error:(NSError **)outError AVAILABLE_GRMUSTACHE_VERSION_3_0_AND_LATER;

/**
 Parses a bundle resource template, and returns a compiled template.
 
 @return A GRMustacheTemplate instance
 @param name The name of a bundle resource
 @param ext The extension of the bundle resource
 @param bundle The bundle where to look for the template resource
 @param outError If there is an error loading or parsing template and partials, upon return contains an NSError object that describes the problem.
 
 If you provide nil as a bundle, the resource will be looked in the main bundle.
 
 The template resource must be encoded in UTF8. See the GRMustacheTemplateRepository class for more encoding options.
 
 @since v1.11
 */
+ (id)templateFromResource:(NSString *)name withExtension:(NSString *)ext bundle:(NSBundle *)bundle error:(NSError **)outError AVAILABLE_GRMUSTACHE_VERSION_3_0_AND_LATER;


/**
 Renders a context object from a bundle resource template.
 
 @return A string containing the rendered template
 @param object A context object used for interpreting Mustache tags
 @param name The name of a bundle resource of extension "mustache"
 @param bundle The bundle where to look for the template resource
 @param outError If there is an error loading or parsing template and partials, upon return contains an NSError object that describes the problem.
 
 If you provide nil as a bundle, the resource will be looked in the main bundle.
 
 The template resource must be encoded in UTF8. See the GRMustacheTemplateRepository class for more encoding options.
 
 @since v1.0
 */
+ (NSString *)renderObject:(id)object fromResource:(NSString *)name bundle:(NSBundle *)bundle error:(NSError **)outError AVAILABLE_GRMUSTACHE_VERSION_3_0_AND_LATER;

/**
 Renders a context object from a bundle resource template.
 
 @return A string containing the rendered template
 @param object A context object used for interpreting Mustache tags
 @param name The name of a bundle resource
 @param ext The extension of the bundle resource
 @param bundle The bundle where to look for the template resource.
 @param outError If there is an error loading or parsing template and partials, upon return contains an NSError object that describes the problem.
 
 If you provide nil as a bundle, the resource will be looked in the main bundle.
 
 The template resource must be encoded in UTF8. See the GRMustacheTemplateRepository class for more encoding options.
 
 @since v1.0
 */
+ (NSString *)renderObject:(id)object fromResource:(NSString *)name withExtension:(NSString *)ext bundle:(NSBundle *)bundle error:(NSError **)outError AVAILABLE_GRMUSTACHE_VERSION_3_0_AND_LATER;


//////////////////////////////////////////////////////////////////////////////////////////
/// @name Rendering a Parsed Template
//////////////////////////////////////////////////////////////////////////////////////////

/**
 Renders a template with a context object.
 
 @return A string containing the rendered template
 @param object A context object used for interpreting Mustache tags
 
 @since v1.0
 */
- (NSString *)renderObject:(id)object AVAILABLE_GRMUSTACHE_VERSION_3_0_AND_LATER;

/**
 Renders a template with context objects.
 
 @return A string containing the rendered template
 @param object, ... A comma-separated list of objects used for interpreting Mustache tags, ending with nil
 
 @since v1.5
 */
- (NSString *)renderObjects:(id)object, ... __attribute__ ((sentinel)) AVAILABLE_GRMUSTACHE_VERSION_3_0_AND_LATER;

/**
 Renders a template without any context object for interpreting Mustache tags.
 
 @return A string containing the rendered template
 
 @since v1.0
 */
- (NSString *)render AVAILABLE_GRMUSTACHE_VERSION_3_0_AND_LATER;

@end
