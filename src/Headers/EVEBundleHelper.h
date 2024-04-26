#import <UIKit/UIKit.h>

@interface EVEBundleHelper : NSObject
@property(nonatomic, strong, readonly) NSBundle *bundle;
@property(class, strong, readonly) EVEBundleHelper *sharedHelper;
- (NSData *)premiumBlankData;
@end

@interface UITabBarButtonLabel : UILabel
@end
