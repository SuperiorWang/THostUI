//
//  AddCardModel.h
//  UQPayHostUI
//
//  Created by uqpay on 2019/7/9.
//  Copyright © 2019 优钱付. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CardModel.h"
#if __has_include("JSONModel.h")
#import "JSONModel.h"
#else
#import <JSONModel/JSONModel.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@interface AddCardModel : JSONModel

@property(nonatomic) NSString* clientType;
@property(nonatomic) NSString* token;
@property(nonatomic) NSString* verifyCode;
@property(nonatomic) NSString* uqOrderId;
@property(nonatomic) CardModel* card;

@end

NS_ASSUME_NONNULL_END
