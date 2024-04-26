#import <objc/runtime.h>
#import "Headers/EVEPopUpHelper.h"
#import "Headers/SPTEncorePopUpDialog.h"
#import "Headers/SPTEncorePopUpPresenter.h"
#import "Headers/SPTEncorePopUpDialogModel.h"

@implementation EVEPopUpHelper
+ (void)showPopUpWithMessage:(NSString *)message buttonText:(NSString *)buttonText {
    SPTEncorePopUpDialogModel *model =
        [[objc_getClass("SPTEncorePopUpDialogModel") alloc]
                               initWithTitle:@"EeveeSpotify"
                                 description:message
                                       image:nil
                          primaryButtonTitle:buttonText
                        secondaryButtonTitle:nil];

    SPTEncorePopUpDialog *dialog = [objc_getClass("SPTEncorePopUpDialog") new];
    SPTEncorePopUpPresenter *popUpPresenter = [objc_getClass("SPTEncorePopUpPresenter") shared];

    [dialog update:model];
    [dialog setEventHandler:^{
        [popUpPresenter dismissPopupWithAnimate:YES
                                     clearQueue:NO
                                     completion:nil];
    }];

    [popUpPresenter presentPopUp:dialog];
}
@end
