//
//  UQAddCardViewController.m
//  UQPayHostUI
//
//  Created by uqpay on 2019/7/5.
//  Copyright © 2019 优钱付. All rights reserved.
//

#import "UQAddCardViewController.h"
#import "../Helpers/SystemUtils.h"
#import "../Helpers/UQDropInUIUtilities.h"
#import "../Models/SMSModel.h"
#import "../Models/AddCardModel.h"
#import "../Models/CardModel.h"
#import "../Models/ResultModel.h"
#import "../Public/UQHostResult.h"
#import "../Images/UQImageUtils.h"

#define DURATION_TIME 60

@interface UQAddCardViewController()

@property (nonatomic, strong) UIScrollView*                    scrollView;
@property (nonatomic, strong) UIView*                          scrollViewContentWrapper;
@property (nonatomic, strong) UIButton*                        photoBtn;


@property (nonatomic, strong) UQUIKCardNumberFormField*        cardNumberField;
@property (nonatomic, strong) UQUIKCardholderNameFormField*    cardholderNameField;
@property (nonatomic, strong) UQUIKExpiryFormField*            expirationDateField;
@property (nonatomic, strong) UQUIKSecurityCodeFormField*      securityCodeField;
@property (nonatomic, strong) UQUIKPostalCodeFormField*        postalCodeField;
@property (nonatomic, strong) UQUIKMobileCountryCodeFormField* mobileCountryCodeField;
@property (nonatomic, strong) UQUIKMobileNumberFormField*      mobilePhoneField;
@property (nonatomic, strong) UIButton*                        nextButton;
@property (nonatomic, strong) UIStackView*                     stackView;
@property (nonatomic, strong) UIStackView*                     paymentOptionsLabelContainerStackView;
@property (nonatomic, strong) NSArray <UQUIKFormField *>*      formFields;
@property (nonatomic, strong) UIView*                          smsView;
@property (nonatomic, strong) UIButton*                        sendSMSBtn;


@property (nonatomic, strong) UIStackView *cardNumberErrorView;
@property (nonatomic, strong) UIStackView *cardNumberHeader;
@property (nonatomic, strong) UIStackView *enrollmentFooter;

@property (nonatomic,weak) NSTimer* countDownTimer;
@property (nonatomic, assign) NSInteger durationTime;

@property (nonatomic, strong) NSString*                        cardNumber;
@property (nonatomic, getter=isCollapsed) BOOL collapsed;

@property (nonatomic, copy) NSString* uqOrderId;

@end

@interface CardIOSurrogate : NSObject
+ (NSString*)cardIOLibraryVersion;
+ (id)initWithPaymentDelegate:id;
+ (BOOL)canReadCardWithCamera;
@property (nonatomic, strong) NSString *cardNumber;
@property (nonatomic, assign, readwrite) BOOL hideCardIOLogo;
@property (nonatomic, retain, readwrite) UIColor *navigationBarTintColor;
@property (nonatomic, assign, readwrite) BOOL collectExpiry;
@property (nonatomic, assign, readwrite) BOOL collectCVV;
@end

@implementation UQAddCardViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    [self initUI];
    [self setupForms];
//    [self resetForm];
//    [self showLoadingScreen: YES];
//    [self loadConfiguration];
//    [self updateFormBorders];
//    [self test];
}

