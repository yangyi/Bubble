//
//  WeiboFilters.m
//  Bubble
//
//  Created by Luke on 10/31/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "WeiboFilters.h"
#import "NSDateAdditions.h"
#define WEIBO_DATE_FORMAT		@"weibo_date_format"
#define WEIBO_CONTENT_FORMAT    @"weibo_content_format"
#define WEIBO_LINK_TARGET_BLABK @"weibo_link_target_blank"

@implementation WeiboFilters
- (NSArray *)filters{
	return [NSArray arrayWithObjects:
			WEIBO_DATE_FORMAT, WEIBO_CONTENT_FORMAT,WEIBO_LINK_TARGET_BLABK,
			nil];
}
- (NSObject *)filterInvoked:(NSString *)filter withArguments:(NSArray *)args onValue:(NSObject *)value{
	if ([filter isEqualToString:WEIBO_DATE_FORMAT]) {
		NSString *dateString=[NSString stringWithFormat:@"%@",value];
		NSDate *date=[NSDate dateFromString:dateString withFormat:@"EEE MMM d HH:mm:ss ZZZ yyyy"];
	    long interval = -[date timeIntervalSinceNow];
		if (interval>24*60*60) {
			return [date stringWithFormat:@"yyyy-MM-dd HH:mm:ss"];
		}else {
			if (interval<60*60) {
				return [NSString stringWithFormat:@"%d minites ago",interval/60];
			}else {
				return [NSString stringWithFormat:@"%d hours ago",interval/3600];
			}

		}
		 
	}
	if ([filter isEqualToString:WEIBO_CONTENT_FORMAT]) {
		NSMutableString *mutableContent=[NSMutableString stringWithFormat:@"%@",value];
		NSString        *regexString       = @"(@)(\\w+)\\W";
		NSString        *replaceWithString = @"<a href='http://t.sina.com.cn/n/$2' target='_blank'>$1$2</a>";
		[mutableContent replaceOccurrencesOfRegex:regexString withString:replaceWithString];
		return mutableContent;
	}
	
	if ([filter isEqualToString:WEIBO_LINK_TARGET_BLABK]) {
		NSMutableString *link=[NSMutableString stringWithFormat:@"%@",value];
		[link replaceOccurrencesOfRegex:@"<a" withString:@"<a target=\"_blank\" "];
		return link;
	}
	
	return value;
}

@end
