//
//  WeiboHomeTimeline.m
//  Rainbow
//
//  Created by Luke on 9/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "WeiboHomeTimeline.h"


@implementation WeiboHomeTimeline
@synthesize statusArray,selected,unread,lastReadStatusId,lastReceivedStatusId,scrollPosition;
-(id)initWithWeiboConnector:(WeiboConnector*)connector{
	if (self=[super init]) {
		weiboConnector=connector;
		selected=YES;
		NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
		[nc addObserver:self selector:@selector(startLoadOlderHomeTimeline:) 
				   name:StartLoadOlderHomeTimelineNotification 
				 object:nil];
		[NSTimer scheduledTimerWithTimeInterval:60 
										 target:self 
									   selector:@selector(loadNewerHomeTimeline) 
									   userInfo:nil 
										repeats:YES];
	}
	return self;
}

-(void) loadRecentHomeTimeline{
	//when app started,execute this first
	unread=NO;
	selected=YES;
	NSMutableDictionary* params =[[[NSMutableDictionary alloc] initWithCapacity:0] autorelease];
	[weiboConnector getHomeTimelineWithParameters:params
								 completionTarget:self
								 completionAction:@selector(didLoadRecentHomeTimeline:)];
}

-(void)didLoadRecentHomeTimeline:(NSArray*)statuses{
	statusArray =[statuses mutableCopy];
	[[statusArray lastObject] setObject:[NSNumber numberWithInt:1] forKey:@"gap"];
	//NSMutableDictionary *gapStatus=[[statuses lastObject] mutableCopy];
	//[gapStatus setObject:[NSNumber numberWithInt:1] forKey:@"gap"];
	//[statusArray replaceObjectAtIndex:[statusArray count]-1 withObject:gapStatus];
	//NSLog(@"%@",[[statusArray lastObject] objectForKey:"gap"]);
	if (statuses!=nil&&[statuses count]>0) {		
		lastReceivedStatusId=[[statuses objectAtIndex:0] objectForKey:@"id"];
        lastReadStatusId = [[statuses objectAtIndex:0] objectForKey:@"id"];
		oldestReceivedStatusId =[[statuses lastObject] objectForKey:@"id"];
		[[NSNotificationCenter defaultCenter] postNotificationName:ReloadHomeTimelineNotification
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
			[[NSNotificationCenter defaultCenter] postNotificationName:DidLoadNewerHomeTimelineNotification
																object:statuses];
		}else {
			unread=YES;
			[[NSNotificationCenter defaultCenter] postNotificationName:UnreadNotification object:nil];
		}
	}
}

-(void)startLoadOlderHomeTimeline:(NSNotification*)notification{
	[self loadOlderHomeTimeline];
}
-(void)loadOlderHomeTimeline{
	NSMutableDictionary* params =[[[NSMutableDictionary alloc] initWithCapacity:0] autorelease];
	[params setObject:[NSString stringWithFormat:@"%@",oldestReceivedStatusId]
			   forKey:@"max_id"];
	NSLog(@"%@",oldestReceivedStatusId);
	[weiboConnector getHomeTimelineWithParameters:params
								 completionTarget:self
								 completionAction:@selector(didLoadOlderHomeTimeline:)];
}
-(void)didLoadOlderHomeTimeline:(NSArray*)statuses{
	if (statuses!=nil&&[statuses count]>0) {
		oldestReceivedStatusId=[[statuses lastObject] objectForKey:@"id"];
		[statusArray addObjectsFromArray:statuses];
		[[statusArray lastObject] setObject:[NSNumber numberWithInt:1] forKey:@"gap"];
		[[NSNotificationCenter defaultCenter] postNotificationName:DidLoadOlderHomeTimelineNotification
															object:statuses];
	}
}
@end
