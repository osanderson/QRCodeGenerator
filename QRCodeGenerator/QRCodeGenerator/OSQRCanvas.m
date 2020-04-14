//
//  OSQRCanvas.m
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

#import "OSQRCanvas.h"


@interface OSQRCanvas ()
{
    CGSize size;
    
    CGContextRef ctx;
}

@property (nonatomic,assign) CGSize       size;
@property (nonatomic,assign) CGContextRef ctx;

@end






@implementation OSQRCanvas

@synthesize size = _size;
@synthesize ctx = _ctx;


-(OSQRCanvas*)init
{
    self = [super init];

    if ( self )
    {
        // init local data        
        self.size = CGSizeZero;
        self.ctx  = NULL;
    }
    
    return self;
}

+(OSQRCanvas*)setupWithSize:(CGSize)iSize
{
    OSQRCanvas *ret = [[super alloc] init];
    
    if ( ret )
    {
        ret.size = iSize;
        
        UIGraphicsBeginImageContextWithOptions(ret.size, false, 0.0);

        ret.ctx = UIGraphicsGetCurrentContext();
    }

    return ret;
}

-(void)dealloc
{
    UIGraphicsEndImageContext();
}





-(void)setFillColour:(UIColor*)iColour
{
    CGContextSetFillColorWithColor(_ctx,[iColour CGColor]);
}


-(void)drawStyledRect:(CGRect)iRect
    andRoundedCorners:(UIRectCorner)iRoundedCorners
andRoundedCornerRadius:(CGFloat)iRoundedCornerRadius
            andColour:(UIColor*)iColour
{
    CGRect tmpRect = iRect;
    
    [self setFillColour:iColour];
    
    CGFloat x_min = CGRectGetMinX(tmpRect),
            x_mid = CGRectGetMidX(tmpRect),
            x_max = CGRectGetMaxX(tmpRect);

    CGFloat y_min = CGRectGetMinY(tmpRect),
            y_mid = CGRectGetMidY(tmpRect),
            y_max = CGRectGetMaxY(tmpRect);

    CGContextMoveToPoint  (_ctx,x_min,y_mid);
    CGContextAddArcToPoint(_ctx,x_min,y_min,x_mid,y_min,iRoundedCorners & UIRectCornerTopLeft     ? iRoundedCornerRadius : 0);
    CGContextAddArcToPoint(_ctx,x_max,y_min,x_max,y_mid,iRoundedCorners & UIRectCornerTopRight    ? iRoundedCornerRadius : 0);
    CGContextAddArcToPoint(_ctx,x_max,y_max,x_mid,y_max,iRoundedCorners & UIRectCornerBottomRight ? iRoundedCornerRadius : 0);
    CGContextAddArcToPoint(_ctx,x_min,y_max,x_min,y_mid,iRoundedCorners & UIRectCornerBottomLeft  ? iRoundedCornerRadius : 0);
    CGContextClosePath    (_ctx);

    CGContextDrawPath(_ctx,kCGPathFill);
}




-(void)drawImage:(CGRect)iRect
        andImage:(UIImage*)iImage
{
    iRect.origin.y *= -1.0;

    // save the context so that it can be undone later
    CGContextSaveGState(_ctx);
        
    // put the origin of the coordinate system at the top left
    CGContextTranslateCTM(_ctx,0,iRect.size.height);
    CGContextScaleCTM(_ctx, 1.0, -1.0);

    CGImageRef imgRef = [iImage CGImage];
    CGContextDrawImage(_ctx,iRect,imgRef);
    CGImageRelease(imgRef);
    
    // undo changes to the context
    CGContextRestoreGState(_ctx);
}




-(UIImage*)generateImage
{
    UIImage *ret = nil;
    
    CGImageRef imgRef = CGBitmapContextCreateImage(_ctx);
    ret = [UIImage imageWithCGImage:imgRef];
    CGImageRelease(imgRef);
    
    return ret;
}


@end
