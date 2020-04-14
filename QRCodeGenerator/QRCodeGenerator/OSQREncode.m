//
//  OSQREncode.m
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

#import "OSQREncode.h"

/*
 * constants for libqrencode pixel bitmasks
 */
#define kLIBQRENCODE_PIXEL_BITMASK_BLACK    1
//#define kLIBQRENCODE_PIXEL_BITMASK_FINDER   64


@interface OSQREncode ()
{
    QRcode *qr;
}

@property (nonatomic,assign) QRcode *qr;

@end


@implementation OSQREncode

@synthesize qr = _qr;


-(OSQREncode*)init
{
    self = [super init];

    if ( self )
    {
        _qr = NULL;
    }
    
    return self;
}

+(OSQREncode*)encodeString:(NSString*)iData
                     andEC:(enum eOSQRENCODE_EC)iEC
{
    OSQREncode *ret = [[super alloc] init];
    
    if ( ret )
    {
        QRecLevel ecLevel = QR_ECLEVEL_H;
        
        switch ( iEC )
        {
            case eOSQRENCODE_EC_LOW:
                ecLevel = QR_ECLEVEL_L;
                break;
                
            case eOSQRENCODE_EC_MEDIUM:
                ecLevel = QR_ECLEVEL_M;
                break;
                
            case eOSQRENCODE_EC_QUARTILE:
                ecLevel = QR_ECLEVEL_Q;
                break;
                
            case eOSQRENCODE_EC_HIGH:
            default:
                ecLevel = QR_ECLEVEL_H;
        } // end-switch

        ret.qr = QRcode_encodeString([iData UTF8String],0,ecLevel,QR_MODE_8,1);
        
        if ( NULL == ret.qr )
        {
            ret = nil;
        }
    }

    return ret;
}


-(NSInteger)width
{
    // sanity check
    if ( _qr == NULL )
        return 0;

    return _qr->width;
}

-(NSInteger)height;
{
    // NB height/width are always the same on a QR
    return [self width];
}

-(NSInteger)area
{
    return [self width] * [self height];
}

-(BOOL)isValidIdx:(NSInteger)iIdx
{
    BOOL ret = NO;
    
    // sanity check
    if ( _qr == NULL )
        return NO;

    if ( (iIdx >= 0) && (iIdx < [self area]) )
    {
        ret = YES;
    }
    
    return ret;
}


-(BOOL)isSet:(NSInteger)iIdx
{
    BOOL ret = NO;

    if ( [self isValidIdx:iIdx] )
    {
        if ( _qr->data[iIdx] & kLIBQRENCODE_PIXEL_BITMASK_BLACK )
        {
            ret = YES;
        }
    }

    return ret;
}

-(BOOL)isUnset:(NSInteger)iIdx
{
    BOOL ret = NO;

    if ( [self isValidIdx:iIdx] )
    {
        if ( !(_qr->data[iIdx] & kLIBQRENCODE_PIXEL_BITMASK_BLACK) )
        {
            ret = YES;
        }
    }

    return ret;
}


// unsets the pixel
-(void)unset:(NSInteger)iIdx
{
    if ( [self isValidIdx:iIdx] )
    {
        _qr->data[iIdx] = 0;;
    }
}








// returns: index (0..n) *OR* kOSQR_ENCODE_INVALID_IDX if out-of-bounds
-(NSInteger)getIdxByOffset:(NSInteger)iIdx
                andOffsetX:(NSInteger)iOffsetX
                andOffsetY:(NSInteger)iOffsetY
{
    NSInteger retIdx = kOSQR_ENCODE_INVALID_IDX;
    
    NSInteger idx_x = iIdx % [self width];
    NSInteger idx_y = iIdx / [self width];
    
    idx_x += iOffsetX;
    idx_y += iOffsetY;
    
    // proceed if within bounds
    if ( (idx_x >= 0) && (idx_x < [self width]) &&
         (idx_y >= 0) && (idx_y < [self height]) )
    {
        retIdx = (idx_y * [self width]) + idx_x;
        
        if ( [self isValidIdx:retIdx] == NO )
            retIdx = kOSQR_ENCODE_INVALID_IDX;
    }
    
    return retIdx;
}











-(NSInteger)getFinderTLIdx_TL
{
    return 0;
}

-(NSInteger)getFinderTLIdx_TR
{
    return [self getIdxByOffset:0
              andOffsetX:([self width] - kOSQRENCODE_FINDER_PATTERN_WIDTH)
              andOffsetY:0];
}

-(NSInteger)getFinderTLIdx_BL
{
    return [self getIdxByOffset:0
              andOffsetX:0
              andOffsetY:([self height] - kOSQRENCODE_FINDER_PATTERN_WIDTH)];
}










-(void)dealloc
{
    if ( NULL != _qr )
    {
        QRcode_free(_qr);
        _qr = NULL;
    }
}

@end
