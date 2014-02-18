//********************************************************************************
//
// This source is Copyright (c) 2013 by Solinst Canada.  All rights reserved.
//
//********************************************************************************
/**
 * \file   	NumberPicker.m
 * \details A model for a general-purpose number picker that can handle numbers
 *          with up to 14 digits and a fixed decimal point.  This model also
 *          acts as a delegate and data source for a \e UIPicker.  Expanded
 *          interface to allow selection of negative numbers as well.
 * \author  Michael Griebling
 * \date   	1 October 2013
 */
//********************************************************************************

#import "NumberPicker.h"

@interface NumberPicker ()

@property (strong, nonatomic, readwrite) NSDecimalNumber *maxValue;
@property (strong, nonatomic, readwrite) NSDecimalNumber *minValue;
@property (strong, nonatomic, readwrite) NSDecimalNumber *stepSize;
@property (strong, nonatomic, readwrite) NSArray *columnValues;
@property (strong, nonatomic, readwrite) NSArray *negativeColumnValues;
@property (strong, nonatomic, readwrite) NSArray *labels;
@property (nonatomic, readwrite) NSInteger decimalColumn;
@property (strong, nonatomic, readwrite) NSDecimalNumber *value;
@property (strong, nonatomic, readwrite) LLRate *rate;
@property (nonatomic) NSInteger maxActiveRow;
@property (nonatomic) NSUInteger kindOfPicker;
@property (nonatomic, strong) NSNumberFormatter *formatter;

@end

@implementation NumberPicker

@synthesize value = _value;

#define MinMaxPicker  1
#define NumberPicker  0
#define RatePicker    2

//********************************************************************************
/**
 * \details Getter for the number formatter.
 * \author  Michael Griebling
 * \date   	17 April 2013
 */
