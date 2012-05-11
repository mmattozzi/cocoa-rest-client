//
//  HighlightedTextView.h
//  CocoaRestClient
//
//  Created by Sergey Klimov on 5/10/12.
//  Copyright (c) 2012 Self-Employed. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface HighlightedTextView : NSView
@property (assign) NSTextView * textView;
@property (copy) NSString * syntaxMIME;
@end
