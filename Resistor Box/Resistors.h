//
//  Resistors.h
//  Resistor Box
//
//  Created by Michael Griebling on 2May2013.
//  Copyright (c) 2013 Computer Inspirations. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Resistors : NSObject

+ (NSString *) stringFromR:(double)r;
+ (double) parseString: (NSString *)Rs;

+ (NSArray *) computeSeries:(double) X;
+ (NSArray *) ComputeParallel:(double) X;
+ (NSArray *) ComputeSeriesParallel:(double) X;

@end
