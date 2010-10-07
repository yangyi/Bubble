//
//  WeiboGlobal.h
//  Rainbow
//
//  Created by Luke on 9/1/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//


//Status Finished Notification,Tell webview and mainWindow to update
#define FinishedLoadRecentHomeTimelineNotification @"FinishedLoadRecentHomeTimelineNotification"
#define FinishedLoadNewerHomeTimelineNotification @"FinishedLoadNewerHomeTimelineNotification"
#define FinishedLoadOlderHomeTimelineNotification @"FinishedLoadOlderHomeTimelineNotification"

//HTTP Connection Notification
#define HTTPConnectionErrorNotification @"HTTPConnectionErrorNotification"
#define HTTPConnectionStartNotification @"HTTPConnectionStartNotification"
#define HTTPConnectionFinishedNotification @"HTTPConnectionFinishedNotification"

@protocol WeiboConnectorDelegate

@end