//
//  WeiboGlobal.h
//  Rainbow
//
//  Created by Luke on 9/1/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//


//Status Finished Notification,Tell webview and mainWindow to update
#define ReloadHomeTimelineNotification @"ReloadHomeTimelineNotification"

//HTTP Connection Notification
#define HTTPConnectionErrorNotification @"HTTPConnectionErrorNotification"
#define HTTPConnectionStartNotification @"HTTPConnectionStartNotification"
#define HTTPConnectionFinishedNotification @"HTTPConnectionFinishedNotification"


//URL Handler Notification
#define StartLoadOlderHomeTimelineNotification @"StartLoadOlderHomeTimelineNotification"
#define HomeTimelineStatusClickNotification @"HomeTimelineStatusClickNotification"
#define DidLoadOlderHomeTimelineNotification @"DidLoadOlderHomeTimelineNotification"
#define DidLoadNewerHomeTimelineNotification @"DidLoadNewerHomeTimelineNotification"
//Other Notification
#define UnreadNotification @"UnreadNotification"

@protocol WeiboConnectorDelegate

@end