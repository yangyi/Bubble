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

@interface WeiboAccount : NSObject<WeiboConnectorDelegate> {
	NSString *username;
	NSString *password;

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
-(void)removePassword;

//weibo api related
-(void)postWithStatus:(NSString*)status;
-(void)postWithStatus:(NSString*)status image:(NSData*)data imageName:(NSString*)imageName;
-(void)didPostWithStatus:(id)result;
@property(nonatomic,retain) WeiboTimeline *homeTimeline;
@property(nonatomic,retain) WeiboTimeline *mentions;
@property(nonatomic,retain) WeiboTimeline *comments;
@property(nonatomic,retain) WeiboTimeline *favorites;
@property(nonatomic,retain)NSString* username;
@property(nonatomic,retain)NSString* password;
@end