- (void)initUI{

    _collapsed = NO;
    _durationTime = DURATION_TIME;
    
    self.view.backgroundColor = [UQUIKAppearance sharedInstance].formBackgroundColor;
    
    self.navigationItem.leftBarButtonItem = [[UQUIKBarButtonItem alloc]initWithImage:[UQImageUtils backIcon] style:UIBarButtonItemStylePlain target:self action:@selector(cancelTapped)];
    self.title = UQUIKLocalizedString(UQ_ADD_BANK_CARD);
    
    self.scrollView = [[UIScrollView alloc]init];
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.scrollView setAlwaysBounceVertical:NO];
    self.scrollView.scrollEnabled = YES;
    [self.view addSubview:self.scrollView];
    
    self.scrollViewContentWrapper = [[UIView alloc]init];
    self.scrollViewContentWrapper.translatesAutoresizingMaskIntoConstraints = NO;
    [self.scrollView addSubview:self.scrollViewContentWrapper];
    
    self.stackView = [self newStackView];
    [self.scrollViewContentWrapper addSubview:self.stackView];
    
    [self.scrollView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor].active = YES;
    [self.scrollView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor].active = YES;
    [self.scrollView.topAnchor constraintEqualToAnchor:self.view.topAnchor].active = YES;
    [self.scrollView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor].active = YES;
    
    NSDictionary *viewBindings = @{@"stackView": self.stackView,
                                   @"scrollView": self.scrollView,
                                   @"scrollViewContentWrapper": self.scrollViewContentWrapper};

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[scrollViewContentWrapper]"
                                                                      options:0
                                                                      metrics:[UQUIKAppearance metrics]
                                                                        views:viewBindings]];

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[scrollViewContentWrapper(scrollView)]"
                                                                      options:0
                                                                      metrics:[UQUIKAppearance metrics]
                                                                        views:viewBindings]];
    
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[stackView]|"
                                                                      options:0
                                                                      metrics:[UQUIKAppearance metrics]
                                                                        views:viewBindings]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[stackView]-|"
                                                                      options:0
                                                                      metrics:[UQUIKAppearance metrics]
                                                                        views:viewBindings]];
    
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideKeyboard)];
    [self.view setUserInteractionEnabled:YES];
    [self.view addGestureRecognizer:tapGesture];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
}

- (void)setupForms{
    self.cardNumberHeader = [UQDropInUIUtilities newStackView];
    self.cardNumberHeader.layoutMargins = UIEdgeInsetsMake(0, [UQUIKAppearance verticalFormSpace], 0, [UQUIKAppearance verticalFormSpace]);
    self.cardNumberHeader.layoutMarginsRelativeArrangement = true;
    
    [self.cardNumberHeader addArrangedSubview:self.photoBtn];
    [UQDropInUIUtilities addSpacerToStackView:self.cardNumberHeader beforeView:self.photoBtn size:[UQUIKAppearance verticalFormSpace]];
    [self.stackView addArrangedSubview:self.cardNumberHeader];
    
    [self.stackView addArrangedSubview:self.cardNumberField];
    NSLayoutConstraint *heightConstraint = [self.cardNumberField.heightAnchor constraintEqualToConstant:[UQUIKAppearance formCellHeight]];
    heightConstraint.priority = UILayoutPriorityDefaultHigh;
    heightConstraint.active = true;
    [self.cardNumberField updateConstraints];
    
    [UQDropInUIUtilities addSpacerToStackView:self.stackView beforeView:self.cardNumberField size:[UQUIKAppearance verticalFormSpace]];
}

- (BOOL)isCardIOAvailable {
    Class kCardIOView = NSClassFromString(@"CardIOPaymentViewController");
    Class kCardIOUtilities = NSClassFromString(@"CardIOUtilities");
    if (kCardIOView != nil && kCardIOView != nil
        && [kCardIOUtilities respondsToSelector:@selector(cardIOLibraryVersion)]
        && [kCardIOUtilities respondsToSelector:@selector(canReadCardWithCamera)]) {
        NSString *cardIOVersion = [kCardIOUtilities cardIOLibraryVersion];
        NSString *majorVersion = [cardIOVersion length] >= 2 ? [cardIOVersion substringToIndex:2] : @"";
        // Require 5.x.x strictly
        return [majorVersion isEqualToString:@"5."] && [kCardIOUtilities canReadCardWithCamera];
    }
    return NO;
}

- (void)presentCardIO {
    Class kCardIOPaymentViewController = NSClassFromString(@"CardIOPaymentViewController");
    id scanViewController = [[kCardIOPaymentViewController alloc] initWithPaymentDelegate:self];
    [scanViewController setNavigationBarTintColor:[[UINavigationBar appearance] barTintColor]];
    [scanViewController setHideCardIOLogo:YES];
    [scanViewController setCollectCVV:NO];
    [scanViewController setCollectExpiry:NO];
    [self presentViewController:scanViewController animated:YES completion:nil];
}

