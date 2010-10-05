//
//  WeiboGlobal.h
//  Rainbow
//
//  Created by Luke on 9/1/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//


//Status Finished Notifaction,Tell webview and mainWindow to update
#define FinishedLoadRecentHomeTimelineNotifaction @"FinishedLoadRecentHomeTimelineNotifaction"
#define FinishedLoadNewerHomeTimelineNotifaction @"FinishedLoadNewerHomeTimelineNotifaction"
#define FinishedLoadOlderHomeTimelineNotifaction @"FinishedLoadOlderHomeTimelineNotifaction"


#define HTTPConnectionErrorNotifaction @"HTTPConnectionErrorNotifaction"


@protocol WeiboConnectorDelegate
- (void)requestFailed:(NSString *)connectionIdentifier withError:(NSError *)error;
@end