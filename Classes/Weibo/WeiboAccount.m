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

@synthesize homeTimeline;

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
		homeTimeline =[[WeiboHomeTimeline alloc] initWithWeiboConnector:weiboConnector];
	}
	return self;
}

-(void)dealloc{
	[weiboConnector release];
	[cache release];
	[homeTimeline release];
	[super dealloc];
}


- (void)requestFailed:(NSString *)connectionIdentifier withError:(NSError *)error{
	[[NSNotificationCenter defaultCenter] postNotificationName:HTTPConnectionErrorNotifaction
														object:error];
}

#pragma mark Account
-(NSString*)username{
	if (!username) {
		username = [[NSUserDefaults standardUserDefaults] stringForKey:@"currentAccount"];
	}
	return username;
}

#pragma mark Password
-(NSString*)password{
	char* cUsername=[username cStringUsingEncoding:NSUTF8StringEncoding];
	char* cPassword;
	UInt32 length=0;
	OSStatus error=SecKeychainFindGenericPassword(NULL,
												  strlen(serviceName), 
												  serviceName, 
												  strlen(cUsername), 
												  cUsername,
												  &length, 
												  &cPassword, 
												  NULL);
	if (error!=noErr) {
		NSLog (@"SecKeychainFindGenericPassword () For User:%@ error: %d",username, error);
	}
	
	NSString *string = [[[NSString alloc] initWithBytes:cPassword 
												 length:length 
											   encoding:NSUTF8StringEncoding] autorelease];
	return string;

}

-(void)setPassword:(NSString *)password{
	[self removePassword];
	const char* cUsername=[username cStringUsingEncoding:NSUTF8StringEncoding];
	const char* cPassword=[password cStringUsingEncoding:NSUTF8StringEncoding];
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
	OSStatus *error=SecKeychainFindGenericPassword(nil,
													  strlen(serviceName),
													  serviceName, 
													  strlen(cUsername),
													  cUsername, 
													  nil, nil, keychainItemRef);
	if (error==noErr) {
		error=SecKeychainItemDelete(keychainItemRef);
		if (error!=noErr) {
			NSLog(@"SecKeychainItemDelete() Error:%d",error);
		}
	}
}
@end
