#import "Foundation/Foundation.h"

@interface SPTEncorePopUpPresenter : NSObject
@property(class, strong, readonly) SPTEncorePopUpPresenter *shared;
- (BOOL)presentPopUp:(SPTEncorePopUpDialog *)popUp;
- (void)dismissPopupWithAnimate:(BOOL)animate
                     clearQueue:(BOOL)clearQueue
                     completion:(id)completion;
@end
