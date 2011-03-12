//
//  AccountPrefsPanel.m
//  Bubble
//
//  Created by Luke on 11/25/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AccountPrefsPanel.h"
#import "AccountController.h"
@implementation AccountPrefsPanel
+ (NSArray *)preferencePanes
{
    return [NSArray arrayWithObjects:[[[AccountPrefsPanel alloc] init] autorelease], nil];
}


- (NSView *)paneView
{
    BOOL loaded = YES;
    
    if (!prefsView) {
        loaded = [NSBundle loadNibNamed:@"AccountPrefsView" owner:self];
		editAccountController=[[AccountEditorController alloc] initWithDelegate:self];
		[accountTable setIntercellSpacing:NSMakeSize(0,0)];
		[accountTable setDoubleAction:@selector(doubleClickAction:)];
		[accountTable setTarget:self];
    }
    
    if (loaded) {
        return prefsView;
    }
    
    return nil;
}


- (NSString *)paneName
{
    return @"Account";
}


- (NSImage *)paneIcon
{
    return [[[NSImage alloc] initWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForImageResource:@"Accounts.tiff"]] autorelease];
}


- (NSString *)paneToolTip
{
    return @"Account Preferences";
}


- (BOOL)allowsHorizontalResizing
{
    return YES;
}


- (BOOL)allowsVerticalResizing
{
    return NO;
}

-(IBAction)addAccount:(id)sender{
	[editAccountController setUsername:@""];
	[editAccountController setPassword:@""];
	[editAccountController show:[prefsView window]];
}

-(void)saveAccount:(NSString*)username withPassword:(NSString*)password{
	NSLog(@"%@%@",username,password);
	[accountsController addObject:username];
	[[AccountController instance] setPasswordForUser:username withPassword:password];
	[editAccountController close:self];
}
-(void)removeAccount:(NSString*)username{
	
}

- (void)tableView:(NSTableView *)aTableView willDisplayCell:(id)aCell forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
	[aCell setDrawsBackground: ((rowIndex % 2) == 0)];
}

- (IBAction)doubleClickAction:(id)sender {
    NSInteger rowIndex=[sender clickedRow];
	if (rowIndex!=-1) {
		NSArray* selected=[accountsController selectedObjects];
		NSString *username=[selected objectAtIndex:0];
		[editAccountController setUsername:username];
		[editAccountController setPassword:[[AccountController instance]getPasswordForUser:username]];
		[editAccountController show:[prefsView window]];
		//NSLog(@"%@",username);
	}
}
@end
