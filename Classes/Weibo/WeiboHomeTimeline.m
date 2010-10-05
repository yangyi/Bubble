//
//  WeiboHomeTimeline.m
//  Rainbow
//
//  Created by Luke on 9/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "WeiboHomeTimeline.h"


@implementation WeiboHomeTimeline
@synthesize statusArray;
-(id)initWithWeiboConnector:(WeiboConnector*)connector{
	if (self=[super init]) {
		weiboConnector=connector;
	}
	return self;
}

-(void) loadRecentHomeTimeline{
	NSMutableDictionary* params =[[[NSMutableDictionary alloc] initWithCapacity:0] autorelease];
	[weiboConnector getHomeTimelineWithParameters:params
								 completionTarget:self
								 completionAction:@selector(didLoadRecentHomeTimeline:)];
}

-(void)didLoadRecentHomeTimeline:(NSArray*)statuses{
	statusArray =statuses;
	if (statuses!=nil&&[statuses count]>0) {		
		lastStatusId = [[statuses objectAtIndex:0] objectForKey:@"id"];
		[[NSNotificationCenter defaultCenter] postNotificationName:FinishedLoadRecentHomeTimelineNotifaction
																			object:self];
	}
}

-(void)loadNewerHomeTimeline{
	NSMutableDictionary* params =[[[NSMutableDictionary alloc] initWithCapacity:0] autorelease];
	[params setObject:[NSString stringWithFormat:@"%d",[lastStatusId unsignedIntValue]]
			   forKey:@"since_id"];
	[weiboConnector getHomeTimelineWithParameters:params
								 completionTarget:self
								 completionAction:@selector(didLoadNewerHomeTimeline:)];
}

-(void)didLoadNewerHomeTimeline:(NSArray*)statuses{
	statusArray =statuses;
	if (statuses!=nil&&[statuses count]>0) {		
		lastStatusId = [[statuses objectAtIndex:0] objectForKey:@"id"];
		[[NSNotificationCenter defaultCenter] postNotificationName:FinishedLoadNewerHomeTimelineNotifaction
															object:self];
	}
}
@end
