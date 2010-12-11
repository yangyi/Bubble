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

@interface AccountController : NSObject<WeiboConnectorDelegate> {
	WeiboAccount *currentAccount;

	WeiboConnector *weiboConnector;
	WeiboCache *cache;
	
	WeiboTimeline *homeTimeline;
	WeiboTimeline *mentions;
	WeiboTimeline *comments;
	WeiboTimeline *favorites;
	
}
+(id)instance;
+(id)newInstance;
-(id)init;
-(void)dealloc;
-(void)verifyCurrentAccount;
-(void)didVerifyCurrentAccount:(id)result;

-(void)checkStatusUnread;
-(void)didCheckStatusUnread:(id)result;

-(void)selectAccount:(NSString*)username;
-(void)resetTimeline;
-(NSString*)getPasswordForUser:(NSString*)username;
-(void)setPasswordForUser:(NSString*)username withPassword:(NSString *)newPassword;
-(void)removePasswordForUser:(NSString*)username;
//weibo api related
-(void)postWithStatus:(NSString*)status;
-(void)postWithStatus:(NSString*)status image:(NSData*)data imageName:(NSString*)imageName;
-(void)didPostWithStatus:(id)result;

@property(nonatomic,retain) WeiboAccount *currentAccount;
@property(nonatomic,retain) WeiboTimeline *homeTimeline;
@property(nonatomic,retain) WeiboTimeline *mentions;
@property(nonatomic,retain) WeiboTimeline *comments;
@property(nonatomic,retain) WeiboTimeline *favorites;
@end