//********************************************************************************
- (NSNumberFormatter *)formatter {
    if (!_formatter) {
        _formatter = [[NSNumberFormatter alloc] init];
        [_formatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
        [_formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [_formatter setGeneratesDecimalNumbers:YES];
    }
    return _formatter;
}

//********************************************************************************
/**
 * \details Getter for the \e columnValues property.
 * \author  Michael Griebling
 * \date   	17 April 2013
 */
//********************************************************************************
- (NSArray *)columnValues {
    if (!_columnValues) {
        _columnValues = [NSArray array];
    }
    return _columnValues;
}

//********************************************************************************
/**
 * \details Setter for the \e decimalColumn property.  Also sets the initial
 *          value for \e maxActiveRow.
 * \author  Michael Griebling
 * \date   	17 April 2013
 */
//********************************************************************************
- (void)setDecimalColumn:(NSInteger)decimalColumn {
    _decimalColumn = decimalColumn;
    self.maxActiveRow = decimalColumn;
}

//********************************************************************************
/**
 * \details Getter for the \e value property.  This property maintains the
 *          current value for the number picker.
 * \author  Michael Griebling
 * \date   	17 April 2013
 */
//********************************************************************************
- (NSDecimalNumber *)value {
    if (!_value) {
        _value = [NSDecimalNumber zero];
    }
    return _value;
}

//********************************************************************************
/**
 * \details Getter for the \e minValue property.  This property maintains the
 *          minimum value for the number picker.  The minimum will be a large
 *          negative number if unused.
 * \author  Michael Griebling
 * \date   	17 April 2013
 */
//********************************************************************************
- (NSDecimalNumber *)minValue {
    if (!_minValue) {
        _minValue = [[NSDecimalNumber zero] decimalNumberBySubtracting:[NSDecimalNumber maximumDecimalNumber]];
    }
    return _minValue;
}

//********************************************************************************
/**
 * \details Getter for the \e stepSize property.  This property maintains the
 *          stepping value for the number picker.  The \e stepSize will be zero
 *          for variable resolution numbers.
 * \author  Michael Griebling
 * \date   	17 April 2013
 */
//********************************************************************************
- (NSDecimalNumber *)stepSize {
    if (!_stepSize) {
        _stepSize = [NSDecimalNumber zero];
    }
    return _stepSize;
}

//********************************************************************************
/**
 * \details Setter for the \e value property.  This method implements a callback
 *          using \e valueChangeCallback so the user can monitor changes to an
 *          associated number picker.
 * \author  Michael Griebling
 * \date   	17 April 2013
 */
//********************************************************************************
- (void)setValue:(NSDecimalNumber *)value {
    _value = value;
    if (self.valueChangeCallback) {
        self.valueChangeCallback(self);
    }
}

//********************************************************************************
/**
 * \details Return \e YES if the active number is negative.
 * \author  Michael Griebling
 * \date   	1 October 2013
 */
//********************************************************************************
- (BOOL) isNegativeNumber {
    return self.value.doubleValue < 0.0;
}

//********************************************************************************
/**
 * \details Internal method to return the number of columns in the picker -- while
 *          ignoring any labels.
 * \author  Michael Griebling
 * \date   	17 April 2013
 */
//********************************************************************************
- (NSInteger) getNumberColumnCount {
    NSArray *columns = ![self isNegativeNumber] ? self.columnValues : self.negativeColumnValues;
    NSInteger numberColumns = [columns count];
    if (self.labels != nil) numberColumns--;
    if (self.negativeColumnValues) numberColumns++;
    return numberColumns;
}

//********************************************************************************
/**
 * \details Returns a string representation of the active picker selections.
 * \author  Michael Griebling
 * \date   	17 April 2013
 */
//********************************************************************************
- (NSString *) getPickerNumberAsString:(UIPickerView *)picker {
    NSMutableString *val = [NSMutableString stringWithString:@""];
    int columns = [self getNumberColumnCount];
    
    for (int i = 0; i < columns; i++) {
        NSInteger selected = [picker selectedRowInComponent:i];
        if ([self negativeColumnValues]) {
            if (i == 0) {
                if (selected == 1) [val appendString:@"-"];
                continue;   // next loop iteration
            } else {
                selected = [picker selectedRowInComponent:i+1];
            }
        }
        if (i == self.decimalColumn) [val appendFormat:@".%d", selected];
        else [val appendFormat:@"%d", selected];
    }
    return val;
}

//********************************************************************************
/**
 * \details Internal method to split a number string into separate character-sized
 *          pieces.
 * \author  Michael Griebling
 * \date   	17 April 2013
 */
//********************************************************************************
- (NSArray *) splitStringToArray:(NSString *)stringVal {
    NSMutableArray *splitVal = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [stringVal length]; i++) {
        NSString *numStr = [NSString stringWithFormat:@"%c", [stringVal characterAtIndex:i]];
        if ([numStr isEqualToString:@"."]) {
            if (self.decimalColumn == -1) self.decimalColumn = i;
            numStr = [NSString stringWithFormat:@"%c", [stringVal characterAtIndex:++i]];
        }
        [splitVal addObject:[NSNumber numberWithInt:[numStr intValue]]];
    }
    return splitVal;
}

//********************************************************************************
/**
 * \details Returns the string representation of the number \e val.  A leading
 *          zero is removed.
 * \author  Michael Griebling
 * \date   	17 April 2013
 */
//********************************************************************************
- (NSString *) getNumberString:(NSDecimalNumber *)val {
    NSString *stringVal = [val stringValue];
    if ([stringVal hasPrefix:@"0."]) {
        stringVal = [stringVal stringByReplacingOccurrencesOfString:@"0." withString:@"."];
    }
    if ([self getNumberColumnCount] > 0 && stringVal.length > [self getNumberColumnCount]) {
        stringVal = [stringVal substringToIndex:[self getNumberColumnCount]];
    }
    return stringVal;
}

//********************************************************************************
/**
 * \details Splits a number \e val into character-sized pieces and returns an
 *          array of these strings.
 * \author  Michael Griebling
 * \date   	17 April 2013
 */
//********************************************************************************
- (NSArray *) split:(NSDecimalNumber *)val {
    self.maxValue = val;
    if (val && [val intValue] >= 0) {
        NSString *stringVal = [self getNumberString:val];
        return [self splitStringToArray:stringVal];
    }
    return nil;
}

//********************************************************************************
/**
 * \details Formats a number \e val into a fixed number of decimal places and
 *          leading digits which are split and returned as an array of strings.
 * \author  Michael Griebling
 * \date   	17 April 2013
 */
//********************************************************************************
- (NSArray *) splitAndPad:(NSDecimalNumber *)val {
    NSMutableArray *splitVal = [[self split:val] mutableCopy];
    int countNumberCols = [self getNumberColumnCount];
    if ([splitVal count] < countNumberCols) {
        int numFloatPrecision = 0;
        int stringLength = countNumberCols;
        if (self.decimalColumn >= 0) {
            stringLength++;
            numFloatPrecision = countNumberCols - self.decimalColumn;
        }
        
        NSString *formatted = [NSString stringWithFormat:@"%0*.*f", stringLength, numFloatPrecision, val.doubleValue];
        return [self splitStringToArray:formatted];
    }
    return splitVal;
}

//********************************************************************************
/**
 * \details Default initializer for the \e NumberPicker objects.  Esssentially
 *          the \e maxValue is analyzed and broken down into columns where each
 *          column contains the values from 0 to 9.  The \e columnValues
 *          property holds all the column arrays.  For example, if \e maxValue
 *          = 999.9; four columns are created.
 * \author  Michael Griebling
 * \date   	17 April 2013
 */
//********************************************************************************
- (id)init:(NSDecimalNumber *)maxValue {
    return [self init:maxValue withMinimum:[NSDecimalNumber decimalNumberWithString:@"0"]];
}

//********************************************************************************
/**
 * \details Extented initializer that also handles negative numbers.
 * \author  Michael Griebling
 * \date   	17 April 2013
 */
//********************************************************************************
- (id) init:(NSDecimalNumber *)maxValue withMinimum:(NSDecimalNumber *)minValue {
    self = [self init];
    self.kindOfPicker = NumberPicker;
    self.decimalColumn = -1;
    NSArray *digits = [self split:maxValue];
    BOOL isNegative = (minValue.doubleValue < 0.0);
    if (isNegative) minValue = [[NSDecimalNumber decimalNumberWithString:@"0"] decimalNumberBySubtracting:minValue];
    NSArray *minDigits = [self split:minValue];
    NSInteger maxColumns = MAX([minDigits count], [digits count]);
    
    // define the positive column values
    NSMutableArray *columnValues = [[NSMutableArray alloc] init];
    for (int i = 0; i < maxColumns; i++) {
        int max = 9;
        if (i == 0) max = [(NSNumber *)[digits objectAtIndex:0] intValue];
        NSMutableArray *column = [[NSMutableArray alloc] init];
        for (int j = 0; j <= max; j++) {
            [column addObject:[NSNumber numberWithInt:j]];
        }
        [columnValues addObject:column];
    }
    _columnValues = columnValues;
    
    // define the negative column values -- if any
    _negativeColumnValues = nil;
    if (isNegative) {
        columnValues = [[NSMutableArray alloc] init];
        int columnIndex = [digits count];
        for (int i = 0; i < maxColumns; i++, columnIndex--) {
            int max = 9;
            if (columnIndex == [minDigits count]) {
                max = [(NSNumber *)[minDigits objectAtIndex:0] intValue];
            } else if (columnIndex > [minDigits count]) {
                max = 0;
            }
            NSMutableArray *column = [[NSMutableArray alloc] init];
            for (int j = 0; j <= max; j++) {
                [column addObject:[NSNumber numberWithInt:j]];
            }
            [columnValues addObject:column];
        }
        _negativeColumnValues = columnValues;
    }
    return self;
}

//********************************************************************************
/**
 * \details Initializer for \e NumberPicker objects that also adds a rightmost
 *          column containing \e labels.  These \e labels can be anything like
 *          units, metric scalers, or any set of strings.
 * \author  Michael Griebling
 * \date   	17 April 2013
 */
//********************************************************************************
- (id) initWithMaximum:(NSDecimalNumber *)maxValue andLabels:(NSArray *)labels {
    self = [self init:maxValue];
    _labels = labels;
    NSMutableArray *columnValues = [self.columnValues mutableCopy];
    [columnValues addObject:labels];
    _columnValues = columnValues;
    _negativeColumnValues = nil;
    return self;
}

//********************************************************************************
/**
 * \details Initializer for \e NumberPicker objects that also adds a rightmost
 *          column containing \e labels.  These \e labels can be anything like
 *          units, metric scalers, or any set of strings.  This version also
 *          supports a minimum negative value.
 * \author  Michael Griebling
 * \date   	17 April 2013
 */
//********************************************************************************
- (id) initWithMaximum:(NSDecimalNumber *)maxValue andMinimum:(NSDecimalNumber *)minValue andLabels:(NSArray *)labels {
    self = [self init:maxValue withMinimum:minValue];
    _labels = labels;
    NSMutableArray *columnValues = [self.columnValues mutableCopy];
    [columnValues addObject:labels];
    _columnValues = columnValues;
    if (minValue.doubleValue < 0.0) {
        columnValues = [self.negativeColumnValues mutableCopy];
        [columnValues addObject:labels];
        _negativeColumnValues = columnValues;
    }
    return self;
}

//********************************************************************************
/**
 * \details Initializer for \e NumberPicker objects that uses a fixed number of
 *          stepper rows defined by the difference between the \e maximum and
 *          \e minimum values divided by the \e step size.
 * \author  Michael Griebling
 * \date   	17 April 2013
 */
//********************************************************************************
- (id) initWithRangeOfNumbers:(NSDecimalNumber *)minimum maximum:(NSDecimalNumber *)maximum stepSize:(NSDecimalNumber *)step labels:(NSArray *)labels {
    self = [self init];
    if (self) {
        _minValue = minimum;
        _maxValue = maximum;
        _stepSize = step;
        
        // create the rows for this control
        NSDecimalNumber *number = maximum;
        NSMutableArray *column = [NSMutableArray array];
        NSMutableArray *columnValues = [self.columnValues mutableCopy];
        while ([number compare:minimum] == NSOrderedDescending) {
            [column addObject:[self.formatter stringFromNumber:number]];
            number = [number decimalNumberBySubtracting:step];
        }
        [columnValues addObject:column];
        [columnValues addObject:labels];
        _columnValues = columnValues;
        _labels = labels;
        _value = minimum;
        _kindOfPicker = MinMaxPicker;
    }
    return self;
}

//********************************************************************************
/**
 * \details Initializer for \e NumberPicker objects that use a rate.
 * \author  Michael Griebling
 * \date   	17 April 2013
 */
//********************************************************************************
- (id)initWithRate:(LLRate *)rate {
    self = [self init];
    if (self) {
        _rate = rate;
        _kindOfPicker = RatePicker;
    }
    return self;
}

//********************************************************************************
/**
 * \details Returns the selected label in the \e picker.
 * \author  Michael Griebling
 * \date   	17 April 2013
 */
//********************************************************************************
- (NSString *) getSelectedLabel:(UIPickerView *)picker {
    NSString *labelVal = @"";
    if (self.labels && self.columnValues) {
        NSInteger columns = [picker numberOfComponents];
        NSInteger pickerSelection = [picker selectedRowInComponent:columns-1];
        labelVal = self.labels[pickerSelection];
    }
    return labelVal;
}

//********************************************************************************
/**
 * \details Sets the current \e picker column indices to match the number \e val.
 * \author  Michael Griebling
 * \date   	17 April 2013
 */
//********************************************************************************
- (void) setPicker:(UIPickerView *)picker toCurrentValue:(id)val {
    if (self.kindOfPicker == MinMaxPicker) {
        NSDecimalNumber *number = (NSDecimalNumber *)val;
        self.value = number;
        NSDecimalNumber *index = [[self.maxValue decimalNumberBySubtracting:number] decimalNumberByDividingBy:self.stepSize];
        [picker selectRow:index.integerValue inComponent:0 animated:YES];
    } else if (self.kindOfPicker == RatePicker) {
        self.rate = val;
        [picker selectRow:[self.rate timeIndex] inComponent:0 animated:YES];  // set time
        [picker selectRow:[self.rate unitIndex] inComponent:1 animated:YES];  // set units
    } else {
        BOOL isNegative = ((NSDecimalNumber *)val).doubleValue < 0.0;
        self.value = val;
        if (isNegative) {
            val = [[NSDecimalNumber decimalNumberWithString:@"0"] decimalNumberBySubtracting:val];
        }
        NSArray *splitVal = [self splitAndPad:val];
        int diff = [self getNumberColumnCount] - [splitVal count];
        int startRow = self.negativeColumnValues ? 1 : 0;
        
        for (int i = startRow; i < [self getNumberColumnCount]; i++) {
            if (i < diff) {
                [picker selectRow:0 inComponent:i animated:YES];
            } else {
                int row = [(NSNumber *)[splitVal objectAtIndex:(i-diff-startRow)] intValue];
                [picker selectRow:row inComponent:i animated:YES];
            }
        }
        
        if (self.negativeColumnValues) {
            [picker selectRow:isNegative ? 1 : 0 inComponent:0 animated:YES];
        }
        
        if ([self findMaximumRow:[self getPickerNumberAsString:picker]]) {
            [picker reloadAllComponents];
        }
    }
}

//********************************************************************************
/**
 * \details Sets both the current \e picker column indices to match the number 
 *          \e val and sets the units column to match \e label.
 * \author  Michael Griebling
 * \date   	17 April 2013
 */
//********************************************************************************
- (void) setPicker:(UIPickerView *)picker toCurrentValue:(id)val label:(NSString *)label {
    [self setPicker:picker toCurrentValue:val];
    for (int i = 0; i < [self.labels count]; i++) {
        NSString *labelVal = [self.labels objectAtIndex:i];
        if ([labelVal isEqualToString:label]) {
            [picker selectRow:i inComponent:([picker numberOfComponents] - 1) animated:YES];
        }
    }
}

#pragma mark - Picker Delegate methods
//********************************************************************************
/**
 * \details Picker delegate method to return the number of columns.
 * \author  Michael Griebling
 * \date   	17 April 2013
 */
//********************************************************************************
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    if (self.kindOfPicker == RatePicker) {
        return 2;
    }
    if ([self negativeColumnValues]) {
        return self.negativeColumnValues.count+1;
    }
    return self.columnValues.count;
}

