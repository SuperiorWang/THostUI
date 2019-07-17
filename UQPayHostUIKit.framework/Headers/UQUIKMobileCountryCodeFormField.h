#import "UQUIKFormField.h"

/// @class Form field to collect a mobile country code
@interface UQUIKMobileCountryCodeFormField : UQUIKFormField

/// The country code
@property (nonatomic, copy, nullable, readonly) NSString *countryCode;

@end
