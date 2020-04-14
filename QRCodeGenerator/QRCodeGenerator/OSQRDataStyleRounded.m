//
//  OSQRDataStyleRounded.m
//
//  Created by Oscar Sanderson on 13/4/20.
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

#import "OSQRDataStyleRounded.h"

@implementation OSQRDataStyleRounded

-(void)drawPixel:(OSQRCanvas*)iCanvas
andColour:(UIColor*)iColour
    andQr:(OSQREncode*)iQr
   andIdx:(NSInteger)iIdx
  andRect:(CGRect)iRect
{
    UIRectCorner roundedCorners = 0;
    
    NSInteger idx_L  = [iQr getIdxByOffset:iIdx andOffsetX:-1 andOffsetY: 0];
    NSInteger idx_T  = [iQr getIdxByOffset:iIdx andOffsetX: 0 andOffsetY:-1];
    NSInteger idx_R  = [iQr getIdxByOffset:iIdx andOffsetX: 1 andOffsetY: 0];
    NSInteger idx_B  = [iQr getIdxByOffset:iIdx andOffsetX: 0 andOffsetY: 1];

    // top-left corner
    if ( (NO == [iQr isSet:idx_L]) && (NO == [iQr isSet:idx_T]) )
        roundedCorners |= UIRectCornerTopLeft;

    // top-right corner
    if ( (NO == [iQr isSet:idx_T]) && (NO == [iQr isSet:idx_R]) )
        roundedCorners |= UIRectCornerTopRight;

    // bottom-right corner
    if ( (NO == [iQr isSet:idx_R]) && (NO == [iQr isSet:idx_B]) )
        roundedCorners |= UIRectCornerBottomRight;

    // bottom-left corner
    if ( (NO == [iQr isSet:idx_B]) && (NO == [iQr isSet:idx_L]) )
        roundedCorners |= UIRectCornerBottomLeft;

    CGFloat tmpCornerRadius = fminf(iRect.size.width,iRect.size.height) / 2.0;
    
    // add extra rounding when we only have a single rounded corner
    if ( (roundedCorners == UIRectCornerTopLeft) ||
         (roundedCorners == UIRectCornerTopRight) ||
         (roundedCorners == UIRectCornerBottomRight) ||
         (roundedCorners == UIRectCornerBottomLeft) )
    {
        tmpCornerRadius *= 2.0;
    }
    
    [iCanvas drawStyledRect:iRect andRoundedCorners:roundedCorners andRoundedCornerRadius:tmpCornerRadius andColour:iColour];
}

@end
