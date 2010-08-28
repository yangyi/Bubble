//
//  TKTemplateEngineSettings.h
//  TKTemplateEngine
//
//  Created by Geoffrey Foster on 28/06/09.
//  Copyright 2009 Geoffrey Foster. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const kTKFilterSeparator;
extern NSString * const kTKFilterArgumentSeparator;
extern NSString * const kTKVariableAttributeSeparator;

extern NSString * const kTKBlockTagStart;
extern NSString * const kTKBlockTagEnd;

extern NSString * const kTKVariableTagStart;
extern NSString * const kTKVariableTagEnd;

extern NSString * const kTKCommentTagStart;
extern NSString * const kTKCommentTagEnd;

extern NSString * const kTKSingleBraceStart;
extern NSString * const kTKSingleBraceEnd;

extern NSString * const kTKAllowedVariableChars;

extern NSString * const kTKPreserveWhitespace;
extern NSString * const kTKOutputErrors;

@interface NSDictionary (TKTemplateEngineSettings)

+ (NSDictionary *)defaultTemplateEngineSettings;

- (NSString *)filterSeparator;
- (NSString *)filterArgumentSeparator;
- (NSString *)variableAttributeSeparator;

- (NSString *)blockTagStart;
- (NSString *)blockTagEnd;

- (NSString *)variableTagStart;
- (NSString *)variableTagEnd;

- (NSString *)commentTagStart;
- (NSString *)commentTagEnd;

- (BOOL)isPreservingWhitespace;

@end
