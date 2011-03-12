//
//  AccountPrefsPanel.h
//  Bubble
//
//  Created by Luke on 11/25/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SS_PreferencePaneProtocol.h"
#import "AccountEditorController.h"
@interface AccountPrefsPanel : NSObject<SS_PreferencePaneProtocol,AccountEditorControllerProtocol,NSTableViewDelegate> {
	IBOutlet NSView *prefsView;
	IBOutlet NSArrayController *accountsController;
	IBOutlet NSTableView *accountTable;
	AccountEditorController *editAccountController;
}
-(IBAction)addAccount:(id)sender;
- (IBAction)doubleClickAction:(id)sender;
@end
