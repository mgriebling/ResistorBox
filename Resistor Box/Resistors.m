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

static NSMutableArray *rInv;                            /* resistor inventory */
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

+ (void) clear {
    [rInv removeAllObjects];
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
    Component *comp = (Component *)rInv[index];
    return [Resistors parseString:comp.value];
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
                Rt = abs(X - alg(i, j, k));
                if (Rt < Re) {
                    Ri = i; Rj = j; Rk = k; Re = Rt;
                }
            }
        }
    }
    
    Rt = alg(Ri, Rj, Rk);
    return @[@([Resistors value:Ri]), @([Resistors value:Rj]), @([Resistors value:Rk]), @(Rt), @(100 * abs(X - Rt) / X)];
}

+ (NSArray *) computeSeries:(double) X {
    return [Resistors compute:X withAlgorithm:^double (int r1, int r2, int r3) {
        return [Resistors value:r1] + [Resistors value:r2] + [Resistors value:r3];
    }];
}

+ (NSArray *) ComputeParallel:(double) X {
    return [Resistors compute:X withAlgorithm:^double (int r1, int r2, int r3) {
        return (1.0 / ((1.0 / [Resistors value:r1]) + (1.0 / [Resistors value:r2]) + (1.0 / [Resistors value:r3])));
    }];
}

+ (NSArray *) ComputeSeriesParallel:(double) X {
    return [Resistors compute:X withAlgorithm:^double (int r1, int r2, int r3) {
        return ([Resistors value:r1] + (1.0 / ((1.0 / [Resistors value:r2]) + (1.0 / [Resistors value:r3]))));
    }];
}

@end

