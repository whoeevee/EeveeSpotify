#import <UIKit/UIKit.h>

@interface EVEBundleHelper : NSObject
@property (nonatomic, strong, readonly) NSBundle *bundle;
+ (instancetype)sharedHelper;
- (NSData *)premiumBlankData;
- (void)showPopupWithMessage:(NSString *)msg buttonText:(NSString *)bText;
- (NSError *)giveURL:(NSURL *)url permissions:(short)perms;
@end

@interface UITabBarButtonLabel : UILabel
@end
