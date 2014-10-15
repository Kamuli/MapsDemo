//
//  ViewController.h
//  MapsDemo
//
//  Created by Juha Näppi on 7.10.2014.
//  Copyright (c) 2014 Kamuli Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>

@interface ViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIView *mainView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *barButtonLeft;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *barButtonRight;
- (IBAction)leftBarButtonPressed:(UIBarButtonItem *)sender;
- (IBAction)rightBarButtonPressed:(UIBarButtonItem *)sender;


@end

