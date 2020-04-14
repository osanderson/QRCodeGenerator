//
//  UIImage+QRCodeGenerator.m
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

#import "UIImage+QRCodeGenerator.h"

@implementation UIImage (QRCodeGenerator)



+ (UIImage*)QRCodeGenerator:(NSString*)iData
                      andEC:(enum eOSQRENCODE_EC)iEC
               andStyleData:(nullable NSObject<OSQRDataStyle>*)_iStyleData
             andStyleFinder:(nullable NSObject<OSQRFinderStyle>*)_iStyleFinder
             andLightColour:(UIColor*)iLightColour
          andDarkColourData:(UIColor*)iDarkColourData
        andDarkColourFinder:(UIColor*)iDarkColourFinder
               andQuietZone:(NSInteger)iQuietZone
                    andSize:(CGFloat)iSize
                    andLogo:(nullable UIImage*)_iLogo
                  andLogoPc:(CGFloat)iLogoPc
{
    UIImage *ret = nil;
    
    OSQREncode *qr = [OSQREncode encodeString:iData andEC:iEC];
    
    OSQRRender *render = [[OSQRRender alloc] init];
    
    [render setSize:iSize];

    [render setQuietZone:1];

    [render setLightColour:iLightColour];
    [render setDarkColourData:iDarkColourData];
    [render setDarkColourFinder:iDarkColourFinder];

    if ( _iStyleData )
        [render setDataStyle:_iStyleData];
    
    if ( _iStyleFinder )
        [render setFinderStyle:_iStyleFinder];
    
    if ( _iLogo && (iLogoPc > 0.0) )
        [render setLogo:_iLogo andSizePc:iLogoPc];

    ret = [render generateImage:qr];
    
    render = nil;
    qr     = nil;
    
    return ret;
}



@end
