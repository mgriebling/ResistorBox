//
//  Resistors.m
//  Resistor Box
//
//  Created by Michael Griebling on 2May2013.
//  Copyright (c) 2013 Computer Inspirations. All rights reserved.
//

#import "Resistors.h"
#import "Component.h"

@implementation Resistors

static NSMutableArray *r5PC, *r10PC, *r1PC;    /* resistor inventory */
static NSArray *rInv;
//static const NSString *OPENS = @"1.0E12";
//static const NSString *SHORTS = @"1.0E-12";
static const double OPEN = 1.0E12;
static const double SHORT = 1.0E-12;
static const double MEG = 1.0E6;
static const double K = 1.0E3;

typedef double (^Algorithm)(NSUInteger r1, NSUInteger r2, NSUInteger r3);   // generic computation block type


+ (void) initInventory {
    if (!r5PC) {
        // 1% minimum: 1 ohm; maximum: 10M ohm
        NSArray *resistors1PerCent = @[
            @1.00, @1.02, @1.05, @1.07, @1.10, @1.13, @1.15, @1.18, @1.21, @1.24, @1.27, @1.30,
            @1.33, @1.37, @1.40, @1.43, @1.47, @1.50, @1.54, @1.58, @1.62, @1.65, @1.69, @1.74,
            @1.78, @1.82, @1.87, @1.91, @1.96, @2.00, @2.05, @2.10, @2.15, @2.21, @2.26, @2.32,
            @2.37, @2.43, @2.49, @2.55, @2.61, @2.67, @2.74, @2.80, @2.87, @2.94, @3.01, @3.09,
            @3.16, @3.24, @3.32, @3.40, @3.48, @3.57, @3.65, @3.74, @3.83, @3.92, @4.02, @4.12,
            @4.22, @4.32, @4.42, @4.53, @4.64, @4.75, @4.87, @4.99, @5.11, @5.23, @5.36, @5.49,
            @5.62, @5.76, @5.90, @6.04, @6.19, @6.34, @6.49, @6.65, @6.81, @6.98, @7.15, @7.32,
            @7.50, @7.68, @7.87, @8.06, @8.25, @8.45, @8.66, @8.87, @9.09, @9.31, @9.53, @9.76
        ];
        r1PC = [NSMutableArray array];
        double scale = 1.0;
        while (scale < 100000000.0) {
            for (NSNumber *resistor in resistors1PerCent) {
                if (scale == 10000000.0 && resistor.doubleValue == 1.02) break;
                [r1PC addObject:@(resistor.doubleValue * scale)];
            }
            scale *= 10.0;
        }
        // Also add open/short
        [r1PC addObject:@(OPEN)];
        [r1PC addObject:@(SHORT)];
        
        // 10% minimum: 1 ohm; maximum: 1M ohm
        NSArray *resistors10PerCent = @[
            @1.0, @1.2, @1.5, @1.8, @2.2, @2.7, @3.3, @3.9, @4.7, @5.6, @6.8, @8.2
        ];
        r10PC = [NSMutableArray array];
        scale = 1.0;
        while (scale < 10000000.0) {
            for (NSNumber *resistor in resistors10PerCent) {
                if (scale == 1000000.0 && resistor.doubleValue == 1.2) break;
                [r10PC addObject:@(resistor.doubleValue * scale)];
            }
            scale *= 10.0;
        }
        // Also add open/short
        [r10PC addObject:@(OPEN)];
        [r10PC addObject:@(SHORT)];
        
        // 5% minimum: 1 ohm; maximum: 56M ohm
        NSArray *resistors5PerCent =
               @[@1.0, @1.1, @1.2, @1.3, @1.5, @1.6, @1.8, @2.0, @2.2, @2.4, @2.7, @3.0,
                 @3.3, @3.6, @3.9, @4.3, @4.7, @5.1, @5.6, @6.2, @6.8, @7.5, @8.2, @9.1];
        
        r5PC = [NSMutableArray array];
        scale = 1.0;
        while (scale < 100000000.0) {
            for (NSNumber *resistor in resistors5PerCent) {
                if (scale == 10000000.0 && resistor.doubleValue == 6.2) break;
                [r5PC addObject:@(resistor.doubleValue * scale)];
            }
            scale *= 10.0;
        }
        
        // Also add open/short
        [r5PC addObject:@(OPEN)];
        [r5PC addObject:@(SHORT)];
        rInv = r1PC;
    }
}

