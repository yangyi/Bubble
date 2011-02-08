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
#import "AccountController.h"
#import "WeiboGlobal.h"
#import "TemplateEngine.h"
#import "PathController.h"
@interface HTMLController : NSObject {
	NSString *theme;
	WebView *webView;
	NSImageView *imageView;
	//web page template engine
	TemplateEngine *templateEngine;
	
	NSString *statusesPageTemplatePath;
	NSString *statusesTemplatePath;
	NSString *userTemplatePath;
	NSString *userlistTemplatePath;
	NSString *statusDetailTemplatePath;
	NSString *commentsTemplatePath;	
	NSString *messagePageTemplatePath;
	NSString *messageTemplatePath;
	NSString* loadingHTML;
	
	AccountController *weiboAccount;
	
	//currentView 用来标记当前选择的View是什么
	//__weak WeiboTimeline *currentTimeline;
	
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

-(void)didSelectAccount:(NSNotification*)notification;
#pragma mark WebView JS 
- (NSString*)setDocumentElement:(NSString*)element visibility:(BOOL)visibility;
- (NSString*) setDocumentElement:(NSString*)element innerHTML:(NSString*)html;
- (void)scrollToTop;

-(void)saveScrollPosition;
-(void)resumeScrollPosition;

@property(nonatomic,retain) WebView *webView;
@property(nonatomic,retain) NSURL *baseURL;
@property(nonatomic,retain) AccountController *weiboAccount;
@property(nonatomic,retain) NSString *statusesPageTemplatePath;
@property(nonatomic,retain) NSString *statusesTemplatePath;
@property(nonatomic,retain) NSString *userTemplatePath;
@property(nonatomic,retain) NSString *userlistTemplatePath;
@property(nonatomic,retain) NSString *statusDetailTemplatePath;
@property(nonatomic,retain) NSString *commentsTemplatePath;	
@property(nonatomic,retain) NSString *messagePageTemplatePath;
@property(nonatomic,retain) NSString *messageTemplatePath;
@property(nonatomic,assign) NSImageView *imageView;
@end
