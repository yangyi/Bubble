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
//#import <TKTemplateEngine/TKTemplateEngine.h>
#import "WeiboAccount.h"
#import "WeiboGlobal.h"
#import "MGTemplateEngine.h"
#import "ICUTemplateMatcher.h"
@interface HTMLController : NSObject<MGTemplateEngineDelegate> {
	NSString *theme;
	WebView *webView;

	//TKTemplate *homeTemplate;
	//TKTemplate *statusesTemplate;
	MGTemplateEngine *engine;
	NSString* loadingHTML;
	
	WeiboAccount *weiboAccount;
	NSURL *baseURL;
	NSString *spinner;
	NSString *loadMore;
}
-(id) initWithWebView:(WebView*) webView;
-(void)dealloc;

-(void)reloadHomeTimeLine;
-(void)selectMentions;
-(void)postWithStatus:(NSString*)status;
#pragma mark WebView JS 
- (NSString*)setDocumentElement:(NSString*)element visibility:(BOOL)visibility;
- (NSString*) setDocumentElement:(NSString*)element innerHTML:(NSString*)html;
- (void)scrollToTop;

-(void)didStartHTTPConnection:(NSNotification*)notification;

@property(nonatomic,retain) WebView *webView;
@property(nonatomic,retain) NSURL *baseURL;
@property(nonatomic,retain) WeiboAccount *weiboAccount;
@end
