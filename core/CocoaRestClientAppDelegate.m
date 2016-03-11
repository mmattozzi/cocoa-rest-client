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
#import <SBJson4.h>
#import <Sparkle/SUUpdater.h>
#import "MsgPackSerialization.h"
#import "MF_Base64Additions.h"
#import "TableRowAndColumn.h"
#import "CRCSavedRequestFolder.h"

#define MAIN_WINDOW_MENU_TAG 150
#define REGET_MENU_TAG 151

#define APPLICATION_NAME @"CocoaRestClient"
#define DATAFILE_NAME @"CocoaRestClient.savedRequests"
#define BACKUP_DATAFILE_1_3_8 @"CocoaRestClient.savedRequests.backup-1.3.8"


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
@synthesize responseWebView;
@synthesize responseTextHeaders;
@synthesize requestView;
@synthesize responseView;
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
@synthesize themeMenuItem;
@synthesize jsonWriter;
@synthesize showLineNumbersMenuItem;

- (id) init {
	self = [super init];
	
    NSDictionary *defaults = [[NSMutableDictionary alloc] init];
    [defaults setValue:[NSNumber numberWithInt:30] forKey:RESPONSE_TIMEOUT];
    [defaults setValue:[NSNumber numberWithBool:YES] forKey:FOLLOW_REDIRECTS];
    [defaults setValue:[NSNumber numberWithBool:YES] forKey:SYNTAX_HIGHLIGHT];
    [defaults setValue:[NSNumber numberWithInteger:ACEThemeChrome] forKey:THEME];
    [defaults setValue:[NSNumber numberWithBool:YES] forKey:SHOW_LINE_NUMBERS];
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
	
    xmlContentTypes = [NSArray arrayWithObjects:@"application/xml", @"application/atom+xml", @"application/rss+xml",
                       @"text/xml", @"application/soap+xml", @"application/xml-dtd", nil];
    
    jsonContentTypes = [NSArray arrayWithObjects:@"application/json", @"text/json", nil];
    
    msgPackContentTypes = [NSArray arrayWithObjects:@"application/x-msgpack", @"application/x-messagepack", nil];
    
    [self loadDataFromDisk];
    
    exportRequestsController = [[ExportRequestsController alloc] initWithWindowNibName:@"ExportRequests"];
    exportRequestsController.savedRequestsArray = savedRequestsArray;
    
    self.welcomeController = [[WelcomeController alloc] initWithWindowNibName:@"Welcome"];
    
    // Register a key listener
    NSEvent * (^monitorHandler)(NSEvent *);
    monitorHandler = ^NSEvent * (NSEvent * theEvent) {
        
        if (([theEvent modifierFlags] & NSCommandKeyMask) && [[theEvent characters] isEqualToString:@"l"]) {
            [urlBox selectText:nil];
            return nil;
        } else {
            return theEvent;
        }
    };
    
    eventMonitor = [NSEvent addLocalMonitorForEventsMatchingMask:NSKeyDownMask handler:monitorHandler];
    
	return self;
}

- (void)setupObservers {
    [[NSUserDefaults standardUserDefaults]addObserver:self
                                           forKeyPath:SYNTAX_HIGHLIGHT
                                              options:NSKeyValueObservingOptionNew
                                              context:nil];
}



- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:SYNTAX_HIGHLIGHT]) {
        // This might come on a bg thread, good old foundation bug. Thats why the GCD call.
        // Diego
        dispatch_async(dispatch_get_main_queue(), ^{
            [self syntaxHighlightingPreferenceChanged];
        });
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
    self.jsonWriter = [[SBJson4Writer alloc] init];
    self.jsonWriter.humanReadable = YES;
    self.jsonWriter.sortKeys = NO;
    
    [self.requestTabView addItems:@[self.requestBodyItemView,
                                    self.requestHeadersItemView,
                                    self.requestAuthItemView,
                                    self.requestFilesItemView]];
    
    [self.responseTabView addItems:@[self.responseBodyItemView,
                                     self.responseHeadersItemView,
                                     self.responseHeadersSentItemView]];
  
    
    // Sync default params from defaults.plist
    [[NSUserDefaults standardUserDefaults]registerDefaults:[NSDictionary dictionaryWithContentsOfFile:@"defaults.plist"]];
    
    [methodButton removeAllItems];
	[methodButton addItemWithObjectValue:@"GET"];
	[methodButton addItemWithObjectValue:@"POST"];
	[methodButton addItemWithObjectValue:@"PUT"];
	[methodButton addItemWithObjectValue:@"DELETE"];
	[methodButton addItemWithObjectValue:@"HEAD"];
	[methodButton addItemWithObjectValue:@"OPTIONS"];
	[methodButton addItemWithObjectValue:@"PATCH"];
	[methodButton addItemWithObjectValue:@"COPY"];
	[methodButton addItemWithObjectValue:@"SEARCH"];
    
    
    
	requestMethodsWithoutBody = [NSSet setWithObjects:@"GET", @"DELETE", @"HEAD", @"OPTIONS", nil];
	
	[responseTextHeaders setFont:[NSFont fontWithName:@"Courier New" size:DEFAULT_FONT_SIZE]];
	[requestHeadersSentText setFont:[NSFont fontWithName:@"Courier New" size:DEFAULT_FONT_SIZE]];    
	
	[urlBox setNumberOfVisibleItems:10];
    [progressIndicator setHidden:YES];
    
    NSSize drawerSize;
    drawerSize.width = 200;
    drawerSize.height = 0;    
    if ([[NSUserDefaults standardUserDefaults] integerForKey:SAVED_DRAWER_SIZE]) {
        drawerSize.width = [[NSUserDefaults standardUserDefaults] integerForKey:SAVED_DRAWER_SIZE];
    }
    [savedRequestsDrawer setContentSize:drawerSize];
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
    
    [self.responseTextPlain setFont:[NSFont fontWithName:@"Courier" size:12]];
    [self.requestTextPlain setFont:[NSFont fontWithName:@"Courier" size:12]];
    
    [self initHighlightedViews];
    
    //[self syntaxHighlightingPreferenceChanged];
    
    
    // Enable Drag and Drop for outline view of saved requests
    [self.savedOutlineView registerForDraggedTypes: [NSArray arrayWithObject: @"public.text"]];
    
    [self setupObservers];
    
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag {
    return !(flag || ([self.window makeKeyAndOrderFront: self], 0));
}


- (void)syntaxHighlightingPreferenceChanged {
    BOOL syntaxHighlighting = [[NSUserDefaults standardUserDefaults] boolForKey:SYNTAX_HIGHLIGHT];
    syntaxHighlightingMenuItem.state = syntaxHighlighting;
    if (! syntaxHighlighting) {
        // Switch response from syntax highlighting to plain
        [self.responseTextPlain setString:[self.responseView string]];
        [self.responseView setString:@""];
        // Switch request from syntax highlighting to plain
        [self.requestTextPlain setString:[self.requestView string]];
        [self.requestView setString:@""];
    } else {
        // Switch response from plain to syntax highlighting
        [self.responseView setString:[self.responseTextPlain string]];
        [self.responseTextPlain setString:@""];
        
        // Switch request from plain to syntax highlighting
        [self.requestView setString:[self.requestTextPlain string]];
        [self.requestTextPlain setString:@""];
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

- (void) setResponseText:(NSString *)response {
    BOOL syntaxHighlighting = [[NSUserDefaults standardUserDefaults] boolForKey:SYNTAX_HIGHLIGHT];
    syntaxHighlightingMenuItem.state = syntaxHighlighting;
    if (! syntaxHighlighting) {
        [responseTextPlain setString:response];
    } else {
        [responseView setString:response];
    }
}

- (NSString *) getResponseText {
    BOOL syntaxHighlighting = [[NSUserDefaults standardUserDefaults] boolForKey:SYNTAX_HIGHLIGHT];
    syntaxHighlightingMenuItem.state = syntaxHighlighting;
    if (! syntaxHighlighting) {
        return responseTextPlain.string;
    } else {
        return self.responseView.string;
    }
}

- (void) setRequestText:(NSString *)request {
    BOOL syntaxHighlighting = [[NSUserDefaults standardUserDefaults] boolForKey:SYNTAX_HIGHLIGHT];
    syntaxHighlightingMenuItem.state = syntaxHighlighting;
    if (! syntaxHighlighting) {
        [self.requestTextPlain setString:request];
    } else {
        [self.requestView setString:request];
    }
}

- (NSString *) getRequestText {
    BOOL syntaxHighlighting = [[NSUserDefaults standardUserDefaults] boolForKey:SYNTAX_HIGHLIGHT];
    syntaxHighlightingMenuItem.state = syntaxHighlighting;
    if (! syntaxHighlighting) {
        return [self.requestTextPlain string];
    } else {
        return [self.requestView string];
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
	
	[self setResponseText:[NSString stringWithFormat:@"Loading %@", urlStr]];
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
    NSString *method = [methodButton stringValue];
	NSMutableURLRequest * request = nil;
    
	
	// initialize request
	request = [NSMutableURLRequest requestWithURL:url];
	[request setHTTPMethod:method];
	[request setTimeoutInterval:[[NSUserDefaults standardUserDefaults] integerForKey:RESPONSE_TIMEOUT]];
	
	BOOL contentTypeSet = NO;
    BOOL rawRequestBody = [[NSUserDefaults standardUserDefaults]boolForKey:RAW_REQUEST_BODY];
	if(rawRequestBody) {
		if (![requestMethodsWithoutBody containsObject:method]) {
			if([filesTable count] > 0 && [[self getRequestText] isEqualToString:@""]) {
				[CRCFileRequest createRequest:request];
			}
			else  {
				[CRCRawRequest createRequest:request];
			}
		}		
	}
	else {
		if (![requestMethodsWithoutBody containsObject:method]) {
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
        [headersDictionary setObject:[NSString stringWithFormat:@"Basic %@", [plainTextUserPass base64String]]
                              forKey:@"Authorization"];
    }
    
    [request setAllHTTPHeaderFields:headersDictionary];
    
	lastRequest = [CRCRequest requestWithApplication:self];
	if ([method isEqualToString:@"GET"]) {
        reGetResponseMenuItem.enabled = YES; 
    } else {
        reGetResponseMenuItem.enabled = NO;
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
    ACETheme aceTheme = [[NSUserDefaults standardUserDefaults] integerForKey:THEME];
    [[[themeMenuItem submenu] itemWithTag:aceTheme] setState:NSOnState];
    
    aceViewFontSize = 12;
    
    [responseView setDelegate:nil];
    [responseView setMode:ACEModeJSON];
    [responseView setTheme:aceTheme];
    [responseView setShowInvisibles:NO];
    [responseView setReadOnly:YES];
    [responseView setFontSize:aceViewFontSize];
    responseTypeManager = [[HighlightingTypeManager alloc] initWithView:responseView];
    
    [requestView setDelegate:nil];
    [requestView setMode:ACEModeText];
    [requestView setTheme:aceTheme];
    [requestView setShowInvisibles:NO];
    [requestView setFontSize:aceViewFontSize];
    requestTypeManager = [[HighlightingTypeManager alloc] initWithView:requestView];
    
    BOOL show = [[NSUserDefaults standardUserDefaults] boolForKey:SHOW_LINE_NUMBERS];
    [self applyShowLineNumbers:show];
    if (show) {
        [showLineNumbersMenuItem setState:NSOnState];
    } else {
        [showLineNumbersMenuItem setState:NSOffState];
    }
}

- (void) applyShowLineNumbers:(BOOL)show {
    [responseView setShowLineNumbers:show];
    [responseView setShowFoldWidgets:show];
    [responseView setShowGutter:show];
    [requestView setShowLineNumbers:show];
    [requestView setShowFoldWidgets:show];
    [requestView setShowGutter:show];
}

- (void) showLineNumbersToggled:(id)sender {
    NSInteger state = [((NSMenuItem *) sender) state];
    if (state == NSOnState) {
        [self applyShowLineNumbers:NO];
        [((NSMenuItem *) sender) setState:NO];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:SHOW_LINE_NUMBERS];
    } else if (state == NSOffState) {
        [self applyShowLineNumbers:YES];
        [((NSMenuItem *) sender) setState:YES];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:SHOW_LINE_NUMBERS];
    }
}

#pragma mark -
#pragma mark Find Menu items

-(IBAction) findMenuItem:(id)sender {
    NSResponder *responder = [self.window firstResponder];
    // Assume that in most cases the user wants to search in the response, unless they explicitly
    // have their focus on the request.
    if ([requestView ancestorSharedWithView:(NSView *)responder] == requestView) {
        [requestView showFindInterface];
    } else {
        [responseView showFindInterface];
    }
}

- (IBAction) findNextMenuItem:(id)sender {
    NSResponder *responder = [self.window firstResponder];
    // Assume that in most cases the user wants to search in the response, unless they explicitly
    // have their focus on the request.
    if ([requestView ancestorSharedWithView:(NSView *)responder] == requestView) {
        [requestView findNextMatch];
    } else {
        [responseView findNextMatch];
    }
}

- (IBAction) findPreviousMenuItem:(id)sender {
    NSResponder *responder = [self.window firstResponder];
    // Assume that in most cases the user wants to search in the response, unless they explicitly
    // have their focus on the request.
    if ([requestView ancestorSharedWithView:(NSView *)responder] == requestView) {
        [requestView findPreviousMatch];
    } else {
        [responseView findPreviousMatch];
    }
}

- (IBAction) replaceMenuItem:(id)sender {
    NSResponder *responder = [self.window firstResponder];
    // Replace only makes sense for the requestView
    if ([requestView ancestorSharedWithView:(NSView *)responder] == requestView) {
        [requestView showReplaceInterface];
    }
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
	
    // TODO self.responseView.syntaxMIME = contentType;
    [responseTypeManager setModeForMimeType:contentType];
    [responseTextHeaders setString:headers];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	NSLog(@"Did fail");
	[headersTab setLabel:@"Response Headers (Failed)"];
	[self setResponseText:[NSString stringWithFormat:@"Connection to %@ failed.", [urlBox stringValue]]];
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
            NSMutableURLRequest *r = [inRequest mutableCopy]; // original request
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
            [self setResponseText:@"Authentication Failed"];
        }
    }
}

- (void)prettyPrintJsonResponseFromObject:(id)obj {
    id data = [self.jsonWriter dataWithObject:obj];
    NSString *responseFormattedString =
    [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [self setResponseText:responseFormattedString];
}

- (void)prettyPrintJsonResponseFromString:(NSData*)jsonData {
    NSLog(@"Attempting to pretty print JSON");
    
    id block = ^(id obj, BOOL *ignored) {
        [self prettyPrintJsonResponseFromObject:obj];
    };
    
    id eh = ^(NSError *err) {
        NSLog(@"JSON parse error %@", err.description);
        [self printResponsePlain];
    };
    
    id parser = [SBJson4Parser parserWithBlock:block allowMultiRoot:NO unwrapRootArray:NO errorHandler:eh];
    SBJson4ParserStatus parseStatus = [parser parse:jsonData];
    if (parseStatus == SBJson4ParserWaitingForData) {
        NSLog(@"Unexpected end of JSON content");
        [self printResponsePlain];
    }
}

- (void)printResponsePlain {
    // TODO: Use charset to select decoding
    // Attempt to decode the text as UTF8
    NSString *plainString = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
    if (! plainString) {
        // If not UTF8 try ISO-8859-1
        plainString = [[NSString alloc] initWithData:receivedData encoding:NSISOLatin1StringEncoding];
    }
    // Successfully decoded the response string
    if (plainString) {
        [self setResponseText:plainString];
    } else {
        [self setResponseText:@"Unable to decode charset of response to printable string."];
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
                [self setResponseText:[responseXML XMLStringWithOptions:NSXMLNodePrettyPrint]];
                needToPrintPlain = NO;
            }
		} else if ([jsonContentTypes containsObject:contentType]) {
            [self prettyPrintJsonResponseFromString:receivedData];
            needToPrintPlain = NO;
		} else if ([msgPackContentTypes containsObject:contentType]) {
            NSLog(@"Attempting to format MsgPack as JSON");
            [self prettyPrintJsonResponseFromObject:[MsgPackSerialization MsgPackObjectWithData:receivedData options:0 error:nil]];
            needToPrintPlain = NO;
        }
	} 
	
	// Bail out, just print the text
	if (needToPrintPlain) {
        [self printResponsePlain];
	}
    
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
}

- (IBAction) minusParamsRow:(id)sender {
    if (paramsTable.lastObject) {
        [paramsTable removeObjectAtIndex:[paramsTableView selectedRow]];
    }
    [paramsTableView reloadData];
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
}

- (IBAction) plusFileRow:(id)sender {
	
	NSOpenPanel* picker = [NSOpenPanel openPanel];
	
	[picker setCanChooseFiles:YES];
	[picker setCanChooseDirectories:NO];
	[picker setAllowsMultipleSelection:NO];
  
	[picker beginSheetModalForWindow:self.window
     completionHandler:^(NSModalResponse returnCode) {
         if (returnCode == NSModalResponseOK) {
             for(NSURL* url in [picker URLs]) {
                 [self addFileToFilesTable:url];
             }
         }
     }];

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
    [requestTypeManager setModeForMimeType:[sender title]];
    
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
	}

	[tabView selectTabViewItem:reqHeadersTab];
}

