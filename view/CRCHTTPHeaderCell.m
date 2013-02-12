//
//  CRCHTTPHeaderCell.m
//  CocoaRestClient
//
//  Created by Eric Broska on 2/12/13.
//
//

#import "CRCHTTPHeaderCell.h"

#define kCRCHeadersUserDefaultsKey @"kCRCHeadersUserDefaultsKey"
static NSMutableArray *_CRCHeaders = nil;

@interface CRCHTTPHeaderCell (Private)

- (void)valueDidChanged:(NSNotification *)notification;
- (void)updateHeadersListInDefaults;

@end

@implementation CRCHTTPHeaderCell

+ (void)initialize
{
    [super initialize];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey: kCRCHeadersUserDefaultsKey]) {
        _CRCHeaders = [[defaults objectForKey: kCRCHeadersUserDefaultsKey] mutableCopy];
    } else {
        _CRCHeaders = [[[NSBundle mainBundle] objectForInfoDictionaryKey: kCRCHeadersUserDefaultsKey] mutableCopy];
    }
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self=[super initWithCoder: aDecoder])) {
        [self addItemsWithObjectValues: _CRCHeaders];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(valueDidChanged:)
                                                 name: NSControlTextDidEndEditingNotification
                                               object: [self controlView]];
    return (self);
}

- (void)updateHeaderListInDefaults
{
    NSMutableArray *tmp = [_CRCHeaders mutableCopy];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject: tmp forKey: kCRCHeadersUserDefaultsKey];
        [defaults synchronize];
    });
}

- (void)valueDidChanged:(NSNotification *)notification
{
    /* We only want to deal with CRCHTTPHeadersComboBoxCells */
    if ( ! [[[notification object] selectedCell] isKindOfClass: [self class]]) {
        return;
    }
    /*
     * Well, it's a dirty hack to get the _right_ value from the cell,
     * because [self objectValue] returns a *last selected* item's value,
     * not just entered one's.
     */
    
//    NSString *new_value = [[[notification object] selectedCell] objectValue];    
//    @synchronized (_CRCHeaders) {
//        if ( ! ([new_value isEqualToString: @"Key"] || [_CRCHeaders containsObject: new_value])) {
//            [_CRCHeaders addObject: new_value];
//        }
//    }
//    
//    [self updateHeadersListInDefaults];
//    
//    [self removeAllItems];
//    [self addItemsWithObjectValues: _CRCHeaders];
//    [self selectItemWithObjectValue: new_value];
}

- (void)removeSelfFromDefaults
{
    @synchronized (_CRCHeaders) {
        [_CRCHeaders removeObject: self.objectValue];
    }
    [self updateHeadersListInDefaults];
}
@end
