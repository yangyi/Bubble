//
//  WeiboEngineGlobal.h
//  Rainbow
//
//  Created by Luke on 9/1/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//


typedef enum _weiboDataType {
    WeiboStatuses           = 0,    // one or more statuses
} WeiboDataType;

@protocol WeiboDelegate
-(void)statusesReceived:(NSArray *)statuses;
@end