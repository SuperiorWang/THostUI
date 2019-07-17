//
//  UQHostResult.h
//  UQPayHostUI
//
//  Created by uqpay on 2019/7/10.
//  Copyright © 2019 优钱付. All rights reserved.
//

#import <JSONModel/JSONModel.h>

NS_ASSUME_NONNULL_BEGIN

@interface UQHostResult : JSONModel

@property (nonatomic) NSString *issuer;
@property (nonatomic) NSString *panTail;
@property (nonatomic) NSString *uuid;

@end

NS_ASSUME_NONNULL_END
