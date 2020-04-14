//
//  OSQRRender.m
//
//  Created by Oscar Sanderson on 12/4/20.
//
//  This is free and unencumbered software released into the public domain.
//
//  Anyone is free to copy, modify, publish, use, compile, sell, or
//  distribute this software, either in source code form or as a compiled
//  binary, for any purpose, commercial or non-commercial, and by any
//  means.
//
//  In jurisdictions that recognize copyright laws, the author or authors
//  of this software dedicate any and all copyright interest in the
//  software to the public domain. We make this dedication for the benefit
//  of the public at large and to the detriment of our heirs and
//  successors. We intend this dedication to be an overt act of
//  relinquishment in perpetuity of all present and future rights to this
//  software under copyright law.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
//  IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
//  OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
//  ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//
//  For more information, please refer to <https://unlicense.org>
//

#import "OSQRRender.h"

#import "OSQRDataStyleDefault.h"
#import "OSQRFinderStyleDefault.h"

#define kOSQR_SIZE_DEFAULT          200
#define kOSQR_QUIET_ZONE_DEFAULT    4
#define kOSQR_LIGHT_COLOUR_DEFAULT  [UIColor whiteColor]
#define kOSQR_DARK_COLOUR_DEFAULT   [UIColor blackColor]


@interface OSQRRender ()
{
    CGFloat    size;
    
    NSInteger  quietZone;
    
    UIColor   *lightColour;
    UIColor   *darkColourData;      // technically includes more than data
    UIColor   *darkColourFinder;
    
    NSObject<OSQRDataStyle>   *dataStyle;
    NSObject<OSQRFinderStyle> *finderStyle;
    
    UIImage   *logo;
    CGFloat    logoSizePc;
}

@property (nonatomic,assign) CGFloat    size;
@property (nonatomic,assign) NSInteger  quietZone;

@property (nonatomic,strong) UIColor *lightColour;
@property (nonatomic,strong) UIColor *darkColourData;
@property (nonatomic,strong) UIColor *darkColourFinder;

@property (nonatomic,strong) NSObject<OSQRDataStyle>   *dataStyle;
@property (nonatomic,strong) NSObject<OSQRFinderStyle> *finderStyle;

@property (nonatomic,strong,nullable) UIImage *logo;
@property (nonatomic,assign) CGFloat           logoSizePc;

@end


@implementation OSQRRender

@synthesize size = _size;
@synthesize quietZone = _quietZone;

@synthesize lightColour = _lightColour;
@synthesize darkColourData = _darkColourData;
@synthesize darkColourFinder = _darkColourFinder;

@synthesize dataStyle   = _dataStyle;
@synthesize finderStyle = _finderStyle;

@synthesize logo = _logo;
@synthesize logoSizePc = _logoSizePc;


-(OSQRRender*) init
{
    self = [super init];

    if ( self )
    {
        /*
         * set deaults
         */
        _size      = kOSQR_SIZE_DEFAULT;
        _quietZone = kOSQR_QUIET_ZONE_DEFAULT;
        
        _lightColour      = kOSQR_LIGHT_COLOUR_DEFAULT;
        _darkColourData   = kOSQR_DARK_COLOUR_DEFAULT;
        _darkColourFinder = kOSQR_DARK_COLOUR_DEFAULT;
        
        _dataStyle   = [[OSQRDataStyleDefault   alloc] init];
        _finderStyle = [[OSQRFinderStyleDefault alloc] init];
        
        _logo       = nil;
        _logoSizePc = 0.0;
    }
    
    return self;
}


-(CGRect)getRectForIdx:(OSQREncode*)iQr
                andIdx:(NSInteger)iIdx
              andScale:(CGFloat)iScale
{
    CGFloat x = iIdx % [iQr width];
    CGFloat y = iIdx / [iQr width];

    return CGRectMake((_quietZone+x)*iScale,
                      (_quietZone+y)*iScale,
                      iScale,
                      iScale);
}


