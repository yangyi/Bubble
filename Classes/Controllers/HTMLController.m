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
	int y=[[scrollView contentView] bounds].origin.y;
	int height=[[scrollView contentView] bounds].size.height;
	if (y==0) {
		//if ([PathController instance].currentTimeline.operation==None) {
			//这个地方是有问题的，当从另外一个tab切回来的时候，也会触发这里
			[PathController instance].currentTimeline.unread=NO;
			[[NSNotificationCenter defaultCenter] postNotificationName:UpdateTimelineSegmentedControlNotification object:nil];
		//}

	}else if (y+height==[[scrollView documentView] bounds].size.height) {
		[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"weibo://load_older_timeline"]];
	}
	//NSLog(@"%d",[scrollView bounds].size.height);
	//NSLog(@"%d",y);
	//NSLog(@"%d",height);

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
	[[NSNotificationCenter defaultCenter] postNotificationName:ShowLoadingPageNotification object:nil];

	[[PathController instance].currentTimeline loadRecentTimeline];
}

-(void)loadTimelineWithPage{
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
		//[webView setNeedsDisplay:NO];

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
		NSString *messagePage = [templateEngine renderTemplateFileAtPath:messagePageTemplatePath withContext:data];
		[self setInnerHTML:messagePage forElement:@"content"];
		[self setInnerHTML:@"" forElement:@"spinner"];
	}else{
		NSString *statusString=[templateEngine renderTemplateFileAtPath:statusesTemplatePath 
															withContext:[NSDictionary dictionaryWithObject:[PathController instance].currentTimeline.data forKey:@"statuses"]];
		[self setInnerHTML:statusString forElement:@"content"];
		[self setInnerHTML:@"" forElement:@"spinner"];
	}
	[self hideMessageBar];
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
		[webView setNeedsDisplay:YES];
		[[AccountController instance] verifyCurrentAccount];
		[self showMessageBar:@"Login..."];
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
		NSString *eleName;
		NSString *olderStatuses;
		if ([PathController instance].currentTimeline.timelineType==DirectMessages) {
			eleName=@"messages";
			[data setObject:statuses forKey:@"messages"];
			olderStatuses=[templateEngine renderTemplateFileAtPath:messageTemplatePath withContext:data];
		}else {
			eleName=@"content"; 
			[data setObject:statuses forKey:@"statuses"];
			olderStatuses=[templateEngine renderTemplateFileAtPath:statusesTemplatePath withContext:data];
		}

		[self addOldInnerHTML:olderStatuses ForElement:eleName];
	}
	[self setInnerHTML:@"" forElement:@"spinner"];
}

-(void)didLoadNewerTimeline:(NSNotification*)notification{
	WeiboTimeline *sender=(WeiboTimeline*)[notification object];
	if ([PathController instance].currentIndex<0&&[PathController instance].currentTimeline==sender) {
		[self saveScrollPosition];
		NSMutableDictionary *data=[NSMutableDictionary dictionaryWithCapacity:0];
		NSArray *statuses=sender.newData;
		[data setObject:statuses forKey:@"statuses"];
		NSString *newStatuses=[templateEngine renderTemplateFileAtPath:statusesTemplatePath withContext:data];
		[self addNewInnerHTML:newStatuses ForElement:@"content"];
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


-(void)didGetUser:(NSNotification*)notification{
	NSMutableDictionary *data=[NSMutableDictionary dictionaryWithCapacity:0];
	[data setObject:[notification object] forKey:@"user"];
	NSString *userString = [templateEngine renderTemplateFileAtPath:userTemplatePath withContext:data];
	[self setInnerHTML:userString forElement:@"content"];
	[self setInnerHTML:@"" forElement:@"spinner"];
}



-(void)didGetFriends:(NSNotification*)notification{
	NSDictionary *result=(NSDictionary *)[notification object];
	NSMutableDictionary *data=[NSMutableDictionary dictionaryWithCapacity:0];
	[data setObject:[PathController instance].idWithCurrentType forKey:@"screen_name"];
	[data setObject:@"friends" forKey:@"host"];
	[data setObject:[result objectForKey:@"users"] forKey:@"users"];
	[data setObject:[result objectForKey:@"next_cursor"] forKey:@"next_cursor"];
	[data setObject:[result objectForKey:@"previous_cursor"] forKey:@"previous_cursor"];

	NSString *friendsString=[templateEngine renderTemplateFileAtPath:useritemTemplatePath withContext:data];
	[self setInnerHTML:friendsString forElement:@"user_content"];
	[self setInnerHTML:@"" forElement:@"spinner"];
}

-(void)didGetFollowers:(NSNotification*)notification{
	NSDictionary *result=(NSDictionary *)[notification object];
	NSMutableDictionary *data=[NSMutableDictionary dictionaryWithCapacity:0];
	[data setObject:[PathController instance].idWithCurrentType forKey:@"screen_name"];
	[data setObject:[result objectForKey:@"users"] forKey:@"users"];
	[data setObject:@"followers" forKey:@"host"];
	[data setObject:[result objectForKey:@"next_cursor"] forKey:@"next_cursor"];
	[data setObject:[result objectForKey:@"previous_cursor"] forKey:@"previous_cursor"];
	
	NSString *followersString=[templateEngine renderTemplateFileAtPath:useritemTemplatePath withContext:data];
	[self setInnerHTML:followersString forElement:@"user_content"];
	[self setInnerHTML:@"" forElement:@"spinner"];
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
	[self setInnerHTML:messageSentString forElement:@"content"];
	[self setInnerHTML:@"" forElement:@"spinner"];
}
-(void)didShowStatus:(NSNotification*)notification{
	NSDictionary *status=[notification object];
	NSMutableDictionary *data=[NSMutableDictionary dictionaryWithCapacity:0];
	[data setObject:status   forKey:@"status"];
	[data setObject:spinner forKey:@"spinner"];
	NSString *detailString=[templateEngine renderTemplateFileAtPath:statusDetailTemplatePath withContext:data];
	[self setInnerHTML:detailString forElement:@"content"];
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"weibo://get_comments?id=%@&page=",[status objectForKey:@"id"],@"1"]]];

}

