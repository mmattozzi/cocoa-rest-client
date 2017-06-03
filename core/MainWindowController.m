//
//  MainWindowController.m
//  CocoaRestClient
//
//  Created by Mike Mattozzi on 5/7/17.
//
//

#import "MainWindowController.h"
#import "CRCMultipartRequest.h"
#import "CRCFormEncodedRequest.h"
#import "CRCRawRequest.h"
#import "CRCFileRequest.h"
#import "MF_Base64Additions.h"
#import "ContentTypes.h"
#import "MsgPackSerialization.h"
#import "CRCSavedRequestFolder.h"
#import "SavedRequestsDataSource.h"
#import "CRCDrawerView.h"

@implementation MainWindowController

@synthesize appDelegate;
@synthesize lastRequest;
@synthesize paramsTable;
@synthesize filesTable;
@synthesize headersTable;
@synthesize rawRequestBody;
@synthesize fileRequestBody;
@synthesize savedRequestsView;
@synthesize verticalSplitView;
@synthesize savedRequestsOuterView;
@synthesize lastSavedRequestsViewWidth;

#pragma mark -
#pragma mark Init and Window Methods

- (void)windowDidLoad {
    [super windowDidLoad];
    
    self.headersTable = [[NSMutableArray alloc] init];
    self.filesTable   = [[NSMutableArray alloc] init];
    self.paramsTable  = [[NSMutableArray alloc] init];
    
    NSMutableDictionary *row = [[NSMutableDictionary alloc] init];
    
    [row setObject:@"Content-Type" forKey:@"key"];
    [row setObject:@"application/x-www-form-urlencoded" forKey:@"value"];
    [self.headersTable addObject:row];
    
    jsonWriter = [[SBJson4Writer alloc] init];
    jsonWriter.humanReadable = YES;
    jsonWriter.sortKeys = NO;
    
    [self.requestTabView addItems:@[self.requestBodyItemView,
                                    self.requestHeadersItemView,
                                    self.requestAuthItemView,
                                    self.requestFilesItemView]];
    
    [self.responseTabView addItems:@[self.responseBodyItemView,
                                     self.responseHeadersItemView,
                                     self.responseHeadersSentItemView]];
    
    [self.methodButton removeAllItems];
    [self.methodButton addItemWithObjectValue:@"GET"];
    [self.methodButton addItemWithObjectValue:@"POST"];
    [self.methodButton addItemWithObjectValue:@"PUT"];
    [self.methodButton addItemWithObjectValue:@"DELETE"];
    [self.methodButton addItemWithObjectValue:@"HEAD"];
    [self.methodButton addItemWithObjectValue:@"OPTIONS"];
    [self.methodButton addItemWithObjectValue:@"PATCH"];
    [self.methodButton addItemWithObjectValue:@"COPY"];
    [self.methodButton addItemWithObjectValue:@"SEARCH"];
    
    [self.responseTextHeaders setFont:[NSFont fontWithName:@"Courier New" size:DEFAULT_FONT_SIZE]];
    [self.requestHeadersSentText setFont:[NSFont fontWithName:@"Courier New" size:DEFAULT_FONT_SIZE]];
    
    [self.urlBox setNumberOfVisibleItems:10];
    [self.progressIndicator setHidden:YES];
    
    self.rawRequestBody = [[NSUserDefaults standardUserDefaults] boolForKey:RAW_REQUEST_BODY];
    self.fileRequestBody = [[NSUserDefaults standardUserDefaults] boolForKey:FILE_REQUEST_BODY];
    [self selectRequestBodyInputMode];
    
    [self.headersTableView setDoubleAction:@selector(doubleClickedHeaderRow:)];
    [self.headersTableView setTextDidEndEditingAction:@selector(doneEditingHeaderRow:)];
    [self.paramsTableView setDoubleAction:@selector(doubleClickedParamsRow:)];
    [self.paramsTableView setTextDidEndEditingAction:@selector(doneEditingParamsRow:)];
    [self.filesTableView setDoubleAction:@selector(doubleClickedFileRow:)];
    
    [self.filesTableView registerForDraggedTypes: [NSArray arrayWithObject: NSFilenamesPboardType]];
    [self.filesTableView setDelegate: self];
    [self.filesTableView setDataSource: self];
    
    [self.responseTextPlain setEditable:NO];
    
    [self.responseTextPlain setFont:[NSFont fontWithName:@"Courier" size:12]];
    [self.requestTextPlain setFont:[NSFont fontWithName:@"Courier" size:12]];
    
    [self initHighlightedViews];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteTableRow:) name:@"deleteTableRow" object:nil];

    // Enable Drag and Drop for outline view of saved requests WITHIN the outline view
    [self.savedOutlineView registerForDraggedTypes: [NSArray arrayWithObject: @"public.text"]];
    
    // Enable Drag and Drop of external files into CRC
    [self.savedRequestsView registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType, nil]];
}

