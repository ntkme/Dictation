//
//  AppDelegate.h
//  Dictation
//
//  Created by 夏目夏樹 on 12/16/12.
//  Copyright (c) 2012 夏目夏樹. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <objc/runtime.h>

@interface AppDelegate : NSObject <NSApplicationDelegate, NSMenuDelegate> {
    Class DictationManagerMetaClass;
    IBOutlet NSMenu *mainMenu;
    IBOutlet NSMenuItem *showDictationLanguageInStatusbarMenuItem;
    IBOutlet NSMenuItem *hideDictationLanguageInStatusbarMenuItem;
    IBOutlet NSMenuItem *openAtLoginMenuItem;
    NSStatusItem *statusItem;
    NSString *lastSelectedInputMethodLanguage;
}
@end
