//
//  TKFilter.h
//  TKTemplateEngine
//
//  Created by Geoffrey Foster on 29/06/09.
//  Copyright 2009 Geoffrey Foster. All rights reserved.
//



@protocol TKFilter

- (NSString *)filterKey;
- (NSUInteger)numExpectedArgs;
- (NSObject *)filterObject:(NSObject *)obj withArgs:(NSArray *)args;

@end
