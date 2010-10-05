//
//  WeiboHomeTimeline.h
//  Rainbow
//
//  Created by Luke on 9/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "WeiboConnector.h"

@interface WeiboHomeTimeline : NSObject {
	WeiboConnector *weiboConnector;
	NSArray *statusArray;
	
	NSNumber *lastStatusId;
	//标记当前的tab是否处于激活状态。
	BOOL isActive;
}
-(id)initWithWeiboConnector:(WeiboConnector*)connector;

-(void)loadRecentHomeTimeline;
-(void)didLoadRecentHomeTimeline:(NSArray*)statuses;
-(void)loadNewerHomeTimeline;
-(void)didLoadNewerHomeTimeline:(NSArray*)statuses;
@property(nonatomic,assign) NSArray *statusArray;
@end
