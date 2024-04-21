#import "EVEBundleHelper.h"

%hook UITabBar
- (NSArray *)items {
    return [%orig subarrayWithRange:NSMakeRange(0, 3)];  // there is only one UITabBar, so no problem
}
%end

// this method is called quite a lot, but only when you switch tabs, so it's fine i guess
%hook UITabBarButtonLabel
- (NSString *)text {
    NSString *t = %orig;

    // comment while open sourcing: i originally thought i fucked up because "Premium" wouldn't match other languages.
    // however somehow this actually does work? for all languages?? weird, but whatever, no complaints lmao
    if ([t isEqualToString:@"Premium"]) [self.superview removeFromSuperview];

    return t;
}
%end