- (void)windowWillClose:(NSNotification *)notification {
    [appDelegate tabWasRemoved:self];
}

- (IBAction) newWindowForTab: (id)sender {
    [appDelegate addTabFromWindow:self.window];
}

- (void)windowDidBecomeKey:(NSNotification *)notification {
    [appDelegate setCurrentMainWindowController:self];
}

-(void) initHighlightedViews {
    ACETheme aceTheme = [[NSUserDefaults standardUserDefaults] integerForKey:THEME];
    [[[self.appDelegate.themeMenuItem submenu] itemWithTag:aceTheme] setState:NSOnState];
    
    self.appDelegate.aceViewFontSize = 12;
    
    [self.responseView setDelegate:nil];
    [self.responseView setMode:ACEModeJSON];
    [self.responseView setTheme:aceTheme];
    [self.responseView setShowInvisibles:NO];
    [self.responseView setReadOnly:YES];
    [self.responseView setFontSize:self.appDelegate.aceViewFontSize];
    responseTypeManager = [[HighlightingTypeManager alloc] initWithView:self.responseView];
    
    [self.requestView setDelegate:nil];
    [self.requestView setMode:ACEModeText];
    [self.requestView setTheme:aceTheme];
    [self.requestView setShowInvisibles:NO];
    [self.requestView setFontSize:self.appDelegate.aceViewFontSize];
    requestTypeManager = [[HighlightingTypeManager alloc] initWithView:self.requestView];
    
    BOOL show = [[NSUserDefaults standardUserDefaults] boolForKey:SHOW_LINE_NUMBERS];
    [self applyShowLineNumbers:show];
    if (show) {
        [self.appDelegate.showLineNumbersMenuItem setState:NSOnState];
    } else {
        [self.appDelegate.showLineNumbersMenuItem setState:NSOffState];
    }
}

#pragma mark -
#pragma mark Request Manipulation

- (void) setRequestText:(NSString *)request {
    BOOL syntaxHighlighting = [[NSUserDefaults standardUserDefaults] boolForKey:SYNTAX_HIGHLIGHT];
    if (! syntaxHighlighting) {
        [self.requestTextPlain setString:request];
    } else {
        [self.requestView setString:request];
    }
}

- (NSString *) getRequestText {
    BOOL syntaxHighlighting = [[NSUserDefaults standardUserDefaults] boolForKey:SYNTAX_HIGHLIGHT];
    if (! syntaxHighlighting) {
        return [self.requestTextPlain string];
    } else {
        return [self.requestView string];
    }
}

- (IBAction) doubleClickedHeaderRow:(id)sender {
    NSInteger row = [self.headersTableView clickedRow];
    NSInteger col = [self.headersTableView clickedColumn];
    if (row == -1 && col == -1) {
        [self plusHeaderRow:sender];
    } else {
        [self.headersTableView editColumn:col row:row withEvent:nil select:YES];
    }
}

