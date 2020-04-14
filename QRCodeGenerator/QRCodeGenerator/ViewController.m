//
//  ViewController.m
//  QRCodeGenerator
//
//  Created by Oscar Sanderson on 12/4/20.
//  Copyright © 2020 Oscar Sanderson. All rights reserved.
//

#import "ViewController.h"

#import "UIImage+QRCodeGenerator.h"

#import "OSQRDataStyleRounded.h"
#import "OSQRDataStyleDots.h"

#import "OSQRFinderStyleRoundedOuter.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize imgView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor grayColor]];

    // NB should we 1:1 aspect, but pick min size just in case
    CGFloat targetSize = fminf(imgView.bounds.size.width,
                               imgView.bounds.size.height);

    NSString *tmpUrl = @"https://github.com/osanderson/QRCodeGenerator";
    
    // NB logo image (SG flag) taken from:
    // https://www.freeflagicons.com/country/singapore/square_metal_framed_icon/download/
    UIImage *tmpLogo
    = [UIImage imageNamed:@"sampleLogo"];
    CGFloat  tmpLogoPc = 12.0;

    UIImage *tmpImg = [UIImage QRCodeGenerator:tmpUrl
                                         andEC:eOSQRENCODE_EC_QUARTILE
                                  andStyleData:[[OSQRDataStyleRounded alloc] init]
                                andStyleFinder:[[OSQRFinderStyleRoundedOuter alloc] init]
                                andLightColour:[UIColor whiteColor]
                             andDarkColourData:[UIColor blackColor]
                           andDarkColourFinder:[UIColor blackColor]
                                  andQuietZone:1
                                       andSize:targetSize
                                       andLogo:tmpLogo
                                     andLogoPc:tmpLogoPc];

    [imgView setImage:tmpImg];
}



// TODO - doesn't currently support redraw/resize on device rotation

@end
