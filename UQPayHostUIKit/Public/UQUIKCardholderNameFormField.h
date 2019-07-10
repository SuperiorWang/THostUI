#import "UQUIKFormField.h"

@interface UQUIKCardholderNameFormField : UQUIKFormField

/// The cardholder name
@property (nonatomic, strong, readonly) NSString *cardholderName;

/// Is cardholder name input required
@property (nonatomic, assign) BOOL isRequired;

@end
