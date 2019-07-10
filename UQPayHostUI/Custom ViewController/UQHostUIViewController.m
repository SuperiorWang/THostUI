//
//  UQHostUIViewController.m
//  UQPayHostUI
//
//  Created by uqpay on 2019/7/4.
//  Copyright © 2019 优钱付. All rights reserved.
//

#import "UQHostUIViewController.h"
#import "../Helpers/SystemUtils.h"

#if __has_include("UQPayHostUIKit.h")
#import "UQPayHostUIKit.h"
#else
#import <UQPayHostUIKit/UQPayHostUIKit.h>
#endif


#define UQ_ANIMATION_SLIDE_SPEED 0.35
#define UQ_ANIMATION_TRANSITION_SPEED 0.1
#define UQ_HALF_SHEET_MARGIN 5
#define UQ_HALF_SHEET_CORNER_RADIUS 12
#define UQ_CONTENT_HEIGHT 300
#define UQ_CARD_ITEM_HEIGHT 66
#define UQ_CARD_ITEM_PADDING_SIDE 40
#define UQ_CARD_ITEM_PADDING 20

@interface UQHostUIViewController()

@property (nonatomic) BOOL useBlur;
@property (nonatomic, strong) UIToolbar* toolbar;
@property (nonatomic, strong) UIView* contentView;
@property (nonatomic, strong) UIView* contentClippingView;
@property (nonatomic, strong) UIVisualEffectView *blurredContentBackgroundView;
@property (nonatomic, strong) UIView* splitLine;
@property (nonatomic, strong) UQUIKSelectCardView *cardListView;
@property (nonatomic, strong) UQUIKSelectCardView *cardAddView;
@property (nonatomic, assign) UQClientModelType modelType;

@end


@implementation UQHostUIViewController

- (instancetype)init {
    return [self initWithModel:PROTYPE];
}

- (instancetype)initWithModel:(UQClientModelType)modelType
{
    self = [super init];
    if (self) {
        if (SystemUtils.systemVersion >= 8.0) {
            self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        }else{
            self.modalPresentationStyle = UIModalPresentationCurrentContext;
        }
        
        self.useBlur = !UIAccessibilityIsReduceTransparencyEnabled();
        if (![UQUIKAppearance sharedInstance].useBlurs) {
            self.useBlur = NO;
        }
        self.modelType = modelType;
    }
    return self;
}

- (void)viewDidLoad {
    [self initUI];
    [self setupUI];
    [self initClient];
}

