//
//  EUIColumnTemplet.m
//  EUILayoutDemo
//
//  Created by Lux on 2018/9/25.
//  Copyright © 2018年 Lux. All rights reserved.
//

#import "EUIColumnTemplet.h"

@implementation EUIColumnTemplet

- (instancetype)initWithItems:(NSArray<EUIObject> *)items {
    self = [super initWithItems:items];
    if (self) {
        @weakify(self);
        self.parser.xParser.parsingBlock = ^
        (EUILayout *node, EUILayout *preNode,EUIParseContext *context)
        {
            @strongify(self);
            [self parseX:node _:preNode _:context];
        };
    }
    return self;
}

- (void)willLoadSubLayouts {
    [super willLoadSubLayouts];
    if (![self isBoundsValid]) {
        if (!(self.sizeType & EUISizeTypeToHorzFit)) {
            return;
        }
    }
    [self sizeThatFits:self.cacheFrame.size];
}

- (CGSize)sizeThatFits:(CGSize)constrainedSize {
    CGSize size = (CGSize){constrainedSize.width, 0};
    if (!EUIValueIsValid(constrainedSize.width) ||
        !EUIValueIsValid(constrainedSize.height))
    {
        return size;
    }
    
    CGFloat innerVertSide = EUIValue(self.padding.top) + EUIValue(self.padding.bottom);
    
    NSArray <EUILayout *> *nodes = self.nodes;
    NSMutableArray <EUILayout *> *fillNodes = [NSMutableArray arrayWithCapacity:nodes.count];
    CGFloat fitWidth = 0;
    for (EUILayout *node in nodes) {
        BOOL needFit = (node.sizeType & EUISizeTypeToHorzFit) || EUIValueIsValid(node.maxWidth) || EUIValueIsValid(node.width);
        if ( needFit ) {
            EUIParseContext ctx = (EUIParseContext) {
                .step = (EUIParsedStepX | EUIParsedStepY),
                .recalculate = YES,
                .constraintSize = (CGSize) {
                    ({
                        CGFloat w = EUIMaxSize().width;
                        if (EUIValueIsValid(node.maxWidth)) {
                            w = node.maxWidth;
                        } w;
                    }),
                    self.validSize.height - innerVertSide
                }
            };
            [self.parser.hParser parse:node _:nil _:&ctx];
            [self.parser.wParser parse:node _:nil _:&ctx];
            ///< -------------------------- >
            CGRect r = EUIRectUndefine();{
                r.size = ctx.frame.size;
            }
            [node setCacheFrame:r];
            ///< -------------------------- >
            fitWidth += r.size.width + EUIValue(node.margin.left) + EUIValue(node.margin.right);
            size.height = EUI_CLAMP(r.size.height, size.height, constrainedSize.height);
        } else {
            [fillNodes addObject:node];
        }
    }
    
    BOOL updateSelfIfNeeded = self.sizeType & EUISizeTypeToHorzFit;
    if ( updateSelfIfNeeded ) {
        if (fillNodes.count != 0) {
            NSCAssert(0, @"fit计算条件不够，以下 fillNodes:[%@] 的高度无法获知", fillNodes);
        }
        CGRect r = self.cacheFrame;
        r.size.width = fitWidth;
        self.cacheFrame = r;
        if ((self.sizeType & EUISizeTypeToVertFit)) {
            r.size.height = size.height;
            self.cacheFrame = r;
        } else {
            r.size.height = constrainedSize.height;
        }
        return r.size;
    }
    
    if (fillNodes.count == 0 ||
        fitWidth > constrainedSize.width)
    {
        ///< 如果约束过小，无法显示的fill单位就不计算了
        return size;
    }
    
    CGFloat innerHorzSide = EUIValue(self.padding.left) + EUIValue(self.padding.right);
    CGFloat innerWidth = constrainedSize.width - innerHorzSide;
    if (innerWidth <= 0) {
        NSCAssert(0, @"constrainedSize太小了！");
    }
    
    CGFloat aw  = (innerWidth - fitWidth) / fillNodes.count;
    for (EUILayout *node in fillNodes) {
        CGFloat min = 1.f;
        CGFloat h = 0;
        CGRect  r = EUIRectUndefine();
        CGFloat w = aw - EUIValue(node.margin.left) - EUIValue(node.margin.right);

        if (w < min) {
            w = h = min;
            r.size = (CGSize) {w, h};
            [node setCacheFrame:r];
            continue;
        } else {
            r.size.width = w;
        }
        
        EUIParseContext ctx = (EUIParseContext) {
            .step = (EUIParsedStepX | EUIParsedStepY | EUIParsedStepW),
            .recalculate = YES,
            .constraintSize = (CGSize) {w, constrainedSize.height - innerVertSide}
        };
        [self.parser.hParser parse:node _:nil _:&ctx];
        h = ctx.frame.size.height;{
            r.size.height = h;
        }
        [node setCacheFrame:r];
        size.height = EUI_CLAMP(h, size.height, constrainedSize.height);
    }
    
    return size;
}

- (void)parseX:(EUILayout *)node _:(EUILayout *)preNode _:(EUIParseContext *)context {
    EUIParsedStep *step = &(context->step);
    CGRect *frame = &(context->frame);
    CGRect preFrame = preNode ? preNode.cacheFrame : CGRectZero;
    if (preNode && CGRectEqualToRect(CGRectZero, preFrame)) {
        NSCAssert(0, @"EUIError : Layout:[%@] 在 Row 模板下的 Frame 计算异常", preNode);
    }
    CGFloat x = 0;
    if (preNode) {
        x = EUIValue(node.margin.left) + EUIValue(CGRectGetMaxX(preFrame)) + EUIValue(preNode.margin.right);
    } else {
        x = EUIValue(node.margin.left) + EUIValue(self.padding.left);
        if (!self.isHolder) {
            x += EUIValue(CGRectGetMinX(self.cacheFrame));
        }
    }
    frame -> origin.x = CGFloatPixelRound(x);
    *step |= EUIParsedStepX;
}

@end
