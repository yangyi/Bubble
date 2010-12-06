//
//  EditAccountController.h
//  Bubble
//
//  Created by Luke on 12/7/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface EditAccountController : NSObject {
	IBOutlet NSWindow *accountEditSheet;
}
- (void)show:(NSWindow*)window;
-(IBAction)close:(id)sender;
@end