//********************************************************************************
/**
 * \details Picker delegate method to return the number of rows in a \e component
 *          column.
 * \author  Michael Griebling
 * \date   	17 April 2013
 */
//********************************************************************************
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (self.kindOfPicker == RatePicker) {
        if (component == 0) {
            return self.rate.maxIndexForTime;
        } else {
            return self.rate.maxIndexForUnits;
        }
    }
    if ([self negativeColumnValues]) {
        if (component == 0) return 2;
        return ((NSArray *)self.negativeColumnValues[component-1]).count;
    }
    return ((NSArray *)self.columnValues[component]).count;
}

//********************************************************************************
/**
 * \details Returns a string for the \e component column
 *          and the \e row in that column.  If a decimal point was present in the
 *          maximum number, the decimal point is displayed in the correct column.
 *          Any leading zeros are removed from their columns and replaced with a
 *          blank row (e.g., a number like 003.20 is displayed as 3.20).
 * \author  Michael Griebling
 * \date   	17 April 2013
 */
//********************************************************************************
- (NSString *)stringFor:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSString *string;
    if (self.kindOfPicker == MinMaxPicker) {
        NSArray *column = self.columnValues[component];
        string = column[row];
    } else if (self.kindOfPicker == RatePicker) {
        if (component == 0) {
            return [self.rate stringForTimeIndex:row];
        } else {
            return [self.rate stringForUnitIndex:row];
        }
    } else {
        if ([self negativeColumnValues]) {
            if (component == 0) {
                if (row == 0) {
                    return @" ";
                } else {
                    return @"-";
                }
            }
            component--;
        }

        NSArray *column = [self negativeColumnValues] ? self.negativeColumnValues[component] : self.columnValues[component];
        if (self.decimalColumn == component+1) {
            string = [NSString stringWithFormat:@"%@ .", column[row]];
        } else {
            if (row == 0 && self.maxActiveRow > component) string = @" ";
            else string = [NSString stringWithFormat:@"%@", column[row]];
        }
    }
    return string;
}

