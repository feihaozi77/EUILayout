//
//  EUILayout.m
//  EUILayoutDemo
//
//  Created by Lux on 2018/9/25.
//  Copyright © 2018年 Lux. All rights reserved.
//

#import "EUILayout.h"
#import "UIView+EUILayout.h"

@interface EUILayout()
@end

@implementation EUILayout

- (instancetype)init {
    self = [super init];
    if (self) {
        _flexable  = YES;
        _gravity   = EUIGravityVertStart | EUIGravityHorzStart;
        _sizeType  = EUISizeTypeToFill;
        _margin    = EUIEdgeMake(0, 0, 0, 0);
        _padding   = EUIEdgeMake(0, 0, 0, 0);
        _zPosition = EUILayoutZPostionDefault;
        _maxWidth  = NSNotFound;
        _maxHeight = NSNotFound;
        [self setFrame:(CGRect){NSNotFound,NSNotFound,NSNotFound,NSNotFound}];
    }
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size {
    ///< 这里增加自己的margin处理？
    CGSize one = CGSizeZero;
    if (self.sizeThatFits) {
        one = self.sizeThatFits(size);
    }
    if (self.view && [self.view respondsToSelector:@selector(sizeThatFits:)]) {
        one = [self.view sizeThatFits:size];
    }
    return one;
}

- (__kindof EUILayout *)configure:(void(^)(__kindof EUILayout *))block {
    if (block) {
        block(self);
    }
    return self;
}

- (CGSize)validSize {
    CGSize size = {NSNotFound, NSNotFound};
    if (!self.isFlexable && self.view) {
        if (EUIValueIsValid(self.view.bounds.size.width)) {
            size.width = self.view.bounds.size.width;
        }
        if (EUIValueIsValid(self.view.bounds.size.height)) {
            size.height = self.view.bounds.size.height;
        }
        return size;
    }
    
    if (EUIValueIsValid(self.size.width)) {
        size.width = self.size.width;
    } else if (EUIValueIsValid(self.cacheFrame.size.width)) {
        size.width = self.cacheFrame.size.width;
    }
    if (EUIValueIsValid(self.size.height)) {
        size.height = self.size.height;
    } else if (EUIValueIsValid(self.cacheFrame.size.height)) {
        size.height = self.cacheFrame.size.height;
    }
    return size;
}


#pragma mark - Properties

- (void)setSize:(CGSize)size {
    self.width = size.width;
    self.height = size.height;
}

- (CGSize)size {
    return (CGSize) {
        self.width, self.height
    };
}

- (void)setOrigin:(CGPoint)origin {
    self.x = origin.x;
    self.y = origin.y;
}

- (CGPoint)origin {
    return (CGPoint) {
        self.x, self.y
    };
}

- (void)setFrame:(CGRect)frame {
    self.size = frame.size;
    self.origin = frame.origin;
    
}

- (CGRect)frame {
    return (CGRect) {
        .origin = self.origin, .size = self.size
    };
}

- (void)setSizeType:(EUISizeType)sizeType {
    if (_sizeType != sizeType) {
        _sizeType  = sizeType;
        [self setCacheFrame:EUIRectUndefine()];
    }
}

- (void)setGravity:(EUIGravity)gravity {
    if (_gravity != gravity) {
        _gravity  = gravity;
        [self setCacheFrame:EUIRectUndefine()];
    }
}

#pragma mark - NSCopying

@end
