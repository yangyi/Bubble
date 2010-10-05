//
//  HTMLController.h
//  Rainbow
//
//  Created by Luke on 9/6/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import <TKTemplateEngine/TKTemplateEngine.h>
#import "WeiboAccount.h"
#import "WeiboGlobal.h"
@interface HTMLController : NSObject {
	NSString *theme;
	WebView *webView;
	TKTemplate *mainTemplate;
	TKTemplate *timeLineTemplate;
	WeiboAccount *weiboAccount;
	NSURL *baseURL;

}
-(id) initWithWebView:(WebView*) webView;
-(void)dealloc;

-(void)statusesReceived:(NSNotification *)notification;
-(void)statusReceived:(NSArray *)status;
-(void)selectHomeTimeLine;
-(void)selectMentions;
-(void)postWithStatus:(NSString*)status;
#pragma mark WebView JS 
- (NSString*)setDocumentElement:(NSString*)element visibility:(BOOL)visibility;
- (NSString*)setDocumentElement:(NSString*)element innerHTML:(NSString*)html;
- (void)scrollToTop;

@property(nonatomic,retain) WebView *webView;
@property(nonatomic,retain) NSURL *baseURL;
@end
