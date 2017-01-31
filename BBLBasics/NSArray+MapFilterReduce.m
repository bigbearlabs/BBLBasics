//
//  NSArray+MapFilterReduce.m
//  BBLBasics
//
//  Created by Andy Park on 29/01/2017.
//  Copyright © 2017 Big Bear Labs. All rights reserved.
//

#import "NSArray+MapFilterReduce.h"

@implementation NSArray (MapFilterReduce)

- (NSArray *)mapWith:(id (^)(id obj, NSUInteger idx))block {
  NSMutableArray *result = [NSMutableArray arrayWithCapacity:[self count]];
  [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    [result addObject:block(obj, idx)];
  }];
  return result;
}

- (NSArray*)filterWith:(BOOL (^)(id element))block {
  return [self filteredArrayUsingPredicate:
    [NSPredicate predicateWithBlock:^BOOL(id element, NSDictionary<NSString *,id> * _Nullable bindings) {
      return block(element);
    }]
  ];
}

@end

                                             
