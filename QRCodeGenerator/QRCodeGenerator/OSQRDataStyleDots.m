//
//  OSQRDataStyleDots.m
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

#import "OSQRDataStyleDots.h"

@implementation OSQRDataStyleDots

-(void)drawPixel:(OSQRCanvas*)iCanvas
andColour:(UIColor*)iColour
    andQr:(OSQREncode*)iQr
   andIdx:(NSInteger)iIdx
  andRect:(CGRect)iRect
{
    CGRect tmpRect = iRect;

    // NB dots are inset by 1/5... so essentially half the pixel size
    CGFloat tmpInset = tmpRect.size.height / 5.0;

    tmpRect = UIEdgeInsetsInsetRect(tmpRect,UIEdgeInsetsMake(tmpInset,tmpInset,tmpInset,tmpInset));

    [iCanvas drawStyledRect:tmpRect
          andRoundedCorners:UIRectCornerAllCorners
     andRoundedCornerRadius:tmpRect.size.width / 2.0
                  andColour:iColour];
}

@end
