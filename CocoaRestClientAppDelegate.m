//
//  CocoaRestClientAppDelegate.m
//  CocoaRestClient
//
//  Created by mmattozzi on 1/5/10.
//

#import "CocoaRestClientAppDelegate.h"

#import <Foundation/Foundation.h>
#import "JSON.h"

@implementation CocoaRestClientAppDelegate

@synthesize window;
@synthesize submitButton;
@synthesize urlBox;
@synthesize responseText;
@synthesize responseTextHeaders;
@synthesize requestText;
@synthesize methodButton;
@synthesize headersTableView;
@synthesize username;
@synthesize password;
@synthesize savedOutlineView;
@synthesize saveRequestSheet;
@synthesize saveRequestTextField;
@synthesize savedRequestsDrawer;
@synthesize headersTab;

- (id) init {
	self = [super init];
	
	headersTable = [[NSMutableArray alloc] init];
	NSMutableDictionary *row = [[NSMutableDictionary alloc] init];
	[row setObject:@"text/plain" forKey:@"header-value"];
	[row setObject:@"Content-Type" forKey:@"header-name"];
	[headersTable addObject:row];
	
	/*
	savedRequestsArray = [[NSMutableArray alloc] init];
	NSMutableDictionary *req1 = [[NSMutableDictionary alloc] init];
	[req1 setObject:@"github feed" forKey:@"name"];
	[req1 setObject:@"http://github.com/mmattozzi.atom" forKey:@"url"];
	[req1 setObject:@"GET" forKey:@"method"];
	[savedRequestsArray addObject:req1];
	*/
	[self loadDataFromDisk];
	 
	return self;
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
}