- (IBAction) plusHeaderRow:(id)sender {
    NSMutableDictionary *row = [[NSMutableDictionary alloc] init];
    [row setObject:@"Key" forKey:@"key"];
    [row setObject:@"Value" forKey:@"value"];
    [self.headersTable addObject:row];
    [self.headersTableView reloadData];
    [self.headersTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:([self.headersTable count] - 1)] byExtendingSelection:NO];
    [self.headersTableView editColumn:0 row:([self.headersTable count] - 1) withEvent:nil select:YES];
}

- (IBAction) minusHeaderRow:(id)sender {
    if ([self.headersTable count] > [self.headersTableView selectedRow]) {
        [self.headersTable removeObjectAtIndex:[self.headersTableView selectedRow]];
        [self.headersTableView reloadData];
    }
}

- (void) doneEditingHeaderRow:(TableRowAndColumn *)tableRowAndColumn {
    int lastTextMovement = [self.headersTableView getLastTextMovement];
    if (lastTextMovement == NSTabTextMovement && [[tableRowAndColumn.column identifier] isEqualToString:@"value"]) {
        if (tableRowAndColumn.row == [[self.headersTableView dataSource] numberOfRowsInTableView:self.headersTableView] - 1) {
            [self plusHeaderRow:nil];
        } else {
            [self.headersTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:(tableRowAndColumn.row + 1)] byExtendingSelection:NO];
            [self.headersTableView editColumn:0 row:(tableRowAndColumn.row + 1) withEvent:nil select:YES];
        }
    }
}

- (IBAction) clearAuth:(id)sender {
    [self.username setStringValue:@""];
    [self.password setStringValue:@""];
}

- (IBAction) doubleClickedFileRow:(id)sender {
    NSInteger row = [self.filesTableView clickedRow];
    NSInteger col = [self.filesTableView clickedColumn];
    if (row == -1 && col == -1) {
        [self plusFileRow:sender];
    } else {
        [self.filesTableView editColumn:col row:row withEvent:nil select:YES];
    }
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
    if ([self.filesTable count] > [self.filesTableView selectedRow]) {
        [self.filesTable removeObjectAtIndex:[self.filesTableView selectedRow]];
        [self.filesTableView reloadData];
    }
}

- (void) addFileToFilesTable: (NSURL*) fileUrl {
    NSMutableDictionary *row = [[NSMutableDictionary alloc] init];
    [row setObject:[fileUrl lastPathComponent] forKey:@"key"];
    [row setObject:[fileUrl relativePath] forKey:@"value"];
    [row setObject:fileUrl  forKey:@"url"];
    
    [self.filesTable addObject:row];
    [self.filesTableView reloadData];
    [self.filesTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:([self.filesTable count] - 1)] byExtendingSelection:NO];
    [self.filesTableView editColumn:0 row:([self.filesTable count] - 1) withEvent:nil select:YES];
}

- (IBAction) doubleClickedParamsRow:(id)sender {
    NSInteger row = [self.paramsTableView clickedRow];
    NSInteger col = [self.paramsTableView clickedColumn];
    if (row == -1 && col == -1) {
        [self plusParamsRow:sender];
    } else {
        [self.paramsTableView editColumn:col row:row withEvent:nil select:YES];
    }
}

- (IBAction) plusParamsRow:(id)sender {
    NSMutableDictionary *row = [[NSMutableDictionary alloc] init];
    [row setObject:@"Key" forKey:@"key"];
    [row setObject:@"Value" forKey:@"value"];
    
    [self.paramsTable addObject:row];
    [self.paramsTableView reloadData];
    [self.paramsTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:([self.paramsTable count] - 1)] byExtendingSelection:NO];
    [self.paramsTableView editColumn:0 row:([self.paramsTable count] - 1) withEvent:nil select:YES];
}

- (IBAction) minusParamsRow:(id)sender {
    if (self.paramsTable.lastObject) {
        [self.paramsTable removeObjectAtIndex:[self.paramsTableView selectedRow]];
    }
    [self.paramsTableView reloadData];
}

