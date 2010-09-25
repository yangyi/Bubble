//
//  LoginWindowController.m
//  Rainbow
//
//  Created by Luke on 8/23/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LoginWindowController.h"


@implementation LoginWindowController
- (id)init {
	appDelegate= [NSApp delegate];
	self = [super initWithWindowNibName:@"LoginWindow"];
	return self;
}

-(void)login{
	[appDelegate openMainWindow];
}

-(IBAction)loginAction:sender{
	[self login];
}
@end