// outputs: CGRectNull if an error occurs (i.e. invalid finder pattern encountered)
-(void)getFinderRects:(OSQREncode*)iQr
             andIdxTL:(NSInteger)iIdxTL
             andScale:(CGFloat)iScale
         andOuterRect:(CGRect*)oOuterRect
        andMiddleRect:(CGRect*)oMiddleRect
         andInnerRect:(CGRect*)oInnerRect
{
    /*
     *      @@@@@@@
     *      @     @
     *      @ @@@ @
     *      @ @@@ @
     *      @ @@@ @
     *      @     @
     *      @@@@@@@
     */
    
    NSInteger outerIdx_tl = iIdxTL;
    NSInteger outerIdx_br = [iQr getIdxByOffset:outerIdx_tl andOffsetX:6 andOffsetY:6];

    NSInteger midIdx_tl = [iQr getIdxByOffset:outerIdx_tl andOffsetX:1 andOffsetY:1];
    NSInteger midIdx_br = [iQr getIdxByOffset:outerIdx_br andOffsetX:-1 andOffsetY:-1];

    NSInteger innerIdx_tl = [iQr getIdxByOffset:midIdx_tl andOffsetX:1 andOffsetY:1];
    NSInteger innerIdx_br = [iQr getIdxByOffset:midIdx_br andOffsetX:-1 andOffsetY:-1];

    *oOuterRect = CGRectUnion([self getRectForIdx:iQr andIdx:outerIdx_tl andScale:iScale],
                              [self getRectForIdx:iQr andIdx:outerIdx_br andScale:iScale]);

    *oMiddleRect = CGRectUnion([self getRectForIdx:iQr andIdx:midIdx_tl andScale:iScale],
                               [self getRectForIdx:iQr andIdx:midIdx_br andScale:iScale]);

    *oInnerRect = CGRectUnion([self getRectForIdx:iQr andIdx:innerIdx_tl andScale:iScale],
                              [self getRectForIdx:iQr andIdx:innerIdx_br andScale:iScale]);

    /*
     * verify that the pixels within the finder rects are as expected
     */
    {
        BOOL validFinders = YES;
        
        for ( NSInteger idx=0 ; idx<[iQr area] && validFinders ; idx++ )
        {
            CGRect tmpRect = [self getRectForIdx:iQr andIdx:idx andScale:iScale];
            
            // evaluate if pixel if within the OUTER rect of the finder
            if ( CGRectIntersectsRect(tmpRect,*oOuterRect) )
            {
                // validation rules for all pixels within OUTER:
                //  1) if within INNER then must be SET
                //  2) if within MIDDLE and not within INNER then must be UNSET
                //  3) if within OUTER and not within MIDDLE then must be SET
                
                if ( !((CGRectIntersectsRect(tmpRect,*oInnerRect) && [iQr isSet:idx]) ||
                       (CGRectIntersectsRect(tmpRect,*oMiddleRect) && !CGRectIntersectsRect(tmpRect,*oInnerRect) && [iQr isUnset:idx]) ||
                       (CGRectIntersectsRect(tmpRect,*oOuterRect) && !CGRectIntersectsRect(tmpRect,*oMiddleRect) && [iQr isSet:idx])) )
                {
                    // pixel doesn't comply with expected finder pattern rules
                    validFinders = NO;
                }
            }
        } // for-each(idx)
        
        // handle error case where we encountered an invalid finder pattern
        if ( validFinders == NO )
        {
            // reset the finder rects to signal an error
            *oOuterRect  = CGRectNull;
            *oMiddleRect = CGRectNull;
            *oInnerRect  = CGRectNull;
        }
    }
}

/******************************************************************************/

/*
 * NB aspect = width / height
 * returns: maximum logical size that honours the aspect and fits the area
 */
