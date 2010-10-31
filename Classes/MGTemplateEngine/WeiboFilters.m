//
//  WeiboFilters.m
//  Bubble
//
//  Created by Luke on 10/31/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "WeiboFilters.h"

#define WEIBO_DATE_FORMAT		@"weibo_date_format"

@implementation WeiboFilters
- (NSArray *)filters{
	return [NSArray arrayWithObjects:
			WEIBO_DATE_FORMAT, 
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
}

@end
