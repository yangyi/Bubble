//
//  MenuController.m
//  Bubble
//
//  Created by Luke on 11/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MenuController.h"
#import "GeneralPrefsPanel.h"
#import "AccountPrefsPanel.h"
#import "AdvancedPrefsPanel.h"

@implementation MenuController
- (IBAction)preferences:(id)sender
{
	if (!prefs)
	{
		// Determine path to the sample preference panes
		//NSString *pathToPanes = [NSString stringWithFormat:@"%@/../Preference Panes", [[NSBundle mainBundle] resourcePath]];
		//prefs = [[SS_PrefsController alloc] initWithPanesSearchPath:pathToPanes];
		NSMutableArray *panesArray=[NSMutableArray array];
		[panesArray addObject:[[GeneralPrefsPanel alloc] init]];
		[panesArray addObject:[[AccountPrefsPanel alloc] init]];
		[panesArray addObject:[[AdvancedPrefsPanel alloc]init]];
		prefs=[[SS_PrefsController alloc]initWithPanes:panesArray];
		[prefs setAlwaysShowsToolbar:YES];
		[prefs setDebug:YES];
		
		[prefs setAlwaysOpensCentered:YES];
		
		//[prefs setPanesOrder:[NSArray arrayWithObjects:@"General",@"Account", nil]];
	}
    
	// Show the preferences window.
	[prefs showPreferencesWindow];
}
@end
