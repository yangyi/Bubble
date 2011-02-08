//
//  PathController.h
//  Bubble
//
//  Created by Luke on 1/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "WeiboTimeline.h"

@interface PathController : NSObject {
	__weak WeiboTimeline *currentTimeline;
	NSMutableArray *pathArray;
	int currentIndex;
}
+(PathController *)instance;
-(void)add:(NSString*)urlString;
-(void)forward;
-(void)backward;
-(void)resetPath;
@property(nonatomic,assign) WeiboTimeline *currentTimeline;
@property(nonatomic) int currentIndex;
@property(nonatomic,retain) NSMutableArray *pathArray; 
@end