-(void)didGetDirectMessage:(NSNotification*)notification{
	NSMutableDictionary *data=[NSMutableDictionary dictionaryWithCapacity:0];
	[data setObject:[notification object] forKey:@"messages"];
	NSString *messagesString=[templateEngine renderTemplateFileAtPath:messageTemplatePath withContext:data];
	[data setObject:messagesString forKey:@"messages_html"];
	NSString *messagePage = [templateEngine renderTemplateFileAtPath:messagePageTemplatePath withContext:data];
	[self setInnerHTML:messagePage forElement:@"content"];
}

-(void)didGetUserTimeline:(NSNotification*)notification{
	NSString *userStatuses=[templateEngine renderTemplateFileAtPath:statusesTemplatePath withContext:[NSDictionary dictionaryWithObject:[notification object] forKey:@"statuses"]];
	[self setInnerHTML:userStatuses forElement:@"user_content"];
	[self setInnerHTML:@"" forElement:@"spinner"];
}

-(void)showLoadingPage:(NSNotification*)notification{	
	[self setInnerHTML:@"" forElement:@"user_content"];
	DOMDocument *dom=[[webView mainFrame] DOMDocument];
	DOMHTMLElement *spinnerElement=(DOMHTMLElement *)[dom getElementById:@"spinner"];
	[spinnerElement setInnerHTML:@"<div class='spinner'><img class='status_spinner_image' src='spinner.gif'/></div>"];

}

-(void)showTip:(NSNotification*)notification{
	NSString *tipString=[notification object];
	if ([tipString isNotEqualTo:@""]) {
		[self showMessageBar:[notification object]];
	}else {
		[self hideMessageBar];
	}

	
}

-(void)showMessageBar:(NSString*)message{
	DOMDocument *dom=[[webView mainFrame] DOMDocument];
	DOMHTMLElement *tipElement=(DOMHTMLElement *)[dom getElementById:@"message_bar"];
	[tipElement setInnerHTML:message];
	[tipElement setAttribute:@"style" value:@"visibility:visible"];

}
-(void)hideMessageBar{
	DOMDocument *dom=[[webView mainFrame] DOMDocument];
	DOMHTMLElement *tipElement=(DOMHTMLElement *)[dom getElementById:@"message_bar"];
	[tipElement setInnerHTML:@""];
	[tipElement setAttribute:@"style" value:@"visibility:hidden"];
	
}

-(void)loadMainPage{
	NSString *mainPageString=[templateEngine renderTemplateFileAtPath:mainPagePath withContext:nil];
	[[webView mainFrame] loadHTMLString:mainPageString baseURL:baseURL];
}

//Set InnerHTML For Element
-(void)setInnerHTML:(NSString*)innerHTML forElement:(NSString*)elementId{
	DOMDocument *dom=[[webView mainFrame] DOMDocument];
	DOMHTMLElement *element=(DOMHTMLElement *)[dom getElementById:elementId];
	[element setInnerHTML:innerHTML];
}

-(void)addNewInnerHTML:(NSString *)newInnerHTML ForElement:(NSString*)elementId{
	DOMDocument *dom=[[webView mainFrame] DOMDocument];
	DOMHTMLElement *element=(DOMHTMLElement *)[dom getElementById:elementId];
	[element setInnerHTML:[NSString stringWithFormat:@"%@%@",newInnerHTML,[element innerHTML]]];
}

-(void)addOldInnerHTML:(NSString *)oldInnerHTML ForElement:(NSString*)elementId{
	DOMDocument *dom=[[webView mainFrame] DOMDocument];
	DOMHTMLElement *element=(DOMHTMLElement *)[dom getElementById:elementId];
	[element setInnerHTML:[NSString stringWithFormat:@"%@%@",[element innerHTML],oldInnerHTML]];
}
@end