//********************************************************************************
/**
 * \details Picker delegate method to return a view containing a centred string.
 * \author  Michael Griebling
 * \date   	15 July 2013
 */
//********************************************************************************
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel *label;
    if (!view) {
        label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 250, 50)];
        view = label;
    } else {
        label = (UILabel *)view;
    }
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor blackColor];
    label.backgroundColor = [UIColor clearColor];
    label.font = [self fontForComponent:component];
    label.text = [self stringFor:pickerView titleForRow:row forComponent:component];
    label.lineBreakMode = NSLineBreakByTruncatingTail;
    return view;
}

//********************************************************************************
/**
 * \details Font for picker columns.
 * \author  Michael Griebling
 * \date   	10 September 2013
 */
//********************************************************************************
- (UIFont *) fontForComponent:(NSInteger)component {
    BOOL isPad = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
    if (self.kindOfPicker == NumberPicker && !isPad && (component == [self getNumberColumnCount])) {
        return [UIFont boldSystemFontOfSize:12];
    } else {
        return [UIFont boldSystemFontOfSize:18];
    }
}

//********************************************************************************
/**
 * \details Determines the position marker \e maxActiveRow to delineate up to
 *          which column zeros should be replaced by blanks.
 * \author  Michael Griebling
 * \date   	17 April 2013
 */
