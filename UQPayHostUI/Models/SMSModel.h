//
//  SMSModel.h
//  UQPayHostUI
//
//  Created by uqpay on 2019/7/9.
//  Copyright © 2019 优钱付. All rights reserved.
//

#import <Foundation/Foundation.h>
#if __has_include("JSONModel.h")
#import "JSONModel.h"
#else
#import <JSONModel/JSONModel.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@interface SMSModel : JSONModel
@property (nonatomic)NSString * uqOrderId;
@end

NS_ASSUME_NONNULL_END
