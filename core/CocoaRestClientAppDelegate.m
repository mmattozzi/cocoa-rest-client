//
//  CocoaRestClientAppDelegate.m
//  CocoaRestClient
//
//  Created by mmattozzi on 1/5/10.
//

#import "CocoaRestClientAppDelegate.h"
#import "CRCMultipartRequest.h"
#import "CRCFormEncodedRequest.h"
#import "CRCRawRequest.h"
#import "CRCFileRequest.h"
#import "CRCRequest.h"
#import <Foundation/Foundation.h>
#import "JSON.h"
#import <Sparkle/SUUpdater.h>
#import <MGSFragaria/MGSSyntaxController.h>
#import "MessagePack.h"
#import "NSData+Base64.h"
#import "TableRowAndColumn.h"

#define MAIN_WINDOW_MENU_TAG 150
#define REGET_MENU_TAG 151

#define APPLICATION_NAME @"CocoaRestClient"
#define DATAFILE_NAME @"CocoaRestClient.savedRequests"

NSString* const FOLLOW_REDIRECTS = @"followRedirects";
NSString* const APPLY_HTTP_METHOD_ON_REDIRECT = @"applyHttpMethodOnRedirect";
NSString* const SYNTAX_HIGHLIGHT = @"syntaxHighlighting";
NSString* const RESPONSE_TIMEOUT = @"responseTimeout";
NSString* const WELCOME_MESSAGE = @"welcomeMessage-1.3.3";
NSInteger const DEFAULT_FONT_SIZE = 12;

enum {
	CRCContentTypeMultipart,
	CRCContentTypeFormEncoded,
	CRCContentTypeJson,
	CRCContentTypeXml,
	CRCContentTypeImage,
	CRCContentTypeUnknown
};
typedef NSInteger CRCContentType;

static CRCContentType requestContentType;


@interface CocoaRestClientAppDelegate(Private)
- (void)determineRequestContentType;
- (void)loadSavedDictionary:(NSDictionary *)request;
- (void)loadSavedCRCRequest:(CRCRequest *)request;
@end

@implementation CocoaRestClientAppDelegate

@synthesize window;
@synthesize submitButton;
@synthesize urlBox;
@synthesize responseText;
@synthesize responseWebView;
@synthesize responseTextHeaders;
@synthesize requestText;
@synthesize requestView;
@synthesize responseView;
@synthesize responseSyntaxBox;
@synthesize methodButton;
@synthesize headersTable, filesTable, paramsTable;
@synthesize headersTableView, filesTableView, paramsTableView;
@synthesize username;
@synthesize password;
@synthesize preemptiveBasicAuth;
@synthesize savedOutlineView;
@synthesize saveRequestSheet;
@synthesize saveRequestTextField;
@synthesize savedRequestsDrawer;
@synthesize headersTab;
@synthesize timeoutSheet;
@synthesize timeoutField;
@synthesize plusParam, minusParam;
@synthesize rawRequestInput;
@synthesize tabView;
@synthesize reqHeadersTab;
@synthesize status;
@synthesize requestHeadersSentText;
@synthesize progressIndicator;
@synthesize drawerView;
@synthesize preferencesController;
@synthesize responseTextPlain;
@synthesize requestTextPlain;
@synthesize responseTextPlainView;
@synthesize requestTextPlainView;
@synthesize syntaxHighlightingMenuItem;
@synthesize reGetResponseMenuItem;
@synthesize welcomeController;

- (id) init {
	self = [super init];
	
    NSDictionary *defaults = [[NSMutableDictionary alloc] init];
    [defaults setValue:[NSNumber numberWithInt:30] forKey:RESPONSE_TIMEOUT];
    [defaults setValue:[NSNumber numberWithBool:YES] forKey:FOLLOW_REDIRECTS];
    [defaults setValue:[NSNumber numberWithBool:YES] forKey:SYNTAX_HIGHLIGHT];
    [defaults setValue:[NSNumber numberWithBool:YES] forKey:WELCOME_MESSAGE];
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
    
	allowSelfSignedCerts = YES;
    preemptiveBasicAuth = NO;
    
	headersTable = [[NSMutableArray alloc] init];
	filesTable   = [[NSMutableArray alloc] init];
	paramsTable  = [[NSMutableArray alloc] init];
	
	NSMutableDictionary *row = [[NSMutableDictionary alloc] init];
	
	[row setObject:@"Content-Type" forKey:@"key"];
	[row setObject:@"application/x-www-form-urlencoded" forKey:@"value"];
	[headersTable addObject:row];
	[row release];
	
    xmlContentTypes = [NSArray arrayWithObjects:@"application/xml", @"application/atom+xml", @"application/rss+xml",
                       @"text/xml", @"application/soap+xml", @"application/xml-dtd", nil];
    
    jsonContentTypes = [NSArray arrayWithObjects:@"application/json", @"text/json", nil];
    
    msgPackContentTypes = [NSArray arrayWithObjects:@"application/x-msgpack", @"application/x-messagepack", nil];
    
    [self loadDataFromDisk];
    
    exportRequestsController = [[ExportRequestsController alloc] initWithWindowNibName:@"ExportRequests"];
    exportRequestsController.savedRequestsArray = savedRequestsArray;
    
    self.welcomeController = [[WelcomeController alloc] initWithWindowNibName:@"Welcome"];
     
	return self;
}

- (void) setRawRequestInput:(BOOL)value{
	
	rawRequestInput = value;
    
    BOOL syntaxHighlighting = [[NSUserDefaults standardUserDefaults] boolForKey:SYNTAX_HIGHLIGHT];
	
    if(rawRequestInput){
        if (syntaxHighlighting) {
            [requestView setHidden:NO];
        } else {
            [requestTextPlainView setHidden:NO];
        }
		[[paramsTableView enclosingScrollView] setHidden:YES];
		[plusParam setHidden:YES];
		[minusParam setHidden:YES];
	}
	else {
        if (syntaxHighlighting) {
            [requestView setHidden:YES];
        } else {
            [requestTextPlainView setHidden:YES];
        }
		[[paramsTableView enclosingScrollView] setHidden:NO];
		[plusParam setHidden:NO];
		[minusParam setHidden:NO];
	}

}

