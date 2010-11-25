//
//  ImagePanelController.h
//  Bubble
//
//  Created by Luke on 11/21/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NSWindowAdditions.h"

@interface ImagePanelController : NSWindowController {
	IBOutlet NSPanel *imagePanel;
	IBOutlet NSImageView *imageView;
	IBOutlet NSProgressIndicator *progressIndicator;
	NSRect defaultFrameSize;

}
- (void)loadImagefromURL:(NSString *)url;
@end
