//
//  OSQREncode.h
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

#import <Foundation/Foundation.h>

#import "qrencode.h"

NS_ASSUME_NONNULL_BEGIN


#define kOSQRENCODE_FINDER_PATTERN_WIDTH    7

#define kOSQR_ENCODE_INVALID_IDX    -1


enum eOSQRENCODE_EC
{
    eOSQRENCODE_EC_LOW,
    eOSQRENCODE_EC_MEDIUM,
    eOSQRENCODE_EC_QUARTILE,
    eOSQRENCODE_EC_HIGH
};



@interface OSQREncode : NSObject

+(OSQREncode*)encodeString:(NSString*)iData
                     andEC:(enum eOSQRENCODE_EC)iEC;


-(NSInteger)width;
-(NSInteger)height; // height should equal width under normal conditions
-(NSInteger)area; // i.e. width * height


-(BOOL)isFinderPixel:(NSInteger)iIdx;

-(BOOL)isDataPixel:(NSInteger)iIdx;

-(BOOL)isSetPixel:(NSInteger)iIdx;

-(BOOL)isSetDataPixel:(NSInteger)iIdx;

-(NSInteger)getIdxByOffset:(NSInteger)iIdx
                andOffsetX:(NSInteger)iOffsetX
                andOffsetY:(NSInteger)iOffsetY;


-(NSInteger)getFinderTLIdx_TL;
-(NSInteger)getFinderTLIdx_TR;
-(NSInteger)getFinderTLIdx_BL;

@end

NS_ASSUME_NONNULL_END
