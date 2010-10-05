//
//  WeiboURLConnection.m
//  Rainbow
//
//  Created by Luke on 8/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "WeiboURLConnection.h"


@implementation WeiboURLConnection
@synthesize data=_data,identifier=_identifier,completionTarget,completionAction;

-(id)initWithRequest:(NSURLRequest*) request delegate:(id)delegate
{
	if ((self = [super initWithRequest:request delegate:delegate])) {
		_data = [[NSMutableData alloc] initWithCapacity:0];
        _identifier = [[NSString stringWithUUID] retain];
	}
	return self;
}

- (void)appendData:(NSData *)data
{
    [_data appendData:data];
}
- (void)resetDataLength
{
    [_data setLength:0];
}

-(void)dealloc
{
	[_data release];
	[_identifier release];
	[super dealloc];
}
@end
