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
	//NSString *result =[templateEngine processTemplate:templatePath withVariables:variables];
	htmlController = [[HTMLController alloc] initWithWebView:webView];
	//[weibo makeRequrst:nil];
}

-(IBAction)selectViewWithSegmentControl:(id)sender{
	
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
