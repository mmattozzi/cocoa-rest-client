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
#import "GRMustache.h"

@class GRMustacheTemplate;
@class GRMustacheTemplateRepository;

@protocol GRMustacheTemplateRepositoryDataSource <NSObject>
@required
- (id)templateRepository:(GRMustacheTemplateRepository *)templateRepository templateIDForName:(NSString *)name relativeToTemplateID:(id)templateID AVAILABLE_GRMUSTACHE_VERSION_3_0_AND_LATER;
- (NSString *)templateRepository:(GRMustacheTemplateRepository *)templateRepository templateStringForTemplateID:(id)templateID error:(NSError **)outError AVAILABLE_GRMUSTACHE_VERSION_3_0_AND_LATER;
@end

@interface GRMustacheTemplateRepository : NSObject {
@private
    id<GRMustacheTemplateRepositoryDataSource> _dataSource;
    NSMutableDictionary *_templateForTemplateID;
    id _currentlyParsedTemplateID;
}
@property (nonatomic, assign) id<GRMustacheTemplateRepositoryDataSource> dataSource AVAILABLE_GRMUSTACHE_VERSION_3_0_AND_LATER;

#if !TARGET_OS_IPHONE || __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
+ (id)templateRepositoryWithBaseURL:(NSURL *)URL AVAILABLE_GRMUSTACHE_VERSION_3_0_AND_LATER;
+ (id)templateRepositoryWithBaseURL:(NSURL *)URL templateExtension:(NSString *)ext AVAILABLE_GRMUSTACHE_VERSION_3_0_AND_LATER;
+ (id)templateRepositoryWithBaseURL:(NSURL *)URL templateExtension:(NSString *)ext AVAILABLE_GRMUSTACHE_VERSION_3_0_AND_LATER;
+ (id)templateRepositoryWithBaseURL:(NSURL *)URL templateExtension:(NSString *)ext encoding:(NSStringEncoding)encoding AVAILABLE_GRMUSTACHE_VERSION_3_0_AND_LATER;
#endif /* if !TARGET_OS_IPHONE || __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000 */

+ (id)templateRepositoryWithDirectory:(NSString *)path AVAILABLE_GRMUSTACHE_VERSION_3_0_AND_LATER;
+ (id)templateRepositoryWithDirectory:(NSString *)path templateExtension:(NSString *)ext AVAILABLE_GRMUSTACHE_VERSION_3_0_AND_LATER;
+ (id)templateRepositoryWithDirectory:(NSString *)path templateExtension:(NSString *)ext encoding:(NSStringEncoding)encoding AVAILABLE_GRMUSTACHE_VERSION_3_0_AND_LATER;

+ (id)templateRepositoryWithBundle:(NSBundle *)bundle AVAILABLE_GRMUSTACHE_VERSION_3_0_AND_LATER;
+ (id)templateRepositoryWithBundle:(NSBundle *)bundle templateExtension:(NSString *)ext AVAILABLE_GRMUSTACHE_VERSION_3_0_AND_LATER;
+ (id)templateRepositoryWithBundle:(NSBundle *)bundle templateExtension:(NSString *)ext encoding:(NSStringEncoding)encoding AVAILABLE_GRMUSTACHE_VERSION_3_0_AND_LATER;

+ (id)templateRepositoryWithPartialsDictionary:(NSDictionary *)partialsDictionary AVAILABLE_GRMUSTACHE_VERSION_3_0_AND_LATER;

+ (id)templateRepository AVAILABLE_GRMUSTACHE_VERSION_3_0_AND_LATER;

- (GRMustacheTemplate *)templateForName:(NSString *)name error:(NSError **)outError AVAILABLE_GRMUSTACHE_VERSION_3_0_AND_LATER;
- (GRMustacheTemplate *)templateFromString:(NSString *)templateString error:(NSError **)outError AVAILABLE_GRMUSTACHE_VERSION_3_0_AND_LATER;
@end
