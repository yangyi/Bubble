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
	self = [super initWithWindowNibName:@"MainWindow"];
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
	for(int index=0;index< imageNames.count;index++){
		imageName =[imageNames objectAtIndex:index];
		if([timelineSegmentedControl isSelectedForSegment:index]){
			imageName = [imageName stringByAppendingString:@"_down"];
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
@end
