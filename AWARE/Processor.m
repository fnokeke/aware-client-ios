//
//  Processor.m
//  AWARE
//
//  Created by Yuuki Nishiyama on 11/20/15.
//  Copyright © 2015 Yuuki NISHIYAMA. All rights reserved.
//

#import "Processor.h"


@implementation Processor{
    NSTimer * uploadTimer;
    NSTimer * sensingTimer;
}

- (instancetype)initWithSensorName:(NSString *)sensorName{
    self = [super initWithSensorName:sensorName];
    if (self) {
        [super setSensorName:sensorName];
    }
    return self;
}


- (void) createTable{
    NSString *query = [[NSString alloc] init];
    query = @"_id integer primary key autoincrement,"
    "timestamp real default 0,"
    "device_id text default '',"
    "double_last_user real default 0,"
    "double_last_system real default 0,"
    "double_last_idle real default 0,"
    "double_user_load real default 0,"
    "double_system_load real default 0,"
    "double_idle real default 0,"
    "UNIQUE (timestamp,device_id)";
    [super createTable:query];
}



- (BOOL)startSensor:(double)upInterval withSettings:(NSArray *)settings {
    NSLog(@"[%@] Create Table", [self getSensorName]);
    [self createTable];
    
    NSLog(@"[%@] Start Processor Sensor", [self getSensorName]);
    double interval = 1.0f;
    uploadTimer = [NSTimer scheduledTimerWithTimeInterval:upInterval target:self selector:@selector(syncAwareDB) userInfo:nil repeats:YES];
    sensingTimer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(getSensorData) userInfo:nil repeats:YES];
    return YES;
}

- (void) getSensorData{
    // Get wifi information
    NSNumber *cpuUsage = [NSNumber numberWithFloat:[self getCpuUsage]];
    NSNumber *memoryUsage = [NSNumber numberWithFloat:[self getMemory]];
    //https://github.com/Shmoopi/iOS-System-Services
    
    // Save sensor data to the local database.
    double timeStamp = [[NSDate date] timeIntervalSince1970] * 1000;
    NSNumber* unixtime = [NSNumber numberWithLong:timeStamp];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:unixtime forKey:@"timestamp"];
    [dic setObject:[self getDeviceId] forKey:@"device_id"];
    [dic setObject:cpuUsage forKey:@"double_last_user"]; //double
    [dic setObject:@0 forKey:@"double_last_system"]; //double
    [dic setObject:@0 forKey:@"double_last_idle"]; //double
    [dic setObject:@0 forKey:@"double_user_load"];//double
    [dic setObject:@0 forKey:@"double_system_load"]; //double
    [dic setObject:@0 forKey:@"double_system_load"]; //double
    [self setLatestValue:[NSString stringWithFormat:@"%@",cpuUsage]];
    [self saveData:dic toLocalFile:SENSOR_PROCESSOR];
}

- (BOOL)stopSensor{
    [sensingTimer invalidate];
    [uploadTimer invalidate];
    return YES;
}


- (float) getCpuUsage {
    kern_return_t kr;
    task_info_data_t tinfo;
    mach_msg_type_number_t task_info_count;
    
    task_info_count = TASK_INFO_MAX;
    kr = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)tinfo, &task_info_count);
    if (kr != KERN_SUCCESS) {
        return -1;
    }
    
    task_basic_info_t      basic_info;
    thread_array_t         thread_list;
    mach_msg_type_number_t thread_count;
    
    thread_info_data_t     thinfo;
    mach_msg_type_number_t thread_info_count;
    
    thread_basic_info_t basic_info_th;
    uint32_t stat_thread = 0; // Mach threads
    
    basic_info = (task_basic_info_t)tinfo;
    
    // get threads in the task
    kr = task_threads(mach_task_self(), &thread_list, &thread_count);
    if (kr != KERN_SUCCESS) {
        return -1;
    }
    if (thread_count > 0)
        stat_thread += thread_count;
    
    long tot_sec = 0;
    long tot_usec = 0;
    float tot_cpu = 0;
    int j;
    
    for (j = 0; j < thread_count; j++)
    {
        thread_info_count = THREAD_INFO_MAX;
        kr = thread_info(thread_list[j], THREAD_BASIC_INFO,
                         (thread_info_t)thinfo, &thread_info_count);
        if (kr != KERN_SUCCESS) {
            return -1;
        }
        
        basic_info_th = (thread_basic_info_t)thinfo;
        
        if (!(basic_info_th->flags & TH_FLAGS_IDLE)) {
            tot_sec = tot_sec + basic_info_th->user_time.seconds + basic_info_th->system_time.seconds;
            tot_usec = tot_usec + basic_info_th->system_time.microseconds + basic_info_th->system_time.microseconds;
            tot_cpu = tot_cpu + basic_info_th->cpu_usage / (float)TH_USAGE_SCALE * 100.0;
        }
        
    } // for each thread
    
    kr = vm_deallocate(mach_task_self(), (vm_offset_t)thread_list, thread_count * sizeof(thread_t));
    assert(kr == KERN_SUCCESS);
    
    return tot_cpu;
}

- (long) getMemory {
    struct task_basic_info info;
    mach_msg_type_number_t size = sizeof(info);
    kern_return_t kerr = task_info(mach_task_self(),
                                   TASK_BASIC_INFO,
                                   (task_info_t)&info,
                                   &size);
    long memoryUsage = 0;
    if( kerr == KERN_SUCCESS ) {
        NSLog(@"Memory in use (in bytes): %lu", info.resident_size);
        memoryUsage = info.resident_size;
    } else {
        NSLog(@"Error with task_info(): %s", mach_error_string(kerr));
    }
    return memoryUsage;
}


@end
