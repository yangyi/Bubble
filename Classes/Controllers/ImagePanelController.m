//
//  ImagePanelController.m
//  Bubble
//
//  Created by Luke on 11/21/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ImagePanelController.h"
#import "NSWindowAdditions.h"


@implementation ImagePanelController
@synthesize fromRect;
- (id)init {
	self = [super initWithWindowNibName:@"ImagePanel"];
	if (self) {
		NSWindow *window=[self window];
		initPanelRect =[window frame];
	}
	return self;
}


- (void)loadImagefromURL:(NSString *)url 
{
	
	NSWindow *window=[self window];
	NSPoint mouseLoc = [NSEvent mouseLocation];
	fromRect.origin=mouseLoc;
	fromRect.size.width=1;
	fromRect.size.height=1;
	
	if (![window isVisible]) {
		[[self window] setFrame:initPanelRect display:NO];
		[imageView setImage:nil];
		[[self window] zoomOnFromRect:fromRect];
	}
	[progressIndicator display];
	[progressIndicator startAnimation:self];
	NSImage *newImage;
	NSURL *imageURL = [NSURL URLWithString:url];
	NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
	if (imageData != nil) {
		//这里需要恰当的处理图片显示的位置
		//get the full screen frame
 		NSScreen *screen=[window screen];
		NSRect screenFrame=[screen frame];
		//get the image size
		newImage = [[NSImage alloc] initWithData:imageData];
		NSSize imageSize=[newImage size];
		NSRect frame = [window frame];
		if (frame.origin.x+imageSize.width>screenFrame.size.width) {
			frame.size.width=screenFrame.size.width-frame.origin.x-10;
			frame.size.height=imageSize.height*(frame.size.width/imageSize.width);
		}else {
			frame.size=[newImage size];
		}

		[progressIndicator stopAnimation:self];


		[window setFrame:frame display:YES animate:YES];
		[imageView setImage:newImage];
		[newImage release];
	}
}

- (BOOL)windowShouldClose:(id)sender{
	[[self window] zoomOffToRect:fromRect];
	return YES;
}

@end
