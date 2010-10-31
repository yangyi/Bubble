//
//  WeiboGlobal.h
//  Rainbow
//
//  Created by Luke on 9/1/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

typedef enum {
	Home,
	Mentions,
	Comments,
	DirectMessages,
	Favorites
}TimelineType;

//Status Finished Notification,Tell webview and mainWindow to update
#define ReloadTimelineNotification @"ReloadTimelineNotification"

//HTTP Connection Notification
#define HTTPConnectionErrorNotification @"HTTPConnectionErrorNotification"
#define HTTPConnectionStartNotification @"HTTPConnectionStartNotification"
#define HTTPConnectionFinishedNotification @"HTTPConnectionFinishedNotification"


//URL Handler Notification
#define StartLoadOlderTimelineNotification @"StartLoadOlderTimelineNotification"
#define DidClickTimelineNotification @"DidClickTimelineNotification"
#define DidLoadOlderTimelineNotification @"DidLoadOlderTimelineNotification"
#define DidLoadNewerTimelineNotification @"DidLoadNewerTimelineNotification"
//Other Notification
#define UnreadNotification @"UnreadNotification"

#define DidPostStatusNotification @"DidPostStatusNotification"


@protocol WeiboConnectorDelegate

@end