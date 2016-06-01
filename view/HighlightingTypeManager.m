//
//  HighlightingTypeManager.m
//  CocoaRestClient
//
//  Created by Michael Mattozzi on 2/8/15.
//
//

#import "HighlightingTypeManager.h"
#import "ContentTypes.h"

@implementation HighlightingTypeManager

- (HighlightingTypeManager *) initWithView:(ACEView*) aceView {
    self->view = aceView;
    
    typeMapping = @{
        @"application/json": [NSNumber numberWithInteger:ACEModeJSON],
        @"application/vnd.api+json": [NSNumber numberWithInteger:ACEModeJSON],
        @"text/xml": [NSNumber numberWithInteger:ACEModeXML],
        @"application/xml": [NSNumber numberWithInteger:ACEModeXML],
        @"application/javascript": [NSNumber numberWithInteger:ACEModeJavaScript],
        @"text/javascript": [NSNumber numberWithInteger:ACEModeJavaScript],
        @"text/html": [NSNumber numberWithInteger:ACEModeHTML],
        @"application/atom+xml": [NSNumber numberWithInteger:ACEModeXML],
        @"application/rss+xml": [NSNumber numberWithInteger:ACEModeXML],
        @"text/css": [NSNumber numberWithInteger:ACEModeCSS],
        @"application/soap+xml": [NSNumber numberWithInteger:ACEModeXML],
        @"application/xml-dtd": [NSNumber numberWithInteger:ACEModeXML],
        @"text/yaml": [NSNumber numberWithInteger:ACEModeYAML],
        @"application/x-yaml": [NSNumber numberWithInteger:ACEModeYAML],
        @"application/yaml": [NSNumber numberWithInteger:ACEModeYAML]
    };
    
    return self;
}

- (void) setModeForMimeType:(NSString*) mimeType {
    NSNumber *mode = [typeMapping valueForKey:mimeType];
    if (mode) {
        [self->view setMode:[mode intValue]];
    } else if ([[ContentTypes sharedContentTypes] isJson:mimeType]) {
        [self->view setMode:ACEModeJSON];
    } else if ([[ContentTypes sharedContentTypes] isXml:mimeType]) {
        [self->view setMode:ACEModeXML];
    } else {
        [self->view setMode:ACEModeText];
    }
}

@end
