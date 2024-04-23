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
    return [NSData dataWithContentsOfURL:[self.bundle URLForResource:@"premiumblankreal" withExtension:@"bnk"]];
}

- (void)showPopupWithMessage:(NSString *)msg buttonText:(NSString *)bText {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"EeveeSpotify"
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

- (NSError *)giveURL:(NSURL *)url permissions:(short)perms {
    NSError *err;
    [[NSFileManager defaultManager] setAttributes:@{NSFilePosixPermissions: [NSNumber numberWithShort:perms]}
                                                        ofItemAtPath:url.path error:&err];
    return err;
}
@end
