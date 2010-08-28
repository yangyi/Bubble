/*
 *  TKTag.h
 *  TKTemplateEngine
 *
 *  Created by Geoffrey Foster on 25/06/09.
 *  Copyright 2009 Geoffrey Foster. All rights reserved.
 *
 */

@class TKNode, TKParser, TKToken;

@protocol TKTag

- (NSString *)tagKey;

@optional
- (TKNode *)createNodeWithParser:(TKParser *)parser forToken:(TKToken *)token;
- (void)evaluateToken:(TKToken *)token withParser:(TKParser *)parser;

@end
