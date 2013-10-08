//
//  MasterDictationManager.h
//  Dictation
//
//  Created by 夏目夏樹 on 12/24/13.
//
//

#import "DictationManager.h"

@interface MasterDictationManager : DictationManager

+ (void)setOfflineUpgradeSuggestionPresented:(BOOL)flag;
+ (BOOL)isOfflineUpgradeSuggestionPresented;

@end
