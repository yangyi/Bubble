//
//  HTMLController.m
//  Rainbow
//
//  Created by Luke on 9/6/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "HTMLController.h"

@implementation HTMLController
@synthesize webView,baseURL,weiboAccount,statusesPageTemplatePath,statusesTemplatePath,userTemplatePath;
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
		
		[nc addObserver:self selector:@selector(didReloadTimeline:) 
				   name:ReloadTimelineNotification 
				 object:nil];
		[nc addObserver:self selector:@selector(startLoadOlderTimeline:) 
				   name:StartLoadOlderTimelineNotification 
				 object:nil];
		[nc addObserver:self selector:@selector(didLoadOlderTimeline:) 
				   name:DidLoadOlderTimelineNotification 
				 object:nil];
		[nc addObserver:self selector:@selector(didLoadNewerTimeline:) 
				   name:DidLoadNewerTimelineNotification 
				 object:nil];
		[nc addObserver:self selector:@selector(didLoadTimelineWithPage:) 
				   name:DidLoadTimelineWithPageNotification 
				 object:nil];
		
		[nc addObserver:self selector:@selector(didClickTimeline:)
				   name:DidClickTimelineNotification 
				 object:nil];
		[nc addObserver:self selector:@selector(didGetUser:)
				   name:DidGetUserNotification 
				 object:nil];
		
		self.webView=webview;
		[webView setFrameLoadDelegate:self];
		[webView setPolicyDelegate:self];

		templateEngine=[[TemplateEngine alloc] init];
		
		
		self.statusesPageTemplatePath = [[NSBundle mainBundle] pathForResource:@"statuses_page" 
																   ofType:@"html" 
															  inDirectory:@"themes/default"];
		self.statusesTemplatePath = [[NSBundle mainBundle] pathForResource:@"statuses" 
															   ofType:@"html" 
														  inDirectory:@"themes/default"];
		self.userTemplatePath=[[NSBundle mainBundle] pathForResource:@"user" 
															  ofType:@"html" 
														 inDirectory:@"themes/default"];
		

		weiboAccount=[WeiboAccount instance];
		NSString *basePath = [[NSString stringWithFormat:@"%@%@",[[NSBundle mainBundle] resourcePath],@"/themes/default"]retain];
		self.baseURL = [NSURL fileURLWithPath:basePath];

		//下面不起作用的原因是，需要在webview的delegate中的webViewDidFinishLoad方法中写这个才有作用，因为执行到这里的时候webview还没加载好
		//[self setDocumentElement:@"html" innerHTML:spinner];
		//loadRecentHometimeline
		currentTimeline=weiboAccount.homeTimeline;
	
	}
	return self;
}

//当页面点击加载更多的时候接受到这个通知，进行加载历史信息
-(void)startLoadOlderTimeline:(NSNotification*)notification{
	//开始加载历史信息的时候显示等待的图标
	[self setDocumentElement:@"spinner" innerHTML:spinner];
	[currentTimeline loadOlderTimeline];
}

-(void)loadRecentTimeline{
	NSDictionary *data=[NSDictionary dictionaryWithObject:spinner forKey:@"spinner"];
	[[webView mainFrame] loadHTMLString:[templateEngine renderTemplateFileAtPath:statusesPageTemplatePath withContext:data] 
								baseURL:baseURL];
	[currentTimeline loadRecentTimeline];
}

-(void)loadTimelineWithPage{
	NSDictionary *data=[NSDictionary dictionaryWithObject:spinner forKey:@"spinner"];
	[[webView mainFrame] loadHTMLString:[templateEngine renderTemplateFileAtPath:statusesPageTemplatePath withContext:data] 
								baseURL:baseURL];
	[currentTimeline loadTimelineWithPage:@"1"];
}

-(void)didReloadTimeline:(NSNotification *)notification{
	/*WeiboHomeTimeline *homeTimeline =[notification object];
	NSMutableDictionary *data=[NSMutableDictionary dictionaryWithCapacity:0];
	[data setObject:homeTimeline.statusArray forKey:@"statuses"];
	[data setObject:[statusesTemplate render:data] forKey:@"old_statuses"];
	[[webView mainFrame] loadHTMLString:[homeTemplate render:data] baseURL:baseURL];
	 */
	[self reloadTimeline];
}


