//
//  Contacts.h
//  AWARE
//
//  Created by Paul McCartney on 2016/12/28.
//  Copyright © 2016年 Yuuki NISHIYAMA. All rights reserved.
//

#import "AWARESensor.h"
#import <AddressBook/AddressBook.h>

extern NSString * const KEY_PLUGIN_SETTING_CONTACTS_LAST_UPDATE_NSDATE;

@interface Contacts : AWARESensor<AWARESensorDelegate>

- (void) checkStatus;
- (NSDate *) getLastUpdateDate;

@end
