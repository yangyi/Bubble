//
//  MainWindowController.h
//  Rainbow
//
//  Created by Luke on 8/23/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>


@interface MainWindowController : NSWindowController {
	IBOutlet WebView *webView;
	
}
-(id)init;
@end
