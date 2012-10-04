//
//  Songs.h
//  VK Player
//
//  Created by mihael on 03.10.12.
//  Copyright (c) 2012 Mihael Isaev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Songs : NSManagedObject

@property (nonatomic, retain) NSNumber * aid;
@property (nonatomic, retain) NSNumber * owner_id;
@property (nonatomic, retain) NSString * artist;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * duration;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSString * lyrics_id;
@property (nonatomic, retain) NSDecimalNumber * num;

@end
