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

#define MAIN_WINDOW_MENU_TAG 150

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
@synthesize responseTextHeaders;
@synthesize requestText;
@synthesize methodButton;
@synthesize headersTable, filesTable, paramsTable;
@synthesize headersTableView, filesTableView, paramsTableView;
@synthesize username;
@synthesize password;
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

- (id) init {
	self = [super init];
	
	timeout = 20; 
	allowSelfSignedCerts = YES;
    followRedirects = YES;
    
	headersTable = [[NSMutableArray alloc] init];
	filesTable   = [[NSMutableArray alloc] init];
	paramsTable  = [[NSMutableArray alloc] init];
	
	NSMutableDictionary *row = [[NSMutableDictionary alloc] init];
	
	[row setObject:@"Content-Type" forKey:@"key"];
	//[row setObject:@"multipart/form-data" forKey:@"value"];
	[row setObject:@"application/x-www-form-urlencoded" forKey:@"value"];
	[headersTable addObject:row];
	[row release];
	
	/*row = [[NSMutableDictionary alloc] init];
	[row setObject:@"X-HTTP-Method-Override" forKey:@"key"];
	[row setObject:@"PUT" forKey:@"value"];
	[headersTable addObject:row];
	[row release];
	
	row = [[NSMutableDictionary alloc] init];
	[row setObject:@"nano" forKey:@"key"];
	[row setObject:@"bot" forKey:@"value"];
	[paramsTable addObject:row];
	[row release];
	 */
	
	
	/*
	savedRequestsArray = [[NSMutableArray alloc] init];
	NSMutableDictionary *req1 = [[NSMutableDictionary alloc] init];
	[req1 setObject:@"github feed" forKey:@"name"];
	[req1 setObject:@"http://github.com/mmattozzi.atom" forKey:@"url"];
	[req1 setObject:@"GET" forKey:@"method"];
	[savedRequestsArray addObject:req1];
	*/
	[self loadDataFromDisk];
    
    exportRequestsController = [[ExportRequestsController alloc] initWithWindowNibName:@"ExportRequests"];
    exportRequestsController.savedRequestsArray = savedRequestsArray;
     
	return self;
}

- (void) setRawRequestInput:(BOOL)value{
	
	rawRequestInput = value;
	
	if(value){
		[[requestText enclosingScrollView] setHidden:NO];
		[[paramsTableView enclosingScrollView] setHidden:YES];
		[plusParam setHidden:YES];
		[minusParam setHidden:YES];
	}
	else {
		[[requestText enclosingScrollView] setHidden:YES];
		[[paramsTableView enclosingScrollView] setHidden:NO];
		[plusParam setHidden:NO];
		[minusParam setHidden:NO];
	}

}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application 
	
	[methodButton removeAllItems];
	[methodButton addItemWithTitle:@"GET"];
	[methodButton addItemWithTitle:@"POST"];
	[methodButton addItemWithTitle:@"PUT"];
	[methodButton addItemWithTitle:@"DELETE"];
	[methodButton addItemWithTitle:@"HEAD"];
	
	[responseText setFont:[NSFont fontWithName:@"Courier New" size:12]]; 
	[responseTextHeaders setFont:[NSFont fontWithName:@"Courier New" size:12]];
	
	[requestText setFont:[NSFont fontWithName:@"Courier New" size:12]];
	
	[urlBox setNumberOfVisibleItems:10];
	[savedRequestsDrawer open];
    exportRequestsController.savedOutlineView = savedOutlineView;
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
	
	// NSAlert *alert = [NSAlert new];
	// [alert setMessageText:@"Clicked submit"];
	// [alert setInformativeText: [urlBox stringValue]];
	// [alert runModal];
	
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
	
	NSURL *url                    = [NSURL URLWithString:urlStr];
	NSString *method              = [NSString stringWithString:[methodButton titleOfSelectedItem]];
	NSMutableURLRequest * request = nil;
	
	// headers first
	NSMutableDictionary *headersDictionary = [[NSMutableDictionary alloc] init];
	
	for(NSDictionary * row in headersTable)
	{
		[headersDictionary setObject:[row objectForKey:@"value"] 
							  forKey:[row objectForKey:@"key"]];
		
		NSLog(@"%@ = %@", [row objectForKey:@"key"], [row objectForKey:@"value"]);
	}
	
	// initialize request
	request = [NSMutableURLRequest requestWithURL:url];
	[request setHTTPMethod:method];
	[request setAllHTTPHeaderFields:headersDictionary];
	[request setTimeoutInterval:timeout];
	
	NSLog(@"Building req");
	
	if(self.rawRequestInput)
	{
		if ([method isEqualToString:@"PUT"] || [method isEqualToString:@"POST"]) {
			if([filesTable count] > 0 && [[requestText string] isEqualToString:@""])
			{
				[CRCFileRequest createRequest:request];
			}
			else 
			{
				[CRCRawRequest createRequest:request];
			}
		}		
	}
	else 
	{
		if ([method isEqualToString:@"PUT"] || [method isEqualToString:@"POST"]) {
			switch(requestContentType)
			{
				case CRCContentTypeFormEncoded:
					[CRCFormEncodedRequest createRequest:request];
					break;
				
				case CRCContentTypeMultipart:
					[CRCMultipartRequest createRequest:request];
					break;
			}
		}
	}
	
	NSLog(@"Sending method %@", method);
	
	//NSURLResponse *response = [[NSURLResponse alloc] init];
	//NSError *error = [[NSError alloc] init];
	//NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	//[responseText setString:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
	
	if (lastRequest != nil) {
		[lastRequest release];
	}
	lastRequest = [CRCRequest requestWithApplication:self];
	
	if (startDate != nil) {
		[startDate release];
	}
	startDate = [NSDate date];
	NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
	if (! connection) {
		NSLog(@"Could not open connection to resource");
	}

}

