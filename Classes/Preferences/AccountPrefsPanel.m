//
//  AccountPrefsPanel.m
//  Bubble
//
//  Created by Luke on 11/25/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AccountPrefsPanel.h"

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
	[editAccountController show:[prefsView window]];
}

-(void)saveAccount:(NSString*)username withPassword:(NSString*)password{
	NSLog(@"%@%@",username,password);
	[accountsController addObject:username];
	[editAccountController close:self];
}
-(void)removeAccount:(NSString*)username{
	
}
@end
