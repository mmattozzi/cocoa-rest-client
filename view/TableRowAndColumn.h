//
//  TableRowAndColumn.h
//  CocoaRestClient
//
//  Created by Michael Mattozzi on 6/10/13.
//  Copyright (c) 2013 Michael Mattozzi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TableRowAndColumn : NSObject {
    NSTableColumn *column;
    int row;
}

@property (nonatomic, strong) NSTableColumn *column;
@property (nonatomic, assign) int row;

@end
