//
//  TKContext.h
//  TKTemplateEngine
//
//  Created by Geoffrey Foster on 24/06/09.
//  Copyright 2009 Geoffrey Foster. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TKContext : NSObject {
	NSMutableArray *_dicts;
	BOOL _autoescape;
}

@property(readwrite, nonatomic) BOOL autoescape;

+ (TKContext *)contextWithDict:(NSDictionary *)aDict;

- (id)initWithDict:(NSDictionary *)aDict;
- (id)initWithDict:(NSDictionary *)aDict autoescape:(BOOL)doesAutoescape;

- (NSMutableDictionary *)push;
- (NSMutableDictionary *)pop;

- (void)setObject:(id)obj forKey:(id)key;
- (id)objectForKey:(id)key;
- (BOOL)hasKey:(id)key;

- (NSMutableDictionary *)update:(NSDictionary *)otherDict;

@end
