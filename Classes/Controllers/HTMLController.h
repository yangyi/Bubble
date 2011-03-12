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
	//web page template engine
	TemplateEngine *templateEngine;
	
	NSString *statusesPageTemplatePath;
	NSString *statusesTemplatePath;
	NSString *userTemplatePath;
	NSString *userlistTemplatePath;
	NSString *useritemTemplatePath;
	NSString *statusDetailTemplatePath;
	NSString *commentsTemplatePath;	
	NSString *messagePageTemplatePath;
	NSString *messageTemplatePath;
	NSString *messageSentTemplatePath;
	NSString* loadingHTML;
	
	NSString *mainPagePath;
	
	AccountController *weiboAccount;
	
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
-(void)didStartHTTPConnection:(NSNotification*)notification;



-(void)saveScrollPosition;
-(void)resumeScrollPosition;

-(void)showTipMessage:(NSString*)message;
-(void)hideTipMessage;


-(void)initPage;
-(void)setInnerHTML:(NSString*)innerHTML forElement:(NSString*)elementId;
-(void)addNewInnerHTML:(NSString *)newInnerHTML ForElement:(NSString*)elementId;
-(void)addOldInnerHTML:(NSString *)oldInnerHTML ForElement:(NSString*)elementId;

@property(nonatomic,retain) WebView *webView;
@property(nonatomic,retain) NSURL *baseURL;
@property(nonatomic,retain) AccountController *weiboAccount;
@property(nonatomic,retain) NSString *statusesPageTemplatePath;
@property(nonatomic,retain) NSString *statusesTemplatePath;
@property(nonatomic,retain) NSString *userTemplatePath;
@property(nonatomic,retain) NSString *userlistTemplatePath;
@property(nonatomic,retain) NSString *useritemTemplatePath;
@property(nonatomic,retain) NSString *statusDetailTemplatePath;
@property(nonatomic,retain) NSString *commentsTemplatePath;	
@property(nonatomic,retain) NSString *messagePageTemplatePath;
@property(nonatomic,retain) NSString *messageTemplatePath;
@property(nonatomic,retain) NSString *messageSentTemplatePath;

@property(nonatomic,retain) NSString *mainPagePath;

@end
