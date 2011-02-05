//
//  HTMLController.m
//  Rainbow
//
//  Created by Luke on 9/6/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "HTMLController.h"

@implementation HTMLController
@synthesize webView,baseURL,weiboAccount,statusesPageTemplatePath,statusesTemplatePath,userTemplatePath,userlistTemplatePath,statusDetailTemplatePath,commentsTemplatePath,messagePageTemplatePath,messageTemplatePath,imageView;
-(id) initWithWebView:(WebView*) webview{
	if(self=[super init]){
		spinner=@"<img class='status_spinner_image' src='spinner.gif'> Loading...</div>";
		loadMore=@"<a href='weibo://load_older_home_timeline' target='_blank'>Load More</a>";
		//data received notification
		NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
		[nc addObserver:self selector:@selector(showLoadingPage:) 
				   name:ShowLoadingPageNotification
				 object:nil];
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
		[nc addObserver:self selector:@selector(didGetFriends:)
				   name:DidGetFriendsNotification 
				 object:nil];
		[nc addObserver:self selector:@selector(didSelectAccount:) 
				   name:DidSelectAccountNotification 
				 object:nil];
		[nc addObserver:self selector:@selector(didSaveScrollPosition:) 
				   name:SaveScrollPositionNotification 
				 object:nil];
		
		[nc addObserver:self selector:@selector(didShowStatus:) 
				   name:DidShowStatusNotification 
				 object:nil];
		[nc addObserver:self selector:@selector(didGetStatusComments:) 
				   name:DidGetStatusCommentsNotification 
				 object:nil];
		
		[nc addObserver:self selector:@selector(didGetDirectMessage:) 
				   name:DidGetDirectMessageNotification 
				 object:nil];
		self.webView=webview;
		[webView setFrameLoadDelegate:self];
		[webView setPolicyDelegate:self];

		templateEngine=[[TemplateEngine alloc] init];
		
		
		self.statusesPageTemplatePath = [[NSBundle mainBundle] pathForResource:@"status_stream" 
																   ofType:@"html" 
															  inDirectory:@"themes/default"];
		self.statusesTemplatePath = [[NSBundle mainBundle] pathForResource:@"status_item" 
															   ofType:@"html" 
														  inDirectory:@"themes/default"];
		self.userTemplatePath=[[NSBundle mainBundle] pathForResource:@"user" 
															  ofType:@"html" 
														 inDirectory:@"themes/default"];
		self.userlistTemplatePath=[[NSBundle mainBundle] pathForResource:@"userlist" 
																  ofType:@"html" 
															 inDirectory:@"themes/default"];
		self.statusDetailTemplatePath=[[NSBundle mainBundle] pathForResource:@"statuses_detail" 
																  ofType:@"html" 
															 inDirectory:@"themes/default"];

		self.commentsTemplatePath=[[NSBundle mainBundle] pathForResource:@"comments" 
																	  ofType:@"html" 
																 inDirectory:@"themes/default"];
		
		self.messagePageTemplatePath=[[NSBundle mainBundle] pathForResource:@"message_page" 
																  ofType:@"html" 
															 inDirectory:@"themes/default"];
		
		self.messageTemplatePath=[[NSBundle mainBundle] pathForResource:@"messages" 
																  ofType:@"html" 
															 inDirectory:@"themes/default"];
		weiboAccount=[AccountController instance];
		NSString *basePath = [[NSString stringWithFormat:@"%@%@",[[NSBundle mainBundle] resourcePath],@"/themes/default"]retain];
		self.baseURL = [NSURL fileURLWithPath:basePath];

		//下面不起作用的原因是，需要在webview的delegate中的webViewDidFinishLoad方法中写这个才有作用，因为执行到这里的时候webview还没加载好
		//[self setDocumentElement:@"html" innerHTML:spinner];
		//loadRecentHometimeline
		currentTimeline=weiboAccount.homeTimeline;
		
		//scroll 事件
		NSScrollView *scrollView = [[[[webView mainFrame] frameView] documentView] enclosingScrollView];
		[[scrollView contentView] setPostsBoundsChangedNotifications:YES];
		[nc addObserver:self
			   selector:@selector(webviewContentBoundsDidChange:) name:NSViewBoundsDidChangeNotification object:[scrollView contentView]];
	
	}
	return self;
}


