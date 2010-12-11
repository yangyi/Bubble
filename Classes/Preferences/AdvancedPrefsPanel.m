//
//  AdvancedPrefsPanel.m
//  Bubble
//
//  Created by Luke on 12/11/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AdvancedPrefsPanel.h"


@implementation AdvancedPrefsPanel
+ (NSArray *)preferencePanes
{
    return [NSArray arrayWithObjects:[[[AdvancedPrefsPanel alloc] init] autorelease], nil];
}


- (NSView *)paneView
{
    BOOL loaded = YES;
    
    if (!prefsView) {
        loaded = [NSBundle loadNibNamed:@"AdvancedPrefsView" owner:self];
    }
    
    if (loaded) {
        return prefsView;
    }
    
    return nil;
}


- (NSString *)paneName
{
    return @"Advanced";
}


- (NSImage *)paneIcon
{
    return [NSImage imageNamed:@"NSAdvanced"];
}


- (NSString *)paneToolTip
{
    return @"Advanced Preferences";
}


- (BOOL)allowsHorizontalResizing
{
    return YES;
}


- (BOOL)allowsVerticalResizing
{
    return NO;
}

@end
