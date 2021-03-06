//
//  HTMLController.m
//  Rainbow
//
//  Created by Luke on 9/6/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "HTMLController.h"

@implementation HTMLController

@synthesize webView,baseURL,weiboAccount,mainPagePath,statusesPageTemplatePath,statusesTemplatePath,userTemplatePath,userlistTemplatePath,useritemTemplatePath,statusDetailTemplatePath,commentsTemplatePath,messagePageTemplatePath,messageTemplatePath,messageSentTemplatePath;

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
		
		[nc addObserver:self selector:@selector(didGetFollowers:)
				   name:DidGetFollowersNotification 
				 object:nil];
		[nc addObserver:self selector:@selector(didSaveScrollPosition:) 
				   name:SaveScrollPositionNotification 
				 object:nil];
		
		[nc addObserver:self selector:@selector(didShowStatus:) 
				   name:DidShowStatusNotification 
				 object:nil];
		[nc addObserver:self selector:@selector(setWaitingForComments:)
				   name:GetStatusCommentsNotification 
				 object:nil];
		[nc addObserver:self selector:@selector(didGetStatusComments:) 
				   name:DidGetStatusCommentsNotification 
				 object:nil];
		[nc addObserver:self selector:@selector(didGetMessageSent:)
				   name:DidGetMessageSentNotification 
				 object:nil];
		
		[nc addObserver:self selector:@selector(didGetDirectMessage:) 
				   name:DidGetDirectMessageNotification 
				 object:nil];
		[nc addObserver:self selector:@selector(showTip:) 
				   name:ShowTipMessageNotification 
				 object:nil];

		[nc addObserver:self selector:@selector(didGetUserTimeline:) 
				   name:DidGetUserTimelineNotification 
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
		self.messageSentTemplatePath=[[NSBundle mainBundle] pathForResource:@"message_sent" 
																	 ofType:@"html" 
																inDirectory:@"themes/default"];
		self.useritemTemplatePath=[[NSBundle mainBundle] pathForResource:@"useritem" 
																 ofType:@"html" 
															inDirectory:@"themes/default"];
		self.mainPagePath=[[NSBundle mainBundle] pathForResource:@"main" 
														  ofType:@"html" 
													 inDirectory:@"themes/default"];
		weiboAccount=[AccountController instance];
		NSString *basePath = [[NSString stringWithFormat:@"%@%@",[[NSBundle mainBundle] resourcePath],@"/themes/default"]retain];
		self.baseURL = [NSURL fileURLWithPath:basePath];

		//下面不起作用的原因是，需要在webview的delegate中的webViewDidFinishLoad方法中写这个才有作用，因为执行到这里的时候webview还没加载好
		//[self setDocumentElement:@"html" innerHTML:spinner];
		//loadRecentHometimeline
		[PathController instance].currentTimeline=weiboAccount.homeTimeline;
		
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
		if ([PathController instance].currentTimeline.operation==None) {
			//这个地方是有问题的，当从另外一个tab切回来的时候，也会触发这里
			[PathController instance].currentTimeline.unread=NO;
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
	[[PathController instance].currentTimeline loadOlderTimeline];
}

-(void)loadRecentTimeline{
	NSDictionary *data=[NSDictionary dictionaryWithObject:spinner forKey:@"spinner"];
	[[webView mainFrame] loadHTMLString:[templateEngine renderTemplateFileAtPath:statusesPageTemplatePath withContext:data] 
								baseURL:baseURL];
	[[PathController instance].currentTimeline loadRecentTimeline];
}

-(void)loadTimelineWithPage{
	NSDictionary *data=[NSDictionary dictionaryWithObject:spinner forKey:@"spinner"];
	[[webView mainFrame] loadHTMLString:[templateEngine renderTemplateFileAtPath:statusesPageTemplatePath withContext:data] 
								baseURL:baseURL];
	[[PathController instance].currentTimeline loadTimelineWithPage:@"1"];
}

-(void)didReloadTimeline:(NSNotification *)notification{
	[PathController instance].currentTimeline.operation=Reload;
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
	if ([[element getAttribute:@"class"] isNotEqualTo:@"stream-item-content status"]) {
		element=[[[webView mainFrame] DOMDocument] elementFromPoint:4 y:8];
	}
	NSString *itemId=[element getAttribute:@"id"];
	NSInteger relativeOffset=scrollViewBounds.origin.y-[element offsetTop];
	NSDictionary *scrollPosition=[NSDictionary dictionaryWithObjectsAndKeys:itemId,@"itemId",
								  [NSNumber numberWithInt:relativeOffset],@"relativeOffset",nil];
	[[NSUserDefaults standardUserDefaults] setValue:scrollPosition forKey:[NSString stringWithFormat:@"statuses/%@/%@.scrollPosition",[[AccountController instance] currentAccount].username,[PathController instance].currentTimeline.typeName]];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)resumeScrollPosition{
	NSScrollView *scrollView = [[[[webView mainFrame] frameView] documentView] enclosingScrollView];	
	NSDictionary *scrollPosiotion=[[NSUserDefaults standardUserDefaults] valueForKey:[NSString stringWithFormat:@"statuses/%@/%@.scrollPosition",[[AccountController instance] currentAccount].username,[PathController instance].currentTimeline.typeName]];
	NSString *itemId=[scrollPosiotion valueForKey:@"itemId"];
	NSNumber *relativeOffset=[scrollPosiotion valueForKey:@"relativeOffset"];
	DOMElement* element=[[[webView mainFrame] DOMDocument] getElementById:itemId];
	int y=[element offsetTop]+[relativeOffset intValue];
	[[scrollView documentView] scrollPoint:NSMakePoint(0, y)];
}

#pragma mark Select View
//选择home，未读状态设置为NO，将hometimeline中的statusArray渲染出来，设置lastReadStatusId为最新的status的id
-(void) reloadTimeline{
	if ([PathController instance].currentIndex>-1) {
		return;
	}

	
	if ([[PathController instance].pathArray count]==0) {
		[webView setNeedsDisplay:NO];

	}
	if ([PathController instance].currentTimeline.data==nil) {
		switch ([PathController instance].currentTimeline.timelineType) {
			case Home:
			case Comments:
			case DirectMessages:
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
	if (![PathController instance].currentTimeline.firstReload) {
		[self saveScrollPosition];
	}else {
		[PathController instance].currentTimeline.firstReload=NO;
	}

	
	//////////////
	NSMutableDictionary *data=[NSMutableDictionary dictionaryWithCapacity:0];
	if ([PathController instance].currentTimeline.timelineType==DirectMessages) {
		[data setObject:[PathController instance].currentTimeline.data forKey:@"messages"];
		NSString *messagesString=[templateEngine renderTemplateFileAtPath:messageTemplatePath withContext:data];
		[data setObject:messagesString forKey:@"messages_html"];
		[data setObject:loadMore forKey:@"load_more"];
		NSString *messagePage = [templateEngine renderTemplateFileAtPath:messagePageTemplatePath withContext:data];
		[[webView mainFrame] loadHTMLString:messagePage baseURL:baseURL];
		
	}/*else if ([PathController instance].currentTimeline.timelineType==Comments) {
		[data setObject:[templateEngine renderTemplateFileAtPath:commentsTemplatePath withContext:[NSDictionary dictionaryWithObject:[PathController instance].currentTimeline.data forKey:@"comments"]] 
				 forKey:@"statuses"];
		[data setObject:loadMore forKey:@"load_more"];
		
		//[[webView mainFrame] loadHTMLString:[homeTemplate render:data] baseURL:baseURL];
		[[webView mainFrame] loadHTMLString:[templateEngine renderTemplateFileAtPath:statusesPageTemplatePath withContext:data] 
									baseURL:baseURL];
	}*/else{
		[data setObject:[templateEngine renderTemplateFileAtPath:statusesTemplatePath withContext:[NSDictionary dictionaryWithObject:[PathController instance].currentTimeline.data forKey:@"statuses"]] 
				 forKey:@"statuses"];
		[data setObject:loadMore forKey:@"load_more"];
		
		//[[webView mainFrame] loadHTMLString:[homeTemplate render:data] baseURL:baseURL];
		[[webView mainFrame] loadHTMLString:[templateEngine renderTemplateFileAtPath:statusesPageTemplatePath withContext:data] 
									baseURL:baseURL];

	}
}

-(void)selectMentions{
	[PathController instance].currentTimeline.firstReload=YES;
	[PathController instance].currentTimeline.operation=Switch;
	[self saveScrollPosition];
    [PathController instance].currentTimeline = weiboAccount.mentions;
	[self reloadTimeline];

}

-(void)selectComments{
	[PathController instance].currentTimeline.firstReload=YES;
	[self saveScrollPosition];
	[PathController instance].currentTimeline=weiboAccount.comments;
	[self reloadTimeline];
}
-(void)selectHome{
	[PathController instance].currentTimeline.firstReload=YES;
	[PathController instance].currentTimeline.operation=Switch;
	[self saveScrollPosition];
	[PathController instance].currentTimeline = weiboAccount.homeTimeline;
	[self reloadTimeline];
}

-(void)selectFavorites{
	[PathController instance].currentTimeline.firstReload=YES;
	[self saveScrollPosition];
	[PathController instance].currentTimeline = weiboAccount.favorites;
	[self loadTimelineWithPage];
}

-(void)selectDirectMessage{
	[PathController instance].currentTimeline.firstReload=YES;
	[self saveScrollPosition];
	[PathController instance].currentTimeline = weiboAccount.directMessages;
	[self reloadTimeline];
	//[weiboAccount getDirectMessage];
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
		[webView setNeedsDisplay:YES];

			//[webView setHidden:NO];
		//}
		[PathController instance].currentTimeline.operation=None;
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
	if ([PathController instance].currentIndex<0&&[PathController instance].currentTimeline==sender) {
		NSMutableDictionary *data=[NSMutableDictionary dictionaryWithCapacity:0];
		NSArray *statuses=sender.newData;

		DOMDocument *dom=[[webView mainFrame] DOMDocument];
		NSString *eleName;
		NSString *olderStatuses;
		if ([PathController instance].currentTimeline.timelineType==DirectMessages) {
			eleName=@"messages";
			[data setObject:statuses forKey:@"messages"];
			olderStatuses=[templateEngine renderTemplateFileAtPath:messageTemplatePath withContext:data];
		}else {
			eleName=@"statuses"; 
			[data setObject:statuses forKey:@"statuses"];
			olderStatuses=[templateEngine renderTemplateFileAtPath:statusesTemplatePath withContext:data];
		}

		DOMHTMLElement *oldStatusElement=(DOMHTMLElement *)[dom getElementById:eleName];
		[oldStatusElement setInnerHTML:[NSString stringWithFormat:@"%@%@",[oldStatusElement innerHTML],olderStatuses]];		
	}
	
	
	DOMDocument *dom=[[webView mainFrame] DOMDocument];
	DOMHTMLElement *spinnerEle=(DOMHTMLElement *)[dom getElementById:@"spinner"];
	[spinnerEle setInnerHTML:loadMore];
}

-(void)didLoadNewerTimeline:(NSNotification*)notification{
	WeiboTimeline *sender=(WeiboTimeline*)[notification object];
	if ([PathController instance].currentIndex<0&&[PathController instance].currentTimeline==sender) {
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
	if ([PathController instance].currentIndex<0&&[PathController instance].currentTimeline==sender) {
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
	NSDictionary *result=(NSDictionary *)[notification object];
	NSMutableDictionary *data=[NSMutableDictionary dictionaryWithCapacity:0];
	[data setObject:[PathController instance].idWithCurrentType forKey:@"screen_name"];
	[data setObject:@"friends" forKey:@"host"];
	[data setObject:[result objectForKey:@"users"] forKey:@"users"];
	[data setObject:[result objectForKey:@"next_cursor"] forKey:@"next_cursor"];
	[data setObject:[result objectForKey:@"previous_cursor"] forKey:@"previous_cursor"];

	NSString *friendsString=[templateEngine renderTemplateFileAtPath:userlistTemplatePath withContext:data];
	[[webView mainFrame] loadHTMLString:friendsString 
								baseURL:baseURL];
}

-(void)didGetFollowers:(NSNotification*)notification{
	NSDictionary *result=(NSDictionary *)[notification object];
	NSMutableDictionary *data=[NSMutableDictionary dictionaryWithCapacity:0];
	[data setObject:[PathController instance].idWithCurrentType forKey:@"screen_name"];
	[data setObject:[result objectForKey:@"users"] forKey:@"users"];
	[data setObject:@"followers" forKey:@"host"];
	[data setObject:[result objectForKey:@"next_cursor"] forKey:@"next_cursor"];
	[data setObject:[result objectForKey:@"previous_cursor"] forKey:@"previous_cursor"];
	
	NSString *followersString=[templateEngine renderTemplateFileAtPath:userlistTemplatePath withContext:data];
	[[webView mainFrame] loadHTMLString:followersString 
								baseURL:baseURL];
}
-(void)setWaitingForComments:(NSNotification*)notification{
	DOMDocument *dom=[[webView mainFrame] DOMDocument];
	DOMHTMLElement *commentsElement=(DOMHTMLElement *)[dom getElementById:@"comments"];
	DOMHTMLElement *spinnerElement=(DOMHTMLElement *)[dom getElementById:@"spinner"];
	
	[commentsElement setInnerHTML:@""];
	[spinnerElement setInnerHTML:spinner];
}
-(void)didGetStatusComments:(NSNotification*)notification{
	NSMutableDictionary *data=[NSMutableDictionary dictionaryWithCapacity:0];
	NSString *pathId=[PathController instance].idWithCurrentType;
	NSArray *idArray=[pathId componentsSeparatedByString:@":"];
	[data setObject:[idArray objectAtIndex:0] forKey:@"status_id"];
	int page=[(NSString *)[idArray objectAtIndex:1] intValue];
	[data setObject:[NSString stringWithFormat:@"%d",page+1] forKey:@"next_page"];
	[data setObject:[NSString stringWithFormat:@"%d",page-1] forKey:@"previous_page"];
	[data setObject:[notification object] forKey:@"comments"];
	NSString *commentsString=[templateEngine renderTemplateFileAtPath:commentsTemplatePath withContext:data];
	DOMDocument *dom=[[webView mainFrame] DOMDocument];
	DOMHTMLElement *commentsElement=(DOMHTMLElement *)[dom getElementById:@"comments"];
	DOMHTMLElement *spinnerElement=(DOMHTMLElement *)[dom getElementById:@"spinner"];

	[commentsElement setInnerHTML:commentsString];
	[spinnerElement setInnerHTML:@""];
}


-(void)didGetMessageSent:(NSNotification*)notification{
	NSMutableDictionary *data=[NSMutableDictionary dictionaryWithCapacity:0];
	NSString *pageString=[PathController instance].idWithCurrentType;
	int page=[pageString intValue];
	[data setObject:[NSString stringWithFormat:@"%d",page+1] forKey:@"next_page"];
	[data setObject:[NSString stringWithFormat:@"%d",page-1] forKey:@"previous_page"];
	[data setObject:[notification object] forKey:@"messages"];
	NSString *messageSentString=[templateEngine renderTemplateFileAtPath:messageSentTemplatePath withContext:data];
	[[webView mainFrame] loadHTMLString:messageSentString 
								baseURL:baseURL];
	DOMDocument *dom=[[webView mainFrame] DOMDocument];
	DOMHTMLElement *spinnerElement=(DOMHTMLElement *)[dom getElementById:@"spinner"];
	[spinnerElement setInnerHTML:@""];
}
-(void)didShowStatus:(NSNotification*)notification{
	NSDictionary *status=[notification object];
	NSMutableDictionary *data=[NSMutableDictionary dictionaryWithCapacity:0];
	[data setObject:status   forKey:@"status"];
	[data setObject:spinner forKey:@"spinner"];
	[[webView mainFrame] loadHTMLString:[templateEngine renderTemplateFileAtPath:statusDetailTemplatePath withContext:data] 
								baseURL:baseURL];	 
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"weibo://get_comments?id=%@&page=",[status objectForKey:@"id"],@"1"]]];

}

-(void)didGetDirectMessage:(NSNotification*)notification{
	NSMutableDictionary *data=[NSMutableDictionary dictionaryWithCapacity:0];
	[data setObject:[notification object] forKey:@"messages"];
	NSString *messagesString=[templateEngine renderTemplateFileAtPath:messageTemplatePath withContext:data];
	[data setObject:messagesString forKey:@"messages_html"];
	NSString *messagePage = [templateEngine renderTemplateFileAtPath:messagePageTemplatePath withContext:data];
	[[webView mainFrame] loadHTMLString:messagePage baseURL:baseURL];
}

-(void)didGetUserTimeline:(NSNotification*)notification{
	NSMutableDictionary *data=[NSMutableDictionary dictionaryWithCapacity:0];
	[data setObject:[templateEngine renderTemplateFileAtPath:statusesTemplatePath withContext:[NSDictionary dictionaryWithObject:[notification object] forKey:@"statuses"]] 
			 forKey:@"statuses"];
	[data setObject:loadMore forKey:@"load_more"];
	[[webView mainFrame] loadHTMLString:[templateEngine renderTemplateFileAtPath:statusesPageTemplatePath withContext:data] 
								baseURL:baseURL];
}

-(void)showLoadingPage:(NSNotification*)notification{
	NSString *loading=@"<html><head><link href='status_stream.css' rel='styleSheet' type='text/css' /></head>"
	                  "<body><div class='spinner'>"
	                  "<img class='status_spinner_image' src='spinner.gif'/> "
	                  "Loading...</div></div>"
	                  "<div class='status_bar' id='status_bar'></div>" 
					  "</body></html>";
	
	[[webView mainFrame] loadHTMLString:loading baseURL:baseURL];
}

-(void)showTip:(NSNotification*)notification{
	[self showTipMessage:[notification object]];
}

-(void)showTipMessage:(NSString*)message{
	DOMDocument *dom=[[webView mainFrame] DOMDocument];
	DOMHTMLElement *tipElement=(DOMHTMLElement *)[dom getElementById:@"status_bar"];
	[tipElement setInnerHTML:message];
	[tipElement setAttribute:@"style" value:@"visibility:visible"];

}
-(void)hideTipMessage{
	DOMDocument *dom=[[webView mainFrame] DOMDocument];
	DOMHTMLElement *tipElement=(DOMHTMLElement *)[dom getElementById:@"status_bar"];
	[tipElement setAttribute:@"style" value:@"visibility:hidden"];
	
}


@end

