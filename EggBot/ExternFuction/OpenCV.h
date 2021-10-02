//
//  OpenCV.h
//  EggBot
//
//  Created by Yixiao Li on 2019/12/2.
//  Copyright © 2019 Yixiao Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN



@interface OpenCV : NSObject

+(UIImage*)previewImage: (UIImage*) originalImage thresh: (int) threshold;

+(UIImage*)result: (UIImage*) processedImage Addcoef: (double)AddCoef;

+(NSMutableArray*)resultDataX: (UIImage*) processedImage Addcoef: (double)AddCoef;
+(NSMutableArray*)resultDataY: (UIImage*) processedImage Addcoef: (double)AddCoef;

+(NSMutableArray*)resultDataX_Totoro;
+(NSMutableArray*)resultDataY_Totoro;

+(NSMutableArray*)resultDataX_IcebergBear;
+(NSMutableArray*)resultDataY_IcebergBear;

+(NSMutableArray*)resultDataX_Spongebob;
+(NSMutableArray*)resultDataY_Spongebob;

+(NSMutableArray*)resultDataX_DoraAmen;
+(NSMutableArray*)resultDataY_DoraAmen;

+(NSMutableArray*)resultDataX_CWK;
+(NSMutableArray*)resultDataY_CWK;

+(NSMutableArray*)resultDataX_PKQ;
+(NSMutableArray*)resultDataY_PKQ;

+(NSMutableArray*)resultDataX_PJ;
+(NSMutableArray*)resultDataY_PJ;

+(NSMutableArray*)resultDataX_GT;
+(NSMutableArray*)resultDataY_GT;

+(NSMutableArray*)resultDataX_DLS;
+(NSMutableArray*)resultDataY_DLS;

+(NSMutableArray*)resultDataX_PDX;
+(NSMutableArray*)resultDataY_PDX;
@end

NS_ASSUME_NONNULL_END

