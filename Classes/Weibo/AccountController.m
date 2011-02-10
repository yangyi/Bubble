//
//  WeiboAccount.m
//  Rainbow
//
//  Created by Luke on 9/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AccountController.h"
#import "PathController.h"

@implementation AccountController

static const char *serviceName = "Bubble";
static AccountController *instance;

@synthesize homeTimeline,mentions,comments,favorites,directMessages;;

+(AccountController*)instance{
	if (!instance) {
		return [AccountController newInstance];
	}
	return instance;
}

+(id)newInstance{
	if (instance) {
		[instance release];
		instance=nil;
	}
	instance=[[AccountController alloc]init];
	return instance;
}
#pragma mark Initializers
-(id)init{
	if (self=[super init]) {
		weiboConnector=[[WeiboConnector alloc] initWithDelegate:self];
		cache=[[WeiboCache alloc]init];
		homeTimeline =[[WeiboTimeline alloc] initWithWeiboConnector:weiboConnector 
															 timelineType:Home];
		mentions=[[WeiboTimeline alloc] initWithWeiboConnector:weiboConnector
														timelineType:Mentions];
		comments=[[WeiboTimeline alloc] initWithWeiboConnector:weiboConnector
												  timelineType:Comments];
		favorites=[[WeiboTimeline alloc] initWithWeiboConnector:weiboConnector
												   timelineType:Favorites];
		directMessages=[[WeiboTimeline alloc] initWithWeiboConnector:weiboConnector
														timelineType:DirectMessages];
		NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];

		[nc addObserver:self selector:@selector(getUser:)
				   name:GetUserNotification 
				 object:nil];
		[nc addObserver:self selector:@selector(getFriends:)
				   name:GetFriendsNotification 
				 object:nil];
		[nc addObserver:self selector:@selector(getStatusComments:)
				   name:GetStatusCommentsNotification 
				 object:nil];
		[nc addObserver:self selector:@selector(showStatus:)
				   name:ShowStatusNotification 
				 object:nil];
		
		[NSTimer scheduledTimerWithTimeInterval:60
										 target:self 
									   selector:@selector(checkUnread) 
									   userInfo:nil 
										repeats:YES];
	}
	return self;
}

-(void)dealloc{
	[weiboConnector release];
	[cache release];
	[homeTimeline release];
	[super dealloc];
}



-(void)checkUnread{
	if (currentAccount) {
		//定期刷新页面，使得显示的时间定期更新
		[[NSNotificationCenter defaultCenter] postNotificationName:ReloadTimelineNotification
															object:self];
		
		NSMutableDictionary* params =[[[NSMutableDictionary alloc] initWithCapacity:0] autorelease];
		[params setObject:@"1" forKey:@"with_new_status"];
		[params setObject:[NSString stringWithFormat:@"%@",homeTimeline.lastReceivedId] forKey:@"since_id"];
		[weiboConnector checkUnreadWithParameters:params
								 completionTarget:self
								 completionAction:@selector(didCheckUnread:)];
	}
}

-(void)didCheckUnread:(NSDictionary*)result{
	NSNumber *unreadStatusCount=[result objectForKey:@"new_status"];
	NSNumber *unreadCommentsCount=[result objectForKey:@"comments"];
	NSNumber *unreadFollowersCount=[result objectForKey:@"followers"];
	NSNumber *unreadDMCount=[result objectForKey:@"dm"];
	NSNumber *unreadMentionsCount=[result objectForKey:@"mentions"];
	if ([unreadStatusCount intValue]>0) {
		[homeTimeline loadNewerTimeline];
	}
	if ([unreadMentionsCount intValue]>0) {
		[mentions loadNewerTimeline];
	}
	if ([unreadCommentsCount intValue]>0) {
		[comments loadNewerTimeline];
	}
}


-(void)getUSerTimeline:(NSMutableDictionary*)param{
	[[NSNotificationCenter defaultCenter] postNotificationName:ShowLoadingPageNotification
														object: nil];
	[weiboConnector getUSerTimelineWithParameters:param
							 completionTarget:self
							 completionAction:@selector(didGetUserTimeline:)];
}
-(void)didGetUserTimeline:(NSArray*)result{
	[[NSNotificationCenter defaultCenter] postNotificationName:DidGetUserTimelineNotification
														object:result];
}