-(void)webviewContentBoundsDidChange:(NSNotification *)notification{
	NSScrollView *scrollView = [[[[webView mainFrame] frameView] documentView] enclosingScrollView];
	if ([[scrollView contentView] bounds].origin.y==0) {
		if (currentTimeline.operation==None) {
			//这个地方是有问题的，当从另外一个tab切回来的时候，也会触发这里
			currentTimeline.unread=NO;
			[[NSNotificationCenter defaultCenter] postNotificationName:UpdateTimelineSegmentedControlNotification object:nil];
		}

	}
}
//当页面点击加载更多的时候接受到这个通知，进行加载历史信息
-(void)startLoadOlderTimeline:(NSNotification*)notification{
	//开始加载历史信息的时候显示等待的图标
	//[self setDocumentElement:@"spinner" innerHTML:spinner];
	DOMDocument *dom=[[webView mainFrame] DOMDocument];
	DOMHTMLElement *spinnerEle=(DOMHTMLElement *)[dom getElementById:@"spinner"];
	[spinnerEle setInnerHTML:spinner];
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
	currentTimeline.operation=Reload;
	[self reloadTimeline];
}

-(void)didSaveScrollPosition:(NSNotification *)notification{
	[self saveScrollPosition];
}

-(void)saveScrollPosition{
	//记录当前的scroll的位置
	NSScrollView *scrollView = [[[[webView mainFrame] frameView] documentView] enclosingScrollView];
	// get the current scroll position of the document view
	NSRect scrollViewBounds = [[scrollView contentView] bounds];
	//currentTimeline.scrollPosition=scrollViewBounds.origin; // keep track of position to restore
	DOMElement *element=[[[webView mainFrame] DOMDocument] elementFromPoint:4 y:0];
	if ([[element getAttribute:@"class"] isNotEqualTo:@"status"]) {
		element=[[[webView mainFrame] DOMDocument] elementFromPoint:4 y:8];
	}
	NSString *itemId=[element getAttribute:@"id"];
	NSInteger relativeOffset=scrollViewBounds.origin.y-[element offsetTop];
	NSDictionary *scrollPosition=[NSDictionary dictionaryWithObjectsAndKeys:itemId,@"itemId",
								  [NSNumber numberWithInt:relativeOffset],@"relativeOffset",nil];
	[[NSUserDefaults standardUserDefaults] setValue:scrollPosition forKey:[NSString stringWithFormat:@"statuses/%@/%@.scrollPosition",[[AccountController instance] currentAccount].username,currentTimeline.typeName]];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)resumeScrollPosition{
	NSScrollView *scrollView = [[[[webView mainFrame] frameView] documentView] enclosingScrollView];	
	NSDictionary *scrollPosiotion=[[NSUserDefaults standardUserDefaults] valueForKey:[NSString stringWithFormat:@"statuses/%@/%@.scrollPosition",[[AccountController instance] currentAccount].username,currentTimeline.typeName]];
	NSString *itemId=[scrollPosiotion valueForKey:@"itemId"];
	NSNumber *relativeOffset=[scrollPosiotion valueForKey:@"relativeOffset"];
	DOMElement* element=[[[webView mainFrame] DOMDocument] getElementById:itemId];
	int y=[element offsetTop]+[relativeOffset intValue];
	[[scrollView documentView] scrollPoint:NSMakePoint(0, y)];
}

