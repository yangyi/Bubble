//
//  AccountPrefsPanel.h
//  Bubble
//
//  Created by Luke on 11/25/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SS_PreferencePaneProtocol.h"

@interface AccountPrefsPanel : NSObject<SS_PreferencePaneProtocol> {
	IBOutlet NSView *prefsView;
}
-(IBAction)addAccount:(id)sender;
@end
