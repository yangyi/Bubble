//
//  AccountEditorController.m
//  Bubble
//
//  Created by Luke on 12/7/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AccountEditorController.h"


@implementation AccountEditorController

-(id)initWithDelegate:(id<AccountEditorControllerProtocol>)accountEditorControllerDelegate{
	if (self=[super init]) {
		[NSBundle loadNibNamed: @"AccountEditor" owner: self];
		delegate=accountEditorControllerDelegate;
	}
	return self;
}

- (void)show:(NSWindow*)window{
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

-(IBAction)save:(id)sender{
	if (delegate) {
		[delegate saveAccount:[usernameField stringValue] withPassword:[passwordField stringValue]];
	}
}

-(void)setUsername:(NSString*)username{
	[usernameField setStringValue:username];
}
-(void)setPassword:(NSString*)password{
	[passwordField setStringValue:password];
}
@end
