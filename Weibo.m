//
//  Weibo.m
//  Rainbow
//
//  Created by Luke on 8/28/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Weibo.h"


@implementation Weibo

-(void)makeRequrst:(NSString *)apiPath{
	NSString *s = @"Basic ";
	NSString *up = @"kejinlu@gmail.com:lukejin1986";
	NSString *url = [NSString stringWithFormat:@"%@/statuses/friends_timeline.json?source=1444319711",WEIBO_BASE_URL];
	NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] init] autorelease];
	[request setURL:[NSURL URLWithString:url]];
	//[request setHTTPMethod:@"POST"];
	//[request setHTTPBody:[@"source=1444319711" dataUsingEncoding:NSUTF8StringEncoding]];
	[request setValue:[s stringByAppendingString:[[up dataUsingEncoding:NSUTF8StringEncoding] base64Encoding]] forHTTPHeaderField:@"Authorization"];
	_connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	NSLog(@"%d",[_connection retainCount]);
	_receivedData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	NSLog(@"receiving response... status code = %d", [response statusCode]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	NSString *jsonString = [[NSString alloc] initWithData:_receivedData encoding:NSUTF8StringEncoding];
	NSArray *json = [jsonString JSONValue];
	
	NSInteger count = [json count];
	NSLog(@"%d",[_connection retainCount]);
	NSLog(@"%@",[[json objectAtIndex:0] valueForKey:@"text"]);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_receivedData appendData:data];
}
@end