#pragma mark Select View
//选择home，未读状态设置为NO，将hometimeline中的statusArray渲染出来，设置lastReadStatusId为最新的status的id
-(void) reloadTimeline{
	if (currentTimeline.data==nil) {
		switch (currentTimeline.timelineType) {
			case Home:
			case Comments:
			case Mentions:
				[self loadRecentTimeline];
				break;
			case Favorites:
				[self loadTimelineWithPage];
				break;
			default:
				break;
		}
		return;
	}
	NSMutableDictionary *data=[NSMutableDictionary dictionaryWithCapacity:0];
	//NSNumber *lastReadStatusId=weiboAccount.homeTimeline.lastReadStatusId;
	//NSLog(@"%@",lastReadStatusId);
	NSArray *oldStatuses=[currentTimeline.data filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.id<=%@",currentTimeline.lastReadId]];
	NSArray *newStatuses=[currentTimeline.data filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.id>%@",currentTimeline.lastReadId]];
	if ([oldStatuses count]>0) {
		[data setObject:oldStatuses forKey:@"statuses"];
		//[data setObject:[statusesTemplate render:data] forKey:@"old_statuses"];
		[data setObject:[templateEngine renderTemplateFileAtPath:statusesTemplatePath withContext:data]
				 forKey:@"old_statuses"];
	}
	if ([newStatuses count]>0) {
		[data setObject:newStatuses forKey:@"statuses"];
		[data setObject:@"new" forKey:@"new"];
		//[data setObject:[statusesTemplate render:data] forKey:@"new_statuses"];
		[data setObject:[templateEngine renderTemplateFileAtPath:statusesTemplatePath withContext:data] 
				 forKey:@"new_statuses"];
	}
	[data setObject:loadMore forKey:@"load_more"];
	
	//[[webView mainFrame] loadHTMLString:[homeTemplate render:data] baseURL:baseURL];
	[[webView mainFrame] loadHTMLString:[templateEngine renderTemplateFileAtPath:statusesPageTemplatePath withContext:data] 
								baseURL:baseURL];

}

-(void)selectMentions{
    currentTimeline = weiboAccount.mentions;
	[self reloadTimeline];

}

-(void)selectComments{
	currentTimeline=weiboAccount.comments;
	[self reloadTimeline];
}
-(void)selectHome{
	currentTimeline = weiboAccount.homeTimeline;
	[self reloadTimeline];
}

-(void)selectFavorites{
	currentTimeline = weiboAccount.favorites;
	[self reloadTimeline];
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
		NSScrollView *scrollView = [[[[webView mainFrame] frameView] documentView] enclosingScrollView];	
		[[scrollView documentView] scrollPoint:currentTimeline.scrollPosition];

    }
	 
}

 
- (void)webView:(WebView *)webView decidePolicyForNewWindowAction:(NSDictionary *)actionInformation
		request:(NSURLRequest *)request
   newFrameName:(NSString *)frameName
decisionListener:(id<WebPolicyDecisionListener>)listener{
    
	[[NSWorkspace sharedWorkspace] openURL:[request URL]]; 
}


-(void)didLoadOlderTimeline:(NSNotification*)notification{
	WeiboTimeline *sender=(WeiboTimeline *)[notification object];
	if (currentTimeline==sender) {
		NSMutableDictionary *data=[NSMutableDictionary dictionaryWithCapacity:0];
		NSArray *statuses=sender.newData;
		[data setObject:statuses forKey:@"statuses"];
		NSString *olderStatuses=[templateEngine renderTemplateFileAtPath:statusesTemplatePath withContext:data];
		DOMDocument *dom=[[webView mainFrame] DOMDocument];
		DOMHTMLElement *oldStatusElement=(DOMHTMLElement *)[dom getElementById:@"status_old"];
		[oldStatusElement setInnerHTML:[NSString stringWithFormat:@"%@%@",[oldStatusElement innerHTML],olderStatuses]];		
	}
}

-(void)didLoadNewerTimeline:(NSNotification*)notification{
	WeiboTimeline *sender=(WeiboTimeline*)[notification object];
	if (currentTimeline==sender) {
		NSMutableDictionary *data=[NSMutableDictionary dictionaryWithCapacity:0];
		NSArray *statuses=sender.newData;
		[data setObject:statuses forKey:@"statuses"];
		[data setObject:@"new" forKey:@"new"];
		NSString *newStatuses=[templateEngine renderTemplateFileAtPath:statusesTemplatePath withContext:data];
		DOMDocument *dom=[[webView mainFrame] DOMDocument];
		DOMHTMLElement *newStatusElement=(DOMHTMLElement *)[dom getElementById:@"status_new"];
		[newStatusElement setInnerHTML:[NSString stringWithFormat:@"%@%@",newStatuses,[newStatusElement innerHTML]]];
	}else {
		[[NSNotificationCenter defaultCenter] postNotificationName:UnreadNotification object:nil];
	}
	[[NSNotificationCenter defaultCenter] postNotificationName:@"GrowlNotification" object:nil];

}

-(void)didLoadTimelineWithPage:(NSNotification*)notification{
	WeiboTimeline *sender=(WeiboTimeline*)[notification object];
	if (currentTimeline==sender) {
		NSMutableDictionary *data=[NSMutableDictionary dictionaryWithCapacity:0];
		NSArray *statuses=sender.newData;
		[data setObject:statuses forKey:@"statuses"];
		NSString *olderStatuses=[templateEngine renderTemplateFileAtPath:statusesTemplatePath withContext:data];
		DOMDocument *dom=[[webView mainFrame] DOMDocument];
		DOMHTMLElement *oldStatusElement=(DOMHTMLElement *)[dom getElementById:@"status_old"];
		[oldStatusElement setInnerHTML:[NSString stringWithFormat:@"%@%@",[oldStatusElement innerHTML],olderStatuses]];		
		
	}
}

-(void)didClickTimeline:(NSNotification*)notification{
	NSScrollView *scrollView = [[[[webView mainFrame] frameView] documentView] enclosingScrollView];
	// get the current scroll position of the document view
	NSRect scrollViewBounds = [[scrollView contentView] bounds];
	currentTimeline.scrollPosition=scrollViewBounds.origin; // keep track of position to restore
	
	NSString *statusId=[notification object];
	currentTimeline.lastReadId=[NSNumber numberWithLongLong:[statusId longLongValue]];
	[self reloadTimeline];
}

-(void)didGetUser:(NSNotification*)notification{
	NSMutableDictionary *data=[NSMutableDictionary dictionaryWithCapacity:0];
	[data setObject:[notification object] forKey:@"user"];
	[[webView mainFrame] loadHTMLString:[templateEngine renderTemplateFileAtPath:userTemplatePath withContext:data] 
								baseURL:baseURL];
}
@end
