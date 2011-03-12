//
//  LoginWindowController.m
//  Rainbow
//
//  Created by Luke on 8/23/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LoginWindowController.h"
#import "AccountController.h"

@implementation LoginWindowController
- (id)init {
	appDelegate= [NSApp delegate];
	self = [super initWithWindowNibName:@"LoginWindow"];
	return self;
}

-(void)awakeFromNib{
	NSLog(@"");
}
-(void)login{
	NSString *nameString=[name stringValue];
	NSMutableArray *accounts=[[[[NSUserDefaults standardUserDefaults] valueForKey:@"accounts"]mutableCopy] autorelease];
	if (accounts==nil) {
		accounts=[NSMutableArray arrayWithCapacity:0];
	}
	if (![accounts containsObject:nameString]) {
		[accounts addObject:[name stringValue]];
		[[NSUserDefaults standardUserDefaults] setValue:accounts forKey:@"accounts"];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
	
	[[NSUserDefaults standardUserDefaults] setValue:nameString forKey:@"currentAccount"];
	[[AccountController instance] setPasswordForUser:nameString withPassword:[pw stringValue]];
	[appDelegate openMainWindow];
}

-(IBAction)loginAction:sender{
	[self login];
}
@end
