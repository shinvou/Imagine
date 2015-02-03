#import <Preferences/Preferences.h>

#import <Foundation/NSDistributedNotificationCenter.h>

#define settingsPath @"/var/mobile/Library/Preferences/com.shinvou.imagine.plist"
#define UIColorRGB(r, g, b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0]

@interface ImagineBanner : PSTableCell
@end

@implementation ImagineBanner

- (id)initWithStyle:(int)style reuseIdentifier:(NSString *)identifier specifier:(PSSpecifier *)specifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"imagineBannerCell" specifier:specifier];
    
    if (self) {
        self.backgroundColor = UIColorRGB(74, 74, 74);
        
        UILabel *label =[[UILabel alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 206)];
        label.font = [UIFont fontWithName:@"Helvetica-Light" size:60];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor whiteColor];
        label.text = @"#pantarhei";
        
        [self addSubview:label];
    }
    
    return self;
}

@end

@interface ImagineSettingsListController : PSListController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@end

@implementation ImagineSettingsListController

- (id)specifiers
{
    if (_specifiers == nil) {
        [self setTitle:@"Imagine"];
        
        PSSpecifier *banner = [PSSpecifier preferenceSpecifierNamed:nil
                                                             target:self
                                                                set:NULL
                                                                get:NULL
                                                             detail:Nil
                                                               cell:PSStaticTextCell
                                                               edit:Nil];
        [banner setProperty:[ImagineBanner class] forKey:@"cellClass"];
        [banner setProperty:@"206" forKey:@"height"];
        
        PSSpecifier *firstGroup = [PSSpecifier groupSpecifierWithName:nil];
        [firstGroup setProperty:@"Set alpha of the image." forKey:@"footerText"];
        
        PSSpecifier *alphaSlider = [PSSpecifier preferenceSpecifierNamed:nil
                                                                  target:self
                                                                     set:@selector(setValue:forSpecifier:)
                                                                     get:@selector(getValueForSpecifier:)
                                                                  detail:Nil
                                                                    cell:PSSliderCell
                                                                    edit:Nil];
        [alphaSlider setIdentifier:@"alphaSlider"];
        [alphaSlider setProperty:@(YES) forKey:@"enabled"];
        
        [alphaSlider setProperty:@(0) forKey:@"min"];
        [alphaSlider setProperty:@(1) forKey:@"max"];
        [alphaSlider setProperty:@(NO) forKey:@"showValue"];
        
        PSSpecifier *secondGroup = [PSSpecifier groupSpecifierWithName:nil];
        
        PSSpecifier *chooseImageButton = [PSSpecifier preferenceSpecifierNamed:nil
                                                                       target:self
                                                                          set:NULL
                                                                          get:NULL
                                                                       detail:nil
                                                                         cell:PSButtonCell
                                                                         edit:Nil];
        chooseImageButton.name = @"Choose Image";
        chooseImageButton->action = @selector(chooseImage);
        [chooseImageButton setIdentifier:@"chooseImageButton"];
        [chooseImageButton setProperty:@(YES) forKey:@"enabled"];
        
        PSSpecifier *thirdGroup = [PSSpecifier groupSpecifierWithName:@"contact developer"];
        [thirdGroup setProperty:@"Feel free to follow me on twitter for any updates on my apps and tweaks or contact me for support questions.\n \nThis tweak is Open-Source, so make sure to check out my GitHub." forKey:@"footerText"];
        
        PSSpecifier *twitter = [PSSpecifier preferenceSpecifierNamed:@"twitter"
                                                              target:self
                                                                 set:NULL
                                                                 get:NULL
                                                              detail:Nil
                                                                cell:PSLinkCell
                                                                edit:Nil];
        twitter.name = @"@biscoditch";
        twitter->action = @selector(openTwitter);
        [twitter setIdentifier:@"twitter"];
        [twitter setProperty:@(YES) forKey:@"enabled"];
        [twitter setProperty:[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/WallmartSettings.bundle/twitter.png"] forKey:@"iconImage"];
        
        PSSpecifier *github = [PSSpecifier preferenceSpecifierNamed:@"github"
                                                             target:self
                                                                set:NULL
                                                                get:NULL
                                                             detail:Nil
                                                               cell:PSLinkCell
                                                               edit:Nil];
        github.name = @"https://github.com/shinvou";
        github->action = @selector(openGithub);
        [github setIdentifier:@"github"];
        [github setProperty:@(YES) forKey:@"enabled"];
        [github setProperty:[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/WallmartSettings.bundle/github.png"] forKey:@"iconImage"];
        
        _specifiers = [NSArray arrayWithObjects:banner, firstGroup, alphaSlider, secondGroup, chooseImageButton, thirdGroup, twitter, github, nil];
    }
    
    return _specifiers;
}

- (id)getValueForSpecifier:(PSSpecifier *)specifier
{
    NSMutableDictionary *settings = [[NSMutableDictionary alloc] initWithContentsOfFile:settingsPath];
    
    if ([specifier.identifier isEqualToString:@"alphaSlider"]) {
        if (settings) {
            if ([settings objectForKey:@"alphaSlider"]) {
                return [settings objectForKey:@"alphaSlider"];
            } else {
                return @(1);
            }
        } else {
            return @(1);
        }
    }
    
    return nil;
}

- (void)setValue:(id)value forSpecifier:(PSSpecifier *)specifier
{
    NSMutableDictionary *settings = [[NSMutableDictionary alloc] init];
    [settings addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:settingsPath]];
    
    if ([specifier.identifier isEqualToString:@"alphaSlider"]) {
        [settings setObject:value forKey:@"alphaSlider"];
        [settings writeToFile:settingsPath atomically:YES];
    }
    
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.shinvou.imagine/reloadWallmartSettings"), NULL, NULL, TRUE);
}

- (void)chooseImage
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.allowsEditing = YES;
    imagePicker.delegate = self;
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self.navigationController presentViewController:imagePicker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *imagePath = @"/var/mobile/Library/Imagine/nietzsche.png";
    UIImage *picture = info[UIImagePickerControllerEditedImage];
    NSData *imageData = UIImagePNGRepresentation(picture);
    [imageData writeToFile:imagePath atomically:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
    
    [[NSDistributedNotificationCenter defaultCenter] postNotificationName:@"ImagineImageChanged" object:nil userInfo:nil];
}

- (void)openTwitter
{
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetbot:"]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tweetbot:///user_profile/biscoditch"]];
    } else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitterrific:"]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"twitterrific:///profile?screen_name=biscoditch"]];
    } else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetings:"]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tweetings:///user?screen_name=biscoditch"]];
    } else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter:"]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"twitter://user?screen_name=biscoditch"]];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://mobile.twitter.com/biscoditch"]];
    }
}

- (void)openGithub
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/shinvou"]];
}

@end
