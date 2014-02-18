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
   NSArray *parallel = [Resistors ComputeParallel:value];
   NSArray *both = [Resistors ComputeSeriesParallel:value];

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
