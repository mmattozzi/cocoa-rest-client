//
//  HighlightedTextView.m
//  CocoaRestClient
//
//  Created by Sergey Klimov on 5/10/12.
//  Copyright (c) 2012 Self-Employed. All rights reserved.
//

#import "HighlightedTextView.h"
#import <MGSFragaria/MGSFragaria.h>

@implementation HighlightedTextView {
    MGSFragaria * fragaria;
}
@synthesize textView;
-(id) initWithCoder:(NSCoder *)aDecoder {
    if (self=[super initWithCoder:aDecoder]) {
        fragaria = [[MGSFragaria alloc] init];
        
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
    return self; 
}

@end
