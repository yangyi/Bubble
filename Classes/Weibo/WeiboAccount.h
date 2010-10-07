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
#import "WeiboHomeTimeline.h"
#import "WeiboCache.h"

@interface WeiboAccount : NSObject<WeiboConnectorDelegate> {
	NSString *username;
	NSString *password;

	WeiboConnector *weiboConnector;
	WeiboCache *cache;
	
	WeiboHomeTimeline * homeTimeline;
	
}
+(id)instance;
+(id)newInstance;
-(id)init;
-(void)dealloc;
-(void)removePassword;
@property(nonatomic,retain) WeiboHomeTimeline * homeTimeline;
@property(nonatomic,retain)NSString* username;
@property(nonatomic,retain)NSString* password;
@end