-(CGSize)getMaxLogSizeForAspectAndArea:(CGFloat)iAspect
                              andScale:(CGFloat)iScale
                         andMaxLogArea:(CGFloat)iMaxLogArea
                        andMaxLogWidth:(CGFloat)iMaxLogWidth
                       andMaxLogHeight:(CGFloat)iMaxLogHeight
{
    CGSize ret = CGSizeZero;
    NSInteger log_w = 1;
    
    while(1)
    {
        log_w++;
        
        NSInteger log_h = (((log_w * iScale) / iAspect) + (0.5 * iScale)) / iScale;

        if ( ((log_h * log_w) <= iMaxLogArea) &&
             (log_w <= iMaxLogWidth) &&
             (log_h <= iMaxLogHeight) )
        {
            ret = CGSizeMake(log_w,log_h);
        }
        else
        {
            break;
        }
    } // end-while(1)
    
    return ret;
}


// returns: CGRect indicating where logo has been drawn
-(CGRect)drawLogo:(OSQRCanvas*)iCanvas andQr:(OSQREncode*)iQr andScale:(CGFloat)iScale
{
    CGRect retLogoRect = CGRectNull;
    
    // sanity check
    if ( _logo == nil )
        return retLogoRect;
    
    NSLog(@"[_logo] w:%1.1f, h:%1.1f",_logo.size.width,_logo.size.height);

    NSLog(@"[scale] %1.1f",iScale);
    NSLog(@"[qr.width] %1d",(int)[iQr width]);
    NSLog(@"[qr.height] %1d",(int)[iQr height]);

    /*
     * determine the target logo size based on aspect-ratio and size-percentage (iLogoSizePc)
     */
    CGSize phyLogoSize = CGSizeZero;
    CGSize logLogoSize = CGSizeZero;
    {
        CGFloat logoAspect = _logo.size.width / _logo.size.height;
        
        /*
         * determine the maximum logical area for the logo based on the target logo size (%)
         * NB we exclude the 3 finders and the whitespace next to them from the usable area [(]i.e. 3*(8*8)]
         */
        CGFloat maxLogArea = ([iQr area] - (3*kOSQRENCODE_FINDER_PATTERN_WIDTH*kOSQRENCODE_FINDER_PATTERN_WIDTH)) * (_logoSizePc / 100.0);

        /*
         * determine the maximum logical width/height that we will allow for the logo
         */
        CGFloat maxLogWidth  = [iQr width ] - kOSQRENCODE_FINDER_PATTERN_WIDTH - 1 - 1 - kOSQRENCODE_FINDER_PATTERN_WIDTH;
        CGFloat maxLogHeight = [iQr height] - kOSQRENCODE_FINDER_PATTERN_WIDTH - 1 - 1 - kOSQRENCODE_FINDER_PATTERN_WIDTH;
        
        /*
         * calculate the maximum logical size that the logo can occupy, honouring the area/width/height constraints
         * as well as preserving the aspect ratio of the original logo
         */
        logLogoSize = [self getMaxLogSizeForAspectAndArea:logoAspect
                                                 andScale:iScale
                                            andMaxLogArea:maxLogArea
                                           andMaxLogWidth:maxLogWidth
                                          andMaxLogHeight:maxLogHeight];

        NSLog(@"[logLogoSize] w:%1.1f, h:%1.1f",logLogoSize.width,logLogoSize.height);

        
        CGFloat multiplier = fmin(((logLogoSize.width * iScale) / _logo.size.width),
                                  ((logLogoSize.height * iScale) / _logo.size.height));

        phyLogoSize = CGSizeMake(_logo.size.width  * multiplier,
                                 _logo.size.height * multiplier);

        NSLog(@"[phyLogoSize] w:%1.1f, h:%1.1f",phyLogoSize.width,phyLogoSize.height);
    }
    
    /*
     * determine the logo rect
     */
    {
        NSInteger tmpIdx_TL = [iQr getIdxByOffset:0
                                       andOffsetX:([iQr width ] - logLogoSize.width) / 2
                                       andOffsetY:([iQr height] - logLogoSize.height) / 2];

        NSInteger tmpIdx_BR = [iQr getIdxByOffset:tmpIdx_TL
                                       andOffsetX:logLogoSize.width - 1
                                       andOffsetY:logLogoSize.height - 1];

        retLogoRect = CGRectUnion([self getRectForIdx:iQr andIdx:tmpIdx_TL andScale:iScale],
                                  [self getRectForIdx:iQr andIdx:tmpIdx_BR andScale:iScale]);

        NSLog(@"[oLogoRect] x:%1.1f, y:%1.1f, w:%1.1f, h:%1.1f",retLogoRect.origin.x,retLogoRect.origin.y,retLogoRect.size.width,retLogoRect.size.height);
    }
    
    /*
     * centre and render the logo within the allocated space
     */
    {
        CGRect tmpRect = retLogoRect;

        tmpRect.size = phyLogoSize;
        
        tmpRect.origin.x += (((logLogoSize.width  * iScale) - phyLogoSize.width ) / 2.0);
        tmpRect.origin.y += (((logLogoSize.height * iScale) - phyLogoSize.height) / 2.0);
        
        [iCanvas drawImage:tmpRect andImage:_logo];
    }
    
    return retLogoRect;
}


