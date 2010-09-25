//
//  WeiboCache.m
//  Rainbow
//
//  Created by Luke on 9/24/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "WeiboCache.h"


@implementation WeiboCache
- (NSManagedObjectContext *) managedObjectContext {
	if(managedObjectContext) return managedObjectContext;
	id appDelegate = [NSApp delegate];
	managedObjectContext=[appDelegate managedObjectContext];
	return managedObjectContext;
}

-(void)saveUserFromStatus:(NSDictionary*) status{
	NSError *error = nil;
	WeiboUser* user=(WeiboUser*)[NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:[self managedObjectContext]];
    NSDictionary* userDict = [status objectForKey:@"user"];
	user.identifier=[userDict objectForKey:@"id"];
	user.screenName=[userDict objectForKey:@"screen_name"];
	user.name=[userDict objectForKey:@"name"];
	user.profileImageUrl=[userDict objectForKey:@"profile_image_url"];
	
	if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%s unable to commit editing before saving", [self class], _cmd);
    }
	
    if (![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}

@end