- (void) doneEditingParamsRow:(TableRowAndColumn *)tableRowAndColumn {
    int lastTextMovement = [self.paramsTableView getLastTextMovement];
    if (lastTextMovement == NSTabTextMovement && [[tableRowAndColumn.column identifier] isEqualToString:@"value"]) {
        if (tableRowAndColumn.row == [[self.paramsTableView dataSource] numberOfRowsInTableView:self.paramsTableView] - 1) {
            [self plusParamsRow:nil];
        } else {
            [self.paramsTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:(tableRowAndColumn.row + 1)] byExtendingSelection:NO];
            [self.paramsTableView editColumn:0 row:(tableRowAndColumn.row + 1) withEvent:nil select:YES];
        }
    }
}

- (void) selectRequestBodyInputMode {
    if (self.rawRequestBody && ! self.fileRequestBody) {
        self.rawInputButton.state = NSOnState;
        [self.filesTable removeAllObjects];
        [self.filesTableView reloadData];
    } else if (! self.rawRequestBody && ! self.fileRequestBody) {
        self.fieldInputButton.state = NSOnState;
    } else if (self.rawRequestBody && self.fileRequestBody) {
        self.fileInputButton.state = NSOnState;
        // Clear out contents of raw request form
        [self.requestTextPlain setString:@""];
        [self.requestView setString:@""];
    }
    
    // Indeterminate input mode, default to field input
    if (self.rawInputButton.state == NSOffState && self.fileInputButton.state == NSOffState && self.fieldInputButton.state == NSOffState) {
        NSLog(@"Indeterminate input state");
        self.fieldInputButton.state = NSOnState;
    }
}

- (IBAction)requestBodyInputMode:(id)sender {
    NSLog(@"Sender: %@", [sender identifier]);
    if ([[sender identifier] isEqualToString:@"rawInput"]) {
        self.rawRequestBody = YES;
        self.fileRequestBody = NO;
    } else if ([[sender identifier] isEqualToString:@"fieldInput"]) {
        self.rawRequestBody = NO;
        self.fileRequestBody = NO;
    } else if ([[sender identifier] isEqualToString:@"fileInput"]) {
        self.rawRequestBody = YES;
        self.fileRequestBody = YES;
        
    }
    
    // Set the user preference to the most recently picked value
    [[NSUserDefaults standardUserDefaults]setBool:self.rawRequestBody forKey:RAW_REQUEST_BODY];
    [[NSUserDefaults standardUserDefaults]setBool:self.fileRequestBody forKey:FILE_REQUEST_BODY];
    
    [self selectRequestBodyInputMode];
}

- (void) contentTypeMenuItemSelected:(id)sender
{
    [requestTypeManager setModeForMimeType:[sender title]];
    
    BOOL inserted = FALSE;
    if([self.headersTable count] > 0) {
        for(NSMutableDictionary * row in self.headersTable) {
            if([[[row objectForKey:@"key"] lowercaseString] isEqualToString:@"content-type"]) {
                [row setObject:[sender title] forKey:@"value"];
                [self.headersTableView reloadData];
                inserted = TRUE;
                break;
            }
        }
    }
    
    if (! inserted) {
        NSMutableDictionary *row = [[NSMutableDictionary alloc] init];
        [row setObject:@"Content-Type" forKey:@"key"];
        [row setObject:[sender title] forKey:@"value"];
        [self.headersTable addObject:row];
        [self.headersTableView reloadData];
    }
}

- (void)deleteTableRow:(NSNotification *)notification {
    if ([[self window] isKeyWindow]) {
        NSString *currentTabLabel = [[notification userInfo] valueForKey:@"identifier"];
        if ([currentTabLabel isEqualToString:@"RequestHeaders"] && [self.headersTableView selectedRow] > -1) {
            [self minusHeaderRow:nil];
        } else if ([currentTabLabel isEqualToString:@"RequestBody"] && [self.paramsTableView selectedRow] > -1 && ! self.rawRequestBody) {
            [self minusParamsRow:nil];
        } else if ([currentTabLabel isEqualToString:@"Files"] && [self.filesTableView selectedRow] > -1) {
            [self minusFileRow:nil];
        }
    }
}

