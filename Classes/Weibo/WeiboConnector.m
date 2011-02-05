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
							  body:(NSMutableData*) body
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
@synthesize appKey=_appKey;

-(WeiboConnector*)initWithDelegate:(id)delegate
{
	if ((self = [super init])) {
		_delegate=delegate;
		_appKey=@"1444319711";
		multipartBoundary=@"--12345";
	}
	return self;
}



#pragma mark Sina Weibo API Interface Implementation
-(NSString *) verifyAccountWithParameters:(NSMutableDictionary*)params 
						 completionTarget:(id)target  
						 completionAction:(SEL)action{
	NSString *path=@"account/verify_credentials.json";
	return [self _sendRequestWithMethod:nil
								baseurl:WEIBO_BASE_URL 
								   path:path
						queryParameters:params
								   body:nil completionTarget:target
					   completionAction:action];
}

-(NSString *)checkUnreadWithParameters:(NSMutableDictionary*)params 
					  completionTarget:(id)target  
					  completionAction:(SEL)action{
	NSString *path=@"statuses/unread.json";
	return [self _sendRequestWithMethod:nil
								baseurl:WEIBO_BASE_URL 
								   path:path
						queryParameters:params
								   body:nil completionTarget:target
					   completionAction:action];
}


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
					   completionTarget:target
					   completionAction:action];	
}

-(NSString *) getCommentsWithParameters:(NSMutableDictionary*)params
					   completionTarget:(id)target
					   completionAction:(SEL)action{
	NSString *path=[NSString stringWithString:@"statuses/comments_timeline.json"];
	return [self _sendRequestWithMethod:nil baseurl:WEIBO_BASE_URL
								   path:path queryParameters:params
								   body:nil completionTarget:target
					   completionAction:action];
}


-(NSString *) getFavoritesWithParameters:(NSMutableDictionary*)params
						completionTarget:(id)target
						completionAction:(SEL)action{
	NSString *path=[NSString stringWithString:@"favorites.json"];
	return [self _sendRequestWithMethod:nil baseurl:WEIBO_BASE_URL
								   path:path queryParameters:params
								   body:nil completionTarget:target
					   completionAction:action];
}

-(NSString *) replyWithParamters:(NSMutableDictionary*)params
				completionTarget:(id)target
				completionAction:(SEL)action{
	NSString *path=[NSString stringWithString:@"statuses/comment.json"];
	NSMutableData *postBody = [NSMutableData data];
	NSString *comment=[params objectForKey:@"comment"];
	NSString *sid=[params objectForKey:@"id"];
	NSString *cid=[params objectForKey:@"cid"];
	if (cid) {
		[postBody appendData:[[NSString stringWithFormat:@"comment=%@&id=%@&cid=%@&source=%@",comment,sid,cid,_appKey]dataUsingEncoding:NSUTF8StringEncoding]];
	}else {
		[postBody appendData:[[NSString stringWithFormat:@"comment=%@&id=%@&source=%@",comment,sid,_appKey]dataUsingEncoding:NSUTF8StringEncoding]];
	}
	return [self _sendRequestWithMethod:@"POST" 
								baseurl:WEIBO_BASE_URL
								   path:path 
						queryParameters:nil
								   body:postBody
					   completionTarget:(id)target
					   completionAction:(SEL)action];	

}

-(NSString *) repostWithParamters:(NSMutableDictionary*)params
				 completionTarget:(id)target
				 completionAction:(SEL)action{
	NSString *path=[NSString stringWithString:@"statuses/repost.json"];
	NSMutableData *postBody = [NSMutableData data];
	NSString *status=[params objectForKey:@"status"];
	NSString *sid=[params objectForKey:@"id"];
	[postBody appendData:[[NSString stringWithFormat:@"status=%@&id=%@&source=%@",status,sid,_appKey]dataUsingEncoding:NSUTF8StringEncoding]];
	return [self _sendRequestWithMethod:@"POST" 
								baseurl:WEIBO_BASE_URL
								   path:path 
						queryParameters:nil
								   body:postBody
					   completionTarget:(id)target
					   completionAction:(SEL)action];	
}
	
