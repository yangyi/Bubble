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
#import "WeiboAccount.h"
#define WEIBO_BASE_URL @"http://api.t.sina.com.cn"

@protocol WeiboConnectorDelegate
-(WeiboAccount *)currentAccount;
@end


@interface WeiboConnector : NSObject {
	__weak NSObject <WeiboConnectorDelegate> *_delegate;
	NSMutableDictionary *_connections;
	NSString *_appKey;
	NSString *multipartBoundary;
}
-(WeiboConnector*)initWithDelegate:(id)delegate;

#pragma mark properties
@property(nonatomic,retain) NSString *appKey;

#pragma mark REST API methods
//--------------------------------------------------
//Sina Weibo API Interface
// 参见 http://open.t.sina.com.cn/wiki/index.php/API%E6%96%87%E6%A1%A3
//---------------------------------------------------

//verify_credentials

-(NSString *) verifyAccountWithParameters:(NSMutableDictionary*)params 
						 completionTarget:(id)target  
						 completionAction:(SEL)action;


//check unread
-(NSString *)checkUnreadWithParameters:(NSMutableDictionary*)params 
					  completionTarget:(id)target  
					  completionAction:(SEL)action;
//timeline

-(NSString *) getHomeTimelineWithParameters:(NSMutableDictionary*)params 
						   completionTarget:(id)target
						completionAction:(SEL)action;

-(NSString *) getMentionsWithParameters:(NSMutableDictionary*)params
					   completionTarget:(id)target
					   completionAction:(SEL)action;

-(NSString *) getCommentsWithParameters:(NSMutableDictionary*)params
					   completionTarget:(id)target
					   completionAction:(SEL)action;

-(NSString *) getFavoritesWithParameters:(NSMutableDictionary*)params
					   completionTarget:(id)target
					   completionAction:(SEL)action;

-(NSString *) updateWithStatus:(NSString*)status					   
			  completionTarget:(id)target
			  completionAction:(SEL)action;
-(NSString*) updateWithStatus:(NSString *)status 
						image:(NSData*)imageData
					imageName:(NSString*)imageName
			 completionTarget:(id)target 
			 completionAction:(SEL)action;
-(NSString *) getUserWithParameters:(NSMutableDictionary*)params 
				  completionTarget:(id)target
				  completionAction:(SEL)action;
-(NSString *) getFriendsWithParameters:(NSMutableDictionary*)params 
					 completionTarget:(id)target
					 completionAction:(SEL)action;
-(NSString *) getStatusCommentsWithParameters:(NSMutableDictionary*)params 
							completionTarget:(id)target
							completionAction:(SEL)action;
-(NSString *) getDirectMessagesWithParameters:(NSMutableDictionary*)params 
						   completionTarget:(id)target
						   completionAction:(SEL)action;

-(NSString *) replyWithParameters:(NSMutableDictionary*)params
				completionTarget:(id)target
				completionAction:(SEL)action;
-(NSString *) repostWithParamters:(NSMutableDictionary*)params
				 completionTarget:(id)target
				 completionAction:(SEL)action;
-(NSString *) showStatusWithParameters:(NSMutableDictionary*)params 
					 completionTarget:(id)target
					 completionAction:(SEL)action;


-(NSString *) destroyFavoritesWithParameters:(NSMutableDictionary*)params
							completionTarget:(id)target
							completionAction:(SEL)action;
-(NSString *) createFavoritesWithParameters:(NSMutableDictionary*)params
						   completionTarget:(id)target
						   completionAction:(SEL)action;

@end
