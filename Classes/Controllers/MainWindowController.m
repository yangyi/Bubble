//
//  MainWindowController.m
//  Rainbow
//
//  Created by Luke on 8/23/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MainWindowController.h"
#import "MyScroller.h"
#import "PathController.h"
@implementation MainWindowController
- (id)init {
	if(self = [super initWithWindowNibName:@"MainWindow"]){
		NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
		[nc addObserver:self selector:@selector(didShowErrorInfo:) 
				   name:HTTPConnectionErrorNotification 
				 object:nil];
		[nc addObserver:self selector:@selector(didStartHTTPConnection:) 
				   name:HTTPConnectionStartNotification
				 object:nil];
		[nc addObserver:self selector:@selector(didFinishedHTTPConnection:) 
				   name:HTTPConnectionFinishedNotification 
				 object:nil];
		[nc addObserver:self selector:@selector(didUpdateTimelineSegmentedControl:) 
				   name:UpdateTimelineSegmentedControlNotification 
				 object:nil];
		[nc addObserver:self selector:@selector(didDisplayImage:) 
				   name:DisplayImageNotification object:nil];
		[nc addObserver:self selector:@selector(enableBack:) 
				   name:PathChangedNotification object:nil];
		[nc addObserver:self selector:@selector(handleAccountVerified:) 
				   name:AccountVerifiedNotification object:nil];
		
		
	}
	composeController=[[ComposeController alloc]init];
	imagePanelController =[[ImagePanelController alloc] init];
	userInputController =[[UserInputController alloc] init];
	return self;
}

-(void) awakeFromNib{
	[webView setUIDelegate:self];
    //NSScrollView *scrollView = [[[[webView mainFrame] frameView] documentView] enclosingScrollView];
	//[scrollView setVerticalScroller:[[MyScroller alloc] init]];
	//[scrollView setHasVerticalScroller:YES];
	htmlController = [[HTMLController alloc] initWithWebView:webView];
	htmlController.imageView=imageView;
	//[htmlController loadRecentTimeline];
	[[AccountController instance] verifyCurrentAccount];
	[self updateTimelineSegmentedControl];
	[self reloadUsersMenu];
}

-(void)reloadUsersMenu{
	const int kUsersMenuPresetItems = 8;
	while ([userMenu numberOfItems]>kUsersMenuPresetItems) {
		[userMenu removeItemAtIndex:kUsersMenuPresetItems];
	}
	NSArray *accounts=[[NSUserDefaults standardUserDefaults] arrayForKey:@"accounts"];
	for(NSString *account in accounts){
		NSMenuItem *item = [self menuItemWithTitle:account action:@selector(selectAccount:) representedObject:account indentationLevel:1];
		if ([account isEqualToString:[[AccountController instance] currentAccount].username]) {
			[item setState:NSOnState];
		}else {
			NSTextAttachment* attachment = [[[NSTextAttachment alloc] init] autorelease];
			NSTextAttachmentCell *cell=[[[NSTextAttachmentCell alloc] init] autorelease];
			NSImage *image=[NSImage imageNamed:@"dot"];
			[cell setImage:image];
			[attachment setAttachmentCell:cell];
			NSAttributedString* imageAttributedString = [NSAttributedString attributedStringWithAttachment:attachment];

			NSFont *font=[NSFont menuFontOfSize:[NSFont systemFontSize]];			
			NSMutableAttributedString *attributedTitle =
			[[NSMutableAttributedString alloc] initWithString: account
												   attributes:[NSDictionary dictionaryWithObjectsAndKeys:
															   font,NSFontAttributeName,nil]];
			
			[attributedTitle appendAttributedString:imageAttributedString];
			[item setAttributedTitle:attributedTitle];
		}

		[userMenu addItem:item];
	}
}

- (NSMenuItem*)menuItemWithTitle:(NSString *)title action:(SEL)action representedObject:(id)representedObject indentationLevel:(int)indentationLevel {
	NSMenuItem *menuItem = [[[NSMenuItem alloc] init] autorelease];
	menuItem.title = title;
	menuItem.target = self;
	menuItem.action = action;
	menuItem.representedObject = representedObject;
	menuItem.indentationLevel = indentationLevel;
	return menuItem;
}	
- (IBAction)disabledMenuItem:(id)sender {
	// Do nothing
}


- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
	return (menuItem.action != @selector(disabledMenuItem:));
}

- (IBAction)selectAccount:(id)sender{
	NSString *username=[sender representedObject];
	[[AccountController instance] selectAccount:username];
	[[self window] setTitle:username];
	[self reloadUsersMenu];
}

-(IBAction)selectBackWithSegmentControl:(id)sender{
	int index=[sender selectedSegment];
	switch (index) {
		case 0:
			[[PathController instance] backward];
			break;
		case 1:
			[[PathController instance] forward];
			break;
		default:
			break;
	}
}

-(void)enableBack:(NSNotification*)notification{
	//[[self window] setTitle:[AccountController instance].currentAccount.screenName];
	int index=[PathController instance].currentIndex;
	int count=[[PathController instance].pathArray count];
	if (index<0) {
		[backSegmentedControl setEnabled:NO forSegment:0];
	}else {
		[backSegmentedControl setEnabled:YES forSegment:0];
	}
	if (index+1<count) {
		[backSegmentedControl setEnabled:YES forSegment:1];
	}else {
		[backSegmentedControl setEnabled:NO forSegment:1];
	}
}