-(void)getFollowers:(NSDictionary*)param{
	[[NSNotificationCenter defaultCenter] postNotificationName:ShowLoadingPageNotification
														object: nil];
	[weiboConnector getFollowersWithParameters:param
								 completionTarget:self
								 completionAction:@selector(didGetFollowers:)];
}
-(void)didGetFollowers:(NSArray*)result{
	[[NSNotificationCenter defaultCenter] postNotificationName:DidGetFollowersNotification
														object:result];
}

#pragma mark Account
-(WeiboAccount*)currentAccount{
	if (!currentAccount) {
		NSString *username=[[NSUserDefaults standardUserDefaults] stringForKey:@"currentAccount"];
		if (username) {
			currentAccount=[[WeiboAccount alloc] init];
			currentAccount.username=username;
			currentAccount.password=[self getPasswordForUser:username];
		}
	}
	return currentAccount;
}
-(void)setCurrentAccount:(WeiboAccount *)account{
	self.currentAccount=account;
	[[NSUserDefaults standardUserDefaults]setValue:currentAccount.username forKey:@"currentAccount"];
}



-(void)verifyCurrentAccount{
	if (currentAccount) {
		[[NSNotificationCenter defaultCenter] postNotificationName:ShowLoadingPageNotification object:nil];
		NSMutableDictionary* params =[[[NSMutableDictionary alloc] initWithCapacity:0] autorelease];
		[weiboConnector verifyAccountWithParameters:params
								   completionTarget:self
								   completionAction:@selector(didVerifyCurrentAccount:)];
	}
}

-(void)didVerifyCurrentAccount:(id)result{
	NSDictionary *jsonResult=(NSDictionary*)result;
	if ([jsonResult objectForKey:@"screen_name"]) {
		currentAccount.screenName=[jsonResult objectForKey:@"screen_name"];
		[[PathController instance].currentTimeline loadRecentTimeline];
		[[NSNotificationCenter defaultCenter] postNotificationName:AccountVerifiedNotification
															object:result];
	}
}


-(void)selectAccount:(NSString*)username{
	if (username) {
		if (currentAccount) {
			[currentAccount release];
		}
		currentAccount=[[WeiboAccount alloc] init];
		currentAccount.username=username;
		currentAccount.password=[self getPasswordForUser:username];
		[[NSUserDefaults standardUserDefaults]setValue:currentAccount.username forKey:@"currentAccount"];
		[self resetTimelines];
		[self verifyCurrentAccount];
	}
}


//reset all the timeline
-(void)resetTimelines{
	[homeTimeline reset];
	[mentions reset];
	[comments reset];
	[favorites reset];
}
#pragma mark Password
-(NSString*)getPasswordForUser:(NSString*)username{
	const char* cUsername=[username cStringUsingEncoding:NSUTF8StringEncoding];
	const char* cPassword;
	UInt32 length=0;
	OSStatus error=SecKeychainFindGenericPassword(NULL,
												  strlen(serviceName), 
												  serviceName, 
												  strlen(cUsername), 
												  cUsername,
												  &length, 
												  (void**)&cPassword, 
												  NULL);
	if (error!=noErr) {
		NSLog (@"SecKeychainFindGenericPassword () For User:%@ error: %d",username, error);
	}
	
	NSString *string = [[[NSString alloc] initWithBytes:cPassword 
												 length:length 
											   encoding:NSUTF8StringEncoding] autorelease];
	return string;

}

-(void)setPasswordForUser:(NSString*)username withPassword:(NSString *)newPassword{
	[self removePasswordForUser:username];
	const char* cUsername=[username cStringUsingEncoding:NSUTF8StringEncoding];
	const char* cPassword=[newPassword cStringUsingEncoding:NSUTF8StringEncoding];
	OSStatus error=SecKeychainAddGenericPassword(nil,
													strlen(serviceName),
													serviceName, 
													strlen(cUsername),
													cUsername,
													strlen(cPassword), 
													cPassword,
													nil);
	if (error!=noErr) {
		NSLog(@"SecKeychainAddGenericPassword() error:%d",error);
	}
}

-(void)removePasswordForUser:(NSString*)username{
	const char* cUsername=[username cStringUsingEncoding:NSUTF8StringEncoding];
	SecKeychainItemRef keychainItemRef;
	OSStatus error=SecKeychainFindGenericPassword(nil,
													  strlen(serviceName),
													  serviceName, 
													  strlen(cUsername),
													  cUsername, 
													  nil, nil, &keychainItemRef);
	if (error==noErr) {
		error=SecKeychainItemDelete(keychainItemRef);
		if (error!=noErr) {
			NSLog(@"SecKeychainItemDelete() Error:%d",error);
		}
	}
}

