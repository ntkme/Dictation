//
//  AppDelegate.m
//  Dictation
//
//  Created by 夏目夏樹 on 12/16/12.
//  Copyright (c) 2012 夏目夏樹. All rights reserved.
//

#import "AppDelegate.h"
#import "InputMethodManager.h"
#import "DictationManager.h"
#import "MasterDictationManager.h"
#import "LocaleManager.h"
#import "LoginItem.h"

static NSString *const kAppUserDefaultOpenAtLogin = @"OpenAtLogin";
static NSString *const kAppUserDefaultDictationLanguageInStatusbar = @"DictationLanguageInStatusbar";
static NSString *const kAppUserDefaultDictationLocaleIdentifiers = @"DictationLocaleIdentifiers";
static NSString *const kAppMenuItemLocaleIdentifier = @"LocaleIdentifier";
static NSString *const kAppMenuItemLanguage = @"Language";

@implementation AppDelegate

+ (void)initialize
{
    NSString *currentSystemVersion = [[NSDictionary dictionaryWithContentsOfFile:@"/System/Library/CoreServices/SystemVersion.plist"] objectForKey:@"ProductVersion"];
    NSDictionary *theDictationLocaleIdentifiersDictionary = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"DictationLocaleIdentifiers"
                                                                                                                                       ofType:@"plist"]];
    NSArray *defaultDictationLocaleIdentifiers = [theDictationLocaleIdentifiersDictionary objectForKey:@"LocaleIdentifiers"];
    NSDictionary *minimumSystemVersion = [theDictationLocaleIdentifiersDictionary objectForKey:@"MinimumSystemVersion"];
    for (NSString *systemVersion in minimumSystemVersion) {
        if ([systemVersion compare:currentSystemVersion options:NSNumericSearch] == NSOrderedDescending) {
            defaultDictationLocaleIdentifiers = [defaultDictationLocaleIdentifiers filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSString *localeIdentifier, NSDictionary *bindings) {
                if ([[minimumSystemVersion objectForKey:systemVersion] containsObject:localeIdentifier]) {
                    return NO;
                }
                return YES;
            }]];
        }
    }

    NSArray *preferredLanguages = [NSLocale preferredLanguages];
    NSArray *enabledInputMethodLanguages = [InputMethodManager enabledInputMethodLanguages];
    defaultDictationLocaleIdentifiers = [[defaultDictationLocaleIdentifiers filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSString *localeIdentifier, NSDictionary *bindings) {
        NSString *language = [LocaleManager canonicalLocaleIdentifierFromString:localeIdentifier
                                                                  forComponents:@[NSLocaleLanguageCode, NSLocaleScriptCode]];
        if ([preferredLanguages containsObject:language] &&
            [enabledInputMethodLanguages containsObject:language]) {
            return YES;
        }
        return NO;
    }]] sortedArrayUsingComparator:^(NSString *localeIdentifier1, NSString *localeIdentifier2) {
        NSInteger index1 = [preferredLanguages indexOfObject:[LocaleManager canonicalLocaleIdentifierFromString:localeIdentifier1
                                                                                                  forComponents:@[NSLocaleLanguageCode, NSLocaleScriptCode]]];
        NSInteger index2 = [preferredLanguages indexOfObject:[LocaleManager canonicalLocaleIdentifierFromString:localeIdentifier2
                                                                                                  forComponents:@[NSLocaleLanguageCode, NSLocaleScriptCode]]];
        if (index1 > index2) {
            return NSOrderedDescending;
        }
        if (index1 < index2) {
            return NSOrderedAscending;
        }
        return NSOrderedSame;
    }];

    [[NSUserDefaults standardUserDefaults] registerDefaults:@{
                kAppUserDefaultDictationLanguageInStatusbar:@YES,
                  kAppUserDefaultDictationLocaleIdentifiers:defaultDictationLocaleIdentifiers
     }];

    [[NSUserDefaults standardUserDefaults] setObject:[defaultDictationLocaleIdentifiers sortedArrayUsingComparator:^NSComparisonResult(NSString *localeIdentifier1, NSString *localeIdentifier2) {
        if ([[LocaleManager canonicalLocaleIdentifierFromString:localeIdentifier1
                                                  forComponents:@[NSLocaleLanguageCode, NSLocaleScriptCode]] isEqualToString:[LocaleManager canonicalLocaleIdentifierFromString:localeIdentifier1
                                                                                                                                                                  forComponents:@[NSLocaleLanguageCode, NSLocaleScriptCode]]]) {
            NSInteger index1 = [[[NSUserDefaults standardUserDefaults] arrayForKey:kAppUserDefaultDictationLocaleIdentifiers] indexOfObject:localeIdentifier1];
            NSInteger index2 = [[[NSUserDefaults standardUserDefaults] arrayForKey:kAppUserDefaultDictationLocaleIdentifiers] indexOfObject:localeIdentifier2];
            if (index1 > index2) {
                return NSOrderedDescending;
            }
            if (index1 < index2) {
                return NSOrderedAscending;
            }
        }
        return NSOrderedSame;
    }] forKey:kAppUserDefaultDictationLocaleIdentifiers];
}