- (IBAction) themeMenuItemSelected:(id)sender {
    [responseView setTheme:[sender tag]];
    [requestView setTheme:[sender tag]];
    
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInteger:[sender tag]] forKey:THEME];
    
    // Unselect all theme MenuItems
    NSMenuItem *themeMenu = [((NSMenuItem *) sender) parentItem];
    NSArray *allThemeMenuItems = [themeMenu.submenu itemArray];
    for (id menuItem in allThemeMenuItems) {
        [((NSMenuItem *)menuItem) setState:NSOffState];
    }
    
    // Enable the relevant theme MenuItem
    [((NSMenuItem *) sender) setState:NSOnState];
}

- (IBAction) allowSelfSignedCerts:(id)sender {
    NSMenuItem* menuItemSender = (NSMenuItem *) sender;
    if ([menuItemSender state] == NSOnState) {
        allowSelfSignedCerts = NO;
        [menuItemSender setState:NSOffState];
    } else {
        allowSelfSignedCerts = YES;
        [menuItemSender setState:NSOnState];
    }
}

#pragma mark Table view methods
- (NSInteger) numberOfRowsInTableView:(NSTableView *) tableView {
	NSInteger count= nil;
	
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
}

- (IBAction) plusHeaderRow:(id)sender {
	NSMutableDictionary *row = [[NSMutableDictionary alloc] init];
    [row setObject:@"Key" forKey:@"key"];
	[row setObject:@"Value" forKey:@"value"];
	[headersTable addObject:row];
	[headersTableView reloadData];
	[headersTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:([headersTable count] - 1)] byExtendingSelection:NO];
	[headersTableView editColumn:0 row:([headersTable count] - 1) withEvent:nil select:YES];
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
	} else {
		return [item count];
	}
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    if (item == nil) return NO;
    return [item isKindOfClass:[CRCSavedRequestFolder class]];
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item {
    if (item == nil) {
        return [savedRequestsArray objectAtIndex:index];
    } else {
        return [item objectAtIndex:index];
    }
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
    if ([item isKindOfClass:[CRCRequest class]])
	{
		CRCRequest * req = (CRCRequest *)item;
		return req.name;
	}
	else if ([item isKindOfClass:[CRCSavedRequestFolder class]])
	{
		return ((CRCSavedRequestFolder *)item).name;
	}
	else if (item == savedRequestsArray) {
		return savedRequestsArray;
    }
    
    return nil;
}

