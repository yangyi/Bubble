//
//  ImagePanelController.h
//  Bubble
//
//  Created by Luke on 11/21/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NSWindowAdditions.h"
#import "ImageView.h"
@interface ImagePanelController : NSWindowController {
	IBOutlet ImageView *imagePanel;
	IBOutlet NSImageView *imageView;
	IBOutlet NSProgressIndicator *progressIndicator;

}
- (void)loadImagefromURL:(NSString *)url;
@end
