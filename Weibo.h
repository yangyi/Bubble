//
//  Weibo.h
//  Rainbow
//
//  Created by Luke on 8/28/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NSDataAdditions.h"
#import "JSON.h"
#define WEIBO_BASE_URL @"http://api.t.sina.com.cn"

@interface Weibo : NSObject {
	NSMutableDictionary *_connections;
    NSURLConnection *_connection;
	NSMutableData *_receivedData;
}
-(void) makeRequrst:(NSString*)apiPath;
- (void)connectionDidFinishLoading:(NSURLConnection *)connection;
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;
@end
