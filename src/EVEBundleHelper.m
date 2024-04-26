#import "Headers/EVEBundleHelper.h"
#import <libroot.h>

@implementation EVEBundleHelper
@synthesize bundle = _bundle;

/* cls methods */
+ (instancetype)sharedHelper {
    static EVEBundleHelper *sharedHelper;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedHelper = [self new];
    });

    return sharedHelper;
}

/* inst methods */
- (instancetype)init {
    if (self = [super init]) {
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"EeveeSpotify" ofType:@"bundle"]
                                    ?: JBROOT_PATH_NSSTRING(@"/Library/Application Support/EeveeSpotify.bundle");

        _bundle = [NSBundle bundleWithPath:bundlePath];
    };

    return self;
}

- (NSData *)premiumBlankData {
    return [NSData dataWithContentsOfURL:[self.bundle URLForResource:@"premiumblankreal" withExtension:@"bnk"]];
}
@end
