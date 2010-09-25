//
//  WeiboComment.h
//  Rainbow
//
//  Created by Luke on 9/24/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "WeiboStatus.h"
#import "WeiboUser.h"
@interface WeiboComment : NSManagedObject 
//Attributes
@property(nonatomic,retain) NSNumber *identifier;
@property(nonatomic,retain) NSString *text;
@property(nonatomic,retain) NSString *source;
@property(nonatomic,retain) NSNumber *favorited;
@property(nonatomic,retain) NSNumber *truncated;
@property(nonatomic,retain) NSDate *createdAt;
//Relationships
@property(nonatomic,retain) WeiboUser *user;
@property(nonatomic,retain) WeiboStatus *status;
@property(nonatomic,retain) WeiboComment *replyComment;
@end