+ (void) addBorderToView:(NSView *)view {
    CGColorRef borderColor = (CGColorRef) CGColorCreateGenericRGB(0.745f, 0.745f, 0.745f, 1.0f);
    CALayer *layer = [CALayer layer];
    layer.borderColor = borderColor;
    [view setWantsLayer:YES];
    view.layer = layer;
    view.layer.borderWidth = 1.0f;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	[methodButton removeAllItems];
	[methodButton addItemWithTitle:@"GET"];
	[methodButton addItemWithTitle:@"POST"];
	[methodButton addItemWithTitle:@"PUT"];
	[methodButton addItemWithTitle:@"DELETE"];
	[methodButton addItemWithTitle:@"HEAD"];
	[methodButton addItemWithTitle:@"OPTIONS"];
	[methodButton addItemWithTitle:@"PATCH"];
	[methodButton addItemWithTitle:@"COPY"];
	[methodButton addItemWithTitle:@"SEARCH"];
    
	requestMethodsWithBody = [NSSet setWithObjects:@"POST", @"PUT", @"PATCH", @"COPY", @"SEARCH", nil];
	
	[responseText setFont:[NSFont fontWithName:@"Courier New" size:DEFAULT_FONT_SIZE]]; 
	[responseTextHeaders setFont:[NSFont fontWithName:@"Courier New" size:DEFAULT_FONT_SIZE]];
	[requestHeadersSentText setFont:[NSFont fontWithName:@"Courier New" size:DEFAULT_FONT_SIZE]];    
	[requestText setFont:[NSFont fontWithName:@"Courier New" size:DEFAULT_FONT_SIZE]];
	
	[urlBox setNumberOfVisibleItems:10];
    [progressIndicator setHidden:YES];
	[savedRequestsDrawer open];
    exportRequestsController.savedOutlineView = savedOutlineView;
    
    drawerView.cocoaRestClientAppDelegate = self;
    [drawerView registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType, nil]];
    
    [headersTableView setDoubleAction:@selector(doubleClickedHeaderRow:)];
    [headersTableView setTextDidEndEditingAction:@selector(doneEditingHeaderRow:)];
    [paramsTableView setDoubleAction:@selector(doubleClickedParamsRow:)];
    [paramsTableView setTextDidEndEditingAction:@selector(doneEditingParamsRow:)];
    [filesTableView setDoubleAction:@selector(doubleClickedFileRow:)];
    
    [filesTableView registerForDraggedTypes: [NSArray arrayWithObject: NSFilenamesPboardType]];
    [filesTableView setDelegate: self];
    [filesTableView setDataSource: self];
    
    [responseTextPlain setEditable:NO];
    [reGetResponseMenuItem setEnabled:NO];
    
    MGSSyntaxController *syn = [[[MGSSyntaxController alloc] init] autorelease];
    [responseSyntaxBox addItemsWithObjectValues: [syn syntaxDefinitionNames]];
    [responseSyntaxBox addItemWithObjectValue:@"MsgPack"];
    [responseSyntaxBox selectItemWithObjectValue: @"JavaScript"];
    
    [CocoaRestClientAppDelegate addBorderToView:self.responseView];
    [CocoaRestClientAppDelegate addBorderToView:self.requestView];
    [self initHighlightedViews];
    
    [self syntaxHighlightingPreferenceChanged];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:WELCOME_MESSAGE]) {
        [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(showWelcome) userInfo:nil repeats:NO];        
    }
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag {
    return !(flag || ([self.window makeKeyAndOrderFront: self], 0));
}

- (IBAction) updateResponseSyntaxHighlight:(id)sender {
    NSComboBox *box = sender;
    [responseView setSyntaxMode: [box itemObjectValueAtIndex: [box indexOfSelectedItem]]];
}

- (IBAction)toggleSyntaxHighlighting:(id)sender {
    BOOL syntaxHighlighting = [[NSUserDefaults standardUserDefaults] boolForKey:SYNTAX_HIGHLIGHT];
    [[NSUserDefaults standardUserDefaults] setBool:(!syntaxHighlighting) forKey:SYNTAX_HIGHLIGHT];
    [self syntaxHighlightingPreferenceChanged];
}

- (void) syntaxHighlightingPreferenceChanged {
    BOOL syntaxHighlighting = [[NSUserDefaults standardUserDefaults] boolForKey:SYNTAX_HIGHLIGHT];
    syntaxHighlightingMenuItem.state = syntaxHighlighting;
    if (! syntaxHighlighting) {
        self.responseView.hidden = true;
        self.responseTextPlainView.hidden = false;
        [self.responseText setString:@""];
        self.responseText = self.responseTextPlain;
        
        self.requestView.hidden = true;
        if (self.rawRequestInput) {
            self.requestTextPlainView.hidden = false;
        }
        [self.requestTextPlain setString:[self.requestText string]];
        self.requestText = self.requestTextPlain;
    } else {
        self.responseView.hidden = false;
        self.responseTextPlainView.hidden = true;
        [self.responseText setString:@""];
        self.responseText = self.responseView.textView;
        
        if (self.rawRequestInput) {
            self.requestView.hidden = false;
        }
        self.requestTextPlainView.hidden = true;
        self.requestText = self.requestView.textView;
        [self.requestText setString:[self.requestTextPlain string]];
    }
}

- (void) determineRequestContentType{
	for(NSDictionary * row in headersTable)
	{
		if([[[row objectForKey:@"key"] lowercaseString] isEqualToString:@"content-type"])
		{
			NSString * value = [[row objectForKey:@"value"] lowercaseString];
			NSRange range;
			
			if([value isEqualToString:@"application/x-www-form-urlencoded"]){
				requestContentType = CRCContentTypeFormEncoded;
				break;
			}
			
			if([value isEqualToString:@"multipart/form-data"]){
				requestContentType = CRCContentTypeMultipart;
				break;
			}
			
			range = [value rangeOfString:@"json"];
			if(range.length > 0){
				requestContentType = CRCContentTypeJson;
				break;
			}
			
			range = [value rangeOfString:@"xml"];
			if(range.length > 0){
				requestContentType = CRCContentTypeXml;
				break;
			}
			
			range = [value rangeOfString:@"image"];
			if(range.length > 0){
				requestContentType = CRCContentTypeImage;
				break;
			}
		}
	}
}

