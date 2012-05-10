/*
 
 MGSFragaria
 Written by Jonathan Mitchell, jonathan@mugginsoft.com
 Find the latest version at https://github.com/mugginsoft/Fragaria
 
Smultron version 3.6b1, 2009-09-12
Written by Peter Borg, pgw3@mac.com
Find the latest version at http://smultron.sourceforge.net

Copyright 2004-2009 Peter Borg
 
Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at
 
http://www.apache.org/licenses/LICENSE-2.0
 
Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
*/

#import <Cocoa/Cocoa.h>


@interface MGSExtraInterfaceController : NSObject {

	IBOutlet NSTextField *spacesTextFieldEntabWindow;
	IBOutlet NSTextField *spacesTextFieldDetabWindow;
	IBOutlet NSTextField *lineTextFieldGoToLineWindow;
	IBOutlet NSWindow *entabWindow;
	IBOutlet NSWindow *detabWindow;
	IBOutlet NSWindow *goToLineWindow;
	
	IBOutlet NSView *openPanelAccessoryView;
	IBOutlet NSPopUpButton *openPanelEncodingsPopUp;
	//IBOutlet NSView *printAccessoryView;
	
	IBOutlet NSWindow *commandResultWindow;
	IBOutlet NSTextView *commandResultTextView;
	
	IBOutlet NSWindow *projectWindow;
	IBOutlet NSPanel *regularExpressionsHelpPanel;
}


@property (readonly) IBOutlet NSView *openPanelAccessoryView;
@property (readonly) IBOutlet NSPopUpButton *openPanelEncodingsPopUp;
@property (readonly) IBOutlet NSWindow *commandResultWindow;
@property (readonly) IBOutlet NSTextView *commandResultTextView;
@property (readonly) IBOutlet NSWindow *projectWindow;

- (void)displayEntab;
- (void)displayDetab;
- (IBAction)entabButtonEntabWindowAction:(id)sender;
- (IBAction)detabButtonDetabWindowAction:(id)sender;
- (IBAction)cancelButtonEntabDetabGoToLineWindowsAction:(id)sender;
- (void)displayGoToLine;
- (IBAction)goButtonGoToLineWindowAction:(id)sender;

- (NSPopUpButton *)openPanelEncodingsPopUp;
- (NSView *)openPanelAccessoryView;
- (NSWindow *)commandResultWindow;
- (NSTextView *)commandResultTextView;
- (void)showCommandResultWindow;
- (void)showRegularExpressionsHelpPanel;

@end
