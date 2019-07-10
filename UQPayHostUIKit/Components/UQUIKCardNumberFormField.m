#import "UQUIKCardNumberFormField.h"
#import "UQUIKPaymentOptionCardView.h"
#import "UQUIKLocalizedString.h"
#import "UQUIKUtil.h"
#import "UQUIKTextField.h"
#import "UQUIKViewUtil.h"
#import "UQUIKInputAccessoryToolbar.h"
#import "UQUIKAppearance.h"

#define TEMP_KERNING 8.0

@interface UQUIKCardNumberFormField ()
@property (nonatomic, strong) UQUIKPaymentOptionCardView *hint;
@property (nonatomic, strong) UIButton *validateButton;
@property (nonatomic, strong) UIActivityIndicatorView *loadingView;

@end

@implementation UQUIKCardNumberFormField

@synthesize number = _number;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.state = UQUIKCardNumberFormFieldStateDefault;
        self.textField.accessibilityLabel = UQUIKLocalizedString(CARD_NUMBER_PLACEHOLDER);
        self.textField.placeholder = UQUIKLocalizedString(CARD_NUMBER_PLACEHOLDER);
        self.formLabel.text = @"";
        self.textField.keyboardType = UIKeyboardTypeNumberPad;
        
        self.hint = [UQUIKPaymentOptionCardView new];
        self.hint.paymentOptionType = UQUIKPaymentOptionTypeUnknown;
        self.hint.translatesAutoresizingMaskIntoConstraints = NO;
        [self.hint addConstraint:[NSLayoutConstraint constraintWithItem:self.hint attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:[UQUIKAppearance smallIconHeight]]];
        [self.hint addConstraint:[NSLayoutConstraint constraintWithItem:self.hint attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:[UQUIKAppearance smallIconWidth]]];
        
        self.accessoryView = self.hint;
        [self setAccessoryViewHidden:YES animated:NO];
        
        self.validateButton = [UIButton new];
        [self.validateButton setTitle:UQUIKLocalizedString(NEXT_ACTION) forState:UIControlStateNormal];
        
        NSAttributedString *normalValidateButtonString = [[NSAttributedString alloc] initWithString:UQUIKLocalizedString(NEXT_ACTION) attributes:@{NSForegroundColorAttributeName:[UQUIKAppearance sharedInstance].tintColor, NSFontAttributeName:[UIFont fontWithName:[UQUIKAppearance sharedInstance].boldFontFamily size:[UIFont labelFontSize]]}];
        [self.validateButton setAttributedTitle:normalValidateButtonString forState:UIControlStateNormal];
        NSAttributedString *disabledValidateButtonString = [[NSAttributedString alloc] initWithString:UQUIKLocalizedString(NEXT_ACTION) attributes:@{NSForegroundColorAttributeName:[UQUIKAppearance sharedInstance].disabledColor, NSFontAttributeName:[UIFont fontWithName:[UQUIKAppearance sharedInstance].boldFontFamily size:[UIFont labelFontSize]]}];
        [self.validateButton setAttributedTitle:disabledValidateButtonString forState:UIControlStateDisabled];

        [self.validateButton sizeToFit];
        [self.validateButton layoutIfNeeded];
        [self.validateButton addTarget:self action:@selector(validateButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self updateValidationButton];

        self.loadingView = [UIActivityIndicatorView new];
        self.loadingView.activityIndicatorViewStyle = [UQUIKAppearance sharedInstance].activityIndicatorViewStyle;
        [self.loadingView sizeToFit];
    }
    return self;
}

- (void)validateButtonPressed {
    if (self.cardNumberDelegate != nil) {
        [self.cardNumberDelegate validateButtonPressed:self];
    }
}

- (void)updateValidationButton {
    self.validateButton.enabled = _number.length > 13;
}

- (BOOL)valid {
    return [self.cardType validNumber:self.number];
}

- (BOOL)entryComplete {
    return [super entryComplete] && [self.cardType validAndNecessarilyCompleteNumber:self.number];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSUInteger newLength = textField.text.length - range.length + string.length;
    NSUInteger maxLength = self.cardType == nil ? [UQUIKCardType maxNumberLength] : self.cardType.maxNumberLength;
    if ([self isShowingValidateButton]) {
        return YES;
    } else {
        return newLength <= maxLength;
    }
}

- (void)setText:(NSString *)text {
    [super setText:text];
    [self fieldContentDidChange];
}

