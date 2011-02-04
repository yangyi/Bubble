//
//  AppURLHandler.m
//  Bubble
//
//  Created by Luke on 10/20/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AppURLHandler.h"


@implementation AppURLHandler
-(void)handleURL:(NSString*)urlString{	
	NSURL *url=[NSURL URLWithString:urlString];
	if (!url) {
		return;
	}
	if (![[url resourceSpecifier] hasPrefix:@"//"]) {
		urlString = [NSString stringWithFormat:@"%@://%@", [url scheme], [url resourceSpecifier]];
		url = [NSURL URLWithString:urlString];
	}
	
	NSString *schema = [url scheme];
	NSString *host = [url host];
	if ([schema isEqualToString:@"weibo"]) {
		if ([host isEqualToString:@"load_older_home_timeline"]) {
			[[NSNotificationCenter defaultCenter] postNotificationName:StartLoadOlderTimelineNotification object:nil];
		}
		if ([host isEqualToString:@"home_timeline_status_click"]) {
			NSString *statusId = [[url queryArgumentForKey:@"id"] 
								stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
			[[NSNotificationCenter defaultCenter] postNotificationName:DidClickTimelineNotification object:statusId];
		}
		if ([host isEqualToString:@"user"]) {
			NSMutableDictionary *data=[NSMutableDictionary dictionaryWithCapacity:0];
			[data setObject:[url queryArgumentForKey:@"fetch_with"] forKey:@"fetch_with"];
			[data setObject:[[url queryArgumentForKey:@"value"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] forKey:@"value"];
			[[NSNotificationCenter defaultCenter] postNotificationName:GetUserNotification object:data];
			
		}
		if ([host isEqualToString:@"image"]) {
			NSString *imageUrl=[[url queryArgumentForKey:@"url"] 
								stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
			[[NSNotificationCenter defaultCenter]postNotificationName:DisplayImageNotification object:imageUrl];
		}
		if ([host isEqualToString:@"friends"]) {
			NSString *screenName=[[url queryArgumentForKey:@"screen_name"] 
						  stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
			[[NSNotificationCenter defaultCenter]postNotificationName:GetFriendsNotification object:screenName];
		}
		if ([host isEqualToString:@"status_comments"]) {
			NSString *statusId=[[url queryArgumentForKey:@"sid"] 
								  stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
			[[NSNotificationCenter defaultCenter]postNotificationName:ShowStatusCommentsNotification object:statusId];
		}
		if ([host isEqualToString:@"reply"]) {
			NSString *sid=[[url queryArgumentForKey:@"id"] 
						  stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
			NSString *cid=[[url queryArgumentForKey:@"cid"] 
						  stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
			NSMutableDictionary *data=[NSMutableDictionary dictionaryWithCapacity:0];
			if (cid!=nil) {
				[data setObject:cid forKey:@"cid"];
			}else if (sid!=nil) {
				[data setObject:sid forKey:@"id"];
			}
			[[NSNotificationCenter defaultCenter]postNotificationName:ReplyNotification object:data];
		}
	}
	
}
@end
