//
//  TKTemplateEngineLibrary.h
//  TKTemplateEngine
//
//  Created by Geoffrey Foster on 29/06/09.
//  Copyright 2009 Geoffrey Foster. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TKTag.h"
#import "TKFilter.h"

@interface TKTemplateEngineLibrary : NSObject {
	NSMutableDictionary *_tags;
	NSMutableDictionary *_filters;
}

+ (TKTemplateEngineLibrary *)defaultLibrary;

- (id)initWithDefaults;

- (void)registerObject:(id)obj;

- (NSObject <TKTag> *)tagNamed:(NSString *)name;
- (NSObject <TKFilter> *)filterNamed:(NSString *)name;

@end