- (IBAction) runSubmit:(id)sender {
	[self determineRequestContentType];
	NSLog(@"Got submit press");
    [progressIndicator setHidden:NO];
    [progressIndicator startAnimation:self];
	
	// Append http if it's not there
	NSString *urlStr = [urlBox stringValue];
	if (! [urlStr hasPrefix:@"http"] && ! [urlStr hasPrefix:@"https"]) {
		urlStr = [[NSString alloc] initWithFormat:@"http://%@", urlStr];
		[urlBox setStringValue:urlStr];
	}
	
	[responseText setString:[NSString stringWithFormat:@"Loading %@", urlStr]];
	[status setStringValue:@"Opening URL..."];
	[responseTextHeaders setString:@""];
	[headersTab setLabel:@"Response Headers"];
	[urlBox insertItemWithObjectValue: [urlBox stringValue] atIndex:0];
	
	if (! receivedData) {
		receivedData = [[NSMutableData alloc] init];
	}
	[receivedData setLength:0];
	contentType = NULL;
	
	NSString *urlEscaped = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSURL *url = [NSURL URLWithString:urlEscaped];
	NSString *method = [NSString stringWithString:[methodButton titleOfSelectedItem]];
	NSMutableURLRequest * request = nil;
    
	
	// initialize request
	request = [NSMutableURLRequest requestWithURL:url];
	[request setHTTPMethod:method];
	[request setTimeoutInterval:[[NSUserDefaults standardUserDefaults] integerForKey:RESPONSE_TIMEOUT]];
	
	BOOL contentTypeSet = NO;
	
	if(self.rawRequestInput) {
		if ([requestMethodsWithBody containsObject:method]) {
			if([filesTable count] > 0 && [[requestText string] isEqualToString:@""]) {
				[CRCFileRequest createRequest:request];
			}
			else  {
				[CRCRawRequest createRequest:request];
			}
		}		
	}
	else {
		if ([requestMethodsWithBody containsObject:method]) {
			switch(requestContentType) {
				case CRCContentTypeFormEncoded:
					[CRCFormEncodedRequest createRequest:request];
                    contentTypeSet = YES;
					break;
				
				case CRCContentTypeMultipart:
					[CRCMultipartRequest createRequest:request];
                    contentTypeSet = YES;
					break;
			}
		}
	}
	
    // Set headers
	NSMutableDictionary *headersDictionary = [[NSMutableDictionary alloc] init];
	
	for(NSDictionary * row in headersTable) {
        if (! [[[row objectForKey:@"key"] lowercaseString] isEqualToString:@"content-type"] || ! contentTypeSet) {
            [headersDictionary setObject:[row objectForKey:@"value"] 
                                  forKey:[row objectForKey:@"key"]];
        }
	}
    
    // Pre-emptive HTTP Basic Auth
    if (preemptiveBasicAuth && [username stringValue] && [password stringValue]) {
        NSData *plainTextUserPass = [ [NSString stringWithFormat:@"%@:%@", [username stringValue], [password stringValue]] dataUsingEncoding:NSUTF8StringEncoding];
        [headersDictionary setObject:[NSString stringWithFormat:@"Basic %@", [plainTextUserPass base64EncodedString]] 
                              forKey:@"Authorization"];
    }
    
    [request setAllHTTPHeaderFields:headersDictionary];
    
	if (lastRequest != nil) {
		[lastRequest release];
	}
	lastRequest = [CRCRequest requestWithApplication:self];
	if ([method isEqualToString:@"GET"]) {
        reGetResponseMenuItem.enabled = YES; 
    } else {
        reGetResponseMenuItem.enabled = NO;
    }
    
	if (startDate != nil) {
		[startDate release];
	}
	startDate = [NSDate date];
    
    currentRequest = [request copy];
    
	NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
	if (! connection) {
		NSLog(@"Could not open connection to resource");
	}

}



#pragma mark -
#pragma mark Highlighted Text Views

-(void) initHighlightedViews {
    self.responseText = self.responseView.textView;
    [self.responseText setEditable:NO];
    self.requestText = self.requestView.textView;
}

#pragma mark -
#pragma mark Url Connection Delegate methods
- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[receivedData appendData:data];
}

-(NSCachedURLResponse *)connection:(NSURLConnection *)connection
                 willCacheResponse:(NSCachedURLResponse *)cachedResponse {
    return nil;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	NSLog(@"Did receive response");
	
	[status setStringValue:@"Receiving Data..."];
	NSMutableString *headers = [[NSMutableString alloc] init];
	NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
	[headers appendFormat:@"HTTP %ld %@\n\n", [httpResponse statusCode], [[NSHTTPURLResponse localizedStringForStatusCode:[httpResponse statusCode]] capitalizedString]];
	
	[headersTab setLabel:[NSString stringWithFormat:@"Response Headers (%ld)", [httpResponse statusCode]]];
	
	NSDictionary *headerDict = [httpResponse allHeaderFields];
    contentType = nil;
	for (NSString *key in headerDict) {
		[headers appendFormat:@"%@: %@\n", key, [headerDict objectForKey:key]];
		if ([key isEqualToString:@"Content-Type"]) {
			NSString *contentTypeLine = [headerDict objectForKey:key];
			NSArray *parts = [contentTypeLine componentsSeparatedByString:@";"];
			contentType = [[NSString alloc] initWithString:[parts objectAtIndex:0]];
            if ([parts count] > 1) {
                charset = [[parts objectAtIndex:1] stringByReplacingOccurrencesOfString:@"charset=" withString:@""];
            }
			NSLog(@"Got content type = %@", contentType);            
		}
	}
	
    self.responseView.syntaxMIME = contentType;
    [responseTextHeaders setString:headers];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	NSLog(@"Did fail");
	[headersTab setLabel:@"Response Headers (Failed)"];
	[responseText setString:[NSString stringWithFormat:@"Connection to %@ failed.", [urlBox stringValue]]];
	[status setStringValue:@"Failed"];
    [progressIndicator stopAnimation:self];
    [progressIndicator setHidden:YES];
}

