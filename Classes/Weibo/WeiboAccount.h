//
//  WeiboAccount.h
//  Rainbow
//
//  Created by Luke on 9/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Weibo.h"
#import "WeiboGlobal.h"
@interface WeiboAccount : NSObject<WeiboDelegate> {
	NSString *username;

	Weibo *weibo;
	
}



-(void)addAccountWithUsername:(NSString*)username password:(NSString*)password;

#pragma mark Request Method
-(NSString *) getHomeTimelineWithSinceId:(NSUInteger)sinceId maxId:(NSUInteger)maxId count:(NSUInteger)count page:(NSUInteger)page;
-(NSString *) getMentionsWithSinceId:(NSUInteger)sinceId maxId:(NSUInteger)maxId count:(NSUInteger)count page:(NSUInteger)page;
-(NSString *) updateWeiboWithStatus:(NSString*)status;



@end
