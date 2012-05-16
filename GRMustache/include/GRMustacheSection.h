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

@class GRMustacheInvocation;
@class GRMustacheTemplate;

@interface GRMustacheSection: NSObject {
@private
    GRMustacheInvocation *_invocation;
    GRMustacheTemplate *_rootTemplate;
    NSString *_templateString;
    NSRange _range;
    BOOL _inverted;
    NSArray *_elems;
    id _renderingContext;
}


//////////////////////////////////////////////////////////////////////////////////////////
/// @name Accessing the current rendering context
//////////////////////////////////////////////////////////////////////////////////////////

/**
 Returns the current rendering context.
 
 @since v2.0
 */
@property (nonatomic, readonly) id renderingContext AVAILABLE_GRMUSTACHE_VERSION_3_0_AND_LATER;




//////////////////////////////////////////////////////////////////////////////////////////
/// @name Accessing the literal inner content
//////////////////////////////////////////////////////////////////////////////////////////

/**
 Returns the literal inner content of the section, with unprocessed mustache `{{tags}}`.
 
 @since v2.0
 */
@property (nonatomic, readonly) NSString *innerTemplateString AVAILABLE_GRMUSTACHE_VERSION_3_0_AND_LATER;


//////////////////////////////////////////////////////////////////////////////////////////
/// @name Rendering the inner content
//////////////////////////////////////////////////////////////////////////////////////////

/**
 Renders the inner content of the receiver with the current context
 
 @return A string containing the rendered inner content.
 
 @since v2.0
 */
- (NSString *)render AVAILABLE_GRMUSTACHE_VERSION_3_0_AND_LATER;

@end
