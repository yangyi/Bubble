//
//  UserInputController.h
//  Bubble
//
//  Created by Luke on 2/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface UserInputController : NSObject {
	IBOutlet NSPanel *userInputPanel;
	IBOutlet NSTextField *nameField;
}
-(void)show:(NSWindow*)window;
-(IBAction)close:(id)sender;
-(IBAction)gotoUser:(id)sender;
@end
