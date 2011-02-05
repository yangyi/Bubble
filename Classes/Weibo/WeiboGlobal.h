//
//  WeiboGlobal.h
//  Rainbow
//
//  Created by Luke on 9/1/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

typedef enum {
	Home=0,
	Mentions,
	Comments,
	DirectMessages,
	Favorites
}TimelineType;

//Status Finished Notification,Tell webview and mainWindow to update
#define ReloadTimelineNotification @"ReloadTimelineNotification"
#define ShowLoadingPageNotification @"ShowLoadingPageNotification"
//HTTP Connection Notification
#define HTTPConnectionErrorNotification @"HTTPConnectionErrorNotification"
#define HTTPConnectionStartNotification @"HTTPConnectionStartNotification"
#define HTTPConnectionFinishedNotification @"HTTPConnectionFinishedNotification"


//URL Handler Notification
#define StartLoadOlderTimelineNotification @"StartLoadOlderTimelineNotification"
#define DidClickTimelineNotification @"DidClickTimelineNotification"
#define DidLoadOlderTimelineNotification @"DidLoadOlderTimelineNotification"
#define DidLoadNewerTimelineNotification @"DidLoadNewerTimelineNotification"
#define DidLoadTimelineWithPageNotification @"DidLoadTimelineWithPageNotification"
#define GetUserNotification @"GetUserNotification"
//Other Notification
#define UpdateTimelineSegmentedControlNotification @"UpdateTimelineSegmentedControlNotification"

#define SaveScrollPositionNotification @"SaveScrollPositionNotification"

#define DidPostStatusNotification @"DidPostStatusNotification"
#define DidGetUserNotification @"DidGetUserNotification"
#define DidSelectAccountNotification @"DidSelectAccountNotification"
#define DisplayImageNotification @"DisplayImageNotification"
#define GetFriendsNotification @"GetFriendsNotification"
#define DidGetFriendsNotification @"DidGetFriendsNotification"
#define GetStatusCommentsNotification @"GetStatusCommentsNotification"
#define DidGetStatusCommentsNotification @"DidGetStatusCommentsNotification"
#define ShowStatusCommentsNotification @"ShowStatusCommentsNotification"
#define ShowStatusNotification @"ShowStatusNotification"
#define DidShowStatusNotification @"DidShowStatusNotification"
#define DidGetDirectMessageNotification @"DidGetDirectMessageNotification"

#define ReplyNotification @"ReplyNotification"
#define RepostNotification @"RepostNotification"

