//
//  WeiboHomeTimeline.m
//  Rainbow
//
//  Created by Luke on 9/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "WeiboHomeTimeline.h"


@implementation WeiboHomeTimeline
@synthesize statusArray,selected,unread;
-(id)initWithWeiboConnector:(WeiboConnector*)connector{
	if (self=[super init]) {
		weiboConnector=connector;
		selected=YES;
		[NSTimer scheduledTimerWithTimeInterval:60 
										 target:self 
									   selector:@selector(loadNewerHomeTimeline) 
									   userInfo:nil 
										repeats:YES];
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
	statusArray =[statuses mutableCopy];
	if (statuses!=nil&&[statuses count]>0) {		
		lastReceivedStatusId=[[statuses objectAtIndex:0] objectForKey:@"id"];
		NSLog(@"%@",lastReceivedStatusId);
		if (selected) {
			lastReadStatusId = [[statuses objectAtIndex:0] objectForKey:@"id"];
		}else {
			unread=YES;
		}
		[[NSNotificationCenter defaultCenter] postNotificationName:FinishedLoadRecentHomeTimelineNotification
																			object:self];
	}
}

-(void)loadNewerHomeTimeline{
	NSMutableDictionary* params =[[[NSMutableDictionary alloc] initWithCapacity:0] autorelease];
	[params setObject:[NSString stringWithFormat:@"%@",lastReceivedStatusId]
			   forKey:@"since_id"];
	[weiboConnector getHomeTimelineWithParameters:params
								 completionTarget:self
								 completionAction:@selector(didLoadNewerHomeTimeline:)];
}

-(void)didLoadNewerHomeTimeline:(NSArray*)statuses{
	if (statuses!=nil&&[statuses count]>0) {
		NSMutableIndexSet *indexes=[NSMutableIndexSet indexSet];
		NSUInteger i, count=[statuses count];
		for(i=0;i<count;i++){
			[indexes addIndex:i];
		}
		[statusArray insertObjects:statuses atIndexes:indexes];
		lastReceivedStatusId=[[statuses objectAtIndex:0] objectForKey:@"id"];
		if (selected) {
			lastReadStatusId = [[statuses objectAtIndex:0] objectForKey:@"id"];
			[[NSNotificationCenter defaultCenter] postNotificationName:FinishedLoadRecentHomeTimelineNotification
																object:self];
		}else {
			unread=YES;
		}
	}
}
@end
