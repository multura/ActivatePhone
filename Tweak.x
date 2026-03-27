#import <CoreFoundation/CoreFoundation.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface PassWindow: UIWindow
@end
@implementation PassWindow
- (BOOL)_ignoresHitTest { return YES; }
- (BOOL)_usesWindowServerHitTesting { return NO; }
@end

@interface PassLabel: UILabel
@end
@implementation PassLabel
@end

static UIWindow *_noteWindow = nil;

static NSString* localizedString(NSString *key) {
    NSArray<NSString *> *preferred = [NSLocale preferredLanguages];
    NSString *lang = (preferred.count > 0) ? preferred[0] : @"en";
    
    NSDictionary *strings = @{
        @"en": @{@"title": @"Activate iOS",
                 @"subtitle": @"Go to “Settings” to activate iOS."},
        @"ru": @{@"title": @"Активируйте iOS",
                 @"subtitle": @"Перейдите в «Настройки», чтобы активировать iOS."}
    };
    
    NSDictionary *langDict = strings[([lang hasPrefix:@"ru"] ? @"ru" : @"en")];
    return langDict[key];
}

static void createNoteWindow() {
    if (!_noteWindow) {
        _noteWindow = [[PassWindow alloc] init];

        CGSize screenSize = [[UIScreen mainScreen] bounds].size;
        CGSize windowSize = CGSizeMake(screenSize.width, 0);
        CGRect windowFrame = CGRectMake(0, (screenSize.height - windowSize.height)/2.0, windowSize.width, windowSize.height);
        _noteWindow.frame = windowFrame;
        _noteWindow.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0];
        _noteWindow.windowLevel = UIWindowLevelAlert;
        _noteWindow.userInteractionEnabled = NO;

        UILabel *firstLineLabel = [[PassLabel alloc] initWithFrame:CGRectMake(0,0,windowSize.width,CGFLOAT_MAX)];
        firstLineLabel.translatesAutoresizingMaskIntoConstraints = NO;
        firstLineLabel.userInteractionEnabled = NO;
        firstLineLabel.textAlignment = NSTextAlignmentCenter;
        firstLineLabel.textColor = [UIColor colorWithWhite:0.57 alpha:0.5];
        firstLineLabel.font = [UIFont systemFontOfSize:24.0];
        firstLineLabel.numberOfLines = 1;
        firstLineLabel.text = localizedString(@"title");
        [firstLineLabel sizeToFit];
        [_noteWindow addSubview:firstLineLabel];

        UILabel *secondLineLabel = [[PassLabel alloc] initWithFrame:CGRectMake(0, firstLineLabel.bounds.size.height, windowSize.width, CGFLOAT_MAX)];
        secondLineLabel.translatesAutoresizingMaskIntoConstraints = NO;
        secondLineLabel.userInteractionEnabled = NO;
        secondLineLabel.textAlignment = NSTextAlignmentCenter;
        secondLineLabel.textColor = [UIColor colorWithWhite:0.57 alpha:0.5];
        secondLineLabel.font = [UIFont systemFontOfSize:13.0];
        secondLineLabel.numberOfLines = 1;
        secondLineLabel.text = localizedString(@"subtitle");
        [secondLineLabel sizeToFit];
        [_noteWindow addSubview:secondLineLabel];

        windowSize.height = firstLineLabel.bounds.size.height + secondLineLabel.bounds.size.height;
        _noteWindow.frame = CGRectMake(0, (screenSize.height - windowSize.height)/2.0, windowSize.width, windowSize.height);
    }
}

static BOOL enabled = YES;

static void notificationCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
    if (enabled) {
        [_noteWindow makeKeyAndVisible];
    } else {
        [_noteWindow setHidden:YES];
    }
}

%hook SpringBoard
- (void)applicationDidFinishLaunching:(UIApplication *)application {
    createNoteWindow();
    notificationCallback(NULL, NULL, NULL, NULL, NULL);
    %orig;
}
%end

%ctor {
    notificationCallback(NULL, NULL, NULL, NULL, NULL);
}
