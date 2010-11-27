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
	
	//composeController=[[ComposeController alloc]init];
	//[composeController showWindow:nil];
	
	NSRect	rect;
    rect = [sender convertRect:[sender bounds] toView:nil];
    rect.origin = [[sender window] convertBaseToScreen:rect.origin];
	if ([[composeController window] isVisible]) {
		[[composeController window] zoomOffToRect:rect];
	}else {
		NSWindow * window=[composeController window];
		[window zoomOnFromRect:rect];
	}

	
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
	//CGEventRef ourEvent = CGEventCreate(NULL);
	//CGPoint point = CGEventGetLocation(ourEvent);
	
	NSString *url =[notification object];
	NSRect	rect;
	NSPoint mouseLoc;
	mouseLoc = [NSEvent mouseLocation];
	
	//rect.origin=*(NSPoint *)&point;
	rect.origin=mouseLoc;
	rect.size.width=1;
	rect.size.height=1;
	NSLog(@"Location? x= %f, y = %f", (float)rect.origin.x, (float)rect.origin.y);
	NSWindow * window=[imagePanelController window];
	[window zoomOnFromRect:rect];
	
	//[imagePanelController showWindow:self];
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