- (void)userDidCancelPaymentViewController:(UIViewController *)scanViewController {
    [scanViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)userDidProvideCreditCardInfo:(id)info inPaymentViewController:(UIViewController *)scanViewController {
    NSString *cardNumber = [info cardNumber];
    [scanViewController dismissViewControllerAnimated:YES completion:^{
        [self.cardNumberField setNumber:cardNumber];
        [self.cardNumberField textFieldDidEndEditing:self.cardNumberField.textField];
        [self validateButtonPressed:self.cardNumberField];
    }];
}

//- (void)setupForms {
//    self.nextButton = [[UIButton alloc] init];
//    [self.nextButton setTitle:UQUIKLocalizedString(NEXT_ACTION) forState:UIControlStateNormal];
//    self.nextButton.translatesAutoresizingMaskIntoConstraints = NO;
//    [self.nextButton setTitleColor:self.view.tintColor forState:UIControlStateNormal];
//
//    self.cardNumberHeader = [UQDropInUIUtilities newStackView];
//    self.cardNumberHeader.layoutMargins = UIEdgeInsetsMake(0, [UQUIKAppearance verticalFormSpace], 0, [UQUIKAppearance verticalFormSpace]);
//    self.cardNumberHeader.layoutMarginsRelativeArrangement = true;
//
//    UILabel *cardNumberHeaderLabel = [[UILabel alloc] init];
//    cardNumberHeaderLabel.numberOfLines = 0;
//    cardNumberHeaderLabel.textAlignment = NSTextAlignmentCenter;
//    cardNumberHeaderLabel.text = UQUIKLocalizedString(ENTER_CARD_DETAILS_HELP_LABEL);
//    [UQUIKAppearance styleLargeLabelSecondary:cardNumberHeaderLabel];
//    [self.cardNumberHeader addArrangedSubview:cardNumberHeaderLabel];
//    [UQDropInUIUtilities addSpacerToStackView:self.cardNumberHeader beforeView:cardNumberHeaderLabel size: [UQUIKAppearance verticalFormSpace]];
//    [self.stackView addArrangedSubview:self.cardNumberHeader];
//
//    [self.smsView addSubview:self.sendSMSBtn];
//    [self.smsView addSubview:self.postalCodeField];
//
//    NSDictionary *viewBindings = @{ @"smsView":self.smsView,
//                                    @"postalCodeField":self.postalCodeField,
//                                    @"sendSMSBtn":self.sendSMSBtn,
//                                    };
//    NSArray *conH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[postalCodeField]-[sendSMSBtn(100)]-|"
//                                                            options:0
//                                                            metrics:[UQUIKAppearance metrics]
//                                                              views:viewBindings];
//    [self.smsView addConstraints:conH];
//
//    [self.smsView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[postalCodeField]|"
//                                                                 options:0
//                                                                 metrics:[UQUIKAppearance metrics]
//                                                                   views:viewBindings]];
//
//    [self.smsView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[sendSMSBtn]|"
//                                                                 options:0
//                                                                 metrics:[UQUIKAppearance metrics]                                                                     views:viewBindings]];
//
//    self.formFields = @[self.cardNumberField,self.cardholderNameField, self.expirationDateField, self.securityCodeField, self.mobilePhoneField,self.smsView];
//
//    for (NSInteger i = 0; i< self.formFields.count; i++) {
//        UQUIKFormField *formField = self.formFields[i];
//        [self.stackView addArrangedSubview:formField];
//
//        NSLayoutConstraint* heightConstraint = [formField.heightAnchor constraintEqualToConstant:[UQUIKAppearance formCellHeight]];
//        heightConstraint.priority = UILayoutPriorityDefaultHigh;
//        heightConstraint.active = YES;
//        [formField updateConstraints];
//    }
//    [self.postalCodeField updateConstraints];
//
//    self.cardNumberField.formLabel.text = @"";
//    [self.cardNumberField updateConstraints];
//
//    [UQDropInUIUtilities addSpacerToStackView:self.stackView beforeView:self.cardNumberField size: [UQUIKAppearance verticalFormSpace]];
//    [UQDropInUIUtilities addSpacerToStackView:self.stackView beforeView:self.cardholderNameField size: [UQUIKAppearance verticalFormSpace]];
//    [UQDropInUIUtilities addSpacerToStackView:self.stackView beforeView:self.expirationDateField size: [UQUIKAppearance verticalFormSpace]];
//
//    self.collapsed = YES;
//
//}

- (void)updateUI {
}

- (void)resetForm {
    
}

- (void)showLoadingScreen:(BOOL)show {
    
}

- (void)loadConfiguration {
    
}


- (void)cancelTapped {
    [self hideKeyboard];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)tokenizedCard {
    [self.view endEditing:YES];

    if ([self validateAddCard]){
        UIActivityIndicatorView *spinner = [UIActivityIndicatorView new];
        spinner.activityIndicatorViewStyle = [UQUIKAppearance sharedInstance].activityIndicatorViewStyle;
        [spinner startAnimating];
        
        UIBarButtonItem *addCardButton = self.navigationItem.rightBarButtonItem;
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
        self.view.userInteractionEnabled = NO;
        
        NSString* date = self.expirationDateField.text;
        CardModel *cardModel = [CardModel new];
        cardModel.cardNum = self.cardNumber;
        cardModel.cvv = self.securityCodeField.text;
        cardModel.expireMonth = [date componentsSeparatedByString:@"/"].firstObject;
        cardModel.expireYear =  [[date componentsSeparatedByString:@"/"].lastObject substringFromIndex:2];
        cardModel.phone = self.mobilePhoneField.text;
        
        AddCardModel *addCardModel = [AddCardModel new];
        addCardModel.card = cardModel;
        addCardModel.uqOrderId = self.uqOrderId;
        addCardModel.verifyCode = self.postalCodeField.text;
        
        [[UQHttpClient sharedInstance]addCard:addCardModel success:^(NSDictionary * _Nonnull dict, BOOL isSuccess) {
            if (isSuccess && dict) {
                UQHostResult *resultModel = [[UQHostResult alloc]initWithDictionary:dict error:nil];

                [self dismissViewControllerAnimated:YES completion:^{
                    if (self.delegate != nil) {
                        [self.delegate UQHostResult:resultModel];
                    }
                }];
            }
        } fail:^(NSError * _Nonnull error) {
            NSLog(@"error = %@",error);
            self.navigationItem.rightBarButtonItem = addCardButton;
            self.view.userInteractionEnabled = YES;
        }];
    }
}


#pragma mark -- lazy init--
- (UQUIKCardNumberFormField *)cardNumberField {
    if (_cardNumberField == nil) {
        _cardNumberField = [[UQUIKCardNumberFormField alloc]init];
        _cardNumberField.state = UQUIKCardNumberFormFieldStateValidate;
        _cardNumberField.delegate = self;
        _cardNumberField.cardNumberDelegate = self;
    }
    return _cardNumberField;
}

- (UQUIKCardholderNameFormField *)cardholderNameField {
    if (_cardholderNameField == nil) {
        _cardholderNameField = [[UQUIKCardholderNameFormField alloc]init];
        _cardholderNameField.delegate = self;
        _cardholderNameField.textField.keyboardType = UIKeyboardTypeNumberPad;
    }
    return _cardholderNameField;
}

- (UQUIKExpiryFormField *)expirationDateField {
    if (_expirationDateField == nil) {
        _expirationDateField = [[UQUIKExpiryFormField alloc]init];
    }
    return _expirationDateField;
}

- (UQUIKSecurityCodeFormField *)securityCodeField {
    if (_securityCodeField == nil) {
        _securityCodeField = [[UQUIKSecurityCodeFormField alloc]init];
    }
    return _securityCodeField;
}

- (UQUIKPostalCodeFormField *)postalCodeField {
    if (_postalCodeField == nil) {
        _postalCodeField = [[UQUIKPostalCodeFormField alloc]init];
        _postalCodeField.translatesAutoresizingMaskIntoConstraints = NO;
    }
    
    return _postalCodeField;
}

- (UQUIKMobileCountryCodeFormField *)mobileCountryCodeField {
    if (_mobileCountryCodeField == nil) {
        _mobileCountryCodeField = [[UQUIKMobileCountryCodeFormField alloc]init];
    }
    return _mobileCountryCodeField;
}

- (UQUIKMobileNumberFormField *)mobilePhoneField {
    if (_mobilePhoneField == nil) {
        _mobilePhoneField = [[UQUIKMobileNumberFormField alloc]init];
        _mobilePhoneField.delegate = self;
    }
    return _mobilePhoneField;
}

- (UIView *)smsView {
    if (_smsView == nil) {
        _smsView = [UIView new];
        _smsView.backgroundColor = [UIColor whiteColor];
        _smsView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return _smsView;
}

- (UIButton *)sendSMSBtn {
    if (_sendSMSBtn == nil) {
        _sendSMSBtn = [UIButton new];
        _sendSMSBtn.backgroundColor = self.view.tintColor;
        _sendSMSBtn.translatesAutoresizingMaskIntoConstraints = NO;
        [_sendSMSBtn setTitle:UQUIKLocalizedString(UQ_SEND_CODE) forState:UIControlStateNormal];
        [_sendSMSBtn addTarget:self action:@selector(sendSms) forControlEvents:UIControlEventTouchUpInside];
         _sendSMSBtn.enabled = false;
        [_sendSMSBtn setBackgroundColor:[UIColor grayColor]];
    }
    return _sendSMSBtn;
}

- (UIButton *)photoBtn {
    if (_photoBtn == nil) {
        _photoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _photoBtn.backgroundColor = [UIColor clearColor];
        [_photoBtn setImage:[UQImageUtils photoIcon] forState:UIControlStateNormal];
        _photoBtn.translatesAutoresizingMaskIntoConstraints = NO;
        [_photoBtn addTarget:self action:@selector(presentCardIO) forControlEvents:UIControlEventTouchUpInside];
    }
    return _photoBtn;
}

- (UIStackView *)newStackView {
    UIStackView *stackView = [[UIStackView alloc]init];
    stackView.translatesAutoresizingMaskIntoConstraints = NO;
    stackView.axis = UILayoutConstraintAxisVertical;
    stackView.distribution = UIStackViewDistributionFill;
    stackView.alignment = UIStackViewAlignmentFill;
    stackView.spacing = 0;
    return stackView;
}

#pragma mark - keyboard management
- (void)hideKeyboard {
    [self.view endEditing:YES];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    CGRect keyboardRectInWindow = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGSize keyboardSize = [self.view convertRect:keyboardRectInWindow fromView:nil].size;
    UIEdgeInsets scrollInsets = self.scrollView.contentInset;
    scrollInsets.bottom = keyboardSize.height;
    self.scrollView.contentInset = scrollInsets;
    self.scrollView.scrollIndicatorInsets = scrollInsets;
}

- (void)keyboardWillHide:(__unused NSNotification *)notification {
    UIEdgeInsets scrollInsets = self.scrollView.contentInset;
    scrollInsets.bottom = 0.0;
    self.scrollView.contentInset = scrollInsets;
    self.scrollView.scrollIndicatorInsets = scrollInsets;
}

- (void)updateFormBorders {
    self.cardNumberField.bottomBorder = YES;
    self.cardNumberField.topBorder = YES;
    
    self.mobileCountryCodeField.topBorder = YES;
    self.mobileCountryCodeField.interFieldBorder = YES;
    self.mobilePhoneField.bottomBorder = YES;
    
    NSArray *groupedFormFields = @[self.cardholderNameField, self.expirationDateField, self.securityCodeField, self.mobilePhoneField, self.postalCodeField];
    BOOL topBorderAdded = NO;
    UQUIKFormField* lastVisibleFormField;
    for (NSUInteger i = 0; i < groupedFormFields.count; i++) {
        UQUIKFormField *formField = groupedFormFields[i];
        if (!formField.hidden) {
            if (!topBorderAdded) {
                formField.topBorder = YES;
                topBorderAdded = YES;
            } else {
                formField.topBorder = NO;
            }
            formField.bottomBorder = NO;
            formField.interFieldBorder = YES;
            lastVisibleFormField = formField;
        }
    }
    if (lastVisibleFormField) {
        lastVisibleFormField.bottomBorder = YES;
    }
}

#pragma mark -- switch card number

- (void)setCollapsed:(BOOL)collapsed {
    if (collapsed == self.collapsed) {
        return;
    }
    // Using ivar so that setter is not called
    _collapsed = collapsed;
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.15
                              delay:0.0
                            options:UIViewAnimationOptionAllowAnimatedContent|UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
            self.cardNumberHeader.hidden = !collapsed;
            self.cardholderNameField.hidden = collapsed;
            self.expirationDateField.hidden = collapsed;
            self.securityCodeField.hidden = collapsed;
            self.smsView.hidden = collapsed;
            self.mobilePhoneField.hidden = collapsed;
            [self updateFormBorders];
        } completion:^(__unused BOOL finished) {
            self.cardNumberHeader.hidden = !collapsed;
            self.cardholderNameField.hidden = collapsed;
            self.expirationDateField.hidden = collapsed;
            self.securityCodeField.hidden = collapsed;
            self.smsView.hidden =collapsed;
            self.mobileCountryCodeField.hidden = collapsed;
            self.mobilePhoneField.hidden =  collapsed;
            
            [self updateFormBorders];
        }];
    });
}

