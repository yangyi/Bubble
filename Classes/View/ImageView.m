//
//  ImageView.m
//  Bubble
//
//  Created by Luke on 11/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ImageView.h"


@implementation ImageView
- (void)close{
	NSRect origin=[self frame];
	NSRect ff=[self frame];

	ff.origin.y=ff.origin.y+ff.size.height;
	ff.size.width=1;
	ff.size.height=1;
	[self setFrame:ff display:YES animate:YES];
	[super close];
	[self setFrame:origin display:NO];
	

}

- (NSTimeInterval)animationResizeTime:(NSRect)newFrame
{
    return 0.3;
}
@end