#pragma mark -
#pragma mark Url Connection Delegate methods
- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[receivedData appendData:data];
	//[responseText setString:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
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
	[headers appendFormat:@"HTTP %d %@\n\n", [httpResponse statusCode], [[NSHTTPURLResponse localizedStringForStatusCode:[httpResponse statusCode]] capitalizedString]];
	
	[headersTab setLabel:[NSString stringWithFormat:@"Response Headers (%d)", [httpResponse statusCode]]];
	
	NSDictionary *headerDict = [httpResponse allHeaderFields];
	for (NSString *key in headerDict) {
		[headers appendFormat:@"%@: %@\n", key, [headerDict objectForKey:key]];
		if ([key isEqualToString:@"Content-Type"]) {
			NSString *contentTypeLine = [headerDict objectForKey:key];
			NSArray *parts = [contentTypeLine componentsSeparatedByString:@";"];
			contentType = [[NSString alloc] initWithString:[parts objectAtIndex:0]];
			NSLog(@"Got content type = %@", contentType);
		}
	}
	
	[responseTextHeaders setString:headers];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	NSLog(@"Did fail");
	[headersTab setLabel:@"Response Headers (Failed)"];
	[responseText setString:[NSString stringWithFormat:@"Connection to %@ failed.", [urlBox stringValue]]];
	[status setStringValue:@"Failed"];
}

