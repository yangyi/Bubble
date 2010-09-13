//
//  ComposeController.m
//  Rainbow
//
//  Created by Luke on 9/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ComposeController.h"


@implementation ComposeController
- (id)init {
	self = [super initWithWindowNibName:@"Compose"];
	htmlController = [[HTMLController alloc]initWithWebView:nil];
	return self;
}

- (void)textDidChange:(NSNotification *)aNotification {
	NSString * string=[textView string];
	int remaining=140-[[string precomposedStringWithCanonicalMapping] length];
	[charactersRemaining setStringValue:[NSString stringWithFormat:@"%d",remaining]];
}

-(IBAction)post:(id)sender{
	NSString * string=[textView string];
	[htmlController postWithStatus:string];
}
@end
