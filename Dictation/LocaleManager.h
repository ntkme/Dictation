//
//  LanguageManager.h
//  Dictation
//
//  Created by 夏目夏樹 on 4/5/13.
//  Copyright (c) 2013 夏目夏樹. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LocaleManager : NSLocale

+ (NSString *)canonicalLocaleIdentifierFromString:(NSString *)aLocaleIdentifier forComponents:(NSArray *)components;
+ (NSString *)canonicalLanguageIdentifierFromString:(NSString *)aLocaleIdentifier forComponents:(NSArray *)components;

@end
