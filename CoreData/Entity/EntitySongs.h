//
//  EntitySongs.h
//  VK Player
//
//  Created by mihael on 03.10.12.
//  Copyright (c) 2012 Mihael Isaev. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"

@interface EntitySongs : NSObject

-(void)addOrUpdateWithAid:(NSDecimalNumber*)aid
                  ownerId:(NSDecimalNumber*)owner_id
                   artist:(NSString*)artist
                    title:(NSString*)title
                 duration:(NSDecimalNumber*)duration
                      URL:(NSString*)url
                 lyricsId:(NSString*)lyrics_id
                      num:(NSDecimalNumber*)num
                       ad:(AppDelegate*)ad
                      moc:(NSManagedObjectContext*)moc;
-(NSUInteger)calculateCountByOwnerId:(NSDecimalNumber*)owner_id;
-(NSArray*)getByOwnerId:(NSDecimalNumber*)owner_id;

@end