//********************************************************************************
- (BOOL)findMaximumRow:(NSString *)number {
    // find leading non-zero digit in string to reset leading zeros
    NSRange range = [number rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@"123456789"]];
    if (range.location != NSNotFound) {
        if (range.location+1 != self.maxActiveRow) {
            self.maxActiveRow = MIN(self.decimalColumn, range.location+1);
            if (self.maxActiveRow == number.length) self.maxActiveRow--;
        }
    } else if (self.decimalColumn < 0) {
        self.maxActiveRow = number.length-1;
    } else {
        self.maxActiveRow = self.decimalColumn;
    }
    return YES;
}

//********************************************************************************
/**
 * \details Picker delegate method that is activated whenever the user selects
 *          a different \e row in a column \e component.  This method ensures
 *          that the internal \e value property tracks the user interface and
 *          keeps leading zeros from appearing.
 * \author  Michael Griebling
 * \date   	17 April 2013
 */
//********************************************************************************
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    // update the internal number representation
    if (self.kindOfPicker == MinMaxPicker) {
        NSArray *column = self.columnValues[0];
        NSNumber *number = [self.formatter numberFromString:column[row]];
        self.value = [NSDecimalNumber decimalNumberWithDecimal:[number decimalValue]];
    } else if (self.kindOfPicker == RatePicker) {
        if (component == 1) {
            // update the units
            [self.rate setUnitFromUnitIndex:row];
        } else {
            // update the time
            [self.rate setTimeFromTimeIndex:row];
        }
        if (self.valueChangeCallback) {
            self.valueChangeCallback(self);
        }
        [pickerView reloadAllComponents];
        [pickerView selectRow:[self.rate timeIndex] inComponent:0 animated:YES];  // set time
        [pickerView selectRow:[self.rate unitIndex] inComponent:1 animated:YES];  // set units
    } else {
        NSString *stringValue = [self getPickerNumberAsString:pickerView];
        self.value = [NSDecimalNumber decimalNumberWithString:stringValue];
        if ([self findMaximumRow:stringValue]) {
            [pickerView reloadAllComponents];
        }
    }
}