#pragma mark 操作
-(void)postWithStatus:(NSString*)status{
	[weiboConnector updateWithStatus:status 
					completionTarget:self 
					completionAction:@selector(didPost:)];
}
-(void)postWithStatus:(NSString*)status image:(NSData*)data imageName:(NSString*)imageName{
	[weiboConnector updateWithStatus:status 
						   image:data
						   imageName:imageName
					completionTarget:self 
					completionAction:@selector(didPost:)];
}

-(void)didPost:(id)result{
	[[NSNotificationCenter defaultCenter] postNotificationName:DidPostStatusNotification
														object:nil];
}

-(void)reply:(id)data{
	[weiboConnector replyWithParameters:data
						completionTarget:self
						completionAction:@selector(didPost:)];
}


-(void)repost:(id)data{
	[weiboConnector repostWithParamters:data
					  completionTarget:self
					  completionAction:@selector(didPost:)];
}






-(void)getUser:(NSNotification*)notification{
	NSDictionary *data=[notification object];
	NSString *fetchWith=[data valueForKey:@"fetch_with"];
	NSString *value=[data valueForKey:@"value"];
	NSMutableDictionary* params =[[[NSMutableDictionary alloc] initWithCapacity:0] autorelease];
	[params setObject:value forKey:fetchWith];
	[weiboConnector getUserWithParameters:params
						completionTarget:self
						completionAction:@selector(didGetUser:)];
}

-(void)didGetUser:(NSDictionary*)result{
	[[NSNotificationCenter defaultCenter] postNotificationName:DidGetUserNotification
														object:result];
}

-(void)getFriends:(NSNotification*)notification{
	NSMutableDictionary* params =[[[notification object] mutableCopy] autorelease];
	[weiboConnector getFriendsWithParameters:params
						completionTarget:self
						completionAction:@selector(didGetFriends:)];
}

-(void)didGetFriends:(NSArray*)result{
	[[NSNotificationCenter defaultCenter] postNotificationName:DidGetFriendsNotification
														object:result];
}

-(void)showStatus:(NSNotification*)notification{
	NSString *statusId=[notification object];
	NSMutableDictionary* params =[[[NSMutableDictionary alloc] initWithCapacity:0] autorelease];
	[params setObject:statusId forKey:@"id"];
	[params setObject:@"-1" forKey:@"cursor"];
	[weiboConnector showStatusWithParameters:params
								  completionTarget:self
								  completionAction:@selector(didShowStatus:)];
}
-(void)didShowStatus:(NSDictionary*)result{
	[[NSNotificationCenter defaultCenter] postNotificationName:DidShowStatusNotification
														object:result];
}


-(void)getStatusComments:(NSNotification*)notification{
	[weiboConnector getStatusCommentsWithParameters:[notification object]
						   completionTarget:self
						   completionAction:@selector(didGetStatusComments:)];
}

-(void)didGetStatusComments:(NSArray*)result{
	[[NSNotificationCenter defaultCenter] postNotificationName:DidGetStatusCommentsNotification
														object:result];
}

-(void)getDirectMessage{
	NSMutableDictionary* params =[[[NSMutableDictionary alloc] initWithCapacity:0] autorelease];
	[weiboConnector getDirectMessageWithParameters:params
								  completionTarget:self
								  completionAction:@selector(didGetDirectMessage:)];
}

-(void)didGetDirectMessage:(NSArray*)result{
	[[NSNotificationCenter defaultCenter] postNotificationName:DidGetDirectMessageNotification
														object:result];
}

-(void)createFavorites:(NSString *)statusId{
	NSMutableDictionary* params =[[[NSMutableDictionary alloc] initWithCapacity:0] autorelease];
	[params setObject:statusId forKey:@"id"];
	[weiboConnector createFavoritesWithParameters:params
								  completionTarget:self
								  completionAction:@selector(didCreateFavorites:)];
}
-(void)didCreateFavorites:(NSDictionary*)result{
	
}

-(void)destroyFavorites:(NSString *)statusId{
	NSMutableDictionary* params =[[[NSMutableDictionary alloc] initWithCapacity:0] autorelease];
	[params setObject:statusId forKey:@"id"];
	[weiboConnector destroyFavoritesWithParameters:params
								 completionTarget:self
								 completionAction:@selector(didDestroyFavorites:)];
}

-(void)didDestroyFavorites:(NSDictionary*)result{
	
}
@end
