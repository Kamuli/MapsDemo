//
//  PanoramaView.m
//  MapsDemo
//
//  Created by Juha Näppi on 14.10.2014.
//  Copyright (c) 2014 Kamuli Software. All rights reserved.
//

#import "PanoramaView.h"
#import "AppDelegate.h"

@implementation PanoramaView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(MMDrawerController *)drawControllerFromAppDelegate
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    return appDelegate.drawerController;
}

@end
