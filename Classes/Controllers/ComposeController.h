//
//  ComposeController.h
//  Rainbow
//
//  Created by Luke on 9/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "HTMLController.h"

@interface ComposeController : NSWindowController {
	IBOutlet NSTextView *textView;
	IBOutlet NSTextField *charactersRemaining;

	HTMLController *htmlController;
}
	-(IBAction)post:(id)sender;
@end
