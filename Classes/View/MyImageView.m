//
//  MyImageView.m
//  Bubble
//
//  Created by Luke on 2/7/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MyImageView.h"


@implementation MyImageView
- (void)mouseDown:(NSEvent *)theEvent
{
    [NSApp sendAction:[self action] to:[self target] from:self];
}
- (void)mouseEntered:(NSEvent *)theEvent{
	[[NSCursor openHandCursor] set];
}
- (void)mouseExited:(NSEvent *)theEvent{
	[[NSCursor arrowCursor] set];
}

-(void)drawRect:(NSRect)frame{
	//[super drawRect:frame];
	/*
	NSImage *border=[NSImage imageNamed:@"avatar_frame"];
	[[self image] lockFocus];
	[border drawInRect:NSMakeRect(0, 0, [self image].size.width, [self image].size.height) 
			  fromRect:NSMakeRect(0, 0, border.size.width, border.size.height) 
			 operation:NSCompositeSourceOver 
			  fraction:1.0];
	[[self image] unlockFocus];
	 */
	[NSGraphicsContext saveGraphicsState];
	[[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];

	NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:frame
														 xRadius:4
														 yRadius:4];

	[path addClip];
	
	[[self image] drawInRect:frame
			 fromRect:NSZeroRect
			operation:NSCompositeSourceOver
			 fraction:1.0];
	
	[NSGraphicsContext restoreGraphicsState];

}

@end
