//
//  WeiboAccount.m
//  Rainbow
//
//  Created by Luke on 9/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "WeiboAccount.h"


@implementation WeiboAccount

#pragma mark Initializers
-(id)init{
	if (self=[super init]) {
		weibo=[[Weibo alloc] initWithDelegate:self];
	}
	return self;
}

#pragma mark Request Method
-(NSString *) getHomeTimelineWithSinceId:(NSUInteger)sinceId 
								   maxId:(NSUInteger)maxId 
								   count:(NSUInteger)count 
									page:(NSUInteger)page;
{
	return [weibo getHomeTimelineWithSinceId:sinceId
								maxId:maxId
								count:count 
								 page:page];
}

-(NSString *) getMentionsWithSinceId:(NSUInteger)sinceId 
							   maxId:(NSUInteger)maxId 
							   count:(NSUInteger)count 
								page:(NSUInteger)page{
	return [weibo getMentionsWithSinceId:sinceId 
							maxId:maxId 
							count:count
							 page:page];
}

-(NSString *) updateWeiboWithStatus:(NSString*)status{
	[weibo updateWithStatus:status];
}

#pragma mark WeiboDelegate Method
-(void)statusesDidReceived:(NSArray *)statuses{
	[[NSNotificationCenter defaultCenter] postNotificationName:StatusesReceivedNotification
														object:statuses];
}
@end
