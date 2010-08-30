//
//  NSStringAdditions.m
//  Rainbow
//
//  Created by Luke on 8/30/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NSStringAdditions.h"


@implementation NSString(Additions)
+ (NSString*)stringWithUUID
{
    // Create a new UUID
	/* kCFAllocatorDefault is a synonym for NULL, if you'd rather use a named constant. */
    CFUUIDRef uuidObj = CFUUIDCreate(kCFAllocatorDefault);
    
    // Get the string representation of the UUID
    NSString *uuidStr = (NSString*)CFUUIDCreateString(kCFAllocatorDefault, uuidObj);
    CFRelease(uuidObj);
    return [uuidStr autorelease];
}


@end