#pragma mark -
#pragma mark Request Submission and Response Handling

- (IBAction) runSubmit:(id)sender {
    NSLog(@"Got submit press");
    [self.progressIndicator setHidden:NO];
    [self.progressIndicator startAnimation:self];
    
    // Append http if it's not there
    NSString *urlStr = [self.urlBox stringValue];
    if (! [urlStr hasPrefix:@"http"] && ! [urlStr hasPrefix:@"https"]) {
        urlStr = [[NSString alloc] initWithFormat:@"http://%@", urlStr];
        [self.urlBox setStringValue:urlStr];
    }
    
    [self setResponseText:[NSString stringWithFormat:@"Loading %@", urlStr]];
    [self.status setStringValue:@"Opening URL..."];
    [self.responseTextHeaders setString:@""];
    [self.urlBox insertItemWithObjectValue: [self.urlBox stringValue] atIndex:0];
    
    if (! receivedData) {
        receivedData = [[NSMutableData alloc] init];
    }
    [receivedData setLength:0];
    contentType = NULL;
    
    NSString *urlEscaped = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:urlEscaped];
    NSString *method = [self.methodButton stringValue];
    NSMutableURLRequest * request = nil;
    
    
    // initialize request
    request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:method];
    [request setTimeoutInterval:[[NSUserDefaults standardUserDefaults] integerForKey:RESPONSE_TIMEOUT]];
    
    self.window.title = url.host;
    
    BOOL contentTypeSet = NO;
    if(self.rawRequestBody) {
        if (![self.appDelegate.requestMethodsWithoutBody containsObject:method]) {
            if([CRCFileRequest currentRequestIsCRCFileRequest:self]) {
                [CRCFileRequest createRequest:request withWindow:self];
            }
            else  {
                [CRCRawRequest createRequest:request withWindow:self];
            }
        }
    }
    else {
        if (![self.appDelegate.requestMethodsWithoutBody containsObject:method]) {
            switch([CRCRequest determineRequestContentType:self.headersTable]) {
                case CRCContentTypeFormEncoded:
                    [CRCFormEncodedRequest createRequest:request withWindow:self];
                    contentTypeSet = YES;
                    break;
                    
                case CRCContentTypeMultipart:
                    [CRCMultipartRequest createRequest:request withWindow:self];
                    contentTypeSet = YES;
                    break;
            }
        }
    }
    
    // Set headers
    NSMutableDictionary *headersDictionary = [[NSMutableDictionary alloc] init];
    
    for(NSDictionary * row in self.headersTable) {
        if (! [[[row objectForKey:@"key"] lowercaseString] isEqualToString:@"content-type"] || ! contentTypeSet) {
            [headersDictionary setObject:[row objectForKey:@"value"]
                                  forKey:[row objectForKey:@"key"]];
        }
    }
    
    // Pre-emptive HTTP Basic Auth
    if (self.preemptiveBasicAuth && [self.username stringValue] && [self.password stringValue]) {
        NSData *plainTextUserPass = [ [NSString stringWithFormat:@"%@:%@", [self.username stringValue], [self.password stringValue]] dataUsingEncoding:NSUTF8StringEncoding];
        [headersDictionary setObject:[NSString stringWithFormat:@"Basic %@", [plainTextUserPass base64String]]
                              forKey:@"Authorization"];
    }
    
    [request setAllHTTPHeaderFields:headersDictionary];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:DISABLE_COOKIES]) {
        [request setHTTPShouldHandleCookies:NO];
    }
    
    lastRequest = [CRCRequest requestWithWindow:self named:nil];
    if ([method isEqualToString:@"GET"]) {
        self.appDelegate.reGetResponseMenuItem.enabled = YES;
    } else {
        self.appDelegate.reGetResponseMenuItem.enabled = NO;
    }
    
    startDate = [NSDate date];
    
    currentRequest = [request copy];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
    if (! connection) {
        NSLog(@"Could not open connection to resource");
    }
    
}

