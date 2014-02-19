//
//  MainViewController.m
//  Resistor Box
//
//  Created by Michael Griebling on 2May2013.
//  Copyright (c) 2013 Computer Inspirations. All rights reserved.
//

#import "MainViewController.h"
#import "NumberPicker.h"
#import "Resistors.h"

@interface MainViewController ()
@property (weak, nonatomic) IBOutlet UILabel *R1Label;
@property (weak, nonatomic) IBOutlet UILabel *R2Label;
@property (weak, nonatomic) IBOutlet UILabel *R3Label;
@property (weak, nonatomic) IBOutlet UILabel *R4Label;
@property (weak, nonatomic) IBOutlet UILabel *R5Label;
@property (weak, nonatomic) IBOutlet UILabel *R6Label;
@property (weak, nonatomic) IBOutlet UILabel *R7Label;
@property (weak, nonatomic) IBOutlet UILabel *R8Label;
@property (weak, nonatomic) IBOutlet UILabel *R9Label;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (strong, nonatomic) NumberPicker *picker;
@property (weak, nonatomic) IBOutlet UILabel *seriesResult;
@property (weak, nonatomic) IBOutlet UILabel *parallelResult;
@property (weak, nonatomic) IBOutlet UILabel *combinedResult;
@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    // set up the number picker
    NSDecimalNumber *maximum = [[NSDecimalNumber alloc] initWithDouble:999.9];
    NSDecimalNumber *minimum = [[NSDecimalNumber alloc] initWithDouble:0.0];
    NSArray *units = @[@"mΩ", @"Ω", @"KΩ", @"MΩ"];
    self.picker = [[NumberPicker alloc] initWithMaximum:maximum andMinimum:minimum andLabels:units];
    self.pickerView.delegate = self.picker;
    self.pickerView.dataSource = self.picker;
    __weak MainViewController *wself = self;
    self.picker.valueChangeCallback = ^ (NumberPicker *picker) {
        // allow dynamic updates of values as user plays with picker
        NSLog(@"User picked value = %@%@", picker.value, [picker getSelectedLabel:wself.pickerView]);
        [wself computeMatchingCombinationsForResistor:[NSString stringWithFormat:@"%@%@", picker.value, [picker getSelectedLabel:wself.pickerView]]];
    };
}

- (void)computeMatchingCombinationsForResistor:(NSString *)resistor {
    double value = [Resistors parseString:resistor];
    
    NSArray *series = [Resistors computeSeries:value];
    NSNumber *result = series[3];
    NSNumber *error = series[4];
    self.seriesResult.text = [NSString stringWithFormat:@"Series: %@, Error: %0.4f%%", [Resistors stringFromR:result.doubleValue], error.doubleValue];
    result = series[0];
    self.R1Label.text = [NSString stringWithFormat:@"R₁ = %@", [Resistors stringFromR:result.doubleValue]];
    result = series[1];
    self.R2Label.text = [NSString stringWithFormat:@"R₂ = %@", [Resistors stringFromR:result.doubleValue]];
    result = series[2];
    self.R3Label.text = [NSString stringWithFormat:@"R₃ = %@", [Resistors stringFromR:result.doubleValue]];
//    NSLog(@"Series values = %@", series);
    
    NSArray *parallel = [Resistors ComputeParallel:value];
    result = parallel[3];
    error = parallel[4];
    self.parallelResult.text = [NSString stringWithFormat:@"Parallel: %@, Error: %0.4f%%", [Resistors stringFromR:result.doubleValue], error.doubleValue];
    result = parallel[0];
    self.R4Label.text = [NSString stringWithFormat:@"R₄ = %@", [Resistors stringFromR:result.doubleValue]];
    result = parallel[1];
    self.R5Label.text = [NSString stringWithFormat:@"R₅ = %@", [Resistors stringFromR:result.doubleValue]];
    result = parallel[2];
    self.R6Label.text = [NSString stringWithFormat:@"R₆ = %@", [Resistors stringFromR:result.doubleValue]];
//    NSLog(@"Parallel values = %@", parallel);
    
    NSArray *both = [Resistors ComputeSeriesParallel:value];
    result = both[3];
    error = both[4];
    self.combinedResult.text = [NSString stringWithFormat:@"Combined: %@, Error: %0.4f%%", [Resistors stringFromR:result.doubleValue], error.doubleValue];
    result = both[0];
    self.R7Label.text = [NSString stringWithFormat:@"R₇ = %@", [Resistors stringFromR:result.doubleValue]];
    result = both[1];
    self.R8Label.text = [NSString stringWithFormat:@"R₈ = %@", [Resistors stringFromR:result.doubleValue]];
    result = both[2];
    self.R9Label.text = [NSString stringWithFormat:@"R₉ = %@", [Resistors stringFromR:result.doubleValue]];
//    NSLog(@"Combined values = %@", both);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Flipside View Controller

- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.flipsidePopoverController dismissPopoverAnimated:YES];
        self.flipsidePopoverController = nil;
    }
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.flipsidePopoverController = nil;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showAlternate"]) {
        [[segue destinationViewController] setDelegate:self];
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            UIPopoverController *popoverController = [(UIStoryboardPopoverSegue *)segue popoverController];
            self.flipsidePopoverController = popoverController;
            popoverController.delegate = self;
        }
    }
}

- (IBAction)togglePopover:(id)sender
{
    if (self.flipsidePopoverController) {
        [self.flipsidePopoverController dismissPopoverAnimated:YES];
        self.flipsidePopoverController = nil;
    } else {
        [self performSegueWithIdentifier:@"showAlternate" sender:sender];
    }
}

@end
