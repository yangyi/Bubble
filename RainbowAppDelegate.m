//
//  RainbowAppDelegate.m
//  Rainbow
//
//  Created by Luke on 8/25/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RainbowAppDelegate.h"

@implementation RainbowAppDelegate


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application 
	loginWindow = [[LoginWindowController alloc ]init];
	[loginWindow showWindow:nil];
}
-(void)openMainWindow{
	[loginWindow close];
	[loginWindow release];
	mainWindow=[[MainWindowController alloc]init];
	[mainWindow showWindow:self];
	
}
@end
