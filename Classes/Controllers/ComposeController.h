//
//  ComposeController.h
//  Rainbow
//
//  Created by Luke on 9/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "WeiboAccount.h"

@interface ComposeController : NSWindowController {
	IBOutlet NSTextView *textView;
	IBOutlet NSTextField *charactersRemaining;
	IBOutlet NSProgressIndicator * postProgressIndicator;
	__weak   WeiboAccount *weiboAccount;
	NSRect fromRect;
}
-(IBAction)post:(id)sender;
-(void)didPost:(NSNotification*)notification;
-(void)popUp;
@end