- (void) outlineView:(NSOutlineView *)outlineView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
    if ([item isKindOfClass:[CRCRequest class]]) {
		CRCRequest * req = (CRCRequest *)item;
		req.name = object;
	}
	else if ([item isKindOfClass:[CRCSavedRequestFolder class]]) {
		((CRCSavedRequestFolder *)item).name = object;
	}
}

#pragma mark OutlineView drag and drop methods
- (id <NSPasteboardWriting>)outlineView:(NSOutlineView *)outlineView pasteboardWriterForItem:(id)item{
    // No dragging if <some condition isn't met>
    BOOL dragAllowed = YES;
    if (!dragAllowed)  {
        return nil;
    }
    
    NSPasteboardItem *pboardItem = [[NSPasteboardItem alloc] init];
    NSString *idStr = [NSString stringWithFormat:@"%ld", (long) item];
    [pboardItem setString:idStr forType: @"public.text"];
    NSLog(@"%@", idStr);
    
    return pboardItem;
}


- (NSDragOperation)outlineView:(NSOutlineView *)outlineView validateDrop:(id < NSDraggingInfo >)info proposedItem:(id)targetItem proposedChildIndex:(NSInteger)index{
    
    if (index >= 0) {
        return NSDragOperationMove;
    } else {
        return NSDragOperationNone;
    }
}


