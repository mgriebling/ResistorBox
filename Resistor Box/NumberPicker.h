//
//  NumberPicker.h
//  NumberPicker
//
//  Created by Mike Griebling on 17 Apr 2013.
//  Copyright (c) 2013 Computer Inspirations. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "LLRate.h"

@interface NumberPicker : NSObject <UIPickerViewDataSource, UIPickerViewDelegate>

typedef void (^ValueChanged)(NumberPicker *picker);  // value changed notification

@property (strong, nonatomic, readonly) NSDecimalNumber *maxValue;
@property (strong, nonatomic, readonly) NSDecimalNumber *minValue;
@property (strong, nonatomic, readonly) NSDecimalNumber *stepSize;
@property (strong, nonatomic, readonly) NSDecimalNumber *value;
//@property (strong, nonatomic, readonly) LLRate *rate;
@property (strong, nonatomic) ValueChanged valueChangeCallback;

- (id) init:(NSDecimalNumber *)maxValue;
- (id) initWithMaximum:(NSDecimalNumber *)maxValue andLabels:(NSArray *)labels;
- (id) initWithMaximum:(NSDecimalNumber *)maxValue andMinimum:(NSDecimalNumber *)minValue andLabels:(NSArray *)labels;
- (id) initWithRangeOfNumbers:(NSDecimalNumber *)minimum maximum:(NSDecimalNumber *)maximum stepSize:(NSDecimalNumber *)step labels:(NSArray *)labels;
//- (id)initWithRate:(LLRate *)rate;

- (void) setPicker:(UIPickerView *)picker toCurrentValue:(id)val;
- (void) setPicker:(UIPickerView *)picker toCurrentValue:(id)val label:(NSString *)label;
- (NSString *) getSelectedLabel:(UIPickerView *)picker;

@end