- (void)awakeFromNib
{
    NSString *currentSystemVersion = [[NSDictionary dictionaryWithContentsOfFile:@"/System/Library/CoreServices/SystemVersion.plist"] objectForKey:@"ProductVersion"];
    if ([currentSystemVersion compare:@"10.9" options:NSNumericSearch] != NSOrderedAscending) {
        DictationManagerMetaClass = objc_allocateClassPair([MasterDictationManager class], "DictationManagerMetaClass", 0);
    } else {
        DictationManagerMetaClass = objc_allocateClassPair([DictationManager class], "DictationManagerMetaClass", 0);
    }

    [openAtLoginMenuItem bind:@"value"
                     toObject:[LoginItem loginItemWithBundleIdentifier:@"me.ntk.Dictation-Login-Helper"]
                  withKeyPath:@"self.enabled"
                      options:nil];

    NSArray *localeIdentifiers = [[NSUserDefaults standardUserDefaults] arrayForKey:kAppUserDefaultDictationLocaleIdentifiers];
    NSDictionary *preferedLocaleIdentifiers = [self preferedLocaleIdentifiers];
    NSMutableArray *menuItems = [NSMutableArray array];

    for (NSString *localeIdentifier in localeIdentifiers) {
        NSString *language = [LocaleManager canonicalLocaleIdentifierFromString:localeIdentifier
                                                                  forComponents:@[NSLocaleLanguageCode, NSLocaleScriptCode]];
        if ([localeIdentifier isEqualToString:[preferedLocaleIdentifiers objectForKey:language]]) {
            [menuItems addObject:[[NSMenuItem alloc] initWithTitle:[[NSLocale currentLocale] displayNameForKey:NSLocaleIdentifier
                                                                                                         value:language]
                                                            action:nil
                                                     keyEquivalent:@""]];
        }
        NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:[[NSLocale currentLocale] displayNameForKey:NSLocaleCountryCode
                                                                                                       value:[[LocaleManager componentsFromLocaleIdentifier:localeIdentifier] objectForKey:NSLocaleCountryCode]]
                                                          action:@selector(languageMenuItemAction:)
                                                   keyEquivalent:@""];
        [menuItem setIndentationLevel:1];
        [menuItem setRepresentedObject:@{
          kAppMenuItemLocaleIdentifier:localeIdentifier,
                  kAppMenuItemLanguage:language
         }];
        [menuItems addObject:menuItem];
    }

    if ([menuItems count] > 0) {
        [menuItems addObject:[NSMenuItem separatorItem]];
    }
    [menuItems enumerateObjectsWithOptions:NSEnumerationReverse
                                usingBlock:^(NSMenuItem *menuItem, NSUInteger idx, BOOL *stop) {
                                    [mainMenu insertItem:menuItem atIndex:0];
                                }];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [[NSNotificationCenter defaultCenter] addObserverForName:NSTextInputContextKeyboardSelectionDidChangeNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *aNotification) {
                                                      if ([DictationManagerMetaClass isEnabled]) {
                                                          NSString *selectedInputMethodLanguage = [InputMethodManager language];
                                                          if (![[InputMethodManager bundleIdentifier] isEqualToString:kDictationIMBundleIdentifier] &&
                                                              ![selectedInputMethodLanguage isEqualToString:lastSelectedInputMethodLanguage]) {
                                                              lastSelectedInputMethodLanguage = selectedInputMethodLanguage;

                                                              NSString *dictationLocaleIdentifier;
                                                              for (NSString *localeIdentifier in [[NSUserDefaults standardUserDefaults] objectForKey:kAppUserDefaultDictationLocaleIdentifiers]) {
                                                                  if ([selectedInputMethodLanguage isEqualToString:[LocaleManager canonicalLocaleIdentifierFromString:localeIdentifier
                                                                                                                                                        forComponents:@[NSLocaleLanguageCode, NSLocaleScriptCode]]]) {
                                                                      dictationLocaleIdentifier = localeIdentifier;
                                                                      break;
                                                                  }
                                                              }
                                                              if (!dictationLocaleIdentifier) {
                                                                  dictationLocaleIdentifier = [[[NSUserDefaults standardUserDefaults] arrayForKey:kAppUserDefaultDictationLocaleIdentifiers] objectAtIndex:0];
                                                              }

                                                              [DictationManagerMetaClass setLocaleIdentifier:[LocaleManager canonicalLocaleIdentifierFromString:dictationLocaleIdentifier
                                                                                                                                         forComponents:@[NSLocaleLanguageCode, NSLocaleCountryCode]]];
                                                              [DictationManagerMetaClass terminate];
                                                          }
                                                      }
                                                      [self setStatusItem];
                                                  }];

    [[NSNotificationCenter defaultCenter] postNotificationName:NSTextInputContextKeyboardSelectionDidChangeNotification
                                                        object:self];
}

