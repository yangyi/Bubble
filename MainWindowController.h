//
//  MainWindowController.h
//  Rainbow
//
//  Created by Luke on 8/23/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import <TKTemplateEngine/TKTemplateEngine.h>

@interface MainWindowController : NSWindowController {
	IBOutlet WebView *webView;
	TKTemplate *htmlTemplate;
}
-(id)init;
@end
