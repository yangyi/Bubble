//
//  MainWindowController.m
//  Rainbow
//
//  Created by Luke on 8/23/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MainWindowController.h"
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
		[nc addObserver:self selector:@selector(didUnread:) 
				   name:UnreadNotification 
				 object:nil];
		[nc addObserver:self selector:@selector(didDisplayImage:) 
				   name:DisplayImageNotification object:nil];
	}
	composeController=[[ComposeController alloc]init];
	imagePanelController =[[ImagePanelController alloc] init];
	return self;
}

-(void) awakeFromNib{
	[webView setUIDelegate:self];
	htmlController = [[HTMLController alloc] initWithWebView:webView];
	[htmlController loadRecentTimeline];
	[self updateTimelineSegmentedControl];
	[self reloadUsersMenu];
}

-(void)reloadUsersMenu{
	const int kUsersMenuPresetItems = 8;
	if (userButton==nil) {
		return;
	}
	while ([[userButton menu] numberOfItems]>kUsersMenuPresetItems) {
		[[userButton menu] removeItemAtIndex:kUsersMenuPresetItems];
	}
	NSArray *accounts=[[NSUserDefaults standardUserDefaults] arrayForKey:@"accounts"];
	for(NSString *account in accounts){
		NSMenuItem *item = [self menuItemWithTitle:account action:@selector(selectAccount:) representedObject:account indentationLevel:1];
		if ([account isEqualToString:[[AccountController instance] currentAccount].username]) {
			[item setState:NSOnState];
		}else {
			NSTextAttachment* attachment = [[[NSTextAttachment alloc] init] autorelease];
			NSTextAttachmentCell *cell=[[[NSTextAttachmentCell alloc] init] autorelease];
			NSImage *image=[NSImage imageNamed:@"SmallBlueDot"];
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

		[[userButton menu] addItem:item];
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

-(IBAction)selectViewWithSegmentControl:(id)sender{
	[self updateTimelineSegmentedControl];
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
	unread[1]=NO;
	unread[2]=NO;
	unread[3]=NO;
	for(int index=0;index< imageNames.count;index++){
		imageName =[imageNames objectAtIndex:index];
		if([timelineSegmentedControl isSelectedForSegment:index]){
			imageName = [imageName stringByAppendingString:@"_down"];
		}else {
			if (index<4&&unread[index]) {
				imageName=[imageName stringByAppendingString:@"_dot"];
			}
		}

		imageName = [imageName stringByAppendingString:@".png"];
		[timelineSegmentedControl setImage:[NSImage imageNamed:imageName] forSegment:index];
	}
	
}

-(IBAction)compose:(id)sender{
	[composeController popUp];
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

-(void)didUnread:(NSNotification*)notification{
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

@end
