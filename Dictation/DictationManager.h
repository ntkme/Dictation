//
//  DictationManager.h
//  Dictation
//
//  Created by 夏目夏樹 on 4/5/13.
//  Copyright (c) 2013 夏目夏樹. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const kDictationIMBundleIdentifier;

@interface DictationManager : NSObject

+ (void)setEnabled:(BOOL)flag;
+ (BOOL)isEnabled;
+ (void)setIntroMessagePresented:(BOOL)flag;
+ (BOOL)isIntroMessagePresented;
+ (NSString *)localeIdentifier;
+ (void)setLocaleIdentifier:(NSString *)aLocaleIdentifier;
+ (void)terminate;

@end
