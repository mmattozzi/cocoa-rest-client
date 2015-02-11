//
//  HighlightingTypeManager.h
//  CocoaRestClient
//
//  Created by Michael Mattozzi on 2/8/15.
//
//

#import <Foundation/Foundation.h>
#import "ACEView/ACEView.h"

@interface HighlightingTypeManager : NSObject {
    ACEView *view;
    NSDictionary *typeMapping;
}

- (HighlightingTypeManager *) initWithView:(ACEView*) view;
- (void) setModeForMimeType:(NSString*) mimeType;

@end