+ (void) clear {
    rInv = nil;
}

+ (double) parseString: (NSString *)Rs {
    NSString *subRs = [Rs stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    double scale = 1.0;
    
    if ([subRs hasSuffix:@"Ω"]) subRs = [subRs substringToIndex:subRs.length-1];
    
    if ([subRs hasSuffix:@"m"]) {
        subRs = [subRs substringToIndex:subRs.length-1];
        scale = 1.0/K;
    }
    subRs = [subRs uppercaseString];
    if ([subRs hasSuffix:@"K"]) {
        subRs = [subRs substringToIndex:subRs.length-1];
        scale = K;
    }
    if ([subRs hasSuffix:@"M"]) {
        subRs = [subRs substringToIndex:subRs.length-1];
        scale = MEG;
    }
    if ([subRs hasSuffix:@"MEG"]) {
        subRs = [subRs substringToIndex:subRs.length-3];
        scale = MEG;
    }
    return subRs.doubleValue * scale;
}

+ (double) value:(NSUInteger)index {
    NSNumber *r = rInv[index];
    return r.doubleValue;
}

+ (NSString *) stringFromR:(double)r {
    NSString *ext = @"Ω";
    NSString *s;
    if (r == OPEN) {
        return @"Open";
    } else if (r <= SHORT) {
        return @"Short";
    } else {
        if (r >= MEG) {
            r /= MEG; ext = @"MΩ";
        } else if (r >= K) {
            r /= K; ext = @"KΩ";
        } else if (r < 0.1) {
            r *= K; ext = @"mΩ";
        }
        s = [[NSString stringWithFormat:@"%15.3f", r] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        while ([s hasSuffix:@"0"]) {
            s = [s substringToIndex:s.length-1];
        }
        if ([s hasSuffix:@"."]) {
            s = [s substringToIndex:s.length-1];
        }
        return [s stringByAppendingString:ext];
    }
}

+ (NSArray *) compute:(double)X withAlgorithm:(Algorithm)alg {
    double Re, Rt;
    NSUInteger Rn = rInv.count;
    NSUInteger i, j, k, Ri, Rj, Rk;
    
    Re = 1.0E100; Ri = 0; Rj = 0; Rk = 0;
    for (i = 0; i < Rn; i++) {
        for (j = 0; j < Rn; j++) {
            for (k = 0; k < Rn; k++) {
                Rt = fabs(X - alg(i, j, k));
                if (Rt < Re) {
                    Ri = i; Rj = j; Rk = k;
                    if (fabs(Rt - Re) < 0.000001) {
                        j = Rn; k = Rn; break;
                    }
                    Re = Rt;
                }
            }
        }
    }
    
    Rt = alg(Ri, Rj, Rk);
    return @[@([Resistors value:Ri]), @([Resistors value:Rj]), @([Resistors value:Rk]), @(Rt), (X != 0.0) ? @(100.0 * fabs(X - Rt) / X) : @(fabs(X - Rt))];
}

+ (NSArray *) computeSeries:(double) X {
    [Resistors initInventory];
    return [Resistors compute:X withAlgorithm:^double (NSUInteger r1, NSUInteger r2, NSUInteger r3) {
        return [Resistors value:r1] + [Resistors value:r2] + [Resistors value:r3];
    }];
}

+ (NSArray *) ComputeParallel:(double) X {
//    [Resistors initInventory];
    return [Resistors compute:X withAlgorithm:^double (NSUInteger r1, NSUInteger r2, NSUInteger r3) {
        return (1.0 / ((1.0 / [Resistors value:r1]) + (1.0 / [Resistors value:r2]) + (1.0 / [Resistors value:r3])));
    }];
}

+ (NSArray *) ComputeSeriesParallel:(double) X {
//    [Resistors initInventory];
    return [Resistors compute:X withAlgorithm:^double (NSUInteger r1, NSUInteger r2, NSUInteger r3) {
        return ([Resistors value:r1] + (1.0 / ((1.0 / [Resistors value:r2]) + (1.0 / [Resistors value:r3]))));
    }];
}

@end

