//
//  GeneralPrefsPanel.m
//  Bubble
//
//  Created by Luke on 11/25/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "GeneralPrefsPanel.h"


@implementation GeneralPrefsPanel
+ (NSArray *)preferencePanes
{
    return [NSArray arrayWithObjects:[[[GeneralPrefsPanel alloc] init] autorelease], nil];
}


- (NSView *)paneView
{
    BOOL loaded = YES;
    
    if (!prefsView) {
        loaded = [NSBundle loadNibNamed:@"GeneralPrefsView" owner:self];
    }
    
    if (loaded) {
        return prefsView;
    }
    
    return nil;
}


- (NSString *)paneName
{
    return @"General";
}


- (NSImage *)paneIcon
{
    return [[[NSImage alloc] initWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForImageResource:@"generalPrefs.tiff"]] autorelease];
}


- (NSString *)paneToolTip
{
    return @"General Preferences";
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
