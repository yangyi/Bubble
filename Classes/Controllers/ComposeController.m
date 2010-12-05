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
	[textView setImportsGraphics:TRUE];
	[textView setFont:[NSFont fontWithName:@"Menlo" size:14]];
	CGFloat linespace=3.0f;
	NSMutableParagraphStyle *paragraphStyle=[[[NSMutableParagraphStyle alloc] init] autorelease];
	[paragraphStyle setLineSpacing:linespace];
	[textView setDefaultParagraphStyle:paragraphStyle];
}

- (void)textDidChange:(NSNotification *)aNotification {
	NSString * string=[textView string];
	int remaining=140-[[string precomposedStringWithCanonicalMapping] length];
	[charactersRemaining setStringValue:[NSString stringWithFormat:@"%d",remaining]];
}

-(IBAction)post:(id)sender{
	NSAttributedString *attributedString=[textView attributedString];
	NSUInteger length= attributedString.length;
	NSData *imageData=nil;
	BOOL upload=NO;
	if (length) {
		NSRange searchRange = NSMakeRange(0,0);
		while (searchRange.location<length) {
			NSTextAttachment *textAttachment=[attributedString attribute:NSAttachmentAttributeName
																		atIndex:searchRange.location
																 effectiveRange:&searchRange];
			if (textAttachment) {
				NSFileWrapper *image=[textAttachment fileWrapper];
				imageData=[image regularFileContents];
				//[weiboAccount postWithStatus:[textView string] image:imageData imageName:[image preferredFilename]];
				upload=YES;
				//break;
			}
			searchRange.location+=searchRange.length;
		}
	}
	if (!upload) {
		[weiboAccount postWithStatus:[textView string]];
	}
	[postProgressIndicator setHidden:NO];
	[postProgressIndicator startAnimation:self];
	
}
-(void)didPost:(NSNotification*)notification{
	[postProgressIndicator setHidden:YES];
	[postProgressIndicator stopAnimation:self];
	[self close];
}

-(void)popUp{
	NSWindow *window=[self window];
	NSPoint mouseLoc = [NSEvent mouseLocation];
	fromRect.origin=mouseLoc;
	fromRect.size.width=1;
	fromRect.size.height=1;
	if (![window isVisible]) {
		[window zoomOnFromRect:fromRect];
	}
	[window display];
	[window orderFront:self];
	[window makeKeyWindow];
}

- (BOOL)windowShouldClose:(id)sender{
	[[self window] zoomOffToRect:fromRect];
	[textView setString:@""];
	[charactersRemaining setStringValue:[NSString stringWithFormat:@"%d",140]];
	return YES;
}
@end
