//
//  ZLTitleLabel.m
//  ZLNetEase
//
//  Created by apple on 16/5/3.
//  Copyright © 2016年 ANGELEN. All rights reserved.
//

#import "ZLTitleLabel.h"

@implementation ZLTitleLabel

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.textAlignment = NSTextAlignmentCenter;
        self.font = [UIFont systemFontOfSize:16];
        self.textColor = [UIColor blackColor];
    }
    return self;
}

@end