// This controls if HTTP redirects are followed
- (NSURLRequest *)connection: (NSURLConnection *)inConnection
             willSendRequest: (NSURLRequest *)inRequest
            redirectResponse: (NSURLResponse *)inRedirectResponse;
{
    NSMutableString *headers = [[NSMutableString alloc] init];
    if (inRequest) {
        NSDictionary *sentHeaders = [inRequest allHTTPHeaderFields];
        for (NSString *key in sentHeaders) {
            [headers appendFormat:@"%@: %@\n", key, [sentHeaders objectForKey:key]];
        }
        [requestHeadersSentText setString:headers];
    }
    
    if (inRedirectResponse) {
        if (! [[NSUserDefaults standardUserDefaults] boolForKey:FOLLOW_REDIRECTS]) {
            return nil;
        } else {
            NSMutableURLRequest *r = [[inRequest mutableCopy] autorelease]; // original request
            [r setURL: [inRequest URL]];
            
            // For HTTP 301, 302, & 303s, there is w3c guidance about when the POST should be 
            // propogated rather than converted into a GET on the target of the redirect. See:
            // http://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html
            // Some users were not expecting this and (for better or worse) will be able to override
            // the built-in rules and propogate the HTTP method to the target of the redirect no
            // matter what the guidelines are.
            if ([[NSUserDefaults standardUserDefaults] boolForKey:APPLY_HTTP_METHOD_ON_REDIRECT]) {
                [r setHTTPMethod:[currentRequest HTTPMethod]];
            }
            return r;
        }
    } else {
        return inRequest;
    }
}

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
    if ([protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodClientCertificate]) {
        return NO;
    } else if ([protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        return allowSelfSignedCerts;
    } else {
        return YES;
    }
}

-(void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
        [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
    } else {
        if ([challenge previousFailureCount] == 0) {
            NSURLCredential *newCredential;
            newCredential = [NSURLCredential credentialWithUser:[username stringValue]
                                                       password:[password stringValue]
                                                    persistence:NSURLCredentialPersistenceNone];
            [[challenge sender] useCredential:newCredential forAuthenticationChallenge:challenge];
        } else {
            [[challenge sender] cancelAuthenticationChallenge:challenge];
            [responseText setString:@"Authentication Failed"];
        }
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	NSTimeInterval elapsed = [startDate timeIntervalSinceNow];
	[status setStringValue:[NSString stringWithFormat:@"Finished in %f seconds", -1*elapsed]];
	
	BOOL needToPrintPlain = YES;
	if (contentType != NULL) {
        if ([xmlContentTypes containsObject:contentType]) {
			NSLog(@"Formatting XML");
			NSError *error;
			NSXMLDocument *responseXML = [[NSXMLDocument alloc] initWithData:receivedData options:NSXMLNodePreserveAll error:&error];
			if (!responseXML) {
				NSLog(@"Error reading response: %@", error);
                needToPrintPlain = YES;
			} else {
                [responseText setString:[responseXML XMLStringWithOptions:NSXMLNodePrettyPrint]];
                needToPrintPlain = NO;
            }
		} else if ([jsonContentTypes containsObject:contentType]) {
			NSLog(@"Formatting JSON");
			SBJSON *parser = [[SBJSON alloc] init];
			[parser setHumanReadable:YES];
            NSString *jsonStringFromData = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
			id jsonObj = [parser objectWithString:jsonStringFromData];
            if (jsonObj) {
                NSString *jsonFormattedString = [[NSString alloc] initWithString:[parser stringWithObject:jsonObj]]; 
                [responseText setString:jsonFormattedString];
                needToPrintPlain = NO;
            }
            [parser release];
            [jsonStringFromData release];
            [jsonObj release];
		} else if ([msgPackContentTypes containsObject:contentType]) {
            NSLog(@"Formatting MsgPack");
            NSString *parsedObjectFromMsgPack = [[[receivedData messagePackParse]JSONRepresentation]autorelease];
            // In order to get pretty formatting for free (for now), we convert
            // the parsed MsgPack object back to JSON for pretty printing.
            SBJSON *parser = [[SBJSON alloc] init];
            [parser setHumanReadable:YES];
            id jsonObj = [parser objectWithString:parsedObjectFromMsgPack];
            if (jsonObj) {
                NSString *jsonFormattedString = [[[NSString alloc] initWithString:[parser stringWithObject:jsonObj]]autorelease];
                [responseText setString:jsonFormattedString];
                needToPrintPlain = NO;
            }
            [parser release];
            [jsonObj release];
            
        }
	} 
	
	// Bail out, just print the text
	if (needToPrintPlain) {
        // TODO: Use charset to select decoding
        // Attempt to decode the text as UTF8
        NSString *plainString = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
        if (! plainString) {
            // If not UTF8 try ISO-8859-1
            plainString = [[NSString alloc] initWithData:receivedData encoding:NSISOLatin1StringEncoding];
        }
        // Successfully decoded the response string
        if (plainString) {
            [responseText setString:plainString];
        } else {
            [responseText setString:@"Unable to decode charset of response to printable string."];
        }
	}
    
    [responseSyntaxBox selectItemWithObjectValue:[responseView syntaxMode]];
    [progressIndicator stopAnimation:self];
    [progressIndicator setHidden:YES];
}

#pragma mark -
#pragma mark Params

- (IBAction) doubleClickedParamsRow:(id)sender {
    NSInteger row = [paramsTableView clickedRow];
    NSInteger col = [paramsTableView clickedColumn];
    if (row == -1 && col == -1) {
        [self plusParamsRow:sender];
    } else {
        [paramsTableView editColumn:col row:row withEvent:nil select:YES];
    }
}

- (IBAction) plusParamsRow:(id)sender {
	NSMutableDictionary *row = [[NSMutableDictionary alloc] init];
	[row setObject:@"Key" forKey:@"key"];
	[row setObject:@"Value" forKey:@"value"];
	
	[paramsTable addObject:row];
	[paramsTableView reloadData];
	[paramsTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:([paramsTable count] - 1)] byExtendingSelection:NO];
	[paramsTableView editColumn:0 row:([paramsTable count] - 1) withEvent:nil select:YES];
	
	[row release];
}

- (IBAction) minusParamsRow:(id)sender {
    if ([paramsTable count] > [paramsTableView selectedRow]) {
        [paramsTable removeObjectAtIndex:[paramsTableView selectedRow]];
        [paramsTableView reloadData];
    }
}

- (void) doneEditingParamsRow:(TableRowAndColumn *)tableRowAndColumn {
    int lastTextMovement = [paramsTableView getLastTextMovement];
    if (lastTextMovement == NSTabTextMovement && [[tableRowAndColumn.column identifier] isEqualToString:@"value"]) {
        if (tableRowAndColumn.row == [[paramsTableView dataSource] numberOfRowsInTableView:paramsTableView] - 1) {
            [self plusParamsRow:nil];
        } else {
            [paramsTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:(tableRowAndColumn.row + 1)] byExtendingSelection:NO];
            [paramsTableView editColumn:0 row:(tableRowAndColumn.row + 1) withEvent:nil select:YES];
        }        
    }
    [tableRowAndColumn release];
}


#pragma mark -
#pragma mark Files

