//
//  HTMLController.m
//  Rainbow
//
//  Created by Luke on 9/6/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "HTMLController.h"


@implementation HTMLController
@synthesize webView,baseURL;
-(id) initWithWebView:(WebView*) webview{
	if(self=[super init]){
		self.webView=webview;
		NSString *pathMain = [[NSBundle mainBundle] pathForResource:@"statuses_page" ofType:@"html" inDirectory:@"themes/default"];
		mainTemplate = [[TKTemplate alloc] initWithTemplatePath:pathMain];
		NSString *pathTheme = [[NSBundle mainBundle] pathForResource:@"statues" ofType:@"html" inDirectory:@"themes/default"];
		timeLineTemplate = [[TKTemplate alloc] initWithTemplatePath:pathTheme];
		weiboAccount=[WeiboAccount instance];
		[weiboAccount.homeTimeline loadRecentHomeTimeline];
		NSString *basePath = [[NSString stringWithFormat:@"%@%@",[[NSBundle mainBundle] resourcePath],@"/themes/default"]retain];
		self.baseURL = [NSURL fileURLWithPath:basePath];
		[[webView mainFrame] loadHTMLString:[mainTemplate render:nil] baseURL:baseURL];
		
		//data received notification
		NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
		[nc addObserver:self selector:@selector(didAddRecentHomeTimeline:) 
				   name:FinishedLoadRecentHomeTimelineNotifaction 
				 object:nil];
	}
	return self;
}


-(void)didAddRecentHomeTimeline:(NSNotification *)notification{
	WeiboHomeTimeline *homeTimeline =[notification object];
	NSString *html = [timeLineTemplate render:[NSDictionary dictionaryWithObject:homeTimeline.statusArray 
																		  forKey:@"tweets"]];

	[self setDocumentElement:@"status" visibility:NO];
	[self setDocumentElement:@"home_time_line" innerHTML:html];

}

-(void)statusReceived:(NSArray *)status{
	
	NSLog(@"status received");
}
#pragma mark Select View
-(void) selectHomeTimeLine{

	[[webView mainFrame] loadHTMLString:[mainTemplate render:nil] baseURL:self.baseURL];
	[weiboAccount.homeTimeline loadRecentHomeTimeline];
}

-(void)selectMentions{

	[[webView mainFrame] loadHTMLString:[mainTemplate render:nil] baseURL:self.baseURL];
	[weiboAccount.homeTimeline loadRecentHomeTimeline];
}

-(void)postWithStatus:(NSString*)status{
	[weiboAccount updateWeiboWithStatus:status];
}
#pragma mark WebView JS 
- (NSString*) setDocumentElement:(NSString*)element visibility:(BOOL)visibility {
	NSString *value = visibility ? @"visible" : @"none";
	NSString *js = [NSString stringWithFormat: @"document.getElementById(\'%@\').style.display = \'%@\';", element, value];
	return [webView stringByEvaluatingJavaScriptFromString:js];
}

- (NSString*) setDocumentElement:(NSString*)element innerHTML:(NSString*)html {
	// Create a javascript-safe string.
	NSMutableData *safeData = [NSMutableData dataWithCapacity:html.length * 2];
	int length = html.length;
	unichar c;
	BOOL inWhitespace = NO;
	const unichar kDoubleQuote = 0x0022;
	const unichar kBackslash = 0x005C;
	const unichar kSpace = 0x0020;
	
	for (int index = 0; index < length; index++) {
		c = [html characterAtIndex:index];
		switch (c) {
			case '\\': // Backslash
				[safeData appendBytes:&kBackslash length:2];
				[safeData appendBytes:&kBackslash length:2];
				inWhitespace = NO;
				break;
			case '\"': // Double-quotes
				[safeData appendBytes:&kBackslash length:2];
				[safeData appendBytes:&kDoubleQuote length:2];
				inWhitespace = NO;
				break;
			case 0: case '\t': case '\r': case '\n': // Whitespace to coalesce.
				if (inWhitespace == NO) {
					[safeData appendBytes:&kSpace length:2];
					inWhitespace = YES;
				}
				break;
			default:
				[safeData appendBytes:&c length:2];
				inWhitespace = NO;
				break;
		}
	}
	
	NSString *jsSafe = [NSString stringWithCharacters:safeData.bytes length:safeData.length / 2];
	
	// Set the inner HTML to the string.
	NSString *js = [NSString stringWithFormat: @"document.getElementById(\"%@\").innerHTML = \"%@\";", element, jsSafe];
	return [webView stringByEvaluatingJavaScriptFromString:js];
}

- (void) scrollToTop {
	NSString *js = [NSString stringWithFormat: @"scroll(0,0);"];
	[webView stringByEvaluatingJavaScriptFromString:js];
}

-(void)dealloc{
	[webView release];
	[baseURL release];
	[super dealloc];
}
@end