-(void)setSize:(CGFloat)iSize
{
    _size = iSize;
}

-(void)setQuietZone:(NSInteger)iQuietZone
{
    _quietZone = iQuietZone;
}

-(void)setLightColour:(UIColor*)iColour
{
    _lightColour = iColour;
}

-(void)setDarkColourData:(UIColor*)iColour
{
    _darkColourData = iColour;
}

-(void)setDarkColourFinder:(UIColor*)iColour
{
    _darkColourFinder = iColour;
}

-(void)setFinderStyle:(NSObject<OSQRFinderStyle>*)iStyleHandler
{
    _finderStyle = iStyleHandler;
}

-(void)setLogo:(UIImage*)iLogo
     andSizePc:(CGFloat)iSizePc
{
    _logo = iLogo;
    
    if ( (iSizePc >= 0.0) && (iSizePc <= 100.0) )
        _logoSizePc = iSizePc;
}

/*
 * unsets any pixels that intersect with rect
 */
-(void)unsetPixelsIntersectingRect:(OSQREncode*)iQr
                           andRect:(CGRect)iRect
                          andScale:(CGFloat)iScale
{
    for ( NSInteger idx=0 ; idx<[iQr area] ; idx++ )
    {
        if ( [iQr isSet:idx] )
        {
            CGRect tmpRect = [self getRectForIdx:iQr andIdx:idx andScale:iScale];

            if ( YES == CGRectIntersectsRect(tmpRect,iRect) )
            {
                [iQr unset:idx];
            }
        } // end-if(isSetPixel)
    }// end-for(idx)
}

/*
 * returns: UIImage for QRCode *OR* nil if an error occurred (e.g. invalid finder pattern encountered)
 */
