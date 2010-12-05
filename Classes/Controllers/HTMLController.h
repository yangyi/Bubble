//
//  HTMLController.h
//  Rainbow
//
//  Created by Luke on 9/6/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import <WebKit/WebPolicyDelegate.h>
#import "WeiboAccount.h"
#import "WeiboGlobal.h"
#import "TemplateEngine.h"
@interface HTMLController : NSObject {
	NSString *theme;
	WebView *webView;
	//web page template engine
	TemplateEngine *templateEngine;
	
	NSString *statusesPageTemplatePath;
	NSString *statusesTemplatePath;
	NSString *userTemplatePath;
	
	NSString* loadingHTML;
	
	WeiboAccount *weiboAccount;
	
	//currentView 用来标记当前选择的View是什么
	__weak WeiboTimeline *currentTimeline;
	
	NSURL *baseURL;
	NSString *spinner;
	NSString *loadMore;
}
-(id) initWithWebView:(WebView*) webView;
-(void)dealloc;
-(void)loadRecentTimeline;
-(void)loadTimelineWithPage;
-(void)reloadTimeline;
-(void)selectMentions;
-(void)selectComments;
-(void)selectHome;
-(void)selectFavorites;
#pragma mark 接受通知的方法
-(void)didReloadTimeline:(NSNotification *)notification;
-(void)didLoadNewerTimeline:(NSNotification*)notification;
-(void)startLoadOlderTimeline:(NSNotification*)notification;
-(void)didLoadNewerTimeline:(NSNotification*)notification;
-(void)didClickTimeline:(NSNotification*)notification;
-(void)didStartHTTPConnection:(NSNotification*)notification;


#pragma mark WebView JS 
- (NSString*)setDocumentElement:(NSString*)element visibility:(BOOL)visibility;
- (NSString*) setDocumentElement:(NSString*)element innerHTML:(NSString*)html;
- (void)scrollToTop;



@property(nonatomic,retain) WebView *webView;
@property(nonatomic,retain) NSURL *baseURL;
@property(nonatomic,retain) WeiboAccount *weiboAccount;
@property(nonatomic,retain) NSString *statusesPageTemplatePath;
@property(nonatomic,retain) NSString *statusesTemplatePath;
@property(nonatomic,retain) NSString *userTemplatePath;
@end
