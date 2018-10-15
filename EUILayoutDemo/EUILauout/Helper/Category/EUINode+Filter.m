//
//  EUINode+Filter.m
//  EUILayoutDemo
//
//  Created by Lux on 2018/10/15.
//  Copyright © 2018 Lux. All rights reserved.
//

#import "EUINode+Filter.h"
#import "UIView+EUILayout.h"

@implementation EUINode (Filter)

+ (EUINode * __nullable)findNode:(EUIObject)object {
    if (!object) return nil;
    EUINode *one = nil;
    if ([object isKindOfClass:UIView.class]) {
        one = [(UIView *)object eui_node];
    } else if ([object isKindOfClass:EUINode.class]) {
        one = object;
    } else {
        return nil;
    }
    return one;
}

+ (NSArray <EUINode *> *)nodesFromItems:(NSArray <id> *)items {
    if (!items || items.count == 0) {
        return nil;
    }
    if (items.count == 1 && [[items objectAtIndex:0] isKindOfClass:NSArray.class]) {
        items = items[0];
    }
    NSMutableArray *one = @[].mutableCopy;
    for (id item in items) {
        EUINode *node = [EUINode findNode:item];
        if (node) {
            [one addObject:node];
        }
    }
    return one;
}


@end