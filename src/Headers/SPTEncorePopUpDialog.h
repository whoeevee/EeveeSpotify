#import <Foundation/Foundation.h>
#import "SPTEncorePopUpDialogModel.h"

@interface SPTEncorePopUpDialog : NSObject
- (void)update:(SPTEncorePopUpDialogModel *)popUpModel;
- (void)setEventHandler:(void (^)(void))handler;
@end
