//
//  EditAccountController.m
//  Bubble
//
//  Created by Luke on 12/7/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "EditAccountController.h"


@implementation EditAccountController
- (void)show:(NSWindow*)window{
	if (!accountEditSheet) {
		[NSBundle loadNibNamed: @"EditAccount" owner: self];
	}
	[NSApp beginSheet: accountEditSheet
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
	 [NSApp endSheet:accountEditSheet];
}
@end
