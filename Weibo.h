//
//  Weibo.h
//  Rainbow
//
//  Created by Luke on 8/28/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NSDataAdditions.h"
#import "NSURLAdditions.h"
#import "JSON.h"
#import "WeiboEngineGlobal.h"
#import "WeiboURLConnection.h"
#define WEIBO_BASE_URL @"http://api.t.sina.com.cn"

@interface Weibo : NSObject {
	__weak NSObject <WeiboDelegate> *_delegate;
	NSMutableDictionary *_connections;
	NSString *_username;
    NSString *_password;
	NSString *_appKey;
}
-(Weibo*)initWithDelegate:(id)delegate;

#pragma mark properties
@property(nonatomic,retain) NSString *username;
@property(nonatomic,retain) NSString *password;
@property(nonatomic,retain) NSString *appKey;

#pragma mark REST API methods
//--------------------------------------------------
//Sina Weibo API Interface
// 参见 http://open.t.sina.com.cn/wiki/index.php/API%E6%96%87%E6%A1%A3
//---------------------------------------------------

//timeline
-(NSString *) getPublicTimeline;
-(NSString *) getHomeTimelineWithSinceId:(NSUInteger)sinceId maxId:(NSUInteger)maxId count:(NSUInteger)count page:(NSUInteger)page;
-(NSString *) getMentionsWithSinceId:(NSUInteger)sinceId maxId:(NSUInteger)maxId count:(NSUInteger)count page:(NSUInteger)page;
-(NSString *) updateWithStatus:(NSString*)status;
@end
