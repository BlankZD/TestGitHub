//
//  VerticallyAlignedLabel.h
//  TestLoadImage
//
//  Created by 歐陽 on 16/5/11.
//  Copyright © 2016年 歐陽. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum VerticalAlignment {
    VerticalAlignmentTop,
    VerticalAlignmentMiddle,
    VerticalAlignmentBottom,
} VerticalAlignment;

@interface VerticallyAlignedLabel : UILabel

@property (nonatomic, assign) VerticalAlignment verticalAlignment;

@end