#pragma mark Select View
//选择home，未读状态设置为NO，将hometimeline中的statusArray渲染出来，设置lastReadStatusId为最新的status的id
-(void) reloadTimeline{
	
	NSImage* image;
	NSBitmapImageRep* rep;
	[webView lockFocus];
	rep = [[NSBitmapImageRep alloc] initWithFocusedViewRect:[webView bounds]];
	[webView unlockFocus];
	image = [[[NSImage alloc] initWithSize:NSZeroSize] autorelease];
	[image addRepresentation:rep];
	[rep release];
	
	[imageView setImage: image];
	
	[webView setHidden:YES];
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
	if (!currentTimeline.firstReload) {
		[self saveScrollPosition];
	}else {
		currentTimeline.firstReload=NO;
	}

	
	//////////////
	NSMutableDictionary *data=[NSMutableDictionary dictionaryWithCapacity:0];

	[data setObject:[templateEngine renderTemplateFileAtPath:statusesTemplatePath withContext:[NSDictionary dictionaryWithObject:currentTimeline.data forKey:@"statuses"]] 
				 forKey:@"statuses"];
	[data setObject:loadMore forKey:@"load_more"];
	
	//[[webView mainFrame] loadHTMLString:[homeTemplate render:data] baseURL:baseURL];
	[[webView mainFrame] loadHTMLString:[templateEngine renderTemplateFileAtPath:statusesPageTemplatePath withContext:data] 
								baseURL:baseURL];

}

-(void)selectMentions{
	currentTimeline.firstReload=YES;
	currentTimeline.operation=Switch;
	[self saveScrollPosition];
    currentTimeline = weiboAccount.mentions;
	[self reloadTimeline];

}

-(void)selectComments{
	currentTimeline.firstReload=YES;
	[self saveScrollPosition];
	currentTimeline=weiboAccount.comments;
	[self reloadTimeline];
}
-(void)selectHome{
	currentTimeline.firstReload=YES;
	currentTimeline.operation=Switch;
	[self saveScrollPosition];
	currentTimeline = weiboAccount.homeTimeline;
	[self reloadTimeline];
}

-(void)selectFavorites{
	currentTimeline.firstReload=YES;
	[self saveScrollPosition];
	currentTimeline = weiboAccount.favorites;
	[self loadTimelineWithPage];
}

-(void)selectDirectMessage{
	[weiboAccount getDirectMessage];
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
	//[self setDocumentElement:@"spinner" visibility:NO];

}

//called when the frame finishes loading
- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)webFrame
{
    if([webFrame isEqual:[webView mainFrame]])
    {
		[self resumeScrollPosition];
		//NSRect oriRect=[webView frame];
		//NSRect initFrame=NSMakeRect(oriRect.origin.x+oriRect.size.width, oriRect.origin.y, oriRect.size.width, oriRect.size.height);
		//if (currentTimeline.operation==Switch) {
		//	[webView setFrame:initFrame];
		//	[webView setHidden:NO];
		//	[NSAnimationContext beginGrouping];
		//	[[NSAnimationContext currentContext] setDuration:0.18f]; // However long you want the slide to take
			
		//	[[webView animator] setFrame:oriRect];
			
		//	[NSAnimationContext endGrouping];
		//}else {
			[webView setHidden:NO];
		//}
		currentTimeline.operation=None;
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
		DOMHTMLElement *oldStatusElement=(DOMHTMLElement *)[dom getElementById:@"statuses"];
		[oldStatusElement setInnerHTML:[NSString stringWithFormat:@"%@%@",[oldStatusElement innerHTML],olderStatuses]];		
	}
	
	
	DOMDocument *dom=[[webView mainFrame] DOMDocument];
	DOMHTMLElement *spinnerEle=(DOMHTMLElement *)[dom getElementById:@"spinner"];
	[spinnerEle setInnerHTML:loadMore];
}