- (void) setResponseText:(NSString *)response {
    BOOL syntaxHighlighting = [[NSUserDefaults standardUserDefaults] boolForKey:SYNTAX_HIGHLIGHT];
    if (! syntaxHighlighting) {
        [self.responseTextPlain setString:response];
    } else {
        [self.responseView setString:response];
    }
}

- (NSString *) getResponseText {
    BOOL syntaxHighlighting = [[NSUserDefaults standardUserDefaults] boolForKey:SYNTAX_HIGHLIGHT];
    if (! syntaxHighlighting) {
        return self.responseTextPlain.string;
    } else {
        return self.responseView.string;
    }
}

- (void)prettyPrintJsonResponseFromObject:(id)obj {
    id data = [jsonWriter dataWithObject:obj];
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


#pragma mark -
#pragma mark Saved Request Handling

- (void)loadSavedRequest:(id)request {
    
    if([request isKindOfClass:[NSDictionary class]]) {
        [self loadSavedDictionary:(NSDictionary *)request];
    }
    else if([request isKindOfClass:[CRCRequest class]]) {
        [self loadSavedCRCRequest:(CRCRequest *)request];
        if ([CRCFileRequest currentRequestIsCRCFileRequest:self]) {
            self.fileRequestBody = YES;
        } else {
            self.fileRequestBody = NO;
        }
    }
    
    [self selectRequestBodyInputMode];
}

- (IBAction) createNewSavedFolder:(id)sender {
    CRCSavedRequestFolder *folder = [[CRCSavedRequestFolder alloc] init];
    folder.name = @"New folder";
    // [savedRequestsArray addObject:folder];
    
    id selectedSavedOutlineViewItem = [self.savedOutlineView itemAtRow:[self.savedOutlineView selectedRow]];
    if ([selectedSavedOutlineViewItem isKindOfClass:[CRCSavedRequestFolder class]]) {
        [selectedSavedOutlineViewItem addObject:folder];
    } else {
        [SavedRequestsDataSource.savedRequestsArray addObject:folder];
    }
    
    [self.appDelegate redrawRequestViews];
    [self.savedOutlineView expandItem:folder expandChildren:YES];
    [self.savedOutlineView editColumn:0 row:[self.savedOutlineView rowForItem:folder] withEvent:nil select:YES];
}

- (IBAction) deleteSavedRequestFromButton:(id) sender {
    id object = [self.savedOutlineView itemAtRow:[self.savedOutlineView selectedRow]];
    if ([SavedRequestsDataSource.savedRequestsArray containsObject:object]) {
        [SavedRequestsDataSource.savedRequestsArray removeObject:object];
    } else {
        for (id entry in SavedRequestsDataSource.savedRequestsArray) {
            if ([entry isKindOfClass:[CRCSavedRequestFolder class]]) {
                [entry removeObject:object];
            }
        }
    }
    [self.appDelegate redrawRequestViews];
    [self.savedRequestsDataSource saveDataToDisk];
}

- (void)loadSavedCRCRequest:(CRCRequest *)request
{
    [self.urlBox setStringValue:request.url];
    [self.methodButton setStringValue:request.method];
    [self.username setStringValue:request.username];
    [self.password setStringValue:request.password];
    
    self.rawRequestBody = request.rawRequestInput;
    self.preemptiveBasicAuth = request.preemptiveBasicAuth;
    
    if(self.rawRequestBody)
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
    
    [self.headersTable removeAllObjects];
    [self.paramsTable removeAllObjects];
    [self.filesTable removeAllObjects];
    
    // Make headers, params, and files mutable dictionaries when they get loaded so that
    // they can still be updated after being loaded.
    if (headers) {
        for(NSDictionary *header in headers) {
            NSMutableDictionary *headerTranslated = [[NSMutableDictionary alloc] initWithDictionary:header];
            [self.headersTable addObject:headerTranslated];
            if ([((NSString *)[header objectForKey:@"key"]) isEqualToString:@"Content-Type"]) {
                [requestTypeManager setModeForMimeType:[header objectForKey:@"value"]];
            }
        }
    }
    
    if (params) {
        for(NSDictionary *param in params) {
            NSMutableDictionary *paramTranslated = [[NSMutableDictionary alloc] initWithDictionary:param];
            [self.paramsTable addObject:paramTranslated];
        }
    }
    
    if (files) {
        for(NSDictionary *file in files) {
            NSMutableDictionary *fileTranslated = [[NSMutableDictionary alloc] initWithDictionary:file];
            [self.filesTable addObject:fileTranslated];
        }
    }
    
    [self.headersTableView reloadData];
    [self.filesTableView reloadData];
    [self.paramsTableView reloadData];
}

// Respond to click on a row of the saved requests outline view
- (IBAction) outlineClick:(id)sender {
    [self loadSavedRequest:[self.savedOutlineView itemAtRow:[self.savedOutlineView selectedRow]]];
}

// if it's a dictionary it's the old format, files, params, rawRequestInput will not be present
- (void)loadSavedDictionary:(NSDictionary *)request
{
    [self.urlBox setStringValue:[request objectForKey:@"url"]];
    [self.methodButton setStringValue:[request objectForKey:@"method"]];
    [self.username setStringValue:[request objectForKey:@"username"]];
    [self.password setStringValue:[request objectForKey:@"password"]];
    
    self.rawRequestBody = YES;
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
    
    [self.headersTable removeAllObjects];
    [self.paramsTable removeAllObjects];
    [self.filesTable removeAllObjects];
    
    if (headers)
        [self.headersTable addObjectsFromArray:headersTranslated];
    
    [self.headersTableView reloadData];
    [self.filesTableView reloadData];
    [self.paramsTableView reloadData];
}

#pragma mark -
#pragma mark Handling Preference Updates

- (void) applyShowLineNumbers:(BOOL)show {
    [self.responseView setShowLineNumbers:show];
    [self.responseView setShowFoldWidgets:show];
    [self.responseView setShowGutter:show];
    [self.requestView setShowLineNumbers:show];
    [self.requestView setShowFoldWidgets:show];
    [self.requestView setShowGutter:show];
}

- (void)syntaxHighlightingPreferenceChanged {
    BOOL syntaxHighlighting = [[NSUserDefaults standardUserDefaults] boolForKey:SYNTAX_HIGHLIGHT];
    self.appDelegate.syntaxHighlightingMenuItem.state = syntaxHighlighting;
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
    
    [self.status setStringValue:@"Receiving Data..."];
    NSMutableString *headers = [[NSMutableString alloc] init];
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
    [headers appendFormat:@"HTTP %ld %@\n\n", [httpResponse statusCode], [[NSHTTPURLResponse localizedStringForStatusCode:[httpResponse statusCode]] capitalizedString]];
    
    _responseHeadersItemView.tabTitle = [NSString stringWithFormat:@"Headers (%ld)", [httpResponse statusCode]];
    
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
    [self.responseTextHeaders setString:headers];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Did fail");
    [self setResponseText:[NSString stringWithFormat:@"Connection to %@ failed.", [self.urlBox stringValue]]];
    [self.status setStringValue:@"Failed"];
    [self.progressIndicator stopAnimation:self];
    [self.progressIndicator setHidden:YES];
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
        [self.requestHeadersSentText setString:headers];
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
        return [[NSUserDefaults standardUserDefaults] boolForKey:ALLOW_SELF_SIGNED_CERTS];
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
            newCredential = [NSURLCredential credentialWithUser:[self.username stringValue]
                                                       password:[self.password stringValue]
                                                    persistence:NSURLCredentialPersistenceNone];
            [[challenge sender] useCredential:newCredential forAuthenticationChallenge:challenge];
        } else {
            [[challenge sender] cancelAuthenticationChallenge:challenge];
            [self setResponseText:@"Authentication Failed"];
        }
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSTimeInterval elapsed = [startDate timeIntervalSinceNow];
    [self.status setStringValue:[NSString stringWithFormat:@"Finished in %f seconds", -1*elapsed]];
    
    BOOL needToPrintPlain = YES;
    if (contentType != NULL) {
        if ([[ContentTypes sharedContentTypes] isXml:contentType]) {
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
        } else if ([[ContentTypes sharedContentTypes] isJson:contentType]) {
            [self prettyPrintJsonResponseFromString:receivedData];
            needToPrintPlain = NO;
        } else if ([[ContentTypes sharedContentTypes] isMsgPack:contentType]) {
            NSLog(@"Attempting to format MsgPack as JSON");
            [self prettyPrintJsonResponseFromObject:[MsgPackSerialization MsgPackObjectWithData:receivedData options:0 error:nil]];
            needToPrintPlain = NO;
        }
    }
    
    // Bail out, just print the text
    if (needToPrintPlain) {
        [self printResponsePlain];
    }
    
    [self.progressIndicator stopAnimation:self];
    [self.progressIndicator setHidden:YES];
}

