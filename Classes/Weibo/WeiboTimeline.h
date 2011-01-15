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
#import "ScrollOffset.h"

@interface WeiboTimeline : NSObject{
	//类型 
	TimelineType timelineType;
	NSString *typeName;
	__weak WeiboConnector *weiboConnector;
	
	//data 中记录当前timeline的维护数据 newData记录最近收到的数据
	NSMutableArray *data;
	NSArray *newData;
	
	//NSNumber *lastReadId;
	NSNumber *lastReceivedId;
	NSNumber *oldestReceivedId;
	BOOL unread;
	BOOL firstReload;
}
-(id)initWithWeiboConnector:(WeiboConnector*)connector 
			   timelineType:(TimelineType)type;

-(void)loadRecentTimeline;
-(void)didLoadRecentTimeline:(NSArray*)statuses;

-(void)loadNewerTimeline;
-(void)didLoadNewerTimeline:(NSArray*)statuses;


-(void)loadOlderTimeline;
-(void)didLoadOlderTimeline:(NSArray*)statuses;

-(void)loadTimelineWithPage:(NSString*)pageNumber;
-(void)didLoadTimelineWithPage:(NSArray*)statuses;

//重置,当切换用户时进行重置
-(void)reset;
@property(nonatomic,retain) NSMutableArray *data;
@property(nonatomic,retain) NSArray *newData;
@property(nonatomic)BOOL unread;
@property(nonatomic)BOOL firstReload;
@property(nonatomic)TimelineType timelineType;
@property(nonatomic,retain) NSString *typeName;
@property(nonatomic,retain) NSNumber *lastReceivedId;
@property(nonatomic,retain) NSNumber *oldestReceivedId;
@end
