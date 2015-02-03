//
//  Imagine.xm
//  Imagine
//
//  Created by Timm Kandziora on 26.01.15.
//  Copyright (c) 2015 Timm Kandziora. All rights reserved.
//

#import "ImagineHeader.h"

static BOOL isVisible = NO;
static BOOL isEditing = NO;

static CGFloat _lastScale = 0.0;
static CGFloat _firstX = 0.0;
static CGFloat _firstY = 0.0;

static UIImageView *imageView = nil;
static UILabel *hudLabel = nil;
static UIView *hudView = nil;
static UIView *view = nil;
static UIWindow *window = nil;

static CGFloat alphaSlider = 1.0;

@implementation ImagineWindow

- (ImagineWindow *)init
{
	if (self = [super initWithFrame:[UIScreen mainScreen].bounds]) {
		#ifdef __IPHONE_8_0
		[self _setSecure:YES];
		#endif
	}

	return self;
}

- (BOOL)_ignoresHitTest
{
	return !isEditing;
}

@end

%hook SpringBoard

- (void)applicationDidFinishLaunching:(id)application
{
	%orig;

	window = [[ImagineWindow alloc] init];
	window.windowLevel = 9223372036854775807;
	window.hidden = !isVisible;
	window.userInteractionEnabled = YES;

	view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
	view.alpha = alphaSlider;
	view.backgroundColor = [UIColor clearColor];
	view.userInteractionEnabled = YES;

	CGRect frame = CGRectMake([[UIScreen mainScreen] bounds].size.width / 2 - 100, [[UIScreen mainScreen] bounds].size.height / 2 - 100, 200, 200);
	hudView = [[UIView alloc] initWithFrame:frame];
	hudView.layer.cornerRadius = 8;
	hudView.layer.masksToBounds = YES;
	hudView.backgroundColor = [UIColor grayColor];
	hudView.alpha = 0.0;
	hudView.userInteractionEnabled = NO;

	hudLabel =[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
	hudLabel.font = [UIFont fontWithName:@"Helvetica-Light" size:15];
	hudLabel.textAlignment = NSTextAlignmentCenter;
	hudLabel.textColor = [UIColor whiteColor];
	hudLabel.userInteractionEnabled = NO;

	imageView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:imagePath]];
	imageView.contentMode = UIViewContentModeScaleAspectFit;
	imageView.frame = CGRectMake(0, 0, 100, 100);
	imageView.userInteractionEnabled = NO;

	UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(scale:)];
	[pinchRecognizer setDelegate:self];
	[view addGestureRecognizer:pinchRecognizer];

	UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(move:)];
	[panRecognizer setMinimumNumberOfTouches:1];
	[panRecognizer setMaximumNumberOfTouches:1];
	[panRecognizer setDelegate:self];
	[view addGestureRecognizer:panRecognizer];

	[hudView addSubview:hudLabel];
	[view addSubview:imageView];
	[view addSubview:hudView];
	[window addSubview:view];
}

%new - (void)scale:(UIPinchGestureRecognizer *)sender
{
	if ([sender state] == UIGestureRecognizerStateBegan) {
		_lastScale = 1.0;
	}

	CGFloat scale = 1.0 - (_lastScale - [sender scale]);

	CGAffineTransform currentTransform = imageView.transform;
	CGAffineTransform newTransform = CGAffineTransformScale(currentTransform, scale, scale);

	[imageView setTransform:newTransform];

	_lastScale = [sender scale];
}

%new - (void)move:(UIPanGestureRecognizer *)sender
{
	CGPoint translatedPoint = [sender translationInView:view];

	if ([sender state] == UIGestureRecognizerStateBegan) {
		_firstX = [imageView center].x;
		_firstY = [imageView center].y;
	}

	translatedPoint = CGPointMake(_firstX + translatedPoint.x, _firstY + translatedPoint.y);

	[imageView setCenter:translatedPoint];
}

%new - (void)showHud
{
	hudLabel.text = [NSString stringWithFormat:@"Edit mode %@", isEditing ? @"activated." : @"deactivated."];

	[UIView animateWithDuration:1.0 animations:^{
		hudView.alpha = 1.0;
	} completion:nil];

	[self performSelector:@selector(hideHud) withObject:nil afterDelay:2.0];
}

%new - (void)hideHud
{
	[UIView animateWithDuration:1.0 animations:^{
		hudView.alpha = 0.0;
	} completion:nil];
}

%end

static void ReloadSettings()
{
	NSMutableDictionary *settings = [[NSMutableDictionary alloc] initWithContentsOfFile:settingsPath];

	if (settings) {
		if ([settings objectForKey:@"alphaSlider"]) {
			alphaSlider = [[settings objectForKey:@"alphaSlider"] floatValue];

			if (view) {
				view.alpha = alphaSlider;
			}
		}
	}
}

%ctor {
	@autoreleasepool {
		ReloadSettings();
		CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)ReloadSettings, CFSTR("com.shinvou.imagine/reloadWallmartSettings"), NULL, CFNotificationSuspensionBehaviorCoalesce);

		[[NSDistributedNotificationCenter defaultCenter] addObserverForName:@"ImagineImageChanged" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
			[imageView performSelectorOnMainThread:@selector(removeFromSuperview) withObject:nil waitUntilDone:NO];
			imageView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:imagePath]];
			imageView.frame = CGRectMake(0, 0, 100, 100);
			imageView.contentMode = UIViewContentModeScaleAspectFit;
			[view addSubview:imageView];
		}];

		[[NSDistributedNotificationCenter defaultCenter] addObserverForName:@"ImagineEditModeChanged" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
			if (isVisible) {
				isEditing = !isEditing;
				[(SpringBoard *)[UIApplication sharedApplication] showHud];
			}
		}];

		[[NSDistributedNotificationCenter defaultCenter] addObserverForName:@"ImagineVisibilityChanged" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
			isVisible = !isVisible;
			window.hidden = !isVisible;
		}];
	}
}