-(NSString *) updateWithStatus:(NSString*)status				  
			  completionTarget:(id)target
			  completionAction:(SEL)action{
	NSString *path=[NSString stringWithString:@"statuses/update.json"];
	NSMutableData *postBody = [NSMutableData data];
	[postBody appendData:[[NSString stringWithFormat:@"status=%@&source=%@",status,_appKey]dataUsingEncoding:NSUTF8StringEncoding]];
	return [self _sendRequestWithMethod:@"POST" 
								baseurl:WEIBO_BASE_URL
								   path:path 
						queryParameters:nil
								   body:postBody
					   completionTarget:(id)target
					   completionAction:(SEL)action];	
}

-(NSString*) updateWithStatus:(NSString *)status 
						image:(NSData*)imageData
					imageName:(NSString*)imageName
			 completionTarget:(id)target 
			 completionAction:(SEL)action{
	NSString *path=[NSString stringWithString:@"statuses/upload.json"];
	NSString *imgExt=(NSString*)[[imageName componentsSeparatedByString:@"."] lastObject];
	if ([imgExt isEqualToString:@"jpg"]) {
		imgExt=@"jpeg";
	}
	//fill the post body data
	NSMutableData *postBody = [NSMutableData data];
	[postBody appendData:[[NSString stringWithFormat:@"--%@\r\n", multipartBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[@"Content-Disposition: form-data; name= \"status\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[status dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", multipartBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"pic\"; filename=\"%@\"\r\n", imageName] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithFormat:@"Content-Type: image/%@\r\n\r\n",imgExt] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:imageData];
	[postBody appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", multipartBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[@"Content-Disposition: form-data; name= \"source\"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[_appKey dataUsingEncoding:NSUTF8StringEncoding]];
	[postBody appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",multipartBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
	
	return [self _sendRequestWithMethod:@"MULTIPART_POST" baseurl:WEIBO_BASE_URL
								   path:path queryParameters:nil
								   body:postBody
					   completionTarget:(id)target
					   completionAction:(SEL)action];
	
}

-(NSString *) getUserWithParamters:(NSMutableDictionary*)params 
				  completionTarget:(id)target
				  completionAction:(SEL)action{
	NSString *path=[NSString stringWithString:@"users/show.json"];
	
	return [self _sendRequestWithMethod:nil baseurl:WEIBO_BASE_URL
								   path:path queryParameters:params
								   body:nil
					   completionTarget:(id)target
					   completionAction:(SEL)action];
	
}


-(NSString *) getFriendsWithParamters:(NSMutableDictionary*)params 
				  completionTarget:(id)target
				  completionAction:(SEL)action{
	NSString *path=[NSString stringWithString:@"statuses/friends.json"];
	
	return [self _sendRequestWithMethod:nil baseurl:WEIBO_BASE_URL
								   path:path queryParameters:params
								   body:nil
					   completionTarget:(id)target
					   completionAction:(SEL)action];
	
}
-(NSString *) getStatusCommentsWithParamters:(NSMutableDictionary*)params 
					 completionTarget:(id)target
					 completionAction:(SEL)action{
	NSString *path=[NSString stringWithString:@"statuses/comments.json"];
	
	return [self _sendRequestWithMethod:nil baseurl:WEIBO_BASE_URL
								   path:path queryParameters:params
								   body:nil
					   completionTarget:(id)target
					   completionAction:(SEL)action];
	
}
-(NSString *) showStatusWithParamters:(NSMutableDictionary*)params 
							completionTarget:(id)target
							completionAction:(SEL)action{
	NSString *path=[NSString stringWithString:@"statuses/show/:id.json"];
	
	return [self _sendRequestWithMethod:nil baseurl:WEIBO_BASE_URL
								   path:path queryParameters:params
								   body:nil
					   completionTarget:(id)target
					   completionAction:(SEL)action];
	
}


-(NSString *) getDirectMessageWithParamters:(NSMutableDictionary*)params 
						   completionTarget:(id)target
						   completionAction:(SEL)action{
	NSString *path=[NSString stringWithString:@"direct_messages.json"];
	return [self _sendRequestWithMethod:nil baseurl:WEIBO_BASE_URL
								   path:path queryParameters:params
								   body:nil
					   completionTarget:(id)target
					   completionAction:(SEL)action];
}

#pragma mark Request Send Method
-(NSString*)_sendRequestWithMethod:(NSString*)method 
						   baseurl:(NSString*) baseurl
							  path:(NSString*) path
				   queryParameters:(NSMutableDictionary *) params
							  body:(NSMutableData*) body
				  completionTarget:(id)target
				  completionAction:(SEL)action{
	
	if(method==nil||[method isEqualToString:@"GET"]){
		[params setValue:_appKey forKey:@"source"];
	}
	NSString* urlString = [NSURL urlStringWithBaseurl:baseurl path:path queryParameters:params];
	NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
	[theRequest setCachePolicy:NSURLRequestReloadIgnoringCacheData];
	[theRequest setTimeoutInterval:60.0];
	NSString *username=[[_delegate currentAccount] username];
	NSString *password=[[_delegate currentAccount] password];
	if (username&&password) {
		NSString *authStr = [NSString stringWithFormat:@"%@:%@", username, password];
		NSData *authData = [authStr dataUsingEncoding:NSUTF8StringEncoding];
		NSString *authValue = [NSString stringWithFormat:@"Basic %@", [authData base64EncodingWithLineLength:80]];
		[theRequest setValue:authValue forHTTPHeaderField:@"Authorization"];
	}
	
	if(method&&[method isEqualToString:@"POST"]){
		[theRequest setHTTPMethod:method];
		if(body){
			[theRequest setHTTPBody:body]; 
		}
	}
	if (method&&[method isEqualToString:@"MULTIPART_POST"]) {
		[theRequest setHTTPMethod:@"POST"];
		NSString *contentType = [NSString stringWithFormat:@"multipart/form-data, boundary=%@", multipartBoundary];
		[theRequest setValue:contentType forHTTPHeaderField:@"Content-Type"];
		if (body) {
			[theRequest setHTTPBody:body];
		}
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
		[[NSNotificationCenter defaultCenter] postNotificationName:HTTPConnectionStartNotification 
															object:nil];
		
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
		[[NSNotificationCenter defaultCenter] postNotificationName:HTTPConnectionErrorNotification
															object:error];
	}
}


- (void)connection:(WeiboURLConnection *)connection didReceiveData:(NSData *)data
{
    // Append the new data to the receivedData.
    [connection appendData:data];
}

- (void)connectionDidFinishLoading:(WeiboURLConnection *)connection
{
	[[NSNotificationCenter defaultCenter]postNotificationName:HTTPConnectionFinishedNotification object:nil];
	
	NSData *receivedData = connection.data;
	if(receivedData){
		[self _parseDataForConnection:connection];
	}

    [_connections removeObjectForKey:connection.identifier];
}

-(void)connection:(WeiboURLConnection *)connection didFailWithError:(NSError*)error{
	[_connections removeObjectForKey:connection.identifier];
	[[NSNotificationCenter defaultCenter] postNotificationName:HTTPConnectionErrorNotification
														object:error];
}

#pragma mark Parse Data and perform target-action
-(void)_parseDataForConnection:(WeiboURLConnection*)connection{
	NSData *jsonData = [[connection.data copy] autorelease];
	NSString *jsonString = [[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding] autorelease];
	[connection.completionTarget performSelector:connection.completionAction 
									  withObject:[jsonString JSONValue]];
}
@end
