//
//  LoginWindowController.h
//  Rainbow
//
//  Created by Luke on 8/23/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class AppDelegate;
@interface LoginWindowController : NSWindowController {
	AppDelegate* appDelegate;
	IBOutlet NSTextField *name;
	IBOutlet NSTextField *pw;

}
-(IBAction)loginAction:sender;
@end
