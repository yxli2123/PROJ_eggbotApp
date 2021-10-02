//
//  OCVLetter.h
//  EggBot
//
//  Created by Yixiao Li on 2019/12/19.
//  Copyright © 2019 Yixiao Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface OCVLetter : NSObject

+(UIImage*)previewText: (NSString*) originalText font: (int)font;
+(NSMutableArray*)letterResultDataX: (NSString*) originalText font: (int)font;
+(NSMutableArray*)letterResultDataY: (NSString*) originalText font: (int)font;
@end

NS_ASSUME_NONNULL_END
