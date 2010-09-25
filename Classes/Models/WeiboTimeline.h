//
//  WeiboTimeline.h
//  Rainbow
//
//  Created by Luke on 9/23/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "WeiboStatus.h"

@interface WeiboTimeline : NSManagedObject 

//Attributes
@property(nonatomic,retain) NSNumber *identifier;
@property(nonatomic,retain) NSString *timelineType;
//Relationships
@property(nonatomic,retain) WeiboStatus *status;
@end
