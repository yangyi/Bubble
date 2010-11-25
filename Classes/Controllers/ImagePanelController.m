//
//  ImagePanelController.m
//  Bubble
//
//  Created by Luke on 11/21/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ImagePanelController.h"


@implementation ImagePanelController
- (id)init {
	self = [super initWithWindowNibName:@"ImagePanel"];	
	if (self) {
		defaultFrameSize=[[self window] frame];
		[[self window] close];
	}
	return self;
}

- (void)loadImagefromURL:(NSString *)url
{
	NSWindow *window=[self window];
	//[[self window] orderOut:self];
	[progressIndicator startAnimation:self];
	NSImage *newImage;
	NSURL *imageURL = [NSURL URLWithString:url];
	NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
	if (imageData != nil) {
		newImage = [[NSImage alloc] initWithData:imageData];
		[progressIndicator stopAnimation:self];
		NSRect frame = [window frame];
		frame.size=[newImage size];
		[window setFrame:frame display:YES animate:YES];
		[imageView setImage:newImage];
		[newImage release];
	}
}

- (BOOL)windowShouldClose:(id)sender{

	[[self window] setFrame:defaultFrameSize display:YES];
	[imageView setImage:nil];
	return YES;
}

@end
