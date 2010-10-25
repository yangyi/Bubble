//
//  HTMLController.m
//  Rainbow
//
//  Created by Luke on 9/6/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "HTMLController.h"

@implementation HTMLController
@synthesize webView,baseURL,weiboAccount;
-(id) initWithWebView:(WebView*) webview{
	if(self=[super init]){
		spinner=@"<img class='status_spinner_image' src='spinner.gif'> Loading...</div>";
		loadMore=@"<a href='weibo://load_older_home_timeline' target='_blank'>加载更多</a>";
		//data received notification
		NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
		[nc addObserver:self selector:@selector(didStartHTTPConnection:) 
				   name:HTTPConnectionStartNotification
				 object:nil];
		[nc addObserver:self selector:@selector(didFinishedHTTPConnection:) 
				   name:HTTPConnectionFinishedNotification
				 object:nil];
		
		[nc addObserver:self selector:@selector(didReloadHomeTimeline:) 
				   name:ReloadHomeTimelineNotification 
				 object:nil];
		[nc addObserver:self selector:@selector(startLoadOlderHomeTimeline:) 
				   name:StartLoadOlderHomeTimelineNotification 
				 object:nil];
		[nc addObserver:self selector:@selector(didLoadOlderHomeTimeline:) 
				   name:DidLoadOlderHomeTimelineNotification 
				 object:nil];
		[nc addObserver:self selector:@selector(didLoadNewerHomeTimeline:) 
				   name:DidLoadNewerHomeTimelineNotification 
				 object:nil];
		[nc addObserver:self selector:@selector(didClickHomeTimeline:)
				   name:HomeTimelineStatusClickNotification 
				 object:nil];
		
		
		self.webView=webview;
		[webView setFrameLoadDelegate:self];
		[webView setPolicyDelegate:self];
		engine = [[MGTemplateEngine templateEngine] retain];
		[engine setDelegate:self];
		[engine setMatcher:[ICUTemplateMatcher matcherWithTemplateEngine:engine]];
		//[engine setObject:@"luke" forKey:@"test"];
		NSString *testPath = [[NSBundle mainBundle] pathForResource:@"template" ofType:@"html" inDirectory:@"themes/default"];

		NSLog(@"%@",[engine processTemplate:@"{{ test }}" withVariables:[NSMutableDictionary dictionaryWithObject:@"Luke hello" forKey:@"test"]]);
		
		NSString *pathMain = [[NSBundle mainBundle] pathForResource:@"statuses_page" ofType:@"html" inDirectory:@"themes/default"];
		//homeTemplate = [[TKTemplate alloc] initWithTemplatePath:pathMain];
		NSString *pathTheme = [[NSBundle mainBundle] pathForResource:@"statuses" ofType:@"html" inDirectory:@"themes/default"];
		//statusesTemplate = [[TKTemplate alloc] initWithTemplatePath:pathTheme];
		weiboAccount=[WeiboAccount instance];
		NSString *basePath = [[NSString stringWithFormat:@"%@%@",[[NSBundle mainBundle] resourcePath],@"/themes/default"]retain];
		self.baseURL = [NSURL fileURLWithPath:basePath];
		NSDictionary *data=[NSDictionary dictionaryWithObject:spinner forKey:@"spinner"];
		//[[webView mainFrame] loadHTMLString:[homeTemplate render:data] baseURL:baseURL];
		NSLog(@"%@",[engine processTemplateInFileAtPath:pathMain withVariables:data]);
		[[webView mainFrame] loadHTMLString:[engine processTemplateInFileAtPath:pathMain withVariables:data] baseURL:baseURL];

		//下面不起作用的原因是，需要在webview的delegate中的webViewDidFinishLoad方法中写这个才有作用，因为执行到这里的时候webview还没加载好
		//[self setDocumentElement:@"html" innerHTML:spinner];
		//loadRecentHometimeline
		[weiboAccount.homeTimeline loadRecentHomeTimeline];
	
	}
	return self;
}