- (IBAction) doubleClickedFileRow:(id)sender {
    NSInteger row = [filesTableView clickedRow];
    NSInteger col = [filesTableView clickedColumn];
    if (row == -1 && col == -1) {
        [self plusFileRow:sender];
    } else {
        [filesTableView editColumn:col row:row withEvent:nil select:YES];
    }
}

- (void) addFileToFilesTable: (NSURL*) fileUrl {
    NSMutableDictionary *row = [[NSMutableDictionary alloc] init];
    [row setObject:[fileUrl lastPathComponent] forKey:@"key"];
    [row setObject:[fileUrl relativePath] forKey:@"value"];
    [row setObject:fileUrl  forKey:@"url"];
    
    [filesTable addObject:row];
    [filesTableView reloadData];
    [filesTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:([filesTable count] - 1)] byExtendingSelection:NO];
    [filesTableView editColumn:0 row:([filesTable count] - 1) withEvent:nil select:YES];
    [row release];
}

- (IBAction) plusFileRow:(id)sender {
	
	NSOpenPanel* picker = [NSOpenPanel openPanel];
	
	[picker setCanChooseFiles:YES];
	[picker setCanChooseDirectories:NO];
	[picker setAllowsMultipleSelection:NO];
	
	if ( [picker runModalForDirectory:nil file:nil] == NSOKButton ) {
		for(NSURL* url in [picker URLs]) {
			[self addFileToFilesTable:url];
		}
	}

}

- (IBAction) minusFileRow:(id)sender {
    if ([filesTable count] > [filesTableView selectedRow]) {
        [filesTable removeObjectAtIndex:[filesTableView selectedRow]];
        [filesTableView reloadData];
    }
}

- (NSDragOperation)tableView:(NSTableView *)tableView validateDrop:(id<NSDraggingInfo>)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)dropOperation {
    
    return NSDragOperationCopy;
}

- (BOOL)tableView:(NSTableView *)tableView acceptDrop:(id<NSDraggingInfo>)info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)dropOperation {
    
    if (tableView != filesTableView) {
        return NO;
    }

    NSPasteboard *pboard = [info draggingPasteboard];
    if ([[pboard types] containsObject: NSFilenamesPboardType]) {
        NSArray *new_files = [pboard propertyListForType: NSFilenamesPboardType];
        if (new_files.count > 0) {
            [new_files enumerateObjectsUsingBlock:^(NSString* path, NSUInteger idx, BOOL *stop) {
                [self addFileToFilesTable:[NSURL fileURLWithPath:path]];
            }];
            [filesTableView reloadData];
            
            return YES;
        }
    }
    
    return NO;
}

#pragma mark Menu methods
- (IBAction) contentTypeMenuItemSelected:(id)sender
{
    self.requestView.syntaxMIME = [sender title];
	BOOL inserted = FALSE;
	if([headersTable count] > 0) {
		for(NSMutableDictionary * row in headersTable) {
			if([[[row objectForKey:@"key"] lowercaseString] isEqualToString:@"content-type"]) {
				[row setObject:[sender title] forKey:@"value"];
				[headersTableView reloadData];
				inserted = TRUE;
				break;
			}	
		}
	}
	
	if (! inserted) {
		NSMutableDictionary *row = [[NSMutableDictionary alloc] init];
		[row setObject:@"Content-Type" forKey:@"key"];
		[row setObject:[sender title] forKey:@"value"];
		[headersTable addObject:row];
		[headersTableView reloadData];		
		[row release];
	}

//	[tabView selectTabViewItem:reqHeadersTab];
}

- (IBAction) allowSelfSignedCerts:(id)sender {
    if ([sender state] == NSOnState) {
        allowSelfSignedCerts = NO;
        [sender setState:NSOffState];
    } else {
        allowSelfSignedCerts = YES;
        [sender setState:NSOnState];
    }
}

#pragma mark Table view methods
- (NSInteger) numberOfRowsInTableView:(NSTableView *) tableView {
	NSInteger count;
	
	if(tableView == headersTableView)
		count = [headersTable count];
	
	if(tableView == filesTableView)
		count = [filesTable count];
	
	if(tableView == paramsTableView)
		count = [paramsTable count];
	
	return count;
	
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
	
	id object;
	
	if(tableView == headersTableView)
		object = [[headersTable objectAtIndex:row] objectForKey:[tableColumn identifier]];
	
	if(tableView == filesTableView)
		object = [[filesTable objectAtIndex:row] objectForKey:[tableColumn identifier]];
	
	if(tableView == paramsTableView)
		object = [[paramsTable objectAtIndex:row] objectForKey:[tableColumn identifier]];
	
	return object;
}

- (void)tableView:(NSTableView *)aTableView setObjectValue:(id)anObject 
   forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
	
	NSMutableDictionary *row;
	
	if(aTableView == headersTableView){
		row = [headersTable objectAtIndex:rowIndex];
		if (row == NULL) {
			row = [[NSMutableDictionary alloc] init];
		}
		[row setObject:anObject forKey:[aTableColumn identifier]];
		[headersTable replaceObjectAtIndex:rowIndex withObject:row];
	}
	
	if(aTableView == filesTableView){
		row = [filesTable objectAtIndex:rowIndex];
		if (row == NULL) {
			row = [[NSMutableDictionary alloc] init];
		}
		[row setObject:anObject forKey:[aTableColumn identifier]];
		[filesTable replaceObjectAtIndex:rowIndex withObject:row];
	}
	
	if(aTableView == paramsTableView){
		row = [paramsTable objectAtIndex:rowIndex];
		if (row == NULL) {
			row = [[NSMutableDictionary alloc] init];
		}
		[row setObject:anObject forKey:[aTableColumn identifier]];
		[paramsTable replaceObjectAtIndex:rowIndex withObject:row];
	}
}

- (IBAction) doubleClickedHeaderRow:(id)sender {
    NSInteger row = [headersTableView clickedRow];
    NSInteger col = [headersTableView clickedColumn];
    if (row == -1 && col == -1) {
        [self plusHeaderRow:sender];
    } else {
        [headersTableView editColumn:col row:row withEvent:nil select:YES];
    }
}

