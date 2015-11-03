//
//  RequestTextView.m
//  CocoaRestClient
//
//  Created by Toby Harris on 03/11/2015.
//
//

#import "RequestAceView.h"

@implementation RequestACEView

- (NSString*) string
{
    NSString* timeString = [NSString stringWithFormat:@"%lu", (NSUInteger)[[NSDate date] timeIntervalSince1970] + 5 ];
    NSString* returnString = [[super string] stringByReplacingOccurrencesOfString:@"<NowPlus5s>" withString:timeString];
    return returnString;
}

@end
