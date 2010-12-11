//
//  AdvancedPrefsPanel.h
//  Bubble
//
//  Created by Luke on 12/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SS_PreferencePaneProtocol.h"

@interface AdvancedPrefsPanel : NSObject<SS_PreferencePaneProtocol>  {
	IBOutlet NSView *prefsView;
}

@end
