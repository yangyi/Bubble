//
//  WeiboAccount.m
//  Rainbow
//
//  Created by Luke on 9/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AccountController.h"


@implementation AccountController

static const char *serviceName = "Bubble";
static AccountController *instance;

@synthesize homeTimeline,mentions,comments,favorites;

+(id)instance{
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
		NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];

		[nc addObserver:self selector:@selector(getUser:)
				   name:GetUserNotification 
				 object:nil];
	}
	return self;
}

-(void)dealloc{
	[weiboConnector release];
	[cache release];
	[homeTimeline release];
	[super dealloc];
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
		NSMutableDictionary* params =[[[NSMutableDictionary alloc] initWithCapacity:0] autorelease];
		[weiboConnector verifyAccountWithParameters:params
								   completionTarget:self
								   completionAction:@selector(didVerifyCurrentAccount:)];
	}
}

-(void)didVerifyCurrentAccount:(id)result{
	
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
		
	}
	[[NSNotificationCenter defaultCenter] postNotificationName:DidSelectAccountNotification
														object:nil];
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
					completionAction:@selector(didPostWithStatus:)];
}
-(void)postWithStatus:(NSString*)status image:(NSData*)data imageName:(NSString*)imageName{
	[weiboConnector updateWithStatus:status 
						   image:data
						   imageName:imageName
					completionTarget:self 
					completionAction:@selector(didPostWithStatus:)];
}

-(void)didPostWithStatus:(id)result{
	[[NSNotificationCenter defaultCenter] postNotificationName:DidPostStatusNotification
														object:nil];
}

-(void)getUser:(NSNotification*)notification{
	NSDictionary *data=[notification object];
	NSString *fetchWith=[data valueForKey:@"fetch_with"];
	NSString *value=[data valueForKey:@"value"];
	NSMutableDictionary* params =[[[NSMutableDictionary alloc] initWithCapacity:0] autorelease];
	[params setObject:value forKey:fetchWith];
	[weiboConnector getUserWithParamters:params
						completionTarget:self
						completionAction:@selector(didGetUser:)];
}

-(void)didGetUser:(NSDictionary*)result{
	[[NSNotificationCenter defaultCenter] postNotificationName:DidGetUserNotification
														object:result];
}
@end