-(void)didReloadHomeTimeline:(NSNotification *)notification{
	/*WeiboHomeTimeline *homeTimeline =[notification object];
	NSMutableDictionary *data=[NSMutableDictionary dictionaryWithCapacity:0];
	[data setObject:homeTimeline.statusArray forKey:@"statuses"];
	[data setObject:[statusesTemplate render:data] forKey:@"old_statuses"];
	[[webView mainFrame] loadHTMLString:[homeTemplate render:data] baseURL:baseURL];
	 */
	[self reloadHomeTimeLine];
}


#pragma mark Select View
//选择home，未读状态设置为NO，将hometimeline中的statusArray渲染出来，设置lastReadStatusId为最新的status的id
-(void) reloadHomeTimeLine{
	weiboAccount.homeTimeline.unread=NO;
	NSMutableArray *homeStatuses=weiboAccount.homeTimeline.statusArray;
	NSMutableDictionary *data=[NSMutableDictionary dictionaryWithCapacity:0];
	//NSNumber *lastReadStatusId=weiboAccount.homeTimeline.lastReadStatusId;
	//NSLog(@"%@",lastReadStatusId);

	NSArray *oldStatuses=[homeStatuses filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.id<=%@",weiboAccount.homeTimeline.lastReadStatusId]];
	NSArray *newStatuses=[homeStatuses filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.id>%@",weiboAccount.homeTimeline.lastReadStatusId]];
	NSString *pathMain = [[NSBundle mainBundle] pathForResource:@"statuses_page" ofType:@"html" inDirectory:@"themes/default"];
	NSString *pathTheme = [[NSBundle mainBundle] pathForResource:@"statuses" ofType:@"html" inDirectory:@"themes/default"];
	if ([oldStatuses count]>0) {
		[data setObject:oldStatuses forKey:@"statuses"];
		//[data setObject:[statusesTemplate render:data] forKey:@"old_statuses"];
		NSString *result=[engine processTemplateInFileAtPath:pathTheme withVariables:data];
		[data setObject:[engine processTemplateInFileAtPath:pathTheme withVariables:data] forKey:@"old_statuses"];
	}
	if ([newStatuses count]>0) {
		[data setObject:newStatuses forKey:@"statuses"];
		//[data setObject:[statusesTemplate render:data] forKey:@"new_statuses"];
		[data setObject:[engine processTemplateInFileAtPath:pathTheme withVariables:data] forKey:@"new_statuses"];
	}
	[data setObject:loadMore forKey:@"load_more"];
	
	//[[webView mainFrame] loadHTMLString:[homeTemplate render:data] baseURL:baseURL];
	[[webView mainFrame] loadHTMLString:[engine processTemplateInFileAtPath:pathMain withVariables:data] baseURL:baseURL];

}

-(void)selectMentions{
    weiboAccount.homeTimeline.selected=NO;

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

-(void)didStartHTTPConnection:(NSNotification*)notification{
}

-(void)didFinishedHTTPConnection:(NSNotification*)notification{
	[self setDocumentElement:@"spinner" visibility:NO];
}

//called when the frame finishes loading
- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)webFrame
{
    if([webFrame isEqual:[webView mainFrame]])
    {
		if (weiboAccount.homeTimeline.selected) {
			//[webView stringByEvaluatingJavaScriptFromString:
			 //[NSString stringWithFormat:@"scroll(0,%d);",weiboAccount.homeTimeline.scrollPosition]];
			 NSScrollView *scrollView = [[[[webView mainFrame] frameView] documentView] enclosingScrollView];	
			 [[scrollView documentView] scrollPoint:weiboAccount.homeTimeline.scrollPosition];
		}
    }
}

 
- (void)webView:(WebView *)webView decidePolicyForNewWindowAction:(NSDictionary *)actionInformation
		request:(NSURLRequest *)request
   newFrameName:(NSString *)frameName
decisionListener:(id<WebPolicyDecisionListener>)listener{
    
	[[NSWorkspace sharedWorkspace] openURL:[request URL]]; 
}

-(void)startLoadOlderHomeTimeline:(NSNotification*)notification{
	//weiboAccount.homeTimeline.scrollPosition=[[webView stringByEvaluatingJavaScriptFromString:@"window.pageYOffset"] intValue];
	
	NSScrollView *scrollView = [[[[webView mainFrame] frameView] documentView] enclosingScrollView];
	// get the current scroll position of the document view
	NSRect scrollViewBounds = [[scrollView contentView] bounds];
	weiboAccount.homeTimeline.scrollPosition=scrollViewBounds.origin; // keep track of position to restore
	
	[self setDocumentElement:@"spinner" innerHTML:spinner];
}

-(void)didLoadOlderHomeTimeline:(NSNotification*)notification{
	NSMutableDictionary *data=[NSMutableDictionary dictionaryWithCapacity:0];
	NSArray *statuses=[notification object];
	[data setObject:statuses forKey:@"statuses"];
	//NSString *older=[statusesTemplate render:data];
	NSString *pathTheme = [[NSBundle mainBundle] pathForResource:@"statuses" ofType:@"html" inDirectory:@"themes/default"];
	NSString *older=[engine processTemplateInFileAtPath:pathTheme withVariables:data];
	DOMDocument *dom=[[webView mainFrame] DOMDocument];
	DOMHTMLElement *oldStatus=(DOMHTMLElement *)[dom getElementById:@"status_old"];
	[oldStatus setInnerHTML:[NSString stringWithFormat:@"%@%@",[oldStatus innerHTML],older]];
}

-(void)didLoadNewerHomeTimeline:(NSNotification*)notification{
	NSMutableDictionary *data=[NSMutableDictionary dictionaryWithCapacity:0];
	NSArray *statuses=[notification object];
	[data setObject:statuses forKey:@"statuses"];
	//NSString *newStatuses=[statusesTemplate render:data];
	NSString *pathTheme = [[NSBundle mainBundle] pathForResource:@"statuses" ofType:@"html" inDirectory:@"themes/default"];
	NSString *newStatuses=[engine processTemplateInFileAtPath:pathTheme withVariables:data];
	DOMDocument *dom=[[webView mainFrame] DOMDocument];
	DOMHTMLElement *newStatusElement=(DOMHTMLElement *)[dom getElementById:@"status_new"];
	[newStatusElement setInnerHTML:[NSString stringWithFormat:@"%@%@",newStatuses,[newStatusElement innerHTML]]];
}

-(void)didClickHomeTimeline:(NSNotification*)notification{
	NSString *statusId=[notification object];
	weiboAccount.homeTimeline.lastReadStatusId=[NSNumber numberWithLongLong:[statusId longLongValue]];
	[self reloadHomeTimeLine];
}



// ****************************************************************
// 
// Methods below are all optional MGTemplateEngineDelegate methods.
// 
// ****************************************************************


- (void)templateEngine:(MGTemplateEngine *)engine blockStarted:(NSDictionary *)blockInfo
{
	//NSLog(@"Started block %@", [blockInfo objectForKey:BLOCK_NAME_KEY]);
}


- (void)templateEngine:(MGTemplateEngine *)engine blockEnded:(NSDictionary *)blockInfo
{
	//NSLog(@"Ended block %@", [blockInfo objectForKey:BLOCK_NAME_KEY]);
}


- (void)templateEngineFinishedProcessingTemplate:(MGTemplateEngine *)engine
{
	//NSLog(@"Finished processing template.");
}


- (void)templateEngine:(MGTemplateEngine *)engine encounteredError:(NSError *)error isContinuing:(BOOL)continuing;
{
	NSLog(@"Template error: %@", error);
}


@end
