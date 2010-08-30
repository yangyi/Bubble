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
	NSString *path = [[NSBundle mainBundle] pathForResource:@"template" ofType:@"html"];
	//[[NSBundle mainBundle] pathForResource:@"tpl.htm" ofType:@"html" inDirectory:@"books/CD_en/icon"];
	htmlTemplate = [[TKTemplate alloc] initWithTemplatePath:path];
	weibo=[[Weibo alloc]init];
	return self;
}

-(void) awakeFromNib{
	//NSString *result =[templateEngine processTemplate:templatePath withVariables:variables];
	NSString *html = [htmlTemplate render:[NSDictionary dictionaryWithObject:@"Luke is a good boy!" forKey:@"luke"]];
	NSString *basePath = [[NSBundle mainBundle] resourcePath];
	NSURL *baseURL = [NSURL fileURLWithPath:basePath];
	[[webView mainFrame] loadHTMLString:html baseURL:baseURL];
	[weibo makeRequrst:nil];
}
@end