- (void)setStatusItem
{
    if (!statusItem) {
        statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
        [statusItem setHighlightMode:YES];
        [statusItem setMenu:mainMenu];
    }
    if ([DictationManagerMetaClass isEnabled]) {
        [statusItem setImage:[NSImage imageNamed:@"StatusBarIcon"]];
        [statusItem setAlternateImage:[NSImage imageNamed:@"StatusBarIconAlternate"]];
    } else {
        [statusItem setImage:[NSImage imageNamed:@"StatusBarIconOff"]];
        [statusItem setAlternateImage:[NSImage imageNamed:@"StatusBarIconOffAlternate"]];
    }
    if ([DictationManagerMetaClass isEnabled] && [[NSUserDefaults standardUserDefaults] boolForKey:kAppUserDefaultDictationLanguageInStatusbar]) {
        [statusItem setAttributedTitle:[[NSAttributedString alloc] initWithString:[[NSLocale currentLocale] displayNameForKey:NSLocaleIdentifier
                                                                                                                        value:[DictationManagerMetaClass localeIdentifier]]
                                                                       attributes:@{
                                                              NSFontAttributeName:[NSFont systemFontOfSize:11]
                                        }]];
    } else {
        [statusItem setTitle:nil];
    }
}

- (NSDictionary *)preferedLocaleIdentifiers
{
    NSMutableDictionary *preferedLocaleIdentifiers = [NSMutableDictionary dictionary];
    for (NSString *localeIdentifier in [[NSUserDefaults standardUserDefaults] arrayForKey:kAppUserDefaultDictationLocaleIdentifiers]) {
        NSString *language = [LocaleManager canonicalLocaleIdentifierFromString:localeIdentifier
                                                                  forComponents:@[NSLocaleLanguageCode, NSLocaleScriptCode]];
        if (![preferedLocaleIdentifiers objectForKey:language]) {
            [preferedLocaleIdentifiers setObject:localeIdentifier forKey:language];
        }
    }
    return [preferedLocaleIdentifiers copy];
}

- (void)menuNeedsUpdate:(NSMenu *)menu
{
    if (menu == mainMenu) {
        NSDictionary *preferedLocaleIdentifiers = [self preferedLocaleIdentifiers];
        for (NSMenuItem *menuItem in [menu itemArray]) {
            NSString *localeIdentifier = [[menuItem representedObject] objectForKey:kAppMenuItemLocaleIdentifier];
            if (localeIdentifier) {
                if ([localeIdentifier isEqualToString:[preferedLocaleIdentifiers objectForKey:[[menuItem representedObject] objectForKey:kAppMenuItemLanguage]]]) {
                    [menuItem setState:NSOnState];
                } else {
                    [menuItem setState:NSOffState];
                }
            }
        }
        if ([[NSUserDefaults standardUserDefaults] boolForKey:kAppUserDefaultDictationLanguageInStatusbar]) {
            [showDictationLanguageInStatusbarMenuItem setHidden:YES];
            [hideDictationLanguageInStatusbarMenuItem setHidden:NO];
        } else {
            [hideDictationLanguageInStatusbarMenuItem setHidden:YES];
            [showDictationLanguageInStatusbarMenuItem setHidden:NO];
        }
    }
}

- (void)languageMenuItemAction:(id)sender
{
    NSMutableArray *localeIdentifiers = [[[NSUserDefaults standardUserDefaults] arrayForKey:kAppUserDefaultDictationLocaleIdentifiers] mutableCopy];
    NSInteger idx1 = [localeIdentifiers indexOfObject:[[sender representedObject] objectForKey:kAppMenuItemLocaleIdentifier]];
    NSInteger idx2 = [localeIdentifiers indexOfObject:[[self preferedLocaleIdentifiers] objectForKey:[[sender representedObject] objectForKey:kAppMenuItemLanguage]]];
    if (idx1 != idx2) {
        [localeIdentifiers exchangeObjectAtIndex:idx1 withObjectAtIndex:idx2];
        [[NSUserDefaults standardUserDefaults] setObject:localeIdentifiers
                                                  forKey:kAppUserDefaultDictationLocaleIdentifiers];
        [[NSUserDefaults standardUserDefaults] synchronize];

        lastSelectedInputMethodLanguage = nil;
        [[NSNotificationCenter defaultCenter] postNotificationName:NSTextInputContextKeyboardSelectionDidChangeNotification
                                                            object:self];
    }
}


- (IBAction)toggleDictationLanguageInStatusbarAction:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setBool:![[NSUserDefaults standardUserDefaults] boolForKey:kAppUserDefaultDictationLanguageInStatusbar]
                                            forKey:kAppUserDefaultDictationLanguageInStatusbar];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self setStatusItem];
}

- (IBAction)openDictationAndSpeechPreferencesAction:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL fileURLWithPath:@"/System/Library/PreferencePanes/Speech.prefPane"]];
}

@end
