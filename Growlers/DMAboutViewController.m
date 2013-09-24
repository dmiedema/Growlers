//
//  DMAboutViewController.m
//  Growlers
//
//  Created by Daniel Miedema on 7/17/13.
//  Copyright (c) 2013 Daniel Miedema. All rights reserved.
//

#import "DMAboutViewController.h"
#import <MapKit/MapKit.h>
#import <MessageUI/MessageUI.h>

@interface DMAboutViewController () <MFMailComposeViewControllerDelegate, UIActionSheetDelegate>
@end

@implementation DMAboutViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    // Removes the title from the back button when this view is pushed.
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    }
    self.navigationController.navigationBar.topItem.title = @"About";
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.navigationController.navigationBar.topItem.title = @"About";
}

@end
