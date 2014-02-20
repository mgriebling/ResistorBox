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

static NSMutableArray *r5PC;                            /* resistor inventory */
static NSArray *rInv;
//static const NSString *OPENS = @"1.0E12";
//static const NSString *SHORTS = @"1.0E-12";
static const double OPEN = 1.0E12;
static const double SHORT = 1.0E-12;
static const double MEG = 1.0E6;
static const double K = 1.0E3;

typedef double (^Algorithm)(int r1, int r2, int r3);   // generic computation block type

//+ (void) openFileWithName:(NSString *) name {
//    ResultSet parts = Parts.getParts();
//    try {
//        while (parts.next()) {
//            Part m = Parts.getPart(parts);
//            if (m.footprint == null ? name == null : m.footprint.equals(name)) {
//                Rinv.add(m);
//                System.out.println(m.toString());
//            }
//        }
//    } catch (Exception e) {
//        System.out.println(e.getMessage());
//    }
//}

+ (void) initInventory {
    if (!r5PC) {
        // 1% minimum: 1 ohm; maximum: 10M ohm
        NSArray *resistors1PerCent = @[
            @10.0, @10.2, @10.5, @10.7, @11.0, @11.3, @11.5, @11.8, @12.1, @12.4, @12.7, @13.0,
            @13.3, @13.7, @14.0, @14.3, @14.7, @15.0, @15.4, @15.8, @16.2, @16.5, @16.9, @17.4,
            @17.8, @18.2, @18.7, @19.1, @19.6, @20.0, @20.5, @21.0, @21.5, @22.1, @22.6, @23.2,
            @23.7, @24.3, @24.9, @25.5, @26.1, @26.7, @27.4, @28.0, @28.7, @29.4, @30.1, @30.9,
            @31.6, @32.4, @33.2, @34.0, @34.8, @35.7, @36.5, @37.4, @38.3, @39.2, @40.2, @41.2,
            @42.2, @43.2, @44.2, @45.3, @46.4, @47.5, @48.7, @49.9, @51.1, @52.3, @53.6, @54.9,
            @56.2, @57.6, @59.0, @60.4, @61.9, @63.4, @64.9, @66.5, @68.1, @69.8, @71.5, @73.2,
            @75.0, @76.8, @78.7, @80.6, @82.5, @84.5, @86.6, @88.7, @90.9, @93.1, @95.3, @97.6
        ];
        
        // 10% minimum: 2.2 ohm; maximum: 1M ohm
        NSArray *resistors10PerCent = @[
            @10, @12, @15, @18, @22, @27, @33, @39, @47, @56, @68, @82
        ];
        
        // 5% minimum: 1 ohm; maximum: 56M ohm
        NSArray *resistors5PerCent =
               @[@1.0, @1.1, @1.2, @1.3, @1.5, @1.6, @1.8, @2.0, @2.2, @2.4, @2.7, @3.0,
                 @3.3, @3.6, @3.9, @4.3, @4.7, @5.1, @5.6, @6.2, @6.8, @7.5, @8.2, @9.1];
        
        r5PC = [NSMutableArray array];
        double scale = 1.0;
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
        rInv = r5PC;
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

+ (double) value:(int)index {
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


//static void ReadResistors(String name) {
//    Open(name); /* Open resistor inventory database */
//    Rinv.add(new Parts.Part(0, "Solinst", "Short", SHORTS, "1%", name));    /* Augment with shorting-bar */
//    Rinv.add(new Parts.Part(0, "Solinst", "Open", OPENS, "1%", name));      /* ...and open */
//}

+ (NSArray *) compute:(double)X withAlgorithm:(Algorithm)alg {
    double Re, Rt;
    int Rn = rInv.count;
    int i, j, k, Ri, Rj, Rk;
    
    Re = 1.0E100; Ri = 0; Rj = 0; Rk = 0;
    for (i = 0; i < Rn; i++) {
        for (j = 0; j < Rn; j++) {
            for (k = 0; k < Rn; k++) {
                Rt = fabs(X - alg(i, j, k));
                if (Rt < Re) {
                    Ri = i; Rj = j; Rk = k; Re = Rt;
//                } else if (fabs(Rt - Re) < 0.000001) {
//                    NSLog(@"Duplicate combination: %@, %@, and %@", [Resistors stringFromR:[Resistors value:i]], [Resistors stringFromR:[Resistors value:j]], [Resistors stringFromR:[Resistors value:k]]);
                }
            }
        }
    }
    
    Rt = alg(Ri, Rj, Rk);
    return @[@([Resistors value:Ri]), @([Resistors value:Rj]), @([Resistors value:Rk]), @(Rt), (X != 0.0) ? @(100.0 * fabs(X - Rt) / X) : @(fabs(X - Rt))];
}

+ (NSArray *) computeSeries:(double) X {
    [Resistors initInventory];
    return [Resistors compute:X withAlgorithm:^double (int r1, int r2, int r3) {
        return [Resistors value:r1] + [Resistors value:r2] + [Resistors value:r3];
    }];
}

+ (NSArray *) ComputeParallel:(double) X {
    [Resistors initInventory];
    return [Resistors compute:X withAlgorithm:^double (int r1, int r2, int r3) {
        return (1.0 / ((1.0 / [Resistors value:r1]) + (1.0 / [Resistors value:r2]) + (1.0 / [Resistors value:r3])));
    }];
}

+ (NSArray *) ComputeSeriesParallel:(double) X {
    [Resistors initInventory];
    return [Resistors compute:X withAlgorithm:^double (int r1, int r2, int r3) {
        return ([Resistors value:r1] + (1.0 / ((1.0 / [Resistors value:r2]) + (1.0 / [Resistors value:r3]))));
    }];
}

@end

