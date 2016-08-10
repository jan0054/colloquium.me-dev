//
//  Event.h
//  cm_math_one
//
//  Created by Chi-sheng Jan on 6/13/16.
//  Copyright © 2016 tapgo. All rights reserved.
//

#import <Realm/Realm.h>

@interface Event : RLMObject
@property NSString *objectId;
@property NSString *name;
@property NSString *organizer;
@property NSString *content;
@property BOOL isParentEvent;
@property NSDate *startDate;
@property NSDate *endDate;
@property NSString *email;
@end

// This protocol enables typed collections. i.e.:
// RLMArray<Event>
RLM_ARRAY_TYPE(Event)
