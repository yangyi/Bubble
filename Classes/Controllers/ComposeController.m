//
//  ComposeController.m
//  Rainbow
//
//  Created by Luke on 9/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ComposeController.h"
#import "NSWindowAdditions.h"

@implementation ComposeController
- (id)init {
	self = [super initWithWindowNibName:@"Compose"];
	weiboAccount=[WeiboAccount instance];
	
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc addObserver:self selector:@selector(didPost:) 
			   name:DidPostStatusNotification
			 object:nil];
	
	return self;
}

-(void)awakeFromNib{
	[[self window] isVisible];
}

- (void)textDidChange:(NSNotification *)aNotification {
	NSString * string=[textView string];
	int remaining=140-[[string precomposedStringWithCanonicalMapping] length];
	[charactersRemaining setStringValue:[NSString stringWithFormat:@"%d",remaining]];
}

-(IBAction)post:(id)sender{
	NSString * string=[textView string];
	[weiboAccount postWithStatus:string];
	[postProgressIndicator setHidden:NO];
	[postProgressIndicator startAnimation:self];
	
}
-(void)didPost:(NSNotification*)notification{
	[postProgressIndicator setHidden:YES];
	[postProgressIndicator stopAnimation:self];
	[self close];
	[textView setValue:@""];
}
@end
