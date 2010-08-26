//
//  LoginWindowController.h
//  Rainbow
//
//  Created by Luke on 8/23/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class RainbowAppDelegate;
@interface LoginWindowController : NSWindowController {
	RainbowAppDelegate* appDelegate;

}
-(id)init;
-(IBAction)loginAction:sender;
@end
