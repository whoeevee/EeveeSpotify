#import "EVEBundleHelper.h"

%hook NSURL
- (instancetype)initWithString:(NSString *)string relativeToURL:(NSURL *)url {
    NSString *finalString = [[string stringByReplacingOccurrencesOfString:@"trackRows=false" withString:@"trackRows=true"]
                                stringByReplacingOccurrencesOfString:@"video=false" withString:@"video=true"];

    return %orig(finalString, url);
}
%end

%hook AppDelegate
- (BOOL)application:(id)app willFinishLaunchingWithOptions:(id)opts {
    %orig(app, opts);

    @try {
        NSArray<NSURL *> *fileURLs = [[NSFileManager defaultManager] 
                                        URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask];
        NSURL *filePath = [fileURLs.firstObject URLByAppendingPathComponent:@"PersistentCache/offline.bnk"];

        if (![[NSFileManager defaultManager] fileExistsAtPath:filePath.path]) {
            NSLog(@"[EeveeSpotify] Not activating due to nonexistent file: %@", filePath.path);

            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [[EVEBundleHelper sharedHelper] showPopupWithTitle:@"EeveeSpotify"
                    message:@"An offline.bnk file was not found. Please log in and restart the app when you're done!"
                    buttonText:@"Okay!"];
            });

            return YES;
        };

        NSData *fileData = [NSData dataWithContentsOfURL:filePath];
        NSUInteger usernameLength = (NSUInteger)(((const char *)[fileData bytes])[8]);
        NSData *usernameData = [fileData subdataWithRange:NSMakeRange(9, usernameLength)];
        NSMutableData *blankData = [[[EVEBundleHelper sharedHelper] premiumBlankData] mutableCopy];

        // range(whatever, 0) is for INSERTING data (Data.insert swift equivalent) (also needs length: i think?)
        [blankData replaceBytesInRange:NSMakeRange(8, 0) withBytes:(const void *)&usernameLength length:1];
        [blankData replaceBytesInRange:NSMakeRange(9, 0) withBytes:[usernameData bytes] length:[usernameData length]];

        [blankData writeToURL:filePath atomically:NO];
        NSLog(@"[EeveeSpotify] Successfully applied");

        // runs in background, reapplies every 20 seconds, maybe this could be useful?
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            for (;;) {
                // waits 20 seconds without blocking thread
                dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
                dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(20.0 * NSEC_PER_SEC));
                dispatch_after(delay, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                    dispatch_semaphore_signal(semaphore);
                });
                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);

                [blankData writeToURL:filePath atomically:NO];
                NSLog(@"[EeveeSpotify] Successfully reapplied");
            };
        });
    } @catch (NSException *error) {
        NSLog(@"[EeveeSpotify] Unable to apply tweak: %@", error);
    }

    return YES;
}
%end

%ctor {
    %init(AppDelegate = objc_getClass("MusicApp_ContainerWiring.SpotifyAppDelegate"));
}