-(void)handleAccountVerified:(NSNotification*)notification{
	NSDictionary *user=[notification object];
	[avatarView setImage:[[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:[user objectForKey:@"profile_image_url"]]]];
}

-(IBAction)selectViewWithSegmentControl:(id)sender{
	[self updateTimelineSegmentedControl];
	[[PathController instance] resetPath];
	int index=[sender selectedSegment];
	switch (index) {
		case 0:
			[htmlController selectHome];
			break;
		case 1:
			[htmlController selectMentions];
			break;
		case 2:
			[htmlController selectComments];
			break;
		case 3:
			[htmlController selectDirectMessage];
			break;

		case 4:
			[htmlController selectFavorites];
			break;

		default:
			break;
	}
}

- (void)updateTimelineSegmentedControl{
	if(timelineSegmentedControl==nil){
		return;
	}
	NSArray *imageNames=[NSArray arrayWithObjects:@"home",@"mentions",@"comments",@"direct",@"star",nil];
	NSString *imageName;
	BOOL unread[4];
	unread[0]=htmlController.weiboAccount.homeTimeline.unread;
	unread[1]=htmlController.weiboAccount.mentions.unread;
	unread[2]=htmlController.weiboAccount.comments.unread;
	unread[3]=NO;
	for(int index=0;index< imageNames.count;index++){
		imageName =[imageNames objectAtIndex:index];
		NSString *dotImageName=@"blue_dot.png";
		if([timelineSegmentedControl isSelectedForSegment:index]){
			imageName = [imageName stringByAppendingString:@"_down"];
			dotImageName=@"white_dot.png";
		}
		imageName = [imageName stringByAppendingString:@".png"];
		NSImage *image=[NSImage imageNamed:imageName];
		if (index<4&&unread[index]) {
			NSImage *dot=[NSImage imageNamed:dotImageName];
			[image lockFocus];
			[dot drawInRect:NSMakeRect([image size].width-[dot size].width, [image size].height-[dot size].height, [dot size].width, [dot size].height) fromRect:NSMakeRect(0, 0, [dot size].width, [dot size].height) operation:NSCompositeSourceOver fraction:1.0];
			[image unlockFocus];
			//clean the image cache
			[image setName:nil];
		}
		[timelineSegmentedControl setImage:nil forSegment:index];
		[timelineSegmentedControl setImage:image forSegment:index];
	}
	
}

-(IBAction)compose:(id)sender{
	[composeController composeNew];
}


-(void)didShowErrorInfo:(NSNotification*)notification{
	NSError* error = [notification object];
	[connectionProgressIndicator setHidden:YES];
	[connectionProgressIndicator stopAnimation:nil];
	[messageText setStringValue:[error localizedDescription]];
}

-(void)didStartHTTPConnection:(NSNotification*)notification{
	[connectionProgressIndicator setHidden:NO];
	[connectionProgressIndicator startAnimation:nil];
}

-(void)didFinishedHTTPConnection:(NSNotification*)notification{
	[connectionProgressIndicator setHidden:YES];
	[connectionProgressIndicator stopAnimation:nil];
}

-(void)didUpdateTimelineSegmentedControl:(NSNotification*)notification{
	[self updateTimelineSegmentedControl];
}

-(void)didDisplayImage:(NSNotification*)notification{
	NSString *url =[notification object];
	[imagePanelController loadImagefromURL:url];
}

- (WebView *)webView:(WebView *)sender createWebViewWithRequest:(NSURLRequest *)request
{

	WebView *_hiddenWebView=[[WebView alloc] init];
	[_hiddenWebView setPolicyDelegate:self];
	return _hiddenWebView;
}

- (void)webView:(WebView *)sender decidePolicyForNavigationAction:(NSDictionary *)actionInformation request:(NSURLRequest *)request frame:(WebFrame *)frame decisionListener:(id<WebPolicyDecisionListener>)listener {
    NSLog(@"%@",[[actionInformation objectForKey:WebActionOriginalURLKey] absoluteString]);
	[[NSWorkspace sharedWorkspace] openURL:[actionInformation objectForKey:WebActionOriginalURLKey]];
	[sender release];
}


-(IBAction)refreshTimeline:(id)sender{
	[[PathController instance].currentTimeline reset]; 
	[[PathController instance].currentTimeline loadRecentTimeline];
}
-(IBAction)openUserInput:(id)sender{
	[userInputController show:[self window]];
}
-(IBAction)popUpUserMenu:(id)sender{
	NSRect frame = [(NSView *)sender frame];
	NSPoint menuOrigin = [[(NSButton *)sender superview] convertPoint:NSMakePoint(frame.origin.x, frame.origin.y-4)
                                                               toView:nil];
	NSEvent *event =  [NSEvent mouseEventWithType:NSLeftMouseDown
                                         location:menuOrigin
                                    modifierFlags:NSLeftMouseDownMask // 0x100
                                        timestamp:0.00
                                     windowNumber:[[(NSView *)sender window] windowNumber]
                                          context:[[(NSView *)sender window] graphicsContext]
                                      eventNumber:0
                                       clickCount:1
                                         pressure:1];
	
	[NSMenu popUpContextMenu:userMenu withEvent:event forView:[(NSView *)sender superview]];
	
}

-(IBAction)showMyProfile:(id)sender{
	NSString *screenName=[AccountController instance].currentAccount.screenName;
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"weibo://user?fetch_with=screen_name&value=%@",screenName]]];

}

@end
