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
	[[webView mainFrame] loadHTMLString:@"Luke" baseURL:nil];
}
@end
