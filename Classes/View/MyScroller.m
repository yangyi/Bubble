//
//  MyScroller.m
//  Bubble
//
//  Created by Luke on 1/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MyScroller.h"


@implementation MyScroller

NSColor *KScrollerKnobColorNormal;
NSColor *KScrollerKnobColorHover;

NSColor *KScrollerKnobSlotColorNormal;
NSColor *KScrollerKnobSlotColorHover;
+ (void)load {
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	
	KScrollerKnobColorNormal =
    [[NSColor colorWithCalibratedWhite:0.2 alpha:0.3] retain];
	KScrollerKnobColorHover =
    [[NSColor colorWithCalibratedWhite:0.2 alpha:0.8] retain];
	
    KScrollerKnobSlotColorNormal=[[NSColor colorWithCalibratedWhite:1.0 alpha:0.01] retain];

	KScrollerKnobSlotColorHover =
    [[NSColor redColor] retain];
	
	[pool drain];
}

- (void)drawKnob {
	NSRect rect = [self rectForPart:NSScrollerKnob];
	rect.size.width = 8.0;
	rect.origin.x = 3.0;
	[(hover_ ? KScrollerKnobColorHover : KScrollerKnobColorNormal) set];
	NSBezierPath *bp = [NSBezierPath bezierPathWithRoundedRect:rect
													   xRadius:4.5
													   yRadius:4.5];
	[bp fill];
}

- (void)drawArrow:(NSScrollerArrow)arrow highlightPart:(int)highlight {
	// we don't roll with arrows
}
- (BOOL)isOpaque {
	return NO;
}


- (void)mouseExited:(NSEvent*)ev {
	hover_ = NO;
	[self setNeedsDisplay:YES];
}

- (void)mouseEntered:(NSEvent*)ev {
	hover_ = YES;
	[self setNeedsDisplay:YES];
	[[self window] invalidateCursorRectsForView:self];
}


- (void)drawKnobSlotInRect:(NSRect)slotRect highlight:(BOOL)highlight {
	NSRect knobRect = [self rectForPart:NSScrollerKnob];
	if (knobRect.size.width != 0.0) {
		// enable mouse tracking
		if (!trackingArea_) {
			trackingArea_ =
			[[NSTrackingArea alloc] initWithRect:[self bounds]
										 options:NSTrackingMouseEnteredAndExited
			 |NSTrackingActiveInKeyWindow
			 |NSTrackingInVisibleRect
										   owner:self
										userInfo:nil];
			[self addTrackingArea:trackingArea_];
		}
		
		// bubble
	
		slotRect.size.width = 9.0;
		slotRect.origin.x = 3.0;
	
		NSBezierPath *bp =
        [NSBezierPath bezierPathWithRoundedRect:slotRect xRadius:4.5 yRadius:4.5];
		[KScrollerKnobSlotColorNormal set];
		[bp fill];
	} else {
		// disable mouse tracking
		if (trackingArea_) {
			[self removeTrackingArea:trackingArea_];
			[trackingArea_ release];
			trackingArea_ = nil;
		}
	}
}
@end
