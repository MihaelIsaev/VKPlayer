//
//  EntitySongs.m
//  VK Player
//
//  Created by mihael on 03.10.12.
//  Copyright (c) 2012 Mihael Isaev. All rights reserved.
//

#import "EntitySongs.h"
#import "Songs.h"

@implementation EntitySongs

static NSString * const tableName = @"Songs";

-(void)addOrUpdateWithAid:(NSDecimalNumber*)aid
                  ownerId:(NSDecimalNumber*)owner_id
                   artist:(NSString*)artist
                    title:(NSString*)title
                 duration:(NSDecimalNumber*)duration
                      URL:(NSString*)url
                 lyricsId:(NSString*)lyrics_id
                      num:(NSDecimalNumber*)num
                       ad:(AppDelegate*)ad
                      moc:(NSManagedObjectContext*)moc
{
    NSError* error;
    Songs *aItem = nil;
    NSFetchRequest * request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:tableName inManagedObjectContext:moc]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"aid=%@ AND owner_id=%@", aid, owner_id]];
    aItem = [[moc executeFetchRequest:request error:&error] lastObject];
    if (error)
        NSLog(@"any error fetch for update: %@", [error localizedDescription]);
    if (!aItem) {
        NSManagedObject *itemsItem = [NSEntityDescription insertNewObjectForEntityForName:tableName inManagedObjectContext:moc];
        [itemsItem setValue:aid         forKey:@"aid"];
        [itemsItem setValue:owner_id    forKey:@"owner_id"];
        [itemsItem setValue:artist      forKey:@"artist"];
        [itemsItem setValue:title       forKey:@"title"];
        [itemsItem setValue:duration    forKey:@"duration"];
        [itemsItem setValue:url         forKey:@"url"];
        [itemsItem setValue:lyrics_id   forKey:@"lyrics_id"];
        [itemsItem setValue:num         forKey:@"num"];
    }
    aItem.aid       = aid;
    aItem.owner_id  = owner_id;
    aItem.artist    = artist;
    aItem.title     = title;
    aItem.duration  = duration;
    aItem.url       = url;
    aItem.lyrics_id = lyrics_id;
    aItem.num       = num;
}

-(NSUInteger)calculateCountByOwnerId:(NSDecimalNumber*)owner_id
{
    AppDelegate *ad = [AppDelegate sharedInstance];
    NSManagedObjectContext *moc = [ad managedObjectContext];
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:tableName inManagedObjectContext:moc];
    [fetch setEntity:entity];
    NSSortDescriptor *sd = [[NSSortDescriptor alloc] initWithKey:@"num" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sd];
    [fetch setSortDescriptors:sortDescriptors];
    NSPredicate *searchFilter = [NSPredicate predicateWithFormat:@"owner_id = %@", owner_id];
    [fetch setPredicate:searchFilter];
    NSError *error;
    NSArray *result = [moc executeFetchRequest:fetch error:&error];
    if(!result){
        NSLog(@"%@", [error localizedDescription]);
        return 0;
    }
    return result.count;
}

-(NSArray*)getByOwnerId:(NSDecimalNumber*)owner_id
{
    AppDelegate *ad = [AppDelegate sharedInstance];
    NSManagedObjectContext *moc = [ad managedObjectContext];
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:tableName inManagedObjectContext:moc];
    [fetch setEntity:entity];
    NSSortDescriptor *sd = [[NSSortDescriptor alloc] initWithKey:@"num" ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sd];
    [fetch setSortDescriptors:sortDescriptors];
    NSPredicate *searchFilter = [NSPredicate predicateWithFormat:@"owner_id = %@", owner_id];
    [fetch setPredicate:searchFilter];
    NSError *error;
    NSArray *result = [moc executeFetchRequest:fetch error:&error];
    if(!result){
        NSLog(@"%@", [error localizedDescription]);
        return nil;
    }
    return result;
}

@end
