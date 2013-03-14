//
//  TehdaItem.h
//  ControlTest
//
//  Created by Shehryar Hussain on 3/13/13.
//  Copyright (c) 2013 Shehryar Hussain. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface TehdaItem : NSManagedObject

@property (nonatomic, retain) NSString * itemTitle;
@property (nonatomic, retain) NSString * itemDetails;
@property (nonatomic, retain) NSDate * itemDate;

@end