- (void) doneEditingHeaderRow:(TableRowAndColumn *)tableRowAndColumn {
    int lastTextMovement = [headersTableView getLastTextMovement];
    if (lastTextMovement == NSTabTextMovement && [[tableRowAndColumn.column identifier] isEqualToString:@"value"]) {
        if (tableRowAndColumn.row == [[headersTableView dataSource] numberOfRowsInTableView:headersTableView] - 1) {
            [self plusHeaderRow:nil];
        } else {
            [headersTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:(tableRowAndColumn.row + 1)] byExtendingSelection:NO];
            [headersTableView editColumn:0 row:(tableRowAndColumn.row + 1) withEvent:nil select:YES];
        }        
    }
    [tableRowAndColumn release];
}

- (IBAction) plusHeaderRow:(id)sender {
	NSMutableDictionary *row = [[NSMutableDictionary alloc] init];
    [row setObject:@"Key" forKey:@"key"];
	[row setObject:@"Value" forKey:@"value"];
	[headersTable addObject:row];
	[headersTableView reloadData];
	[headersTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:([headersTable count] - 1)] byExtendingSelection:NO];
	[headersTableView editColumn:0 row:([headersTable count] - 1) withEvent:nil select:YES];
	
	[row release];
}

- (IBAction) minusHeaderRow:(id)sender {
    if ([headersTable count] > [headersTableView selectedRow]) {
        [headersTable removeObjectAtIndex:[headersTableView selectedRow]];
        [headersTableView reloadData];
    }
}

- (IBAction) clearAuth:(id)sender {
	[username setStringValue:@""];
	[password setStringValue:@""];
}

