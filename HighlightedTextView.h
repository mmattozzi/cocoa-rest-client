//
//  HighlightedTextView.h
//  CocoaRestClient
//
//  Created by Sergey Klimov on 5/10/12.
//  Copyright (c) 2012 Self-Employed. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <MGSFragaria/MGSFragaria.h>

@interface HighlightedTextView : NSView

{
    MGSFragaria * fragaria;
    NSDictionary * syntaxForMIME;
    NSTextView * textView;
}
@property (assign) NSTextView * textView;
@property (copy) NSString * syntaxMIME;
@end
