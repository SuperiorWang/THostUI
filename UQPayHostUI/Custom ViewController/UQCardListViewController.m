//
//  UQCardListViewController.m
//  UQPayHostUI
//
//  Created by uqpay on 2019/7/5.
//  Copyright © 2019 优钱付. All rights reserved.
//

#import "UQCardListViewController.h"
#import "../Helpers/SystemUtils.h"
#import "../Custom View/UQCardItemCell.h"
#import "../Models/CardListModel.h"
#import "../Public/UQHostResult.h"

#if __has_include("UQPayHostUIKit.h")
#import "UQPayHostUIKit.h"
#else
#import <UQPayHostUIKit/UQPayHostUIKit.h>
#endif


#define CELL_IDENTIFIER @"uq_card_item_id"
@interface UQCardListViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIButton    *addCardView;
@property (nonatomic) NSMutableArray *data;

@end

@implementation UQCardListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.data = [[NSMutableArray alloc]initWithCapacity:0];
    
    [self initUI];
    [self updateUI];
    [self initClient];
}

- (void)initUI {
    
    self.view.backgroundColor = [UQUIKAppearance sharedInstance].barBackgroundColor;
    
    self.navigationItem.leftBarButtonItem = [[UQUIKBarButtonItem alloc]initWithTitle:UQUIKLocalizedString(CANCEL_ACTION) style:UIBarButtonItemStylePlain target:self action:@selector(cancelTapped)];
    self.title = UQUIKLocalizedString(UQ_SELECT_CARD);
    
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.addCardView];
    
    self.addCardView.frame = CGRectMake(0, 0,SystemUtils.SCREEN_WIDTH - 30, 120);
    self.addCardView.center = self.view.center;
}


#pragma mark --lazy init --
- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SystemUtils.SCREEN_WIDTH, SystemUtils.SCREEN_HEIGHT)
                                                 style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.showsHorizontalScrollIndicator = NO;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _tableView;
}

- (UIButton *)addCardView {
    if (_addCardView == nil) {
        _addCardView = [UIButton buttonWithType:UIButtonTypeCustom];
        [_addCardView setTitle:UQUIKLocalizedString(UQ_ADD_CARD) forState:UIControlStateNormal];
        [_addCardView setTitleColor:self.view.tintColor forState:UIControlStateNormal];
        _addCardView.titleLabel.font = [UIFont systemFontOfSize:24];
        _addCardView.layer.cornerRadius = 5;
        _addCardView.layer.borderWidth = 1;
        _addCardView.layer.borderColor = self.view.tintColor.CGColor;
        [_addCardView addTarget:self action:@selector(addCard) forControlEvents:UIControlEventTouchUpInside];
    }
    return _addCardView;
}

#pragma mark - delegate -
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.data.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 120;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UQCardItemCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER];
    
    if (cell == nil) {
        cell = [[UQCardItemCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CELL_IDENTIFIER];
    }
    
    cell.iconLabel.text = [self.data[indexPath.row] objectForKey:@"issuer"];
    cell.cardTextLabel.text = [NSString stringWithFormat:@"*** *** *** %@",[self.data[indexPath.row] objectForKey:@"panTail"]];
    cell.revokeBtn.tag = indexPath.row;
    cell.selectBtn.tag = indexPath.row;
    [cell.revokeBtn addTarget:self action:@selector(unBindCard:) forControlEvents:UIControlEventTouchUpInside];
    [cell.selectBtn addTarget:self action:@selector(selectCard:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

- (void)updateUI {
    if (self.data == nil || self.data.count == 0) {
        [UIView animateWithDuration:0.15 animations:^{
            self.tableView.hidden = true;
            self.addCardView.hidden = false;
        }];
    }else {
        [UIView animateWithDuration:0.15 animations:^{
            self.tableView.hidden = false;
            self.addCardView.hidden = true;
        }];
    }
}

- (void)initClient {
    [[UQHttpClient sharedInstance] getCardList:^(NSDictionary * _Nonnull dict, BOOL isSuccess) {
        if (isSuccess) {
            if (dict != nil && dict.count > 0) {
                CardListModel *model = [[CardListModel alloc]initWithDictionary:dict error:nil];
                self.data = [NSMutableArray arrayWithArray:model.data];
                if (self.tableView != nil) {
                    [self.tableView reloadData];
                    [self updateUI];
                }
            }
        }
    } fail:^(NSError * _Nonnull error) {
        
    }];
}

- (void)unBindCard:(UIButton *)btn {
    NSInteger index = btn.tag;
    
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:UQUIKLocalizedString(UQ_WARNING) message:UQUIKLocalizedString(UQ_DELETE_CARD) preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:UQUIKLocalizedString(CANCEL_ACTION)style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:UQUIKLocalizedString(TOP_LEVEL_ERROR_ALERT_VIEW_OK_BUTTON_TEXT) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[UQHttpClient sharedInstance]postCardRevoke:@{@"cardToken": [self.data[index] objectForKey:@"uuid"] } success:^(NSDictionary * _Nonnull dict, BOOL isSuccess) {
            if (isSuccess && dict != nil) {
                if ([[dict objectForKey:@"status"] intValue] == 200) {
                    [self.data removeObjectAtIndex:index];
                    [self.tableView reloadData];
                    [self updateUI];
                }
            }
        } fail:^(NSError * _Nonnull error) {
            
        }];
    }]];
    
    [self presentViewController:alertController animated:YES completion:nil];
    
}

- (void)selectCard:(UIButton *)btn {
    int index = btn.tag;
    
    NSDictionary *resultDic = self.data[index];

    [self dismissViewControllerAnimated:YES completion:^{
        if (self.delegate != nil) {
            [self.delegate UQHostResult: [[UQHostResult alloc]initWithDictionary:resultDic error:nil]];
        }
    }];
}

-(void)cancelTapped {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)addCard {
    UQAddCardViewController *viewController = [[UQAddCardViewController alloc]init];
    [self pushtoNavigationController:viewController];
}

@end
