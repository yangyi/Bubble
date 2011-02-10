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
#import "NSWindowAdditions.h"
#import "ImagePanelController.h"
#import "UserInputController.h"
@interface MainWindowController : NSWindowController {
	IBOutlet WebView *webView;
	IBOutlet NSImageView *imageView;
	IBOutlet NSSegmentedControl *timelineSegmentedControl;
	IBOutlet NSSegmentedControl *backSegmentedControl;
	IBOutlet NSTextField *messageText;
	IBOutlet NSProgressIndicator * connectionProgressIndicator;
	IBOutlet NSWindow *composeWindow;
	IBOutlet NSImageView *avatarView;
	IBOutlet NSMenu *userMenu;
	HTMLController *htmlController;
	ComposeController *composeController;
	ImagePanelController *imagePanelController;
	UserInputController *userInputController;
	
}
-(id)init;
-(IBAction)selectViewWithSegmentControl:(id)sender;
-(IBAction)selectBackWithSegmentControl:(id)sender;
-(IBAction)compose:(id)sender;
-(IBAction)disabledMenuItem:(id)sender;
-(void)reloadUsersMenu;
- (NSMenuItem*)menuItemWithTitle:(NSString *)title action:(SEL)action representedObject:(id)representedObject indentationLevel:(int)indentationLevel;
//主要是更新图标的
- (void)updateTimelineSegmentedControl;

-(void)didStartHTTPConnection:(NSNotification*)notification;
-(void)didFinishedHTTPConnection:(NSNotification*)notification;


-(IBAction)refreshTimeline:(id)sender;
-(IBAction)openUserInput:(id)sender;
-(IBAction)popUpUserMenu:(id)sender;
-(IBAction)showMyProfile:(id)sender;
@end
