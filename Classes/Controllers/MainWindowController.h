//
//  MainWindowController.h
//  Rainbow
//
//  Created by Luke on 8/23/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import "HTMLController.h"
#import "WeiboGlobal.h"
#import "ComposeController.h"
@interface MainWindowController : NSWindowController {
	IBOutlet WebView *webView;
	IBOutlet NSSegmentedControl *timelineSegmentedControl;
	IBOutlet NSTextField *messageText;
	IBOutlet NSProgressIndicator * connectionProgressIndicator;
	HTMLController *htmlController;
	ComposeController *composeController;
	
}
-(id)init;
-(IBAction)selectViewWithSegmentControl:(id)sender;
-(void)mentions;
-(void)homeTimeLine;
-(IBAction)compose:(id)sender;


//主要是更新图标的
- (void)updateTimelineSegmentedControl;

-(void)didStartHTTPConnection:(NSNotification*)notification;
-(void)didFinishedHTTPConnection:(NSNotification*)notification;

@end
