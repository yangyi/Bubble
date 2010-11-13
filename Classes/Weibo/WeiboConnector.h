//
//  WeiboConnector.h
//  Rainbow
//
//  Created by Luke on 8/28/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NSDataAdditions.h"
#import "NSURLAdditions.h"
#import "JSON.h"
#import "WeiboGlobal.h"
#import "WeiboURLConnection.h"
#define WEIBO_BASE_URL @"http://api.t.sina.com.cn"

@interface WeiboConnector : NSObject {
	__weak NSObject <WeiboConnectorDelegate> *_delegate;
	NSMutableDictionary *_connections;
	NSString *_username;
    NSString *_password;
	NSString *_appKey;
}
-(WeiboConnector*)initWithDelegate:(id)delegate;

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

-(NSString *) getHomeTimelineWithParameters:(NSMutableDictionary*)params 
						   completionTarget:(id)target
						completionAction:(SEL)action;

-(NSString *) getMentionsWithParameters:(NSMutableDictionary*)params
					   completionTarget:(id)target
					   completionAction:(SEL)action;

-(NSString *) updateWithStatus:(NSString*)status					   
			  completionTarget:(id)target
			  completionAction:(SEL)action;

-(NSString *) getUserWithParamters:(NSMutableDictionary*)params 
				  completionTarget:(id)target
				  completionAction:(SEL)action;
@end
