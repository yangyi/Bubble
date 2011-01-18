//
//  MyScroller.h
//  Bubble
//
//  Created by Luke on 1/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface MyScroller : NSScroller {
	BOOL hover_;
	 BOOL vertical_;
	NSTrackingArea *trackingArea_;
}

@end
