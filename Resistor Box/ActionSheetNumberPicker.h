

#import "AbstractActionSheetPicker.h"

@class ActionSheetNumberPicker;
typedef void(^ActionNumberDoneBlock)(ActionSheetNumberPicker *picker, NSDecimalNumber *selectedValue, NSString *units);
typedef void(^ActionNumberCancelBlock)(ActionSheetNumberPicker *picker);

@interface ActionSheetNumberPicker : AbstractActionSheetPicker

+ (id)showPickerWithTitle:(NSString *)title number:(NSDecimalNumber *)number maximum:(NSDecimalNumber *)maximum currentUnit:(NSString *)currentUnit units:(NSArray *)units target:(id)target successAction:(SEL)successAction cancelAction:(SEL)cancelActionOrNil origin:(id)origin;

- (id)initWithTitle:(NSString *)title number:(NSDecimalNumber *)number maximum:(NSDecimalNumber *)maximum currentUnit:(NSString *)currentUnit units:(NSArray *)units target:(id)target successAction:(SEL)successAction cancelAction:(SEL)cancelActionOrNil origin:(id)origin;

+ (id)showPickerWithTitle:(NSString *)title number:(NSDecimalNumber *)number maximum:(NSDecimalNumber *)maximum currentUnit:(NSString *)currentUnit units:(NSArray *)units doneBlock:(ActionNumberDoneBlock)doneBlock cancelBlock:(ActionNumberCancelBlock)cancelBlock origin:(id)origin;

- (id)initWithTitle:(NSString *)title number:(NSDecimalNumber *)number maximum:(NSDecimalNumber *)maximum currentUnit:(NSString *)currentUnit units:(NSArray *)units doneBlock:(ActionNumberDoneBlock)doneBlock cancelBlock:(ActionNumberCancelBlock)cancelBlockOrNil origin:(id)origin;

@end