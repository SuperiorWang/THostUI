//
//  UQImageUtils.m
//  UQPayHostUI
//
//  Created by uqpay on 2019/7/12.
//  Copyright © 2019 优钱付. All rights reserved.
//

#import "UQImageUtils.h"

@implementation UQImageUtils

static UQImageUtils* imageUtils;

+ (instancetype) shareInstance {
    if (imageUtils == nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            imageUtils = [UQImageUtils new];
        });
    }
    return imageUtils;
}


+ (UIImage *)backIcon {
     return [self resourceImage:@"back"];
}

+ (UIImage *)cardIcon {
    return [self resourceImage:@"card"];
}

+ (UIImage *)selectIcon {
    return [self resourceImage:@"xuanze"];
}

+ (UIImage *)rectangleImg {
    return [self resourceImage:@"add-rectangle"];
}

+ (UIImage *)deleteIcon {
    return [self resourceImage:@"delete"];
}

+ (UIImage *)photoIcon {
    return [self resourceImage:@"photograph"];
}

+ (NSBundle*)resourceBundle {

    return [NSBundle bundleWithURL:[[NSBundle mainBundle]URLForResource:@"UQHostUIResource" withExtension:@"bundle"]];
}

+ (UIImage *)resourceImage:(NSString *)imgName {
    NSString *imageName = imgName;
    CGFloat scale = [UIScreen mainScreen].scale;
    switch ((int)scale) {
        case 1:
            imageName = [NSString stringWithFormat:@"%@%@", imgName, @".png"];
            break;
        case 2:
            imageName = [NSString stringWithFormat:@"%@%@", imgName, @"@2x.png"];
            break;
        case 3:
            imageName = [NSString stringWithFormat:@"%@%@", imgName, @"@3x.png"];
        default:
            break;
    }
    NSBundle *bundle = [self resourceBundle];
    return [UIImage imageNamed:imageName inBundle:bundle compatibleWithTraitCollection:nil] ;
}

@end
