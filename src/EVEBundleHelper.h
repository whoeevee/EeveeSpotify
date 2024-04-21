#import <UIKit/UIKit.h>

@interface EVEBundleHelper : NSObject
@property (nonatomic, strong, readonly) NSBundle *bundle;
+ (instancetype)sharedHelper;
- (NSData *)premiumBlankData;
- (void)showPopupWithTitle:(NSString *)title message:(NSString *)msg buttonText:(NSString *)bText;
@end

@interface UITabBarButtonLabel : UILabel
@end
