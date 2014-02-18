

#import "ActionSheetNumberPicker.h"
#import "NumberPicker.h"

@interface ActionSheetNumberPicker()
@property (nonatomic, copy) ActionNumberDoneBlock onActionSheetDone;
@property (nonatomic, copy) ActionNumberCancelBlock onActionSheetCancel;
@property (nonatomic) NSDecimalNumber *value;
@property (nonatomic) NumberPicker *model;
@property (nonatomic) NSString *unit;
@end

@implementation ActionSheetNumberPicker

@synthesize onActionSheetDone = _onActionSheetDone;


+ (id)showPickerWithTitle:(NSString *)title number:(NSDecimalNumber *)number maximum:(NSDecimalNumber *)maximum currentUnit:(NSString *)currentUnit units:(NSArray *)units doneBlock:(ActionNumberDoneBlock)doneBlock cancelBlock:(ActionNumberCancelBlock)cancelBlockorNil origin:(id)origin {
    ActionSheetNumberPicker * picker = [[ActionSheetNumberPicker alloc] initWithTitle:title number:number maximum:maximum currentUnit:currentUnit units:units doneBlock:doneBlock cancelBlock:cancelBlockorNil origin:origin];
    [picker showActionSheetPicker];
    return picker;
}

- (id)initWithTitle:(NSString *)title number:(NSDecimalNumber *)number maximum:(NSDecimalNumber *)maximum currentUnit:(NSString *)currentUnit units:(NSArray *)units doneBlock:(ActionNumberDoneBlock)doneBlock cancelBlock:(ActionNumberCancelBlock)cancelBlockOrNil origin:(id)origin {
    self = [self initWithTitle:title number:number maximum:maximum currentUnit:currentUnit units:units target:nil successAction:nil cancelAction:nil origin:origin];
    if (self) {
        self.onActionSheetDone = doneBlock;
        self.onActionSheetCancel = cancelBlockOrNil;
    }
    return self;
}

+ (id)showPickerWithTitle:(NSString *)title number:(NSDecimalNumber *)number maximum:(NSDecimalNumber *)maximum currentUnit:(NSString *)currentUnit units:(NSArray *)units target:(id)target successAction:(SEL)successAction cancelAction:(SEL)cancelActionOrNil origin:(id)origin {
    ActionSheetNumberPicker *picker = [[ActionSheetNumberPicker alloc] initWithTitle:title number:number maximum:maximum currentUnit:currentUnit units:units target:target successAction:successAction cancelAction:cancelActionOrNil origin:origin];
    [picker showActionSheetPicker];
    return picker;
}

- (id)initWithTitle:(NSString *)title number:(NSDecimalNumber *)number maximum:(NSDecimalNumber *)maximum currentUnit:(NSString *)currentUnit units:(NSArray *)units target:(id)target successAction:(SEL)successAction cancelAction:(SEL)cancelActionOrNil origin:(id)origin {
    self = [self initWithTarget:target successAction:successAction cancelAction:cancelActionOrNil origin:origin];
    if (self) {
        self.value = number;
        self.model = [[NumberPicker alloc] initWithLabels:maximum labels:units];
        self.unit = currentUnit;
        self.title = title;
    }
    return self;
}

- (UIView *)configuredPickerView {
    CGRect pickerFrame = CGRectMake(0, 40, self.viewSize.width, 216);
    UIPickerView *numberPicker = [[UIPickerView alloc] initWithFrame:pickerFrame];
    numberPicker.delegate = self.model;
    numberPicker.dataSource = self.model;
    numberPicker.showsSelectionIndicator = YES;
    [self.model setPicker:numberPicker toCurrentValue:self.value label:self.unit];
    
    //need to keep a reference to the picker so we can clear the DataSource / Delegate when dismissing
    self.pickerView = numberPicker;
    return numberPicker;
}


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

- (void)notifyTarget:(id)target didSucceedWithAction:(SEL)successAction origin:(id)origin {
    if (self.onActionSheetDone) {
        _onActionSheetDone(self, self.model.value, [self.model getSelectedLabel:(UIPickerView *)self.pickerView]);
        return;
    } else if (target && [target respondsToSelector:successAction]) {
        [target performSelector:successAction withObject:self.model.value withObject:origin];
        return;
    }
    NSLog(@"Invalid target/action ( %s / %s ) combination used for ActionSheetPicker", object_getClassName(target), sel_getName(successAction));
}

- (void)notifyTarget:(id)target didCancelWithAction:(SEL)cancelAction origin:(id)origin {
    if (self.onActionSheetCancel) {
        _onActionSheetCancel(self);
        return;
    } else if (target && cancelAction && [target respondsToSelector:cancelAction])
        [target performSelector:cancelAction withObject:origin];
}

#pragma clang diagnostic pop

@end