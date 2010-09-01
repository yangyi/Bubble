//
//  Weibo.m
//  Rainbow
//
//  Created by Luke on 8/28/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "Weibo.h"


@implementation Weibo
@synthesize username=_username,password=_password,appKey=_appKey;

-(Weibo*)initWithDelegate:(id)delegate
{
	if ((self = [super init])) {
		_delegate=delegate;
		_username=@"kejinlu@gmail.com";
		_password=@"lukejin1986";
		_appKey=@"1444319711";
	}
	return self;
}

/*
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

*/


//api
- (NSString *)getPublicTimeline{
	NSString *path=[NSString stringWithString:@"statuses/public_timeline.json?source=1444319711"];
	return [self _sendRequestWithMethod:nil baseurl:@"http://api.t.sina.com.cn"
								   path:path queryParameters:nil
								   body:nil dataType:WeiboStatuses];
}


#pragma mark Request Send Method
-(NSString*)_sendRequestWithMethod:(NSString*)method 
						   baseurl:(NSString*) baseurl
							  path:(NSString*) path
				   queryParameters:(NSDictionary *) params
							  body:(NSString*) body
						  dataType:(WeiboDataType)dataType{
	
	if(method==nil||[method isEqualToString:@"GET"]){
		[params setValue:@"1444319711" forKey:@"source"];
	}
	NSString* urlString = [NSURL urlStringWithBaseurl:baseurl path:path queryParameters:params];
	NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
	[theRequest setCachePolicy:NSURLRequestReloadIgnoringCacheData];

	
	if (_username&&_password) {
		NSString *authStr = [NSString stringWithFormat:@"%@:%@", _username, _password];
		NSData *authData = [authStr dataUsingEncoding:NSUTF8StringEncoding];
		NSString *authValue = [NSString stringWithFormat:@"Basic %@", [authData base64EncodingWithLineLength:80]];
		[theRequest setValue:authValue forHTTPHeaderField:@"Authorization"];
	}
	
	if(method&&[method isEqualToString:@"POST"]){
		[theRequest setHTTPMethod:method];
		NSString* bodyStr = @"";
		if(body){
			bodyStr = [bodyStr stringByAppendingString:body];
		}
		if (_appKey) {
			bodyStr = [bodyStr stringByAppendingString:[NSString stringWithFormat:@"%@source=%@", 
														(body) ? @"&" : @"" , 
														_appKey]];
		}
	}
	
	return [self _sendRequest:theRequest dataType:dataType];
}

-(NSString*) _sendRequest:(NSURLRequest*)request dataType:(WeiboDataType)dataType{
	WeiboURLConnection * connection = [[WeiboURLConnection alloc] 
									   initWithRequest:request delegate:self dataType:dataType]; 
	if (!connection) {
        return nil;
    } else {
        [_connections setObject:connection forKey:[connection identifier]];
        [connection release];
    }
	return [connection identifier];
	
}

#pragma mark NSURLConnection delegate methods

- (void)connection:(WeiboURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	[connection resetDataLength];
    
    // Get response code.
    NSHTTPURLResponse *resp = (NSHTTPURLResponse *)response;
    NSInteger statusCode = [resp statusCode];
	NSLog(@"%d",statusCode);
}


- (void)connection:(WeiboURLConnection *)connection didReceiveData:(NSData *)data
{
    // Append the new data to the receivedData.
    [connection appendData:data];
}

- (void)connectionDidFinishLoading:(WeiboURLConnection *)connection
{
	NSData *receivedData = connection.data;
	if(receivedData){
		[self _parseDataForConnection:connection];
	}

    [_connections removeObjectForKey:connection.identifier];
}

#pragma mark Parse Data
-(void)_parseDataForConnection:(WeiboURLConnection*)connection{
	NSData *jsonData = [[connection.data copy] autorelease];
	WeiboDataType dataType = connection.dataType;
	NSString *jsonString = [[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding] autorelease];
	switch (dataType) {
		case WeiboStatuses:
			if(_delegate!=nil&&[_delegate respondsToSelector:@selector(statusesReceived:)]){
				[_delegate statusesReceived:[jsonString JSONValue]];
			}
			break;
		default:
			break;
	}
}
@end
