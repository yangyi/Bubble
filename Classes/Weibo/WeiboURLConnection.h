//
//  WeiboURLConnection.h
//  Rainbow
//
//  Created by Luke on 8/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "WeiboGlobal.h"
#import "NSStringAdditions.h"
@interface WeiboURLConnection : NSURLConnection {
	NSMutableData *_data;
	NSString *_identifier;

	
	id completionTarget;
	SEL completionAction;
	
}
-(id)initWithRequest:(NSURLRequest*) request delegate:(id)delegate;
- (void)appendData:(NSData *)data;
- (void)resetDataLength;

@property(nonatomic,retain) NSMutableData *data;
@property(nonatomic,retain) NSString *identifier;
@property(assign) id completionTarget;
@property(assign) SEL completionAction;
@end