#pragma mark - Protocol conformance
#pragma mark FormField Delegate Methods
- (void)validateButtonPressed:(__unused UQUIKFormField *)formField {
    self.collapsed = NO;
    self.cardholderNameField.text= self.cardNumber;
    self.navigationItem.rightBarButtonItem.enabled = true;
}

- (void)formFieldDidChange:(UQUIKFormField *)formField {
    if (formField.class == self.mobilePhoneField.class) {
        if (self.durationTime == DURATION_TIME) {
            [self validatePhoneNumber];
        }
    }else if ([formField isKindOfClass:UQUIKCardNumberFormField.class]) {
        self.cardNumber = formField.text;
    }else if ([formField isKindOfClass:UQUIKCardholderNameFormField.class]) {
        self.cardNumber = formField.text;
        if (self.cardNumber.length < 12) {
            self.collapsed = YES;
            self.navigationItem.rightBarButtonItem.enabled = false;
        }
    }
}

- (NSTimer *)countDownTimer {
    if (_countDownTimer == nil) {
        _countDownTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(countDown:) userInfo:nil repeats:YES];
    }
    return _countDownTimer;
}

#pragma mark
- (void)sendSms {
   self.sendSMSBtn.enabled = false;
   self.sendSMSBtn.backgroundColor =  [UIColor grayColor];
   [[NSRunLoop currentRunLoop]addTimer:self.countDownTimer forMode:NSRunLoopCommonModes];
 
    [[UQHttpClient sharedInstance]getSms:@{@"cardNum":self.cardNumber, @"phone":self.mobilePhoneField.text} success:^(NSDictionary * _Nonnull dict, BOOL isSuccess) {
        if (isSuccess) {
            if (dict != nil) {
                NSDictionary *data = [dict objectForKey:@"data"];
                NSError *error;
                SMSModel *model = [[SMSModel alloc]initWithDictionary:data error:&error];
                self.uqOrderId = model.uqOrderId;
            }
        }
    } fail:^(NSError * _Nonnull error) {
        NSLog(@"error %@",error);
    }];
}

