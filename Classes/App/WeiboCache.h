//
//  WeiboCache.h
//  Rainbow
//
//  Created by Luke on 9/24/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "WeiboUser.h"
@interface WeiboCache : NSObject {
    NSManagedObjectContext *managedObjectContext;
}
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;

-(void)saveUserFromStatus:(NSDictionary*) status;
@end
