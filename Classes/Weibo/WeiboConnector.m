//
//  WeiboConnector.m
//  Rainbow
//
//  Created by Luke on 8/28/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "WeiboConnector.h"

#pragma mark Weibo Private Interface
@interface WeiboConnector(Private) 

-(NSString*)_sendRequestWithMethod:(NSString*)method 
						   baseurl:(NSString*) baseurl
							  path:(NSString*) path
				   queryParameters:(NSDictionary *) params
							  body:(NSString*) body
				  completionTarget:(id)target
				  completionAction:(SEL)action;

-(NSString*) _sendRequest:(NSURLRequest*)request
		 completionTarget:(id)target
		 completionAction:(SEL)action;

-(void)_parseDataForConnection:(WeiboURLConnection*)connection;

- (void)connectionDidFinishLoading:(NSURLConnection *)connection;
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;
@end


@implementation WeiboConnector
@synthesize username=_username,password=_password,appKey=_appKey;

-(WeiboConnector*)initWithDelegate:(id)delegate
{
	if ((self = [super init])) {
		_delegate=delegate;
		_username=@"kejinlu@gmail.com";
		_password=@"lukejin1986";
		_appKey=@"1444319711";
	}
	return self;
}



#pragma mark Sina Weibo API Interface Implementation


-(NSString *) getHomeTimelineWithParameters:(NSMutableDictionary*)params
						   completionTarget:(id)target
						   completionAction:(SEL)action
{
	NSString *path=[NSString stringWithString:@"statuses/home_timeline.json"];
	return [self _sendRequestWithMethod:nil 
								baseurl:WEIBO_BASE_URL
								   path:path 
						queryParameters:params
								   body:nil
					   completionTarget:(id)target
					   completionAction:(SEL)action];
}

-(NSString *) getMentionsWithParameters:(NSMutableDictionary*)params
					   completionTarget:(id)target
					   completionAction:(SEL)action{
	NSString *path=[NSString stringWithString:@"statuses/mentions.json"];

	return [self _sendRequestWithMethod:nil baseurl:WEIBO_BASE_URL
								   path:path queryParameters:params
								   body:nil
					   completionTarget:(id)target
					   completionAction:(SEL)action];	
}

-(NSString *) updateWithStatus:(NSString*)status				  
			  completionTarget:(id)target
			  completionAction:(SEL)action{
	NSString *path=[NSString stringWithString:@"statuses/update.json"];
	NSString *body=[NSString stringWithFormat:@"status=%@",status];
	return [self _sendRequestWithMethod:@"POST" 
								baseurl:WEIBO_BASE_URL
								   path:path 
						queryParameters:nil
								   body:body 
					   completionTarget:(id)target
					   completionAction:(SEL)action];	
}


#pragma mark Request Send Method
-(NSString*)_sendRequestWithMethod:(NSString*)method 
						   baseurl:(NSString*) baseurl
							  path:(NSString*) path
				   queryParameters:(NSMutableDictionary *) params
							  body:(NSString*) body
				  completionTarget:(id)target
				  completionAction:(SEL)action{
	
	if(method==nil||[method isEqualToString:@"GET"]){
		[params setValue:_appKey forKey:@"source"];
	}
	NSString* urlString = [NSURL urlStringWithBaseurl:baseurl path:path queryParameters:params];
	NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
	[theRequest setCachePolicy:NSURLRequestReloadIgnoringCacheData];
	[theRequest setTimeoutInterval:60.0];

	
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
		[theRequest setHTTPBody:[bodyStr dataUsingEncoding:NSUTF8StringEncoding]]; 
	}
	

	return [self _sendRequest:theRequest 				  
			 completionTarget:(id)target
			 completionAction:(SEL)action];
}

-(NSString*) _sendRequest:(NSURLRequest*)request 				  
		 completionTarget:(id)target
		 completionAction:(SEL)action{
	WeiboURLConnection * connection = [[WeiboURLConnection alloc] 
									   initWithRequest:request delegate:self];
	if (!connection) {
        return nil;
    } else {
		connection.completionTarget=target;
		connection.completionAction=action;
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
	if (statusCode>=400) {
		[_connections removeObjectForKey:connection.identifier];
		NSError *error=[NSError errorWithDomain:@"HTTP" code:statusCode userInfo:nil];
		if (_delegate!=nil&&[_delegate respondsToSelector:@selector(requestFailed:withError:)]) {
			[_delegate requestFailed:connection.identifier withError:error];
		}
	}
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

-(void)connection:(WeiboURLConnection *)connection didFailWithError:(NSError*)error{
	[_connections removeObjectForKey:connection.identifier];
	if (_delegate!=nil&&[_delegate respondsToSelector:@selector(requestFailed:withError:)]) {
		[_delegate requestFailed:connection.identifier withError:error];
	}
}

#pragma mark Parse Data and perform target-action
-(void)_parseDataForConnection:(WeiboURLConnection*)connection{
	NSData *jsonData = [[connection.data copy] autorelease];
	NSString *jsonString = [[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding] autorelease];
	[connection.completionTarget performSelector:connection.completionAction 
									  withObject:[jsonString JSONValue]];
}
@end
