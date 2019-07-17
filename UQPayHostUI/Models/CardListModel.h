//
//  CardListModel.h
//  UQPayHostUI
//
//  Created by uqpay on 2019/7/10.
//  Copyright © 2019 优钱付. All rights reserved.
//

#import "ResultModel.h"
#if __has_include("JSONModel.h")
#import "JSONModel.h"
#else
#import <JSONModel/JSONModel.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@interface CardListModel : JSONModel

@property (nonatomic) NSArray<ResultModel *>* data;

@end

NS_ASSUME_NONNULL_END
