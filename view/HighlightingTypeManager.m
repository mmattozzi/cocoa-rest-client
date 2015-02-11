//
//  HighlightingTypeManager.m
//  CocoaRestClient
//
//  Created by Michael Mattozzi on 2/8/15.
//
//

#import "HighlightingTypeManager.h"

@implementation HighlightingTypeManager

- (HighlightingTypeManager *) initWithView:(ACEView*) aceView {
    self->view = aceView;
    
    typeMapping = @{
        @"application/json": [NSNumber numberWithInteger:ACEModeJSON],
        @"text/xml": [NSNumber numberWithInteger:ACEModeXML],
        @"application/xml": [NSNumber numberWithInteger:ACEModeXML],
        @"application/javascript": [NSNumber numberWithInteger:ACEModeJavaScript],
        @"text/javascript": [NSNumber numberWithInteger:ACEModeJavaScript],
        @"text/html": [NSNumber numberWithInteger:ACEModeHTML],
        @"application/atom+xml": [NSNumber numberWithInteger:ACEModeXML],
        @"application/rss+xml": [NSNumber numberWithInteger:ACEModeXML],
        @"text/css": [NSNumber numberWithInteger:ACEModeCSS]
    };
    
    return self;
}

- (void) setModeForMimeType:(NSString*) mimeType {
    NSNumber *mode = [typeMapping valueForKey:mimeType];
    if (mode) {
        [self->view setMode:[mode intValue]];
    } else {
        [self->view setMode:ACEModeText];
    }
}

@end