- (BOOL)outlineView:(NSOutlineView *)outlineView acceptDrop:(id < NSDraggingInfo >)info item:(id)targetItem childIndex:(NSInteger)targetIndex{
    
    NSPasteboard *p = [info draggingPasteboard];
    NSString *objId = [p stringForType:@"public.text"];
    NSLog(@"Pasteboad item = %@", objId);
    
    id sourceItem = nil;
    CRCSavedRequestFolder *sourceParentFolder = nil;
    int sourceIndex = -1;
    
    for (id entry in savedRequestsArray) {
        if ([[NSString stringWithFormat:@"%ld", (long) entry] isEqualToString:objId]) {
            sourceItem = entry;
            sourceIndex = [savedRequestsArray indexOfObject:sourceItem];
        } else if ([entry isKindOfClass:[CRCSavedRequestFolder class]]) {
            id recursiveParent = [((CRCSavedRequestFolder *)entry) findParentOfObjectWith:objId];
            if (recursiveParent) {
                sourceParentFolder = recursiveParent;
                sourceItem = [((CRCSavedRequestFolder *)sourceParentFolder) findObjectWith:objId];
                sourceIndex = [((CRCSavedRequestFolder *)sourceParentFolder) findIndexOfObject:sourceItem];
            }
        }
    }
    
    // Unclear how this would happen, but we don't know what we are moving
    if (! sourceItem) {
        NSLog(@"Unable to find source item dropped into list");
        return NO;
    }
    
    if (sourceIndex == -1) {
        NSLog(@"Unable to find index of moving item");
        return NO;
    }
        
    if (sourceParentFolder) {
        [((CRCSavedRequestFolder *) sourceParentFolder) removeObject:sourceItem];
    } else {
        [savedRequestsArray removeObject:sourceItem];
    }    
    
    NSLog(@"Found source item of drop: %@ with parent %@", sourceItem, sourceParentFolder);
    
    if (! targetItem) {
        // Saving into the top level array
        if (sourceParentFolder == nil && (targetIndex > sourceIndex)) {
            targetIndex--;
        }
        [savedRequestsArray insertObject:sourceItem atIndex:targetIndex];
        [savedOutlineView reloadItem:nil reloadChildren:YES];
        [self saveDataToDisk];
        return YES;
    } else {
        // Saving into a sub-folder
        NSLog(@"TargetIndex = %ld and sourceIndex = %d", targetIndex, sourceIndex);
        if (sourceParentFolder == targetItem && (targetIndex > sourceIndex)) {
            targetIndex--;
        }
        [((CRCSavedRequestFolder *) targetItem) insertObject:sourceItem atIndex:targetIndex];
        [savedOutlineView reloadItem:nil reloadChildren:YES];
        [self saveDataToDisk];
        return YES;
    }
    
}


