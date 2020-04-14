//
//  OSQRFinderStyleRoundedOuter.m
//
//  Created by Oscar Sanderson on 14/4/20.
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

#import "OSQRFinderStyleRoundedOuter.h"

#import "OSQREncode.h"

@implementation OSQRFinderStyleRoundedOuter


-(void)drawFinder:(OSQRCanvas*)iCanvas
   andLightColour:(UIColor*)iLightColour
    andDarkColour:(UIColor*)iDarkColour
     andOuterRect:(CGRect)iOuterRect
    andMiddleRect:(CGRect)iMiddleRect
     andInnerRect:(CGRect)iInnerRect
andRoundedCorners:(UIRectCorner)iRoundedCorners
{

    CGFloat tmpScale = fminf(iOuterRect.size.width,iOuterRect.size.height) / kOSQRENCODE_FINDER_PATTERN_WIDTH;
    
    [iCanvas drawStyledRect:iOuterRect
          andRoundedCorners:iRoundedCorners
     andRoundedCornerRadius:tmpScale * 2.0
                  andColour:iDarkColour];

    [iCanvas drawStyledRect:iMiddleRect
          andRoundedCorners:iRoundedCorners
     andRoundedCornerRadius:tmpScale
                  andColour:iLightColour];

    [iCanvas drawStyledRect:iInnerRect
          andRoundedCorners:0
     andRoundedCornerRadius:0
                  andColour:iDarkColour];
}


-(void)drawFinderTL:(OSQRCanvas*)iCanvas
    andLightColour:(UIColor*)iLightColour
     andDarkColour:(UIColor*)iDarkColour
 andOuterRect:(CGRect)iOuterRect
andMiddleRect:(CGRect)iMiddleRect
 andInnerRect:(CGRect)iInnerRect
{
    [self drawFinder:iCanvas
      andLightColour:iLightColour
       andDarkColour:iDarkColour
        andOuterRect:iOuterRect
       andMiddleRect:iMiddleRect
        andInnerRect:iInnerRect
   andRoundedCorners:UIRectCornerTopLeft];
}

-(void)drawFinderTR:(OSQRCanvas*)iCanvas
          andLightColour:(UIColor*)iLightColour
           andDarkColour:(UIColor*)iDarkColour
       andOuterRect:(CGRect)iOuterRect
      andMiddleRect:(CGRect)iMiddleRect
       andInnerRect:(CGRect)iInnerRect;
{
     [self drawFinder:iCanvas
       andLightColour:iLightColour
        andDarkColour:iDarkColour
         andOuterRect:iOuterRect
        andMiddleRect:iMiddleRect
         andInnerRect:iInnerRect
    andRoundedCorners:UIRectCornerTopRight];
}

-(void)drawFinderBL:(OSQRCanvas*)iCanvas
          andLightColour:(UIColor*)iLightColour
           andDarkColour:(UIColor*)iDarkColour
       andOuterRect:(CGRect)iOuterRect
      andMiddleRect:(CGRect)iMiddleRect
       andInnerRect:(CGRect)iInnerRect;
{
     [self drawFinder:iCanvas
       andLightColour:iLightColour
        andDarkColour:iDarkColour
         andOuterRect:iOuterRect
        andMiddleRect:iMiddleRect
         andInnerRect:iInnerRect
    andRoundedCorners:UIRectCornerBottomLeft];
}

@end