#pragma mark OutlineViewDataSource methods
- (NSInteger) outlineView: (NSOutlineView *)outlineView numberOfChildrenOfItem: (id)item {
	if (item == nil) {
		return [savedRequestsArray count];
	}
	if (item == savedRequestsArray) {
		return [item count];
	}
	return 0;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    return NO;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item {
    if (item == nil) {
        item = savedRequestsArray;
    }
    
    if (item == savedRequestsArray) {
        return [item objectAtIndex:index];
    }
    
    return nil;
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
    if ([item isKindOfClass:[CRCRequest class]])
	{
		CRCRequest * req = (CRCRequest *)item;
		return req.name;
	}
	else if([item isKindOfClass:[NSDictionary class]] )
	{
		return [item objectForKey:@"name"];
	}
	else if (item == savedRequestsArray) {
		return savedRequestsArray;
    }
    
    return nil;
}

// Respond to click on a row of the saved requests outline view
- (IBAction) outlineClick:(id)sender {
	[self loadSavedRequest:[savedOutlineView itemAtRow:[savedOutlineView selectedRow]]];
}

- (IBAction) deleteSavedRequest:(id) sender {
    NSInteger row = [savedOutlineView selectedRow];
    if (savedRequestsArray.count > row) {
        [savedRequestsArray removeObjectAtIndex:row];
        [savedOutlineView reloadItem:nil reloadChildren:YES];
    }
}

// Save an HTTP request into the request drawer
- (IBAction) saveRequest:(id) sender {
	[NSApp beginSheet:saveRequestSheet modalForWindow:window
        modalDelegate:self didEndSelector:NULL contextInfo:nil];
}

// Dispose of save request sheet
- (IBAction) doneSaveRequest:(id) sender {
	if ([sender isKindOfClass:[NSTextField class]] || ! [[sender title] isEqualToString:@"Cancel"]) {
		CRCRequest * request = [CRCRequest requestWithApplication:self];
		
		[savedRequestsArray addObject:request];
		[savedOutlineView reloadItem:nil reloadChildren:YES];
	}
	[saveRequestSheet orderOut:nil];
    [NSApp endSheet:saveRequestSheet];
}

//
// Find the name attribute of the given request, assuming the input object is a request.
// On unknown input type, return "Unnamed". 
//
+ (NSString *) nameForRequest:(id)object {
    // Handle current request model
    if ([object isKindOfClass:[CRCRequest class]])
    {
        CRCRequest *crcRequest = (CRCRequest *) object;
        return crcRequest.name;
    }
    // Handle older version of requests
    else if([object isKindOfClass:[NSDictionary class]] )
    {
        return [object objectForKey:@"name"];
    }
    return @"Unnamed";
}

//
// Overwrite the selected request with the settings currently in the Application window, using the 
// same name as the selected request.
//
- (IBAction) overwriteRequest:(id)sender {
    NSLog(@"Overwriting request");
    int row = [savedOutlineView selectedRow];
    if (row > -1) {
        CRCRequest * request = [CRCRequest requestWithApplication:self];
        NSString *name = [CocoaRestClientAppDelegate nameForRequest:[savedRequestsArray objectAtIndex:row]];
        request.name = name;
        [savedRequestsArray replaceObjectAtIndex:row withObject:request];
        [savedOutlineView reloadItem:nil reloadChildren:YES];
    }
}

- (IBAction) openTimeoutDialog:(id) sender {
	[timeoutField setIntValue:[[NSUserDefaults standardUserDefaults] integerForKey:RESPONSE_TIMEOUT]];
	[NSApp beginSheet:timeoutSheet modalForWindow:window modalDelegate:self didEndSelector:NULL contextInfo:nil];
}

- (IBAction) closeTimoutDialog:(id) sender {
	if ([sender isKindOfClass:[NSTextField class]] || ! [[sender title] isEqualToString:@"Cancel"]) {
		[[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInteger:[timeoutField intValue]] forKey:RESPONSE_TIMEOUT];
	}
	[timeoutSheet orderOut:nil];
    [NSApp endSheet:timeoutSheet];
}

- (void)loadSavedRequest:(id)request {
	
	if([request isKindOfClass:[NSDictionary class]]) {
		[self loadSavedDictionary:(NSDictionary *)request];
	}
	else if([request isKindOfClass:[CRCRequest class]]) {
		[self loadSavedCRCRequest:(CRCRequest *)request];
	}
	
}

// if it's a dictionary it's the old format, files, params, rawRequestInput will not be present
- (void)loadSavedDictionary:(NSDictionary *)request
{
	[urlBox setStringValue:[request objectForKey:@"url"]];
	[methodButton selectItemWithTitle:[request objectForKey:@"method"]];
	[username setStringValue:[request objectForKey:@"username"]];
	[password setStringValue:[request objectForKey:@"password"]];
	
	self.rawRequestInput = YES;
    self.preemptiveBasicAuth = NO;
	
	if ([request objectForKey:@"body"]) {
		[requestText setString:[request objectForKey:@"body"]];
	} 
	else {
		[requestText setString:@""];
	}
	
	NSArray *headers = [request objectForKey:@"headers"];
	
	NSMutableArray *headersTranslated = [[NSMutableArray alloc] init];
	for(NSDictionary *header in headers) {
		if ([header objectForKey:@"header-name"]) {
			NSMutableDictionary *headerTranslated = [[NSMutableDictionary alloc] init];
			[headerTranslated setObject:[header objectForKey:@"header-name"] forKey:@"key"];
			[headerTranslated setObject:[header objectForKey:@"header-value"] forKey:@"value"];
			[headersTranslated addObject:headerTranslated];
		} else {
			[headersTranslated addObject:header];
		}
	}
	
	[headersTable removeAllObjects];
	[paramsTable removeAllObjects];
	[filesTable removeAllObjects];
	
	if (headers)
		[headersTable addObjectsFromArray:headersTranslated];
	
	[headersTableView reloadData];
	[filesTableView reloadData];
	[paramsTableView reloadData];
}

- (void)loadSavedCRCRequest:(CRCRequest *)request
{
	[urlBox setStringValue:request.url];
	[methodButton selectItemWithTitle:request.method];
	[username setStringValue:request.username];
	[password setStringValue:request.password];
	
	self.rawRequestInput = request.rawRequestInput;
    self.preemptiveBasicAuth = request.preemptiveBasicAuth;
	
	if(request.rawRequestInput)
	{
		[requestText setString:request.requestText];
	}
	else 
	{
		[requestText setString:@""];
	}
	
	NSArray *headers = [[NSArray alloc] initWithArray:request.headers copyItems:YES];
	NSArray *params = [[NSArray alloc] initWithArray:request.params copyItems:YES];
	NSArray *files = [[NSArray alloc] initWithArray:request.files copyItems:YES];
	
	[headersTable removeAllObjects];
	[paramsTable removeAllObjects];
	[filesTable removeAllObjects];
	
	// Make headers, params, and files mutable dictionaries when they get loaded so that 
	// they can still be updated after being loaded.
	if (headers) {
		for(NSDictionary *header in headers) {
			NSMutableDictionary *headerTranslated = [[NSMutableDictionary alloc] initWithDictionary:header];
			[headersTable addObject:headerTranslated];
		}
	}
	
	if (params) {
		for(NSDictionary *param in params) {
			NSMutableDictionary *paramTranslated = [[NSMutableDictionary alloc] initWithDictionary:param];
			[paramsTable addObject:paramTranslated];
		}
	}
	
	if (files) {
		for(NSDictionary *file in files) {
			NSMutableDictionary *fileTranslated = [[NSMutableDictionary alloc] initWithDictionary:file];
			[filesTable addObject:fileTranslated];
		}
	}
	
	[headersTableView reloadData];
	[filesTableView reloadData];
	[paramsTableView reloadData];
}

- (NSString *) pathForDataFile {
    if (!appDataFilePath) {
        NSArray *allPaths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
        NSString *dir = [[allPaths objectAtIndex: 0] stringByAppendingPathComponent: APPLICATION_NAME];
        if (!dir) {
            NSLog(@"Can not locate the Application Support directory. Weird.");
            return nil;
        }
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSError *error = nil;
        BOOL success = [fileManager createDirectoryAtPath: dir withIntermediateDirectories: YES
                                               attributes: nil error: &error];
        if (!success) {
            NSLog(@"Can not create a support directory.\n%@", [error localizedDescription]);
            return nil;
        }
        appDataFilePath = [[dir stringByAppendingPathComponent: DATAFILE_NAME] retain];
    }
    return appDataFilePath;  
}

- (void) saveDataToDisk {
	NSString *path = [self pathForDataFile];
	[NSKeyedArchiver archiveRootObject:savedRequestsArray toFile:path];
}

- (void) loadDataFromDisk {
	NSString *path = [self pathForDataFile];
	savedRequestsArray = [[NSMutableArray alloc] initWithArray:[NSKeyedUnarchiver unarchiveObjectWithFile:path]];
}

- (void) importRequestsFromArray:(NSArray *)requests {
    [exportRequestsController prepareToDisplayImports:requests];
    [NSApp beginSheet: [exportRequestsController window]
       modalForWindow: window
        modalDelegate: exportRequestsController
       didEndSelector: @selector(didEndSheet:returnCode:contextInfo:)
          contextInfo: nil];
}

- (void) invalidFileAlert {
    NSAlert *alert = [[[NSAlert alloc] init] autorelease];
    [alert addButtonWithTitle:@"OK"];
    [alert setMessageText:@"Invalid file"];
    [alert setInformativeText:@"Unable to read stored requests from file."];
    [alert setAlertStyle:NSWarningAlertStyle];
    [alert beginSheetModalForWindow:window modalDelegate:self didEndSelector:nil contextInfo:nil];
}

- (IBAction) importRequests:(id)sender {
    
    NSOpenPanel* picker = [NSOpenPanel openPanel];
	
	[picker setCanChooseFiles:YES];
	[picker setCanChooseDirectories:NO];
	[picker setAllowsMultipleSelection:NO];
    
    NSMutableArray *loadedRequests = [[NSMutableArray alloc] init];
    
    if ( [picker runModalForDirectory:nil file:nil] == NSOKButton ) {
        @try {
            for(NSURL* url in [picker URLs]) {
                NSString *path = [url path];
                NSLog(@"Loading requests from %@", path);
                [loadedRequests addObjectsFromArray:[NSKeyedUnarchiver unarchiveObjectWithFile:path]];            
            }
        }
        @catch (NSException *exception) {
            [self invalidFileAlert];
        }
	}
    
    if ([loadedRequests count] > 0) {
        [self importRequestsFromArray:loadedRequests];
    }
}

- (IBAction) exportRequests:(id)sender {
    [exportRequestsController prepareToDisplayExports];
    [NSApp beginSheet: [exportRequestsController window]
       modalForWindow: window
        modalDelegate: exportRequestsController
       didEndSelector: @selector(didEndSheet:returnCode:contextInfo:)
          contextInfo: nil];
}

- (IBAction) handleOpenWindow:(id)sender {
	[window makeKeyAndOrderFront:self];
}

- (IBAction) handleCloseWindow:(id)sender {
    [window close];
}

// Including this to disable Open Window menu item when window is already open
- (BOOL)validateMenuItem:(NSMenuItem *)item
{
	//check to see if the Main Menu NSMenuItem is
	//being validcated
	if([item tag] == MAIN_WINDOW_MENU_TAG) {
		return ![window isVisible];
	} else if ([item tag] == REGET_MENU_TAG) {
        return (lastRequest != nil && [lastRequest.method isEqualToString:@"GET"]);
    }
	
	return TRUE;
}

- (void) applicationWillTerminate: (NSNotification *)note {
	[self saveDataToDisk];
}

- (IBAction) helpInfo:(id)sender {
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://code.google.com/p/cocoa-rest-client/"]]; 
}

- (IBAction) licenseInfo:(id)sender {
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://cocoa-rest-client.googlecode.com/svn/trunk/LICENSE.txt"]]; 
}

- (IBAction) reloadLastRequest:(id)sender {
	if (lastRequest != nil) {
		[self loadSavedCRCRequest:(CRCRequest *)lastRequest];
		[self runSubmit: self];
	}
}

- (IBAction)deleteRow:(id)sender {
    NSLog(@"Calling delete row");
    NSString *currentTabLabel = [[tabView selectedTabViewItem] label];
    if ([currentTabLabel isEqualToString:@"Request Headers"] && [headersTableView selectedRow] > -1) {
        [self minusHeaderRow:sender];
    } else if ([currentTabLabel isEqualToString:@"Request Body"] && [paramsTableView selectedRow] > -1 && ! self.rawRequestInput) {
        [self minusParamsRow:sender];
    } else if ([currentTabLabel isEqualToString:@"Files"] && [filesTableView selectedRow] > -1) {
        [self minusFileRow:sender];
    }
}

- (IBAction) showPreferences:(id)sender {
    NSLog(@"Check for updates: %d", [[SUUpdater sharedUpdater] automaticallyChecksForUpdates]);
    NSLog(@"Downloads updates: %d", [[SUUpdater sharedUpdater] automaticallyDownloadsUpdates]);
    NSLog(@"Update check freq: %f", [[SUUpdater sharedUpdater] updateCheckInterval]);
    
    if(!self.preferencesController)
        self.preferencesController = [[PreferencesController alloc] initWithWindowNibName:@"Preferences"];
    
    [self.preferencesController showWindow:self];
}

- (void) showWelcome {
    [self.welcomeController showWindow:self];
    [[self.welcomeController window] makeKeyAndOrderFront:self];
    [[self.welcomeController window] setOrderedIndex:0];
    [[self.welcomeController window] center];
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:WELCOME_MESSAGE];
}

