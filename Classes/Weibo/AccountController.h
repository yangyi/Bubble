//
//  WeiboAccount.h
//  Rainbow
//
//  Created by Luke on 9/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "WeiboConnector.h"
#import "WeiboGlobal.h"
#import "WeiboTimeline.h"
#import "WeiboCache.h"
#import "WeiboAccount.h"

//1. 评论数，2. @me数，3. 私信数，4. 关注数
typedef enum {
	CommentCount=1,
	AtCount,
	MessageCount,
	FollowerCount
}StatusResetType;

@interface AccountController : NSObject<WeiboConnectorDelegate> {
	WeiboAccount *currentAccount;

	WeiboConnector *weiboConnector;
	WeiboCache *cache;
	
	WeiboTimeline *homeTimeline;
	WeiboTimeline *mentions;
	WeiboTimeline *comments;
	WeiboTimeline *directMessages;
	WeiboTimeline *favorites;
	
}
+(AccountController*)instance;
+(id)newInstance;
-(id)init;
-(void)dealloc;
-(void)verifyCurrentAccount;
-(void)didVerifyCurrentAccount:(id)result;
-(void)checkUnread;
-(void)didCheckUnread:(NSDictionary*)result;
-(void)resetCount:(StatusResetType)resetType;
-(void)didResetCount:(NSDictionary*)result;

-(WeiboAccount*)getCurrentAccount;

-(void)selectAccount:(NSString*)username;
-(void)resetTimelines;
-(NSString*)getPasswordForUser:(NSString*)username;
-(void)setPasswordForUser:(NSString*)username withPassword:(NSString *)newPassword;
-(void)removePasswordForUser:(NSString*)username;
//weibo api related
-(void)postWithStatus:(NSString*)status;
-(void)postWithStatus:(NSString*)status image:(NSData*)data imageName:(NSString*)imageName;
-(void)didPost:(id)result;
-(void)getDirectMessage;
-(void)reply:(id)data;
-(void)repost:(id)data;
-(void)createFavorites:(NSString *)statusId;
-(void)destroyFavorites:(NSString *)statusId;
-(void)getUSerTimeline:(NSDictionary*)param;
-(void)didGetUserTimeline:(NSArray*)result;
-(void)getFollowers:(NSDictionary*)param;
-(void)didGetFollowers:(NSArray*)result;

-(void)sendMessage:(NSMutableDictionary*)param;
@property(nonatomic,retain) WeiboAccount *currentAccount;
@property(nonatomic,retain) WeiboTimeline *homeTimeline;
@property(nonatomic,retain) WeiboTimeline *mentions;
@property(nonatomic,retain) WeiboTimeline *comments;
@property(nonatomic,retain) WeiboTimeline *favorites;
@property(nonatomic,retain) WeiboTimeline *directMessages;
@end
