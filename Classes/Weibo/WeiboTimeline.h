//
//  WeiboHomeTimeline.h
//  Rainbow
//
//  Created by Luke on 9/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "WeiboConnector.h"
#import "WeiboGlobal.h"

@interface WeiboTimeline : NSObject{
	//类型 
	TimelineType timelineType;
	__weak WeiboConnector *weiboConnector;
	
	//data 中记录当前timeline的维护数据 newData记录最近收到的数据
	NSMutableArray *data;
	NSArray *newData;
	
	NSNumber *lastReadId;
	NSNumber *lastReceivedId;
	NSNumber *oldestReceivedId;
	NSPoint scrollPosition;

}
-(id)initWithWeiboConnector:(WeiboConnector*)connector 
			   timelineType:(TimelineType)type;

-(void)loadRecentTimeline;
-(void)didLoadRecentTimeline:(NSArray*)statuses;

-(void)loadNewerTimeline;
-(void)didLoadNewerTimeline:(NSArray*)statuses;


-(void)loadOlderTimeline;
-(void)didLoadOlderTimeline:(NSArray*)statuses;


@property(nonatomic,retain) NSMutableArray *data;
@property(nonatomic,retain) NSArray *newData;
@property(nonatomic)BOOL unread;
@property(nonatomic,retain) NSNumber *lastReadId;
@property(nonatomic,retain) NSNumber *lastReceivedId;
@property(nonatomic,retain) NSNumber *oldestReceivedId;
@property(nonatomic) NSPoint scrollPosition;
@end
