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

	}
	return self;
}

-(void) awakeFromNib{
	htmlController = [[HTMLController alloc] initWithWebView:webView];
	[self updateTimelineSegmentedControl];
}

-(IBAction)selectViewWithSegmentControl:(id)sender{
	[self updateTimelineSegmentedControl];
	int index=[sender selectedSegment];
	switch (index) {
		case 0:
			[self homeTimeLine];
			break;
		case 1:
			[self mentions];
		default:
			break;
	}
}

- (void)updateTimelineSegmentedControl{
	if(timelineSegmentedControl==nil){
		return;
	}
	NSArray *imageNames=[NSArray arrayWithObjects:@"home",@"mentions",@"comments",@"direct",@"star",@"user",nil];
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
	
	composeController=[[ComposeController alloc]init];
	[composeController showWindow:nil];
}

-(void)mentions{
	
	[htmlController selectMentions];
}

-(void)homeTimeLine{
	
	[htmlController selectHomeTimeLine];
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
	[self updateTimelineSegmentedControl];
}

@end