- (IBAction)zoomIn:(id)sender {
    NSFont *existingFont = [self.responseText font];
    if (existingFont) {
        [self.responseText setFont:[[NSFontManager sharedFontManager] convertFont:existingFont toSize:existingFont.pointSize + 2]];
    }
}

- (IBAction)zoomOut:(id)sender{
    NSFont *existingFont = [self.responseText font];
    if (existingFont) {
        [self.responseText setFont:[[NSFontManager sharedFontManager] convertFont:existingFont toSize:existingFont.pointSize - 2]];
    } 
}

- (IBAction) zoomDefault:(id)sender {
    NSFont *existingFont = [self.responseText font];
    if (existingFont) {
        [self.responseText setFont:[[NSFontManager sharedFontManager] convertFont:existingFont toSize:DEFAULT_FONT_SIZE]];
    }
}

- (IBAction) exportResponse:(id)sender {
    NSSavePanel* picker = [NSSavePanel savePanel];
	
    if ( [picker runModal] == NSOKButton ) {
		NSString* path = [picker filename];
        NSLog(@"Saving requests to %@", path);
        
        NSError *error;
        BOOL savedOK = [[responseText string] writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&error];
        
        if (! savedOK) {
            NSLog(@"Error writing file at %@\n%@", path, [error localizedFailureReason]);
            NSAlert *alert = [[NSAlert alloc] init];
            [alert addButtonWithTitle:@"OK"];
            [alert setMessageText:@"Unable to save response"];
            [alert setInformativeText:[error localizedFailureReason]];
            [alert setAlertStyle:NSWarningAlertStyle];
            [alert runModal];
        }
    }
}

- (NSString *) saveResponseToTempFile {
    NSString *tempDir = NSTemporaryDirectory();
    
    static int sequenceNumber = 0;
    NSString *path;
    do {
        sequenceNumber++;
        path = [NSString stringWithFormat:@"%d-%d-%d", [[NSProcessInfo processInfo] processIdentifier], 
                (int)[NSDate timeIntervalSinceReferenceDate], sequenceNumber];
        path = [tempDir stringByAppendingPathComponent:path];
    } while ([[NSFileManager defaultManager] fileExistsAtPath:path]);
    
    NSLog(@"Saving to %@", path);
    NSError *error;
    BOOL savedOK = [[responseText string] writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&error];
    
    if (! savedOK) {
        NSLog(@"Error writing file at %@\n%@", path, [error localizedFailureReason]);
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"OK"];
        [alert setMessageText:@"Unable to save response as temp file"];
        [alert setInformativeText:[error localizedFailureReason]];
        [alert setAlertStyle:NSWarningAlertStyle];
        [alert runModal];
        return nil;
    } else {
        return path;
    }
}

- (IBAction) viewResponseInBrowser:(id)sender {
    NSString *path = [self saveResponseToTempFile];
    if (path) {
        NSURL *outAppURL;
        OSStatus osStatus = LSGetApplicationForInfo(kLSUnknownType, kLSUnknownCreator, CFSTR("html"), kLSRolesViewer, (FSRef *) nil, (CFURLRef *) &outAppURL);
        NSLog(@"Browser app = %@", outAppURL);
        
        if (outAppURL != nil) {
            [[NSWorkspace sharedWorkspace] openFile:path withApplication:[outAppURL relativePath]];
        } else {
            NSLog(@"Error discovering default web browser");
            NSAlert *alert = [[NSAlert alloc] init];
            [alert addButtonWithTitle:@"OK"];
            [alert setMessageText:@"Unable to discover default web browser"];
            [alert setInformativeText:[NSString stringWithFormat:@"Status code = %d", osStatus]];
            [alert setAlertStyle:NSWarningAlertStyle];
            [alert runModal];
        }
    }
}

- (IBAction) reGetResponseInBrowser:(id)sender {
    if (lastRequest != nil && [lastRequest.method isEqualToString:@"GET"]) {
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:lastRequest.url]];
    }
}

- (IBAction) viewResponseInDefaultApplication:(id)sender {
    NSString *path = [self saveResponseToTempFile];
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"file://%@", path]]];
}

@end
