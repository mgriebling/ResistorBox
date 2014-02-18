//
//  MainViewController.m
//  Resistor Box
//
//  Created by Michael Griebling on 2May2013.
//  Copyright (c) 2013 Computer Inspirations. All rights reserved.
//

#import "MainViewController.h"
#import "NumberPicker.h"

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
    NSDecimalNumber *maximum = [[NSDecimalNumber alloc] initWithDouble:1000.0];
    NSDecimalNumber *minimum = [[NSDecimalNumber alloc] initWithDouble:0.0];
    NSDecimalNumber *step    = [[NSDecimalNumber alloc] initWithDouble:1.0];
    NSArray *units = @[@"Ω", @"KΩ", @"MΩ"];
    self.picker = [[NumberPicker alloc] initWithRangeOfNumbers:minimum maximum:maximum stepSize:step labels:units];
    
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
