//
//  WeiboDirectMessage.h
//  Rainbow
//
//  Created by Luke on 9/23/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "WeiboUser.h"

@interface WeiboDirectMessage : NSManagedObject 
//Attributes
@property(nonatomic,retain) NSNumber *identifier;
@property(nonatomic,retain) NSString *text;
@property(nonatomic,retain) NSNumber *senderId;
@property(nonatomic,retain) NSNumber *recipientId;
@property(nonatomic,retain) NSDate *createdAt;
@property(nonatomic,retain) NSString *senderScreenName;
@property(nonatomic,retain) NSString *recipientScreenName;
//Relationships
@property(nonatomic,retain) WeiboUser *sender;
@property(nonatomic,retain) WeiboUser *recipient;
@end
