//
//  RainbowAppDelegate.h
//  Rainbow
//
//  Created by Luke on 8/25/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MainWindowController.h"
#import "LoginWindowController.h"

@interface RainbowAppDelegate : NSObject <NSApplicationDelegate> {
	LoginWindowController *loginWindow;
    MainWindowController *mainWindow;
}

-(void)openMainWindow;
@end
