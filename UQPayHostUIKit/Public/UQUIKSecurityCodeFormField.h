#import "UQUIKFormField.h"

/// @class Form field to collect a mobile country code
@interface UQUIKSecurityCodeFormField : UQUIKFormField

/// The security code
@property (nonatomic, copy, nullable, readonly) NSString *securityCode;

@end
