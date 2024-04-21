#import "EVEBundleHelper.h"
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
    return [NSData dataWithContentsOfURL:[self.bundle URLForResource:@"premiumblank" withExtension:@"bnk"]];
}

- (void)showPopupWithTitle:(NSString *)title message:(NSString *)msg buttonText:(NSString *)bText {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                message:msg
                                preferredStyle:UIAlertControllerStyleAlert];

            [alert addAction:[UIAlertAction actionWithTitle:bText
                                style:UIAlertActionStyleDefault
                                handler:nil]];

            [UIApplication.sharedApplication.delegate.window.rootViewController
                        presentViewController:alert animated:YES completion:nil];
        });
    });
}
@end