- (IBAction) createNewSavedFolder:(id)sender {
    CRCSavedRequestFolder *folder = [[CRCSavedRequestFolder alloc] init];
    folder.name = @"New folder";
    // [savedRequestsArray addObject:folder];
    
    id selectedSavedOutlineViewItem = [savedOutlineView itemAtRow:[savedOutlineView selectedRow]];
    if ([selectedSavedOutlineViewItem isKindOfClass:[CRCSavedRequestFolder class]]) {
        [selectedSavedOutlineViewItem addObject:folder];
    } else {
        [savedRequestsArray addObject:folder];
    }
    
    [savedOutlineView reloadItem:nil reloadChildren:YES];
    [savedOutlineView expandItem:folder expandChildren:YES];
    [savedOutlineView editColumn:0 row:[savedOutlineView rowForItem:folder] withEvent:nil select:YES];
}

// Respond to click on a row of the saved requests outline view
- (IBAction) outlineClick:(id)sender {
	[self loadSavedRequest:[savedOutlineView itemAtRow:[savedOutlineView selectedRow]]];
}

- (IBAction) deleteSavedRequest:(id) sender {
    id object = [savedOutlineView itemAtRow:[savedOutlineView selectedRow]];
    if ([savedRequestsArray containsObject:object]) {
        [savedRequestsArray removeObject:object];
    } else {
        for (id entry in savedRequestsArray) {
            if ([entry isKindOfClass:[CRCSavedRequestFolder class]]) {
                [entry removeObject:object];
            }
        }
    }
    [savedOutlineView reloadItem:nil reloadChildren:YES];
    [self saveDataToDisk];
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
		
        id selectedSavedOutlineViewItem = [savedOutlineView itemAtRow:[savedOutlineView selectedRow]];
        if ([selectedSavedOutlineViewItem isKindOfClass:[CRCSavedRequestFolder class]]) {
            [selectedSavedOutlineViewItem addObject:request];
        } else {
            [savedRequestsArray addObject:request];
        }
		[savedOutlineView reloadItem:nil reloadChildren:YES];
	}
	[saveRequestSheet orderOut:nil];
    [NSApp endSheet:saveRequestSheet];
    [self saveDataToDisk];
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
        
        id selectedSavedOutlineViewItem = [savedOutlineView itemAtRow:[savedOutlineView selectedRow]];
        if ([selectedSavedOutlineViewItem isKindOfClass:[CRCSavedRequestFolder class]]) {
            // TODO: doesn't make sense to overwrite a folder
        } else {
            [((CRCRequest *) selectedSavedOutlineViewItem) overwriteContentsWith:request];
            [savedOutlineView reloadItem:nil reloadChildren:YES];
            [self saveDataToDisk];
        }
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
    [methodButton setStringValue:[request objectForKey:@"method"]];
	[username setStringValue:[request objectForKey:@"username"]];
	[password setStringValue:[request objectForKey:@"password"]];
	
	//self.rawRequestInput = YES;
    self.preemptiveBasicAuth = NO;
	
	if ([request objectForKey:@"body"]) {
		[self setRequestText:[request objectForKey:@"body"]];
	} 
	else {
        [self setRequestText:@""];
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
    [methodButton setStringValue:request.method];
	[username setStringValue:request.username];
	[password setStringValue:request.password];
	
	[[NSUserDefaults standardUserDefaults]setBool:request.rawRequestInput
                                            forKey:RAW_REQUEST_BODY];
    self.preemptiveBasicAuth = request.preemptiveBasicAuth;
	
	if([[NSUserDefaults standardUserDefaults]boolForKey:RAW_REQUEST_BODY])
	{
        [self setRequestText:request.requestText];
	}
	else 
	{
		[self setRequestText:@""];
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
            if ([((NSString *)[header objectForKey:@"key"]) isEqualToString:@"Content-Type"]) {
                [requestTypeManager setModeForMimeType:[header objectForKey:@"value"]];
            }
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
        appDataFilePath = [dir stringByAppendingPathComponent: DATAFILE_NAME];
        
        // On first time startup of version 1.3.8 of the app, backup the data file since the format
        // will make it backwards incompatible.
        NSString *backupDataFilePath = [dir stringByAppendingPathComponent:BACKUP_DATAFILE_1_3_8];
        if (! [fileManager fileExistsAtPath:backupDataFilePath]) {
            NSError *error = nil;
            [fileManager copyItemAtPath:appDataFilePath toPath:backupDataFilePath error:&error];
            if (! error) {
                NSLog(@"Successfully backed up 1.3.8 datafile as: %@", backupDataFilePath);
            } else {
                NSLog(@"Error backing up old data file: %@", [error localizedDescription]);
            }
        }
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
    NSAlert *alert = [[NSAlert alloc] init];
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
    [picker beginSheetModalForWindow:self.window
                   completionHandler:^(NSInteger result) {
                       if (result == NSFileHandlingPanelOKButton) {
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
                   }];
    
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
    [[NSUserDefaults standardUserDefaults] setInteger:[savedRequestsDrawer contentSize].width forKey:SAVED_DRAWER_SIZE];
    [NSEvent removeMonitor:eventMonitor];
}

- (IBAction) helpInfo:(id)sender {
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://mmattozzi.github.io/cocoa-rest-client/"]]; 
}

- (IBAction) licenseInfo:(id)sender {
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://raw.githubusercontent.com/mmattozzi/cocoa-rest-client/master/LICENSE.txt"]];
}

- (IBAction) reloadLastRequest:(id)sender {
	if (lastRequest != nil) {
		[self loadSavedCRCRequest:(CRCRequest *)lastRequest];
		[self runSubmit: self];
	}
}

- (IBAction)deleteRow:(id)sender {
    NSLog(@"Calling delete row");
    
    if ([window firstResponder] == savedOutlineView) {
        [self deleteSavedRequest: sender];
        return;
    }
    BOOL rawRequestBody = [[NSUserDefaults standardUserDefaults]boolForKey:RAW_REQUEST_BODY];
    
    NSString *currentTabLabel = [[tabView selectedTabViewItem] label];
    if ([currentTabLabel isEqualToString:@"Request Headers"] && [headersTableView selectedRow] > -1) {
        [self minusHeaderRow:sender];
    } else if ([currentTabLabel isEqualToString:@"Request Body"] && [paramsTableView selectedRow] > -1 && ! rawRequestBody) {
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

- (IBAction)zoomIn:(id)sender {
    aceViewFontSize += 2;
    [responseView setFontSize:aceViewFontSize];
    [requestView setFontSize:aceViewFontSize];
}

- (IBAction)zoomOut:(id)sender{
    aceViewFontSize -= 2;
    [responseView setFontSize:aceViewFontSize];
    [requestView setFontSize:aceViewFontSize];
}

- (IBAction) zoomDefault:(id)sender {
    [responseView setFontSize:DEFAULT_FONT_SIZE];
    [requestView setFontSize:DEFAULT_FONT_SIZE];
}

- (IBAction) exportResponse:(id)sender {
    NSSavePanel* picker = [NSSavePanel savePanel];
	
    if ( [picker runModal] == NSOKButton ) {
		NSURL* path = [picker URL];
        NSLog(@"Saving requests to %@", path.absoluteString);
        
        NSError *error;
        BOOL savedOK = [[self getResponseText] writeToFile:path.absoluteString atomically:YES encoding:NSUTF8StringEncoding error:&error];
        
        if (! savedOK) {
            NSLog(@"Error writing file at %@\n%@", path.absoluteString, [error localizedFailureReason]);
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
        path = [NSString stringWithFormat:@"%d-%d-%d.txt", [[NSProcessInfo processInfo] processIdentifier],
                (int)[NSDate timeIntervalSinceReferenceDate], sequenceNumber];
        path = [tempDir stringByAppendingPathComponent:path];
    } while ([[NSFileManager defaultManager] fileExistsAtPath:path]);
    
    NSLog(@"Saving to %@", path);
    NSError *error;
    BOOL savedOK = [[self getResponseText] writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&error];
    
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
        NSURL *defaultBrowserURL =
        [[NSWorkspace sharedWorkspace]URLForApplicationToOpenURL:[NSURL URLWithString:@"http://google.com"]];
        [[NSWorkspace sharedWorkspace]openFile:path.stringByStandardizingPath
                               withApplication:defaultBrowserURL.absoluteString.lastPathComponent];
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
