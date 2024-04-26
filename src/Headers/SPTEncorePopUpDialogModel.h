#import <Foundation/Foundation.h>

@interface SPTEncorePopUpDialogModel : NSObject
- (instancetype)initWithTitle:(NSString *)title
                  description:(NSString *)description
                        image:(id)image
           primaryButtonTitle:(NSString *)primaryButtonTitle
         secondaryButtonTitle:(NSString *)secondaryButtonTitle;
@end
