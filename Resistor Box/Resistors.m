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

+ (void) initInventory {
    if (!rInv) {
        NSArray *rStrings =
               @[@"1.0", @"10", @"100", @"1.0K", @"10", @"100K", @"1.0M",
                 @"1.1", @"11", @"110", @"1.1K", @"11K", @"110K", @"1.1M",
                 @"1.2", @"12", @"120", @"1.2K", @"12K", @"120K", @"1.2M",
                 @"1.3", @"13", @"130", @"1.3K", @"13K", @"130K", @"1.3M",
                 @"1.5", @"15", @"150", @"1.5K", @"15K", @"150K", @"1.5M",
                 @"1.6", @"16", @"160", @"1.6K", @"16K", @"160K", @"1.6M",
                 @"1.8", @"18", @"180", @"1.8K", @"18K", @"180K", @"1.8M",
                 @"2.0", @"20", @"200", @"2.0K", @"20K", @"200K", @"2.0M",
                 @"2.2", @"22", @"220", @"2.2K", @"22K", @"220K", @"2.2M",
                 @"2.4", @"24", @"240", @"2.4K", @"24K", @"240K", @"2.4M",
                 @"2.7", @"27", @"270", @"2.7K", @"27K", @"270K", @"2.7M",
                 @"3.0", @"30", @"300", @"3.0K", @"30K", @"300K", @"3.0M",
                 @"3.3", @"33", @"330", @"3.3K", @"33K", @"330K", @"3.3M",
                 @"3.6", @"36", @"360", @"3.6K", @"36K", @"360K", @"3.6M",
                 @"3.9", @"39", @"390", @"3.9K", @"39K", @"390K", @"3.9M",
                 @"4.3", @"43", @"430", @"4.3K", @"43K", @"430K", @"4.3M",
                 @"4.7", @"47", @"470", @"4.7K", @"47K", @"470K", @"4.7M",
                 @"5.1", @"51", @"510", @"5.1K", @"51K", @"510K", @"5.1M",
                 @"5.6", @"56", @"560", @"5.6K", @"56K", @"560K", @"5.6M",
                 @"6.2", @"62", @"620", @"6.2K", @"62K", @"620K", @"6.2M",
                 @"6.8", @"68", @"680", @"6.8K", @"68K", @"680K", @"6.8M",
                 @"7.5", @"75", @"750", @"7.5K", @"75K", @"750K", @"7.5M",
                 @"8.2", @"82", @"820", @"8.2K", @"82K", @"820K", @"8.2M",
                 @"9.1", @"91", @"910", @"9.1K", @"91K", @"910K", @"9.1M"];
        
        rInv = [NSMutableArray array];
        for (NSString *rString in rStrings) {
            [rInv addObject:@([Resistors parseString:rString])];
        }
        
        // Also add open/short
        [rInv addObject:@(OPEN)];
        [rInv addObject:@(SHORT)];
    }
}

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
//    Component *comp = (Component *)rInv[index];
//    return [Resistors parseString:comp.value];
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

