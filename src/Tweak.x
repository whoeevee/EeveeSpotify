#import "EVEBundleHelper.h"

%hook NSURL
- (instancetype)initWithString:(NSString *)string relativeToURL:(NSURL *)url {
    NSString *finalString = [[string stringByReplacingOccurrencesOfString:@"trackRows=false" withString:@"trackRows=true"]
                                stringByReplacingOccurrencesOfString:@"video=false" withString:@"video=true"];

    return %orig(finalString, url);
}
%end

%hook AppDelegate
- (BOOL)application:(id)app didFinishLaunchingWithOptions:(id)opts {
    %orig(app, opts);

    @try {
        NSArray<NSURL *> *fileURLs = [[NSFileManager defaultManager] 
                                        URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask];
        NSURL *filePath = [fileURLs.firstObject URLByAppendingPathComponent:@"PersistentCache/offline.bnk"];

        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath.path]) {
            NSData *fileData = [NSData dataWithContentsOfURL:filePath];

            NSUInteger usernameLength = (NSUInteger)(((const char *)[fileData bytes])[8]);
            NSData *usernameData = [fileData subdataWithRange:NSMakeRange(9, usernameLength)];

            NSMutableData *blankData = [[[EVEBundleHelper sharedHelper] premiumBlankData] mutableCopy];

            // range(whatever, 0) is for INSERTING data (Data.insert swift equivalent) (also needs length: i think?)
            [blankData replaceBytesInRange:NSMakeRange(8, 0) withBytes:(const void *)&usernameLength length:1];
            [blankData replaceBytesInRange:NSMakeRange(9, 0) withBytes:[usernameData bytes] length:[usernameData length]];

            [blankData writeToURL:filePath atomically:NO];
            NSLog(@"[EeveeSpotify] Successfully applied");
        } else {
            NSLog(@"[EeveeSpotify] Not activating due to nonexistent file: %@", filePath.path);
        }
    } @catch (NSException *error) {
        NSLog(@"[EeveeSpotify] Unable to apply tweak: %@", error);
    }

    return YES;
}
%end

%ctor {
    %init(AppDelegate = objc_getClass("MusicApp_ContainerWiring.SpotifyAppDelegate"));
}