-(UIImage*)generateImage:(OSQREncode*)iQr
{
    BOOL     haveError = NO;
    UIImage *ret       = nil;
    
    // TODO - should really top/left align the image if it's going to be slightly smaller than what the user requested
    //          - otherwise we return a slightly smaller size and the image may get stretched by the caller
    
    // logical pixel size of the QR - including quiet-zone around the edges
    NSInteger logQrSize = _quietZone + [iQr width] + _quietZone;
 
    // determine scaling amount from logical to physical size
    CGFloat scale = floorf(_size / logQrSize);
    if ( scale < 1.0 )
        scale = 1.0;
    
    // physical size in drawing units
    CGFloat phyQrSize = logQrSize * scale;
        
    // generate the image
    {
        OSQRCanvas *canvas = [OSQRCanvas setupWithSize:CGSizeMake(phyQrSize,phyQrSize)];
        
        /*
         * initialise everything to LIGHT colour
         */
        [canvas drawStyledRect:CGRectMake(0,0,phyQrSize,phyQrSize)
             andRoundedCorners:0
        andRoundedCornerRadius:0
                     andColour:_lightColour];

        /*
         * draw logo (if provided)
         */
        CGRect logoRect = CGRectNull;
        if ( _logo )
        {
            logoRect = [self drawLogo:canvas
                                andQr:iQr
                             andScale:scale];
            
            // unset any pixels that will be occupied by the logo
            if ( CGRectIsNull(logoRect) == NO )
                [self unsetPixelsIntersectingRect:iQr andRect:logoRect andScale:scale];
        }

        /*
         * determine location of TL/TR/BL finders (outer/middle/inner rects)
         */
        CGRect finderTL_outer,
        finderTL_middle,
        finderTL_inner,
        finderTR_outer,
        finderTR_middle,
        finderTR_inner,
        finderBL_outer,
        finderBL_middle,
        finderBL_inner;

        [self getFinderRects:iQr
                    andIdxTL:[iQr getFinderTLIdx_TL]
                    andScale:scale
                andOuterRect:&finderTL_outer
               andMiddleRect:&finderTL_middle
                andInnerRect:&finderTL_inner];

        [self getFinderRects:iQr
                    andIdxTL:[iQr getFinderTLIdx_TR]
                    andScale:scale
                andOuterRect:&finderTR_outer
               andMiddleRect:&finderTR_middle
                andInnerRect:&finderTR_inner];

        [self getFinderRects:iQr
                    andIdxTL:[iQr getFinderTLIdx_BL]
                    andScale:scale
                andOuterRect:&finderBL_outer
               andMiddleRect:&finderBL_middle
                andInnerRect:&finderBL_inner];

        /*
         * verify that we correctly identified the finders
         * NB we only evaluate the OUTER rect of each as this is sufficient
         */
        if ( CGRectIsNull(finderTL_outer) || CGRectIsNull(finderTR_outer) || CGRectIsNull(finderBL_outer) )
        {
            haveError = YES;
        }
        
        if ( !haveError )
        {
            // unset any pixels that are occupied by the 3 finder patterns (as we want to custom draw)
            // NB we only do for the 'outer' regions as middle/inner are within outer
            [self unsetPixelsIntersectingRect:iQr andRect:finderTL_outer andScale:scale];
            [self unsetPixelsIntersectingRect:iQr andRect:finderTR_outer andScale:scale];
            [self unsetPixelsIntersectingRect:iQr andRect:finderBL_outer andScale:scale];
        }

        /*
         * draw any SET pixels
         * NB we've already UNSET any pixels that will be occupied by the logo/finders
         */
        if ( !haveError )
        {
            for ( NSInteger idx=0 ; idx<([iQr area]) ; idx++ )
            {
                if ( [iQr isSet:idx] )
                {
                    CGRect tmpRect = [self getRectForIdx:iQr andIdx:idx andScale:scale];

                    [_dataStyle drawPixel:canvas
                                andColour:_darkColourData
                                    andQr:iQr andIdx:idx
                                  andRect:tmpRect];
                }
            } // end-for (idx)
        }
        
        /*
         * draw finders
         */
        if ( !haveError )
        {
            [_finderStyle drawFinderTL:canvas
                        andLightColour:_lightColour
                         andDarkColour:_darkColourFinder
                          andOuterRect:finderTL_outer
                         andMiddleRect:finderTL_middle
                          andInnerRect:finderTL_inner];

            [_finderStyle drawFinderTR:canvas
                        andLightColour:_lightColour
                         andDarkColour:_darkColourFinder
                          andOuterRect:finderTR_outer
                         andMiddleRect:finderTR_middle
                          andInnerRect:finderTR_inner];

            [_finderStyle drawFinderBL:canvas
                        andLightColour:_lightColour
                         andDarkColour:_darkColourFinder
                          andOuterRect:finderBL_outer
                         andMiddleRect:finderBL_middle
                          andInnerRect:finderBL_inner];
        }

        /*
         * generate the UIImage
         */
        if ( !haveError )
        {
            ret = [canvas generateImage];
        }

        canvas = nil;
    }
    
    return ret;
}


@end