- (IBAction) runSubmit:(id)sender {
	NSLog(@"Got submit press");
	// NSAlert *alert = [NSAlert new];
	// [alert setMessageText:@"Clicked submit"];
	// [alert setInformativeText: [urlBox stringValue]];
	// [alert runModal];
	
	[responseText setString:[NSString stringWithFormat:@"Loading %@", [urlBox stringValue]]];
	[responseTextHeaders setString:@""];
	[headersTab setLabel:@"Response Headers"];
	[urlBox insertItemWithObjectValue: [urlBox stringValue] atIndex:0];
	
	if (! receivedData) {
		receivedData = [[NSMutableData alloc] init];
	}
	[receivedData setLength:0];
	contentType = NULL;
	
	NSURL *url = [NSURL URLWithString:[urlBox stringValue]];
	NSString *method = [NSString stringWithString:[methodButton titleOfSelectedItem]];
	NSData *body = NULL;
	if ([method isEqualToString:@"PUT"] || [method isEqualToString:@"POST"]) {
		body = [[requestText string] dataUsingEncoding:NSUTF8StringEncoding];
	}
	
	NSMutableDictionary *headersDictionary = [[NSMutableDictionary alloc] init];
	for (int i = 0; i < [headersTable count]; i++) {
		[headersDictionary setObject:[[headersTable objectAtIndex:i] objectForKey:@"header-value"] 
							  forKey:[[headersTable objectAtIndex:i] objectForKey:@"header-name"]];
		NSLog(@"%@ = %@", [[headersTable objectAtIndex:i] objectForKey:@"header-name"], [[headersTable objectAtIndex:i] objectForKey:@"header-value"]);
	}
	
	NSLog(@"Building req");
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
	NSLog(@"Sending method %@", method);
	[request setHTTPMethod:method];
	[request setAllHTTPHeaderFields:headersDictionary];
	[request setTimeoutInterval:20];
	if (body != NULL) {
		NSLog(@"Setting body");
		[request setHTTPBody:body];
	}
	
	//NSURLResponse *response = [[NSURLResponse alloc] init];
	//NSError *error = [[NSError alloc] init];
	//NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	//[responseText setString:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
	
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

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	NSLog(@"Did receive response");
	
	NSMutableString *headers = [[NSMutableString alloc] init];
	NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
	[headers appendFormat:@"HTTP %d\n\n", [httpResponse statusCode]];
	
	[headersTab setLabel:[NSString stringWithFormat:@"Response Headers (%d)", [httpResponse statusCode]]];
	
	NSDictionary *headerDict = [httpResponse allHeaderFields];
	for (NSString *key in headerDict) {
		[headers appendFormat:@"%@: %@\n", key, [headerDict objectForKey:key]];
		if ([key isEqualToString:@"Content-Type"]) {
			NSString *contentTypeLine = [headerDict objectForKey:key];
			NSArray *parts = [contentTypeLine componentsSeparatedByString:@"; "];
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
}

-(void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
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

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
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
			id jsonObj = [parser objectWithString:[[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding]];
			NSString *jsonFormattedString = [[NSString alloc] initWithString:[parser stringWithObject:jsonObj]]; 
			[responseText setString:jsonFormattedString];
			needToPrintPlain = NO;
			[parser release];
		}
	} 
	
	// Bail out, just print the text
	if (needToPrintPlain) {
		[responseText setString:[[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding]];
	}
}

#pragma mark Table view methods
- (NSInteger) numberOfRowsInTableView:(NSTableView *) tableView {
	NSLog(@"Calling number rows");
	return [headersTable count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
	NSLog(@"Calling objectValueForTableColumn %d %@", row, [tableColumn identifier]);
	return [[headersTable objectAtIndex:row] objectForKey:[tableColumn identifier]];
}

- (void)tableView:(NSTableView *)aTableView setObjectValue:(id)anObject 
   forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
	NSMutableDictionary *row = [headersTable objectAtIndex:rowIndex];
	if (row == NULL) {
		row = [[NSMutableDictionary alloc] init];
	}
	[row setObject:anObject forKey:[aTableColumn identifier]];
	[headersTable replaceObjectAtIndex:rowIndex withObject:row];
}

- (IBAction) plusHeaderRow:(id)sender {
	NSMutableDictionary *row = [[NSMutableDictionary alloc] init];
	[headersTable addObject:row];
	[headersTableView reloadData];
	[headersTableView selectRow:([headersTable count] - 1) byExtendingSelection:NO];
	[headersTableView editColumn:0 row:([headersTable count] - 1) withEvent:nil select:YES];
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
- (int) outlineView: (NSOutlineView *)outlineView numberOfChildrenOfItem: (id)item {
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

- (id)outlineView:(NSOutlineView *)outlineView child:(int)index ofItem:(id)item {
    if (item == nil) {
        item = savedRequestsArray;
    }
    
    if (item == savedRequestsArray) {
        return [item objectAtIndex:index];
    }
    
    return nil;
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
    if ([item isKindOfClass:[NSDictionary class]]) {
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
		NSMutableDictionary *savedReq = [self saveCurrentRequestAsDictionary];
		[savedRequestsArray addObject:savedReq];
		[savedOutlineView reloadItem:nil reloadChildren:YES];
	}
	[saveRequestSheet orderOut:nil];
    [NSApp endSheet:saveRequestSheet];
}

- (NSMutableDictionary *) saveCurrentRequestAsDictionary {
	NSMutableDictionary *savedReq = [[NSMutableDictionary alloc] init];
	[savedReq setObject:[saveRequestTextField stringValue] forKey:@"name"];
	[savedReq setObject:[urlBox stringValue] forKey:@"url"];
	[savedReq setObject:[methodButton titleOfSelectedItem] forKey:@"method"];
	[savedReq setObject:[[NSString alloc] initWithString:[requestText string]] forKey:@"body"];
	[savedReq setObject:[username stringValue] forKey:@"username"];
	[savedReq setObject:[password stringValue] forKey:@"password"];
	
	[savedReq setObject:[[NSArray alloc] initWithArray:headersTable] forKey:@"headers"];
	
	return savedReq;
}

- (void) loadSavedRequest:(NSDictionary *) request {
	[urlBox setStringValue:[request objectForKey:@"url"]];
	[methodButton selectItemWithTitle:[request objectForKey:@"method"]];
	if ([request objectForKey:@"body"]) {
		[requestText setString:[request objectForKey:@"body"]];
	} else {
		[requestText setString:@""];
	}
	[username setStringValue:[request objectForKey:@"username"]];
	[password setStringValue:[request objectForKey:@"password"]];
	
	NSArray *headers = [request objectForKey:@"headers"];
	[headersTable removeAllObjects];
	if (headers) {
		[headersTable addObjectsFromArray:headers];
	}
	[headersTableView reloadData];
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

- (void) applicationWillTerminate: (NSNotification *)note {
	[self saveDataToDisk];
}

@end
