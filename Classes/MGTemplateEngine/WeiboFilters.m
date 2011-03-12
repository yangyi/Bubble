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
#define WEIBO_LINK_TARGET_BLANK @"weibo_link_target_blank"
#define WEIBO_CONTENT_TRUNCATE  @"weibo_content_truncate"
#define WEIBO_BIG_PROFILE_IMAGE  @"weibo_big_image"

#define AT_STRING @"(@)([\\x{4e00}-\\x{9fa5}A-Za-z0-9_\\-]+)"
#define AT_REPLACE_STRING @"<a href='weibo://user?fetch_with=screen_name&value=$2' target='_blank'>$1$2</a> "
#define TOPIC_STRING @"#(.+?)#"
#define TOPIC_REPLACE_STRING @"<a href=\"http://t.sina.com.cn/k/$1\" target=\"_blank\">#$1#</a>"

#define LINK_STRING @"(http://sinaurl.cn/[a-zA-Z0-9]+)"
#define LINK_REPLACE_STRING @"<a href=\"$1\" target=\"_blank\">$1</a>"

const int TRUNCATE_LENGTH=20;
@implementation WeiboFilters
- (NSArray *)filters{
	return [NSArray arrayWithObjects:
			WEIBO_DATE_FORMAT, WEIBO_CONTENT_FORMAT,WEIBO_LINK_TARGET_BLANK,WEIBO_CONTENT_TRUNCATE,WEIBO_BIG_PROFILE_IMAGE,
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
		[mutableContent replaceOccurrencesOfRegex:LINK_STRING withString:LINK_REPLACE_STRING];
		[mutableContent replaceOccurrencesOfRegex:AT_STRING withString:AT_REPLACE_STRING];
		[mutableContent replaceOccurrencesOfRegex:TOPIC_STRING withString:TOPIC_REPLACE_STRING];
		return mutableContent;
	}
	
	if ([filter isEqualToString:WEIBO_LINK_TARGET_BLANK]) {
		NSMutableString *link=[NSMutableString stringWithFormat:@"%@",value];
		[link replaceOccurrencesOfRegex:@"<a" withString:@"<a target=\"_blank\" "];
		return link;
	}
	
	if ([filter isEqualToString:WEIBO_CONTENT_TRUNCATE]) {
		NSString *content=[NSString stringWithFormat:@"%@",value];
		int stringLength=content.length;
		int length=stringLength<TRUNCATE_LENGTH?stringLength:TRUNCATE_LENGTH;
		return [[NSString stringWithFormat:@"%@...",[content substringToIndex:length]] urlEncoded];
	}
	
	if ([filter isEqualToString:WEIBO_BIG_PROFILE_IMAGE]) {
		NSString *content=[NSString stringWithFormat:@"%@",value];
		return [content stringByReplacingOccurrencesOfString:@"/50/" withString:@"/180/"];
	}
	return value;
}

@end
