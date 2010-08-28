//
//  TKTemplate.h
//  TKTemplateEngine
//
//  Created by Geoffrey Foster on 24/06/09.
//  Copyright 2009 Geoffrey Foster. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TKTemplateEngineSettings.h"

@class TKNodeList;

@interface TKTemplate : NSObject {
	NSString *_templateString;
	NSString *_origin;
	NSString *_name;
	TKNodeList *_nodeList;
	NSDictionary *_settings;
}

@property(readwrite, nonatomic, retain) NSDictionary *settings;
@property(readonly, nonatomic) TKNodeList *nodeList;
@property(readonly, nonatomic) NSString *origin;

- (id)initWithTemplatePath:(NSString *)templatePath;
- (id)initWithTemplatePath:(NSString *)templatePath settings:(NSDictionary *)settings;

- (id)initWithTemplateString:(NSString *)templateString;
- (id)initWithTemplateString:(NSString *)templateString origin:(NSString *)origin;
- (id)initWithTemplateString:(NSString *)templateString origin:(NSString *)origin name:(NSString *)name;
- (id)initWithTemplateString:(NSString *)templateString origin:(NSString *)origin name:(NSString *)name settings:(NSDictionary *)settings;
- (id)initWithTemplateString:(NSString *)templateString settings:(NSDictionary *)settings;

- (NSString *)render:(id)context;

@end
