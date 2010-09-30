//
//  WeiboGlobal.h
//  Rainbow
//
//  Created by Luke on 9/1/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

//Notification constants
#define StatusesReceivedNotification @"StatusesReceivedNotification" 

typedef enum _weiboDataType {
    DataTypeWeiboStatuses           = 0,
	DataTypeWeiboStatus             = 1
} WeiboDataType;




@protocol WeiboDelegate
-(void)statusesDidReceived:(NSArray *)statuses withRequestPath:(NSString*)requestPath;
-(void)statusDidReceived:(NSDictionary*)status;
@end