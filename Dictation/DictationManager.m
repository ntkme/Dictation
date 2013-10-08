//
//  DictationManager.m
//  Dictation
//
//  Created by 夏目夏樹 on 4/5/13.
//  Copyright (c) 2013 夏目夏樹. All rights reserved.
//

#import "DictationManager.h"

NSString *const kDictationIMBundleIdentifier = @"com.apple.inputmethod.ironwood";
static NSString *const kDictationIMUserDefaultPersistentDomain = @"com.apple.speech.recognition.AppleSpeechRecognition.prefs";
static NSString *const kDictationIMIntroMessagePresented = @"DictationIMIntroMessagePresented";
static NSString *const kDictationIMLocaleIdentifier = @"DictationIMLocaleIdentifier";
static NSString *const kDictationIMCanAutoEnable = @"AppleIronwoodCanAutoEnable";

@interface DictationManager ()

+ (NSDictionary *)persistentDomain;
+ (void)setPersistentDomain:(NSDictionary *)aDictionary;
+ (void)addEntriesToPersistentDomainFromDictionary:(NSDictionary *)aDictionary;

@end


@implementation DictationManager

+ (NSDictionary *)persistentDomain
{
    return [[NSUserDefaults standardUserDefaults] persistentDomainForName:kDictationIMUserDefaultPersistentDomain];
}

+ (void)setPersistentDomain:(NSDictionary *)aDictionary
{
    [[NSUserDefaults standardUserDefaults] setPersistentDomain:aDictionary
                                                       forName:kDictationIMUserDefaultPersistentDomain];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)addEntriesToPersistentDomainFromDictionary:(NSDictionary *)aDictionary
{
    NSMutableDictionary *theMutablePersistentDomain = [[self persistentDomain] mutableCopy];
    [theMutablePersistentDomain addEntriesFromDictionary:aDictionary];
    [self setPersistentDomain:theMutablePersistentDomain];
}

+ (void)setEnabled:(BOOL)flag
{
    [self addEntriesToPersistentDomainFromDictionary:@{
                           kDictationIMCanAutoEnable:[NSNumber numberWithBool:flag]
     }];
}

+ (BOOL)isEnabled
{
    return [[[self persistentDomain] objectForKey:kDictationIMCanAutoEnable] boolValue];
}


+ (void)setIntroMessagePresented:(BOOL)flag
{
    [self addEntriesToPersistentDomainFromDictionary:@{
                   kDictationIMIntroMessagePresented:[NSNumber numberWithBool:flag]
     }];
}

+ (BOOL)isIntroMessagePresented
{
    return [[[self persistentDomain] objectForKey:kDictationIMIntroMessagePresented] boolValue];
}

+ (NSString *)localeIdentifier
{
    return [[self persistentDomain] objectForKey:kDictationIMLocaleIdentifier];
}

+ (void)setLocaleIdentifier:(NSString *)aLocaleIdentifier
{
    NSDictionary *theComponents = [NSLocale componentsFromLocaleIdentifier:aLocaleIdentifier];
    [self addEntriesToPersistentDomainFromDictionary:@{
                        kDictationIMLocaleIdentifier:[NSLocale canonicalLocaleIdentifierFromString:[NSLocale localeIdentifierFromComponents:@{
                                                                                                                       NSLocaleLanguageCode:[theComponents objectForKey:NSLocaleLanguageCode],
                                                                                                                        NSLocaleCountryCode:[theComponents objectForKey:NSLocaleCountryCode]
                                                                                                    }]]
     }];
}

+ (void)terminate
{
    for (NSRunningApplication *runningApplication in [NSRunningApplication runningApplicationsWithBundleIdentifier:kDictationIMBundleIdentifier]) {
        [runningApplication terminate];
    }
}

@end
