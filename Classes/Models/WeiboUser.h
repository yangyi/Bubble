//
//  WeiboUser.h
//  Rainbow
//
//  Created by Luke on 9/22/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface WeiboUser : NSManagedObject 
//Attributes
@property(nonatomic,retain) NSNumber *identifier;
@property(nonatomic,retain) NSDate   *createdAt;
@property(nonatomic,retain) NSString *screenName;
@property(nonatomic,retain) NSString *name;
@property(nonatomic,retain) NSString *province;
@property(nonatomic,retain) NSString *city;
@property(nonatomic,retain) NSString *location;
@property(nonatomic,retain) NSString *userDescription;
@property(nonatomic,retain) NSString *url;
@property(nonatomic,retain) NSString *profileImageUrl;
@property(nonatomic,retain) NSString *domain;
@property(nonatomic,retain) NSString *gender;
@property(nonatomic,retain) NSNumber *followersCount;
@property(nonatomic,retain) NSNumber *friendsCount;
@property(nonatomic,retain) NSNumber *statusesCount;
@property(nonatomic,retain) NSNumber *favouritesCount;
@property(nonatomic,retain) NSNumber *following;
@property(nonatomic,retain) NSNumber *verified;
@end
