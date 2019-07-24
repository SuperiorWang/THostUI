#import "UQUIKFormField.h"

/// @class Form field to collect a mobile phone number
@interface UQUIKMobileNumberFormField : UQUIKFormField

/// The mobile phone number
@property (nonatomic, copy, nullable, readonly) NSString *mobileNumber;

@end
