#import <UIKit/UIKit.h>
#import "UQUIKPaymentOptionType.h"

/// @class A UILabel that contains images representing multiple UQUIKPaymentOptionType's
@interface UQUIKCardListLabel : UILabel

/// The array of UQUIKPaymentOptionType's to display
@property (nonatomic, copy) NSArray* availablePaymentOptions;

/// The UQUIKPaymentOptionType to emphasize by fading all other payment methods included in availablePaymentOptions
- (void)emphasizePaymentOption:(UQUIKPaymentOptionType)paymentOption;

@end
