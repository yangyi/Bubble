//
//  UserInputController.m
//  Bubble
//
//  Created by Luke on 2/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UserInputController.h"


@implementation UserInputController

-(void)show:(NSWindow*)window{
	if (!userInputPanel) {
		[NSBundle loadNibNamed: @"UserInput" owner: self];
	}
	[NSApp beginSheet: userInputPanel
	   modalForWindow: window
		modalDelegate: self
	   didEndSelector: @selector(didEndSheet:returnCode:contextInfo:)
		  contextInfo: nil];
}
- (void)didEndSheet:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
    [sheet orderOut:self];
}

-(IBAction)close:(id)sender{
	[NSApp endSheet:userInputPanel];
}
-(IBAction)gotoUser:(id)sender{
	NSString *screenName=[nameField stringValue];
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"weibo://user?fetch_with=screen_name&value=%@",screenName]]];
	[self close:nil];
}
@end
