//
//  ImagineHeader.h
//  Imagine
//
//  Created by Timm Kandziora on 26.01.15.
//  Copyright (c) 2015 Timm Kandziora. All rights reserved.
//

#import <Foundation/NSDistributedNotificationCenter.h>

#define imagePath @"/var/mobile/Library/Imagine/nietzsche.png"
#define settingsPath @"/var/mobile/Library/Preferences/com.shinvou.imagine.plist"

@interface UIWindow (Imagine)
- (void)_setSecure:(BOOL)secure;
@end

@interface ImagineWindow : UIWindow
@end

@interface SpringBoard : NSObject <UIGestureRecognizerDelegate>
- (void)applicationDidFinishLaunching:(id)application;
- (void)scale:(id)sender;
- (void)move:(id)sender;
- (void)showHud;
- (void)hideHud;
@end
