//
//  CRCHTTPHeadersComboBoxCell.m
//  CocoaRestClient
//
//  Created by Eric Broska on 2/2/13.
//
//

#import "CRCHTTPHeadersComboBoxCell.h"

#define kCRCStandardHeaders @"Default HTTP headers"

static NSMutableArray *_headersList = nil;

@interface CRCHTTPHeadersComboBoxCell (Private)
- (void)initHeadersList;
- (void)synchronizeListOfHeaders;
- (void)userDidEnterSomeValue:(NSNotification *)notification;
@end

@implementation CRCHTTPHeadersComboBoxCell

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder: aDecoder])) {
        
        @synchronized (_headersList) {
            if (!_headersList) {
                [self initHeadersList];
            }
        }
        [self addItemsWithObjectValues: _headersList];
        
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(userDidEnterSomeValue:)
                                                     name: NSControlTextDidEndEditingNotification
                                                   object: [self controlView]];
    }
    return self;
}

- (void)initHeadersList
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey: kCRCStandardHeaders]) {
        _headersList = [[defaults objectForKey: kCRCStandardHeaders] mutableCopy];
    } else {
        _headersList = [[[NSBundle mainBundle] objectForInfoDictionaryKey: kCRCStandardHeaders] mutableCopy];
    }
}

- (void)synchronizeListOfHeaders
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject: _headersList forKey: kCRCStandardHeaders];
        [defaults synchronize];
    });
}

- (void)userDidEnterSomeValue:(NSNotification *)notification
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
    NSString *new_value = [[[notification object] selectedCell] objectValue];
    if ( ! ([new_value isEqualToString: @"Key"] || [_headersList containsObject: new_value])) {
        [_headersList addObject: new_value];
    }
    
    [self synchronizeListOfHeaders];
    [self removeAllItems];
    [self addItemsWithObjectValues: _headersList];
    [self selectItemWithObjectValue: new_value];
}

@end
