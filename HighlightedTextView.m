//
//  HighlightedTextView.m
//  CocoaRestClient
//
//  Created by Sergey Klimov on 5/10/12.
//  Copyright (c) 2012 Self-Employed. All rights reserved.
//

#import "HighlightedTextView.h"
#import <MGSFragaria/MGSFragaria.h>

@implementation HighlightedTextView
@synthesize textView;

-(void) initHighlightedFrame {
    fragaria = [[MGSFragaria alloc] init];
    syntaxForMIME = [NSDictionary dictionaryWithObjectsAndKeys:
                     @"JavaScript", @"application/json", 
                     @"XML", @"application/xml", 
                     nil];
    
    //
    // assign user defaults.
    // a number of properties are derived from the user defaults system rather than the doc spec.
    //
    // see MGSFragariaPreferences.h for details
    //
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:MGSPrefsAutocompleteSuggestAutomatically];	
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:MGSPrefsLineWrapNewDocuments];	
    
    // define initial object configuration
    //
    // see MGSFragaria.h for details
    //
    [fragaria setObject:[NSNumber numberWithBool:YES] forKey:MGSFOIsSyntaxColoured];
    [fragaria setObject:[NSNumber numberWithBool:YES] forKey:MGSFOShowLineNumberGutter];
    [fragaria setObject:self forKey:MGSFODelegate];
    [fragaria setObject:@"JavaScript" forKey:MGSFOSyntaxDefinitionName];
    // embed editor in editView
    [fragaria embedInView:self];
    
    self.textView = [fragaria objectForKey:ro_MGSFOTextView];
}

-(id) initWithFrame:(NSRect)frameRect {
    if (self = [super initWithFrame:frameRect]) {
        [self initHighlightedFrame];
    }
    return self;
}

-(id) initWithCoder:(NSCoder *)aDecoder {
    if (self=[super initWithCoder:aDecoder]) {
        [self initHighlightedFrame];
    }
    return self; 
}

-(NSString*) syntaxMIME {
    __block NSString * result;
    [syntaxForMIME enumerateKeysAndObjectsUsingBlock:^(NSString* key, NSString* obj, BOOL *stop) {
        if([obj isEqualToString: [fragaria objectForKey:MGSFOSyntaxDefinitionName]]) {
            result = key;
        }
    }];
    return result;
}

-(void) setSyntaxMIME:(NSString *)syntaxMIME {
    NSString* newSyntaxName =[syntaxForMIME objectForKey:syntaxMIME];
    NSLog(@"%@", newSyntaxName);

    [fragaria setObject:newSyntaxName forKey:MGSFOSyntaxDefinitionName];

}

@end
