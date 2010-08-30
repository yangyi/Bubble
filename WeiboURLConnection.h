//
//  WeiboURLConnection.h
//  Rainbow
//
//  Created by Luke on 8/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface WeiboURLConnection : NSObject {
	NSMutableData *_data;
	
}
@property(nonatomic,retain) NSMutableData *data;
@end
