//
//  WeiboAccount.m
//  Rainbow
//
//  Created by Luke on 9/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "WeiboAccount.h"


@implementation WeiboAccount

static const char *serviceName = "Bubble";
static WeiboAccount *instance;

@synthesize homeTimeline,mentions;

+(id)instance{
	if (!instance) {
		return [WeiboAccount newInstance];
	}
	return instance;
}

+(id)newInstance{
	if (instance) {
		[instance release];
		instance=nil;
	}
	instance=[[WeiboAccount alloc]init];
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
-(NSString*)username{
	if (!username) {
		username = [[NSUserDefaults standardUserDefaults] stringForKey:@"currentAccount"];
	}
	return username;
}

-(void)setUsername:(NSString *)newUsername{
	username=newUsername;
	[[NSUserDefaults standardUserDefaults]setValue:newUsername forKey:@"currentAccount"];
}

#pragma mark Password
-(NSString*)password{
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

-(void)setPassword:(NSString *)newPassword{
	[self removePassword];
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

-(void)removePassword{
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
