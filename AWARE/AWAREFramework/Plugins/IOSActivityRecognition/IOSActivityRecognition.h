//
//  IOSActivityRecognition.h
//  AWARE
//
//  Created by Yuuki Nishiyama on 9/19/16.
//  Copyright © 2016 Yuuki NISHIYAMA. All rights reserved.
//

#import "AWARESensor.h"
#import "AWAREKeys.h"
#import <CoreMotion/CoreMotion.h>

typedef enum: NSInteger {
    IOSActivityRecognitionModeLive = 0,
    IOSActivityRecognitionModeHistory = 1
} IOSActivityRecognitionMode;

extern NSString * const AWARE_PREFERENCES_STATUS_IOS_ACTIVITY_RECOGNITION;
extern NSString * const AWARE_PREFERENCES_FREQUENCY_IOS_ACTIVITY_RECOGNITION;
extern NSString * const AWARE_PREFERENCES_LIVE_MODE_IOS_ACTIVITY_RECOGNITION;

@interface IOSActivityRecognition : AWARESensor <AWARESensorDelegate>

- (BOOL) startSensorWithLiveMode:(CMMotionActivityConfidence) filterLevel;
- (BOOL) startSensorWithHistoryMode:(CMMotionActivityConfidence)filterLevel interval:(double) interval;
- (BOOL) startSensorWithConfidenceFilter:(CMMotionActivityConfidence) filterLevel
                                    mode:(IOSActivityRecognitionMode)mode
                                interval:(double) interval;

@end
