//
//  ImagineEvents.xm
//  Imagine
//
//  Created by Timm Kandziora on 26.01.15.
//  Copyright (c) 2015 Timm Kandziora. All rights reserved.
//

#import <libactivator/libactivator.h>
#import <Foundation/NSDistributedNotificationCenter.h>

@interface ImagineChangeEditMode : NSObject <LAListener>
@end

@implementation ImagineChangeEditMode

- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event
{
	[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"ImagineEditModeChanged" object:nil userInfo:nil];

	[event setHandled:YES]; // To prevent the default OS implementation
}

- (NSString *)activator:(LAActivator *)activator requiresLocalizedTitleForListenerName:(NSString *)listenerName
{
	return @"Imagine";
}

- (NSString *)activator:(LAActivator *)activator requiresLocalizedDescriptionForListenerName:(NSString *)listenerName
{
	return @"Change edit mode";
}

- (NSArray *)activator:(LAActivator *)activator requiresCompatibleEventModesForListenerWithName:(NSString *)listenerName
{
	return [NSArray arrayWithObjects:@"springboard", @"lockscreen", @"application", nil];
}

+ (void)load
{
	if ([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.apple.springboard"]) {
		[[%c(LAActivator) sharedInstance] registerListener:[self new] forName:@"com.shinvou.imagine.changeeditmode"];
	}
}

@end

@interface ImagineChangeVisibility : NSObject <LAListener>
@end

@implementation ImagineChangeVisibility

- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event
{
	[[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"ImagineVisibilityChanged" object:nil userInfo:nil];

	[event setHandled:YES]; // To prevent the default OS implementation
}

- (NSString *)activator:(LAActivator *)activator requiresLocalizedTitleForListenerName:(NSString *)listenerName
{
	return @"Imagine";
}

- (NSString *)activator:(LAActivator *)activator requiresLocalizedDescriptionForListenerName:(NSString *)listenerName
{
	return @"Change visibility";
}

- (NSArray *)activator:(LAActivator *)activator requiresCompatibleEventModesForListenerWithName:(NSString *)listenerName
{
	return [NSArray arrayWithObjects:@"springboard", @"lockscreen", @"application", nil];
}

+ (void)load
{
	if ([[[NSBundle mainBundle] bundleIdentifier] isEqualToString:@"com.apple.springboard"]) {
		[[%c(LAActivator) sharedInstance] registerListener:[self new] forName:@"com.shinvou.imagine.changevisibility"];
	}
}

@end