#pragma mark -
#pragma mark Table View DataSource methods

- (NSDragOperation)tableView:(NSTableView *)tableView validateDrop:(id<NSDraggingInfo>)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)dropOperation {
    
    return NSDragOperationCopy;
}

- (BOOL)tableView:(NSTableView *)tableView acceptDrop:(id<NSDraggingInfo>)info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)dropOperation {
    
    if (tableView != self.filesTableView) {
        return NO;
    }
    
    NSPasteboard *pboard = [info draggingPasteboard];
    if ([[pboard types] containsObject: NSFilenamesPboardType]) {
        NSArray *new_files = [pboard propertyListForType: NSFilenamesPboardType];
        if (new_files.count > 0) {
            [new_files enumerateObjectsUsingBlock:^(NSString* path, NSUInteger idx, BOOL *stop) {
                [self addFileToFilesTable:[NSURL fileURLWithPath:path]];
            }];
            [self.filesTableView reloadData];
            
            return YES;
        }
    }
    
    return NO;
}

- (NSInteger) numberOfRowsInTableView:(NSTableView *) tableView {
    NSInteger count= nil;
    
    if(tableView == self.headersTableView)
        count = [self.headersTable count];
    
    if(tableView == self.filesTableView)
        count = [self.filesTable count];
    
    if(tableView == self.paramsTableView)
        count = [self.paramsTable count];
    
    return count;
    
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    
    id object;
    
    if(tableView == self.headersTableView)
        object = [[self.headersTable objectAtIndex:row] objectForKey:[tableColumn identifier]];
    
    if(tableView == self.filesTableView)
        object = [[self.filesTable objectAtIndex:row] objectForKey:[tableColumn identifier]];
    
    if(tableView == self.paramsTableView)
        object = [[self.paramsTable objectAtIndex:row] objectForKey:[tableColumn identifier]];
    
    return object;
}

- (void)tableView:(NSTableView *)aTableView setObjectValue:(id)anObject
   forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
    
    NSMutableDictionary *row;
    
    if(aTableView == self.headersTableView){
        row = [self.headersTable objectAtIndex:rowIndex];
        if (row == NULL) {
            row = [[NSMutableDictionary alloc] init];
        }
        [row setObject:anObject forKey:[aTableColumn identifier]];
        [self.headersTable replaceObjectAtIndex:rowIndex withObject:row];
    }
    
    if(aTableView == self.filesTableView){
        row = [self.filesTable objectAtIndex:rowIndex];
        if (row == NULL) {
            row = [[NSMutableDictionary alloc] init];
        }
        [row setObject:anObject forKey:[aTableColumn identifier]];
        [self.filesTable replaceObjectAtIndex:rowIndex withObject:row];
    }
    
    if(aTableView == self.paramsTableView){
        row = [self.paramsTable objectAtIndex:rowIndex];
        if (row == NULL) {
            row = [[NSMutableDictionary alloc] init];
        }
        [row setObject:anObject forKey:[aTableColumn identifier]];
        [self.paramsTable replaceObjectAtIndex:rowIndex withObject:row];
    }
    
}

@end
