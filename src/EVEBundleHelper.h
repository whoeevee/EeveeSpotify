#import <Foundation/Foundation.h>
#import <libroot.h>

@interface EVEBundleHelper : NSObject
@property (nonatomic, strong, readonly) NSBundle *bundle;
+ (instancetype)sharedHelper;
- (NSData *)premiumBlankData;
@end
