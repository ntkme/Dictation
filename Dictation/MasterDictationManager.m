//
//  MasterDictationManager.m
//  Dictation
//
//  Created by 夏目夏樹 on 12/24/13.
//
//

#import "MasterDictationManager.h"

static NSString *const kDictationIMUserDefaultPersistentDomain       = @"com.apple.speech.recognition.AppleSpeechRecognition.prefs";
static NSString *const kDictationIMMasterDictationEnabled            = @"DictationIMMasterDictationEnabled";
static NSString *const kDictationIMPresentedOfflineUpgradeSuggestion = @"PresentedOfflineUpgradeSuggestion";

@interface DictationManager ()

+ (NSDictionary *)persistentDomain;
+ (void)setPersistentDomain:(NSDictionary *)aDictionary;
+ (void)addEntriesToPersistentDomainFromDictionary:(NSDictionary *)aDictionary;

@end


@implementation MasterDictationManager

+ (void)setEnabled:(BOOL)flag
{
    [self addEntriesToPersistentDomainFromDictionary:@{
                                                       kDictationIMMasterDictationEnabled:[NSNumber numberWithBool:flag]
                                                       }];
}

+ (BOOL)isEnabled
{
    return [[[self persistentDomain] objectForKey:kDictationIMMasterDictationEnabled] boolValue];
}

+ (void)setOfflineUpgradeSuggestionPresented:(BOOL)flag
{
    [self addEntriesToPersistentDomainFromDictionary:@{
                                                       kDictationIMPresentedOfflineUpgradeSuggestion:[NSNumber numberWithBool:flag]
                                                       }];
}

+ (BOOL)isOfflineUpgradeSuggestionPresented
{
    return [[[self persistentDomain] objectForKey:kDictationIMPresentedOfflineUpgradeSuggestion] boolValue];
}

@end
