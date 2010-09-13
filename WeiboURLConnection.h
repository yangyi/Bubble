//
//  WeiboURLConnection.h
//  Rainbow
//
//  Created by Luke on 8/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "WeiboEngineGlobal.h"
#import "NSStringAdditions.h"
@interface WeiboURLConnection : NSURLConnection {
	NSMutableData *_data;
	WeiboDataType _dataType;
	NSString *_identifier;
	
}
-(id)initWithRequest:(NSURLRequest*) request delegate:(id)delegate dataType:(WeiboDataType)dataType;
- (void)appendData:(NSData *)data;
- (void)resetDataLength;

@property(nonatomic,retain) NSMutableData *data;
@property(nonatomic,retain) NSString *identifier;
@property(nonatomic) WeiboDataType dataType;
@end