- (void)fieldContentDidChange {
    _number = [UQUIKUtil stripNonDigits:self.textField.text];
    UQUIKCardType *oldCardType = _cardType;
    _cardType = [UQUIKCardType cardTypeForNumber:_number];
    [self formatCardNumber];

    if (self.cardType != oldCardType) {
        [self updateCardHint];
    }
    
    self.displayAsValid = self.valid || (!self.isValidLength && self.isPotentiallyValid) || self.state == UQUIKCardNumberFormFieldStateValidate;
    [self updateValidationButton];
    [self updateAppearance];
    [self setNeedsDisplay];
    
    [self.delegate formFieldDidChange:self];
}

- (void)formatCardNumber {
    if (self.cardType != nil) {
        UITextRange *r = self.textField.selectedTextRange;
        NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithAttributedString:[self.cardType formatNumber:_number kerning:TEMP_KERNING]];
        self.textField.attributedText = text;
        self.textField.selectedTextRange = r;
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.textField.text = _number;
    [super textFieldDidBeginEditing:textField];
    self.displayAsValid = self.valid || (!self.isValidLength && self.isPotentiallyValid);
    self.formLabel.text = @"";
    [UIView transitionWithView:self
                      duration:0.2
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        if ([self isShowingValidateButton]) {
                            [self setAccessoryViewHidden:NO animated:NO];
                        } else {
                            [self setAccessoryViewHidden:YES animated:YES];
                        }
                        [self updateConstraints];
                        [self updateAppearance];
                        
                        if (self.isPotentiallyValid) {
                            [self formatCardNumber];
                        }
                    } completion:nil];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [super textFieldDidEndEditing:textField];
    self.displayAsValid = self.number.length == 0 || (![self isValidLength] && self.state == UQUIKCardNumberFormFieldStateValidate) || (_cardType != nil && [_cardType validNumber:_number]);
    self.formLabel.text = self.number.length == 0 || (![self isValidLength] && self.state == UQUIKCardNumberFormFieldStateValidate) ? @"" : UQUIKLocalizedString(CARD_NUMBER_PLACEHOLDER);
    [UIView animateWithDuration:0.2 animations:^{
        if ([self isShowingValidateButton]) {
            [self setAccessoryViewHidden:NO animated:NO];
        } else {
            if (self.number.length == 0) {
                [self setAccessoryViewHidden:YES animated:YES];
            } else {
                [self showCardHintAccessory];
            }
        }
        if (self.number.length > 7 && ([self isValidLength] || self.state != UQUIKCardNumberFormFieldStateValidate)) {
            NSString *lastFour = [self.number substringFromIndex: [self.number length] - 4];
            self.textField.text = [NSString stringWithFormat:@"•••• %@", lastFour];
        }
        [self updateConstraints];
        [self updateAppearance];
    }];
}

- (void)resetFormField {
    self.formLabel.text = @"";
    self.textField.text = @"";
    [self setAccessoryViewHidden:YES animated:NO];
    [self updateConstraints];
    [self updateAppearance];
}

#pragma mark - Public Methods

- (void)setState:(UQUIKCardNumberFormFieldState)state {
    if (state == self.state) {
        return;
    }
    _state = state;
    if (self.state == UQUIKCardNumberFormFieldStateDefault) {
        self.accessoryView = self.hint;
        [self setAccessoryViewHidden:(self.formLabel.text.length <= 0) animated:YES];
    } else if (self.state == UQUIKCardNumberFormFieldStateLoading) {
        self.accessoryView = self.loadingView;
        [self setAccessoryViewHidden:NO animated:YES];
        [self.loadingView startAnimating];
    } else {
        self.accessoryView = self.validateButton;
        [self setAccessoryViewHidden:NO animated:YES];
    }
}

- (void)setNumber:(NSString *)number {
    self.text = number;
    _number = self.textField.text;
}

- (void)showCardHintAccessory {
    [self setAccessoryViewHidden:NO animated:YES];
}

#pragma mark - Private Helpers

- (BOOL)isShowingValidateButton {
    return self.state == UQUIKCardNumberFormFieldStateValidate;
}

- (BOOL)isValidCardType {
    return self.cardType != nil || _number.length == 0;
}

- (BOOL)isPotentiallyValid {
    return [UQUIKCardType cardTypeForNumber:self.number] != nil;
}

- (BOOL)isValidLength {
    return self.cardType != nil && [self.cardType completeNumber:_number];
}

- (void)updateCardHint {
    UQUIKPaymentOptionType paymentMethodType = [UQUIKViewUtil paymentMethodTypeForCardType:self.cardType];
    self.hint.paymentOptionType = paymentMethodType;
}

@end