// This controls if HTTP redirects are followed
- (NSURLRequest *)connection: (NSURLConnection *)inConnection
             willSendRequest: (NSURLRequest *)inRequest
            redirectResponse: (NSURLResponse *)inRedirectResponse;
{
    if (inRedirectResponse) {
        if (! followRedirects) {
            return nil;
        } else {
            NSMutableURLRequest *r = [[inRequest mutableCopy] autorelease]; // original request
            [r setURL: [inRequest URL]];
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
		if ([contentType isEqualToString:@"application/atom+xml"] || 
			[contentType isEqualToString:@"application/rss+xml"] || 
			[contentType isEqualToString:@"application/xml"]) {
			NSLog(@"Formatting XML");
			NSError *error;
			NSXMLDocument *responseXML = [[NSXMLDocument alloc] initWithData:receivedData options:NSXMLDocumentTidyXML error:&error];
			if (!responseXML) {
				NSLog(@"Error reading response: %@", error);
			}
			[responseText setString:[responseXML XMLStringWithOptions:NSXMLNodePrettyPrint]];
			needToPrintPlain = NO;
		} else if ([contentType isEqualToString:@"application/json"]) {
			NSLog(@"Formatting JSON");
			SBJSON *parser = [[SBJSON alloc] init];
			[parser setHumanReadable:YES];
            NSString *jsonStringFromData = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
			id jsonObj = [parser objectWithString:jsonStringFromData];
			NSString *jsonFormattedString = [[NSString alloc] initWithString:[parser stringWithObject:jsonObj]]; 
			[responseText setString:jsonFormattedString];
			needToPrintPlain = NO;
			[parser release];
            [jsonStringFromData release];
            [jsonObj release];
		}
	} 
	
	// Bail out, just print the text
	if (needToPrintPlain) {
		[responseText setString:[[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding]];
	}
}

#pragma mark -
#pragma mark Params

- (IBAction) plusParamsRow:(id)sender {
	NSMutableDictionary *row = [[NSMutableDictionary alloc] init];
	[row setObject:@"Key" forKey:@"key"];
	[row setObject:@"Value" forKey:@"value"];
	
	[paramsTable addObject:row];
	[paramsTableView reloadData];
	[paramsTableView selectRow:([paramsTable count] - 1) byExtendingSelection:NO];
	[paramsTableView editColumn:0 row:([paramsTable count] - 1) withEvent:nil select:YES];
	
	[row release];
}

- (IBAction) minusParamsRow:(id)sender {
	[paramsTable removeObjectAtIndex:[paramsTableView selectedRow]];
	[paramsTableView reloadData];
}


#pragma mark -
#pragma mark Files
- (IBAction) plusFileRow:(id)sender {
	
	NSOpenPanel* picker = [NSOpenPanel openPanel];
	
	[picker setCanChooseFiles:YES];
	[picker setCanChooseDirectories:NO];
	[picker setAllowsMultipleSelection:NO];
	

	// 10.6
	/*
	[picker beginSheetModalForWindow:window completionHandler:^(NSInteger actionStatus) {
		if(actionStatus == NSOKButton)
		{
			for(NSURL* url in [picker URLs])
			{
				NSMutableDictionary *row = [[NSMutableDictionary alloc] init];
				[row setObject:@"" forKey:@"key"];
				[row setObject:[url relativePath] forKey:@"value"];
				[row setObject:url  forKey:@"url"];
				
				[filesTable addObject:row];
				[filesTableView reloadData];
				[filesTableView selectRow:([filesTable count] - 1) byExtendingSelection:NO];
				[filesTableView editColumn:0 row:([filesTable count] - 1) withEvent:nil select:YES];
				[row release];
			}
		}
	}];
	 */

	// 10.5
	if ( [picker runModalForDirectory:nil file:nil] == NSOKButton )
	{
		
		for(NSURL* url in [picker URLs])
		{
			NSMutableDictionary *row = [[NSMutableDictionary alloc] init];
			[row setObject:@"" forKey:@"key"];
			[row setObject:[url relativePath] forKey:@"value"];
			[row setObject:url  forKey:@"url"];
			
			[filesTable addObject:row];
			[filesTableView reloadData];
			[filesTableView selectRow:([filesTable count] - 1) byExtendingSelection:NO];
			[filesTableView editColumn:0 row:([filesTable count] - 1) withEvent:nil select:YES];
			[row release];
		}

	}

}

- (IBAction) minusFileRow:(id)sender {
	[filesTable removeObjectAtIndex:[filesTableView selectedRow]];
	[filesTableView reloadData];
}

#pragma mark Menu methods
- (IBAction) contentTypeMenuItemSelected:(id)sender
{
	BOOL inserted = FALSE;
	if([headersTable count] > 0)
	{
		for(NSMutableDictionary * row in headersTable)
		{
			if([[[row objectForKey:@"key"] lowercaseString] isEqualToString:@"content-type"])
			{
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

	[tabView selectTabViewItem:reqHeadersTab];
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

- (IBAction) followRedirects:(id)sender {
    if ([sender state] == NSOnState) {
        followRedirects = NO;
        [sender setState:NSOffState];
    } else {
        followRedirects = YES;
        [sender setState:NSOnState];
    }
}

#pragma mark Table view methods
- (NSInteger) numberOfRowsInTableView:(NSTableView *) tableView {
	NSLog(@"Calling number rows");
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
	
	NSLog(@"Calling objectValueForTableColumn %d %@", row, [tableColumn identifier]);
	
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


- (IBAction) plusHeaderRow:(id)sender {
	NSMutableDictionary *row = [[NSMutableDictionary alloc] init];
	[headersTable addObject:row];
	[headersTableView reloadData];
	[headersTableView selectRow:([headersTable count] - 1) byExtendingSelection:NO];
	[headersTableView editColumn:0 row:([headersTable count] - 1) withEvent:nil select:YES];
	
	[row release];
}

- (IBAction) minusHeaderRow:(id)sender {
	[headersTable removeObjectAtIndex:[headersTableView selectedRow]];
	[headersTableView reloadData];
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
	/*
	NSAlert *alert = [NSAlert new];
	[alert setMessageText:[NSString stringWithFormat:@"Selected %@", [savedOutlineView itemAtRow:[savedOutlineView selectedRow]]]];
	[alert runModal];
	 */
	
	[self loadSavedRequest:[savedOutlineView itemAtRow:[savedOutlineView selectedRow]]];
}

- (IBAction) deleteSavedRequest:(id) sender {
	int row = [savedOutlineView selectedRow];
	[savedRequestsArray removeObjectAtIndex:row];
	[savedOutlineView reloadItem:nil reloadChildren:YES];
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

- (IBAction) openTimeoutDialog:(id) sender {
	[timeoutField setIntValue:timeout];
	[NSApp beginSheet:timeoutSheet modalForWindow:window modalDelegate:self didEndSelector:NULL contextInfo:nil];
}

- (IBAction) closeTimoutDialog:(id) sender {
	if ([sender isKindOfClass:[NSTextField class]] || ! [[sender title] isEqualToString:@"Cancel"]) {
		timeout = [timeoutField intValue];
	}
	[timeoutSheet orderOut:nil];
    [NSApp endSheet:timeoutSheet];
}

- (void)loadSavedRequest:(id)request {
	
	if([request isKindOfClass:[NSDictionary class]])
	{
		[self loadSavedDictionary:(NSDictionary *)request];
	}
	else if([request isKindOfClass:[CRCRequest class]])
	{
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
	
	if ([request objectForKey:@"body"]) 
	{
		[requestText setString:[request objectForKey:@"body"]];
	} 
	else 
	{
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
	NSFileManager *fileManager = [NSFileManager defaultManager];
    
	NSString *folder = @"~/Library/Application Support/CocoaRestClient/";
	folder = [folder stringByExpandingTildeInPath];
	
	if ([fileManager fileExistsAtPath: folder] == NO) {
		[fileManager createDirectoryAtPath:folder attributes:nil];
	}
    
	NSString *fileName = @"CocoaRestClient.savedRequests";
	return [folder stringByAppendingPathComponent:fileName];    
}

- (void) saveDataToDisk {
	NSString *path = [self pathForDataFile];
	[NSKeyedArchiver archiveRootObject:savedRequestsArray toFile:path];
}

- (void) loadDataFromDisk {
	NSString *path = [self pathForDataFile];
	savedRequestsArray = [[NSMutableArray alloc] initWithArray:[NSKeyedUnarchiver unarchiveObjectWithFile:path]];
}

- (IBAction) importRequests:(id)sender {
    
    NSOpenPanel* picker = [NSOpenPanel openPanel];
	
	[picker setCanChooseFiles:YES];
	[picker setCanChooseDirectories:NO];
	[picker setAllowsMultipleSelection:NO];
    
    NSMutableArray *loadedRequests = [[NSMutableArray alloc] init];
    
    if ( [picker runModalForDirectory:nil file:nil] == NSOKButton )
	{
		
		for(NSURL* url in [picker URLs])
		{
            NSString *path = [url path];
            NSLog(@"Loading requests from %@", path);
			[loadedRequests addObjectsFromArray:[NSKeyedUnarchiver unarchiveObjectWithFile:path]];            
		}
        
	}
    [exportRequestsController prepareToDisplayImports:loadedRequests];
    [NSApp beginSheet: [exportRequestsController window]
       modalForWindow: window
        modalDelegate: exportRequestsController
       didEndSelector: @selector(didEndSheet:returnCode:contextInfo:)
          contextInfo: nil];
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

// Including this to disable Open Window menu item when window is already open
- (BOOL)validateMenuItem:(NSMenuItem *)item
{
	//check to see if the Main Menu NSMenuItem is
	//being validcated
	if([item tag] == MAIN_WINDOW_MENU_TAG)
	{
		return ![window isVisible];
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

@end
