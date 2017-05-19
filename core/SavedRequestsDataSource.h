//
//  SavedRequestsDataSource.h
//  CocoaRestClient
//
//  Created by Mike Mattozzi on 5/17/17.
//
//

#import <Foundation/Foundation.h>

@class CocoaRestClientAppDelegate;

@interface SavedRequestsDataSource : NSObject <NSOutlineViewDataSource> {
    @private NSString *appDataFilePath;
    @private CocoaRestClientAppDelegate *appDelegate;
}

@property (class, atomic, strong) NSMutableArray *savedRequestsArray;

- (void) saveDataToDisk;
- (void) loadDataFromDisk;
- (NSString *) pathForDataFile;

@end