- (UIToolbar *)toolbar {
    if (_toolbar == nil) {
        _toolbar = [[UIToolbar alloc]init];
        _toolbar.userInteractionEnabled = YES;
        _toolbar.barStyle = UIBarStyleDefault;
        _toolbar.translucent = YES;
        _toolbar.backgroundColor = [UIColor clearColor];
        [_toolbar setBackgroundImage:[UIImage new] forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
        _toolbar.barTintColor = [UIColor clearColor];
        _toolbar.frame = CGRectMake(0, 0, SystemUtils.SCREEN_WIDTH, 44);
    }
    return _toolbar;
}


- (UIView *)contentView {
    if (_contentView == nil) {
        _contentView = [[UIView alloc]init];
        _contentView.backgroundColor = [UIColor clearColor];
        _contentView.layer.cornerRadius = UQ_HALF_SHEET_CORNER_RADIUS;
        _contentView.clipsToBounds = true;
    }
    return _contentView;
}


- (UIView *)contentClippingView {
    if (_contentClippingView == nil) {
        _contentClippingView = [[UIView alloc]init];
        _contentClippingView.backgroundColor = [UIColor clearColor];
        _contentClippingView.clipsToBounds = true;
    }
    return _contentClippingView;
}

- (UIVisualEffectView *)blurredContentBackgroundView {
    if(_blurredContentBackgroundView == nil) {
        UIBlurEffect *contentEffect = [UIBlurEffect effectWithStyle:[UQUIKAppearance sharedInstance].blurStyle];
        _blurredContentBackgroundView = [[UIVisualEffectView alloc]initWithEffect:contentEffect];
        _blurredContentBackgroundView.hidden = !self.useBlur;
    }
    return _blurredContentBackgroundView;
}

- (UIView *)splitLine {
    if (_splitLine == nil) {
        _splitLine = [UIView new];
        _splitLine.backgroundColor = [UQUIKAppearance sharedInstance].lineColor;
    }
    return _splitLine;
}

- (UQUIKSelectCardView *)cardListView {
    if (_cardListView == nil) {
        _cardListView = [[UQUIKSelectCardView alloc]init];
        _cardListView.textView.text = UQUIKLocalizedString(UQ_CARD_LIST);
        [_cardListView addTarget:self actoin:@selector(gotoCardListView)];
    }
    return _cardListView;
}

- (void)gotoCardListView {
    UQCardListViewController *viewController = [[UQCardListViewController alloc]init];
    [self pushtoNavigationController:viewController];
}

- (UQUIKSelectCardView *)cardAddView {
    if (_cardAddView == nil) {
        _cardAddView = [[UQUIKSelectCardView alloc]init];
        _cardAddView.textView.text = UQUIKLocalizedString(UQ_ADD_CARD);
        [_cardAddView addTarget:self actoin:@selector(gotoCardAddView)];
    }
    return _cardAddView;
 }

- (void)gotoCardAddView {
    UQAddCardViewController *viewController = [[UQAddCardViewController alloc]init];
    [self pushtoNavigationController:viewController];
}

- (void)initUI {
    [self.view addSubview:self.contentView];
    [self.contentView addSubview:self.contentClippingView];
    [self.contentView addSubview:self.blurredContentBackgroundView];
    [self.contentView sendSubviewToBack:self.blurredContentBackgroundView];
    [self.contentView addSubview:self.toolbar];
    [self.contentView addSubview:self.splitLine];
    self.view.backgroundColor = [UQUIKAppearance sharedInstance].overlayColor;
    [self updateTooolbar];
    
    [self.contentView addSubview:self.cardListView];
    [self.contentView addSubview:self.cardAddView];
}


- (void)setupUI {
    self.contentView.frame = CGRectMake(UQ_HALF_SHEET_MARGIN, SystemUtils.SCREEN_HEIGHT - UQ_CONTENT_HEIGHT, SystemUtils.SCREEN_WIDTH - UQ_HALF_SHEET_MARGIN * 2, UQ_CONTENT_HEIGHT);
    self.blurredContentBackgroundView.frame = self.contentClippingView.frame = CGRectMake(0, 0, CGRectGetWidth(self.contentView.bounds), CGRectGetHeight(self.contentView.bounds));
    self.splitLine.frame = CGRectMake(0, CGRectGetMaxY(self.toolbar.frame), SystemUtils.SCREEN_WIDTH, 1);
    
    CGFloat flex =  (UQ_CONTENT_HEIGHT - CGRectGetHeight(self.toolbar.bounds) - 2 * UQ_CARD_ITEM_HEIGHT - UQ_CARD_ITEM_PADDING) / 2;
    CGFloat y = flex +  CGRectGetHeight(self.toolbar.bounds);
    
    self.cardListView.frame = CGRectMake(UQ_CARD_ITEM_PADDING_SIDE, y, CGRectGetWidth(self.contentView.bounds) - 2 * UQ_CARD_ITEM_PADDING_SIDE , UQ_CARD_ITEM_HEIGHT);
    self.cardAddView.frame = CGRectMake(UQ_CARD_ITEM_PADDING_SIDE, CGRectGetMaxY(self.cardListView.frame) + UQ_CARD_ITEM_PADDING , CGRectGetWidth(self.contentView.bounds) - 2 * UQ_CARD_ITEM_PADDING_SIDE, UQ_CARD_ITEM_HEIGHT);
}

- (void)initClient {
    [[UQHttpClient sharedInstance]setModelType:self.modelType];
    [[UQHttpClient sharedInstance] setToken:self.token];
}


- (void)updateTooolbar {
    UILabel *titleLabel = [UQUIKAppearance styledNavigationTitleLabel];
    titleLabel.text = UQUIKLocalizedString(ADD_OR_SELECT_CARD);
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [titleLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    [titleLabel sizeToFit];
    UIBarButtonItem *barTitle = [[UIBarButtonItem alloc] initWithCustomView:titleLabel];
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *fixed = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:NULL];
    fixed.width = 1.0;
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(cancel)];
    [self.toolbar setItems:@[leftItem, flex, barTitle, flex, fixed] animated:YES];
    [self.toolbar invalidateIntrinsicContentSize];
}


- (void)cancel {
    [self dismissViewControllerAnimated:YES completion:NULL];
}


@end
