//
//  WeiboStatus.h
//  Rainbow
//
//  Created by Luke on 9/22/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "WeiboUser.h"
#import "WeiboStatus.h"

@interface WeiboStatus : NSManagedObject 
//Attributes
@property(nonatomic,retain) NSNumber *identifier;
@property(nonatomic,retain) NSDate *createdAt;
@property(nonatomic,retain) NSString *text;
@property(nonatomic,retain) NSString *source;
@property(nonatomic,retain) NSNumber *favorited;
@property(nonatomic,retain) NSNumber *truncated;
@property(nonatomic,retain) NSNumber *inReplyToStatusId;
@property(nonatomic,retain) NSNumber *inReplyToUserId;
@property(nonatomic,retain) NSString *inReplyToScreenName;
@property(nonatomic,retain) NSString *thumbnailPic;
@property(nonatomic,retain) NSString *bmiddlePic;
@property(nonatomic,retain) NSString *originalPic;
//Relationships
@property(nonatomic,retain) WeiboUser *user;
@property(nonatomic,retain) WeiboStatus *retweetedStatus;
@end
