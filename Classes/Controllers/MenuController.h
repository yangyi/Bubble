//
//  MenuController.h
//  Bubble
//
//  Created by Luke on 11/26/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SS_PrefsController.h"

@interface MenuController : NSObject {
	SS_PrefsController *prefs;
}
- (IBAction)preferences:(id)sender;
@end