#define OVERHEAD   (25)

//********************************************************************************
/**
 * \details Picker delegate method to determine the width of each column
 *          \e component.
 * \author  Michael Griebling
 * \date   	17 April 2013
 */
//********************************************************************************
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    UIFont *font = [self fontForComponent:component];
    CGFloat width = pickerView.bounds.size.width - 30;
    CGFloat overhead = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad ? OVERHEAD : 2*OVERHEAD/3;
    NSAttributedString *string;
    if (self.kindOfPicker == MinMaxPicker) {
        if (component == 1) return width * 0.3;
        else return width * 0.7;
    } else if (self.kindOfPicker == RatePicker) {
        if (component == 0) return width * 0.3;
        else return width * 0.7;
    } else {
        CGFloat columnWidth = width / self.columnValues.count;
        if (self.decimalColumn == component+1) {
            string = [[NSAttributedString alloc] initWithString:@"9 ." attributes:@{NSFontAttributeName : font}];
        } else if (self.labels && component+1 == self.columnValues.count) {
            string = [[NSAttributedString alloc] initWithString:[self.labels lastObject] attributes:@{NSFontAttributeName : font}];
            return string.size.width+overhead;
        } else {
            string = [[NSAttributedString alloc] initWithString:@"9" attributes:@{NSFontAttributeName : font}];
        }
        return MIN(columnWidth, string.size.width+overhead);
    }
}

@end
