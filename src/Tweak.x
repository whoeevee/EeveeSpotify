#import "EVEBundleHelper.h"

%hook NSURL
- (instancetype)initWithString:(NSString *)string relativeToURL:(NSURL *)url {
    NSString *finalString = [[string stringByReplacingOccurrencesOfString:@"trackRows=false" withString:@"trackRows=true"]
                                stringByReplacingOccurrencesOfString:@"video=false" withString:@"video=true"];

    return %orig(finalString, url);
}
%end

%ctor {
    @try {
        NSArray<NSURL *> *fileURLs = [[NSFileManager defaultManager] 
                                        URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask];
        NSURL *filePath = [fileURLs.firstObject URLByAppendingPathComponent:@"PersistentCache/offline.bnk"];

        NSData *fileData = [NSData dataWithContentsOfURL:filePath];

        NSUInteger usernameLength = (NSUInteger)(((const char *)[fileData bytes])[8]);
        NSData *usernameData = [fileData subdataWithRange:NSMakeRange(9, usernameLength)];

        NSMutableData *blankData = [[[EVEBundleHelper sharedHelper] premiumBlankData] mutableCopy];
        [blankData replaceBytesInRange:NSMakeRange(8, 0) withBytes:&usernameLength length:sizeof(usernameLength)];
        [blankData replaceBytesInRange:NSMakeRange(9, 0) withBytes:[usernameData bytes] length:[usernameData length]];

        [blankData writeToURL:filePath atomically:YES];

        NSLog(@"[EeveeSpotify] Successfully applied");
    } @catch (NSException *error) {
        NSLog(@"[EeveeSpotify] Unable to apply tweak: %@", error);
    }
}