- (void)countDown:(NSTimer*)timer {
    self.durationTime--;
    [self.sendSMSBtn setTitle:[NSString stringWithFormat:@"%ld's", (long)self.durationTime] forState:UIControlStateDisabled];
    if (self.durationTime == 0) {
        [self.countDownTimer invalidate];
        self.durationTime = DURATION_TIME;
        self.sendSMSBtn.enabled = true;
        [self validatePhoneNumber];
        [self.sendSMSBtn setTitle:UQUIKLocalizedString(UQ_SEND_CODE) forState:UIControlStateNormal];
    }
}

#pragma mark -- validate
- (void)validatePhoneNumber {
    if (self.mobilePhoneField.text.length != 0) {
        self.sendSMSBtn.enabled = true;
        self.sendSMSBtn.backgroundColor = self.view.tintColor;
    }else{
        self.sendSMSBtn.enabled = false;
        self.sendSMSBtn.backgroundColor =  [UIColor grayColor];
    }
}

- (BOOL)validateAddCard {
    NSArray * array = @[self.cardholderNameField, self.expirationDateField, self.mobilePhoneField, self.postalCodeField];
    
    for (int i=0; i < array.count; i++) {
        UQUIKFormField *formField = array[i];
        if (!formField.text.length){
            return false;
        }
    }
    return true;
}

#pragma mark ---
-(void)dealloc {
    if (self.countDownTimer != nil) {
        [self.countDownTimer invalidate];
    }
}

-(void)test {
    self.cardNumber = @"6223164991230014";
    self.cardNumberField.text = self.cardNumber;
    self.cardholderNameField.text = self.cardNumber;
    self.mobilePhoneField.text = @"13012345678";
    self.postalCodeField.text = @"111111";
    self.securityCodeField.text = @"123";

}
@end
