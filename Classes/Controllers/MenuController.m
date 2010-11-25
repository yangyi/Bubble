//
//  MenuController.m
//  Bubble
//
//  Created by Luke on 11/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MenuController.h"


@implementation MenuController
- (IBAction)preferences:(id)sender
{
	if (!prefs)
	{
		// Determine path to the sample preference panes
		NSString *pathToPanes = [NSString stringWithFormat:@"%@/../Preference Panes", [[NSBundle mainBundle] resourcePath]];
		
		prefs = [[SS_PrefsController alloc] initWithPanesSearchPath:pathToPanes];
		
		[prefs setAlwaysShowsToolbar:YES];
		[prefs setDebug:YES];
		
		[prefs setAlwaysOpensCentered:YES];
		
		[prefs setPanesOrder:[NSArray arrayWithObjects:@"General",@"Account", nil]];
	}
    
	// Show the preferences window.
	[prefs showPreferencesWindow];
}
@end