-(void)didLoadNewerTimeline:(NSNotification*)notification{
	WeiboTimeline *sender=(WeiboTimeline*)[notification object];
	if (currentTimeline==sender) {
		[self saveScrollPosition];
		NSMutableDictionary *data=[NSMutableDictionary dictionaryWithCapacity:0];
		NSArray *statuses=sender.newData;
		[data setObject:statuses forKey:@"statuses"];
		NSString *newStatuses=[templateEngine renderTemplateFileAtPath:statusesTemplatePath withContext:data];
		DOMDocument *dom=[[webView mainFrame] DOMDocument];
		DOMHTMLElement *statusElement=(DOMHTMLElement *)[dom getElementById:@"statuses"];
		[statusElement setInnerHTML:[NSString stringWithFormat:@"%@%@",newStatuses,[statusElement innerHTML]]];
		[self resumeScrollPosition];
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
	//NSString *statusId=[notification object];
	//currentTimeline.lastReadId=[NSNumber numberWithLongLong:[statusId longLongValue]];
	[self reloadTimeline];
}

-(void)didGetUser:(NSNotification*)notification{
	NSMutableDictionary *data=[NSMutableDictionary dictionaryWithCapacity:0];
	[data setObject:[notification object] forKey:@"user"];
	[[webView mainFrame] loadHTMLString:[templateEngine renderTemplateFileAtPath:userTemplatePath withContext:data] 
								baseURL:baseURL];
}


-(void)didGetFriends:(NSNotification*)notification{
	NSMutableDictionary *data=[NSMutableDictionary dictionaryWithCapacity:0];
	[data setObject:[notification object] forKey:@"users"];
	[[webView mainFrame] loadHTMLString:[templateEngine renderTemplateFileAtPath:userlistTemplatePath withContext:data] 
								baseURL:baseURL];
}


-(void)didGetStatusComments:(NSNotification*)notification{
	NSMutableDictionary *data=[NSMutableDictionary dictionaryWithCapacity:0];
	[data setObject:[notification object] forKey:@"comments"];
	NSString *commentsString=[templateEngine renderTemplateFileAtPath:commentsTemplatePath withContext:data];
	DOMDocument *dom=[[webView mainFrame] DOMDocument];
	DOMHTMLElement *commentsElement=(DOMHTMLElement *)[dom getElementById:@"comments"];
	DOMHTMLElement *spinnerElement=(DOMHTMLElement *)[dom getElementById:@"spinner"];

	[commentsElement setInnerHTML:commentsString];
	[spinnerElement setInnerHTML:@""];
}

-(void)didSelectAccount:(NSNotification*)notification{
	//切换用户，所有的timeline都进行初始化
	[self loadRecentTimeline];
}


-(void)didShowStatus:(NSNotification*)notification{
	NSDictionary *status=[notification object];
	NSMutableDictionary *data=[NSMutableDictionary dictionaryWithCapacity:0];
	[data setObject:status   forKey:@"status"];
	[data setObject:spinner forKey:@"spinner"];
	[[webView mainFrame] loadHTMLString:[templateEngine renderTemplateFileAtPath:statusDetailTemplatePath withContext:data] 
								baseURL:baseURL];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:GetStatusCommentsNotification 
														object:[NSString stringWithFormat:@"%@",[status objectForKey:@"id"]]];

}

-(void)didGetDirectMessage:(NSNotification*)notification{
	NSMutableDictionary *data=[NSMutableDictionary dictionaryWithCapacity:0];
	[data setObject:[notification object] forKey:@"messages"];
	NSString *messagesString=[templateEngine renderTemplateFileAtPath:messageTemplatePath withContext:data];
	[data setObject:messagesString forKey:@"messages_html"];
	NSString *messagePage = [templateEngine renderTemplateFileAtPath:messagePageTemplatePath withContext:data];
	[[webView mainFrame] loadHTMLString:messagePage baseURL:baseURL];
}

-(void)showLoadingPage:(NSNotification*)notification{
	NSString *loading=@"<html><head><link href='style.css' rel='styleSheet' type='text/css' /></head><body><div class='spinner'><img class='status_spinner_image' src='spinner.gif'> Loading...</div></div></body></html>";
	[[webView mainFrame] loadHTMLString:loading baseURL:baseURL];
}
@end
