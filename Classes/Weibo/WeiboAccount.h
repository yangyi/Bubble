//
//  WeiboAccount.h
//  Bubble
//
//  Created by Luke on 12/9/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface WeiboAccount : NSObject {
	NSString *username;
	NSString *password;
	NSString *screenName;
}
@property(nonatomic,retain) NSString *username;
@property(nonatomic,retain) NSString *password;
@property(nonatomic,retain) NSString *screenName;
@end
