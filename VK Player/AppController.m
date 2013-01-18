//
//  AppController.m
//  VK Player
//
//  Created by mihael on 03.10.12.
//  Copyright (c) 2012 Mihael Isaev. All rights reserved.
//

#import "AppController.h"
#import "AudioStreamer.h"
#import <QuartzCore/CoreAnimation.h>

@implementation MediaKeyExampleApp
- (void)sendEvent:(NSEvent *)theEvent
{
	// If event tap is not installed, handle events that reach the app instead
	BOOL shouldHandleMediaKeyEventLocally = ![SPMediaKeyTap usesGlobalMediaKeyTap];
    
	if(shouldHandleMediaKeyEventLocally && [theEvent type] == NSSystemDefined && [theEvent subtype] == SPSystemDefinedEventMediaKeys) {
		[(id)[self delegate] mediaKeyTap:nil receivedMediaKeyEvent:theEvent];
	}
	[super sendEvent:theEvent];
}
@end

@implementation AppController

@synthesize tableView = _tableView;
@synthesize volumeSlider;
@synthesize progressSlider;
@synthesize playButton;
@synthesize searchBar = _searchBar;
@synthesize searchFieldCell = _searchFieldCell;
@synthesize currentSongTitle = _currentSongTitle;
@synthesize loadingBar = _loadingBar;
@synthesize loadingTitle = _loadingTitle;

BOOL isPlaying = NO;
BOOL isPaused = NO;

AppDelegate *ad;
EntitySongs *entitySongs;

NSUserNotification *notification;

int songRow;

-(void)windowDidBecomeMain:(NSNotification *)notification
{
    ad = [[AppDelegate alloc] init];
    entitySongs = [[EntitySongs alloc] init];
    
    _list = [[NSMutableArray alloc] initWithObjects:nil];
    
    NSLog(@"vol string: %@", [ad retrieveString:@"volumeValue"]);
    NSLog(@"vol float: %f", [[ad retrieveString:@"volumeValue"] floatValue]);
    
    if([ad retrieveString:@"volumeValue"] != nil)
        [volumeSlider setDoubleValue:[[ad retrieveString:@"volumeValue"] floatValue]];
    else
        [volumeSlider setDoubleValue:[volumeSlider maxValue]];
    
    if([entitySongs calculateCountByOwnerId:[NSDecimalNumber decimalNumberWithString:[ad retrieveString:@"userId"]]]>0){
        [self getFromCoreData];
        [self startDownloadInBackground];
    }else
        [self startDownloadInBackground];
    keyTap = [[SPMediaKeyTap alloc] initWithDelegate:self];
	if([SPMediaKeyTap usesGlobalMediaKeyTap])
		[keyTap startWatchingMediaKeys];
	else
		NSLog(@"Media key monitoring disabled");
}

-(void)getFromCoreData
{
    NSArray *list_ = [[NSArray alloc] initWithObjects: nil];
    list_ = [entitySongs getByOwnerId:[NSDecimalNumber decimalNumberWithString:[ad retrieveString:@"userId"]]];
    _list = [list_ mutableCopy];
    [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}

- (IBAction)backwardSelector:(id)sender
{
    [self playPrev];
}

- (IBAction)forwardSelector:(id)sender
{
    [self playNext];
}

- (IBAction)searchSelector:(id)sender
{
    NSLog(@"search: %@", _searchFieldCell.stringValue);
}

-(IBAction)playSelector:(id)sender
{
    [self playAction];
}

- (IBAction)stopSelector:(id)sender
{
    [self stopAction];
}

-(void)playAction
{
    if(_list.count >0){
        if(!isPlaying && !isPaused){
            isPlaying = YES;
            isPaused = NO;
            [playButton setImage:[NSImage imageNamed:@"pause"]];
            //NSString *path = [[NSBundle mainBundle] pathForResource:@"call_my_name" ofType:@"mp3"];
            if(theAudio)theAudio=nil;
            NSURL *url = [NSURL URLWithString:[[_list objectAtIndex:songRow] valueForKey:@"url"]];//@"http://cs4616.vkontakte.ru/u71083045/audio/5a42f057e878.mp3"];
            NSData *data = [NSData dataWithContentsOfURL:url];
            theAudio = [[AVAudioPlayer alloc] initWithData:data error:nil];
            //theAudio = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:@"http://cs4616.vkontakte.ru/u71083045/audio/5a42f057e878.mp3"] error:NULL];//[NSURL fileURLWithPath:path] error:NULL];
            theAudio.delegate = self;
            [self setVolume];
            [theAudio play];
            [theAudio setMeteringEnabled:YES];
            [theAudio updateMeters];
            
            if(playbackTimer)playbackTimer = nil;
            playbackTimer = [NSTimer scheduledTimerWithTimeInterval:.01
                                                             target:self
                                                           selector:@selector(myMethod:)
                                                           userInfo:nil
                                                            repeats:YES];
            [self setCurrentPlayedInProfileStatus];
            [_currentSongTitle setStringValue:[NSString stringWithFormat:@"%@ - %@", [[_list objectAtIndex:songRow] valueForKey:@"artist"], [[_list objectAtIndex:songRow] valueForKey:@"title"]]];
            
            [[NSUserNotificationCenter defaultUserNotificationCenter] removeAllDeliveredNotifications];
            notification = [[NSUserNotification alloc] init];
            notification.title = @"Плеер вконтакте";
            notification.informativeText = [NSString stringWithFormat:@"%@ - %@", [[_list objectAtIndex:songRow] valueForKey:@"artist"], [[_list objectAtIndex:songRow] valueForKey:@"title"]];
            //notification.soundName = NSUserNotificationDefaultSoundName;
            [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
        }else if(!isPlaying && isPaused){
            [theAudio play];
            isPlaying = YES;
            isPaused = NO;
            [playButton setImage:[NSImage imageNamed:@"pause"]];
            [self setCurrentPlayedInProfileStatus];
            [_currentSongTitle setStringValue:[NSString stringWithFormat:@"%@ - %@", [[_list objectAtIndex:songRow] valueForKey:@"artist"], [[_list objectAtIndex:songRow] valueForKey:@"title"]]];
        }else if(isPlaying && !isPaused){
            isPlaying = NO;
            isPaused = YES;
            [self cleanPlayedInProfileStatus];
            [theAudio pause];
            [playButton setImage:[NSImage imageNamed:@"play"]];
            [_currentSongTitle setStringValue:@""];
        }
    }
}

-(void)stopAction
{
    [theAudio stop];
    isPlaying = NO;
    isPaused = NO;
    [self didStopSong];
    [_currentSongTitle setStringValue:@""];
}

- (IBAction)volumeSelector:(id)sender
{
    [self setVolume];
}

- (IBAction)progressSelector:(id)sender
{
    float total=theAudio.duration;
    float step = total/progressSlider.maxValue;
    float point = step*[progressSlider doubleValue];
    [theAudio setCurrentTime:point];
}

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [self playNext];
}

-(void)playNext
{
    isPlaying = NO;
    isPaused = NO;
    if(_list.count >0){
        if(songRow == _list.count-1)
            [self selectSongForPlay:0];
        else if(songRow < _list.count-1)
            [self selectSongForPlay:songRow+1];
        else
            [self didStopSong];
    }
}

-(void)playPrev
{
    isPlaying = NO;
    isPaused = NO;
    if(_list.count >0){
        if(songRow == 0)
            [self selectSongForPlay:_list.count-1];
        else if(songRow < _list.count-1)
            [self selectSongForPlay:songRow-1];
        else
            [self didStopSong];
    }
}

-(void)selectSongForPlay:(NSUInteger)_songRow
{
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:_songRow];
    [_tableView selectRowIndexes:indexSet byExtendingSelection:NO];
    songRow = _songRow;
    [self playAction];
}

-(void)didStopSong
{
    [playButton setImage:[NSImage imageNamed:@"play"]];
    [playbackTimer invalidate];
    playbackTimer = nil;
    [progressSlider setDoubleValue:.0f];
}

-(void)setVolume
{
    float volumeFloatValue = [volumeSlider floatValue]/100;
    [ad saveString:[NSString stringWithFormat:@"%f", [volumeSlider floatValue]] :@"volumeValue"];
    [theAudio setVolume:volumeFloatValue];
}

-(void)myMethod:(NSTimer*)timer {
    
    float total=theAudio.duration;
    float f=theAudio.currentTime / total;
    [progressSlider setDoubleValue:f];
}

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return _list.count;
}

-(CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
    return 20.0f;
}

-(BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row
{
    NSLog(@"shouldSelectRow: %ld", row);
    isPaused = NO;
    isPlaying = NO;
    songRow = row;
    [self playAction];
    return YES;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    
    // Get a new ViewCell
    NSTableCellView *cellView = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
    
    // Since this is a single-column table view, this would not be necessary.
    // But it's a good practice to do it in order by remember it when a table is multicolumn.
    if( [tableColumn.identifier isEqualToString:@"SongArtist"] )
    {
        cellView.textField.stringValue = [[_list objectAtIndex:row] valueForKey:@"artist"];
        return cellView;
    }else if( [tableColumn.identifier isEqualToString:@"SongTitle"] )
    {
        cellView.textField.stringValue = [[_list objectAtIndex:row] valueForKey:@"title"];
        return cellView;
    }else if( [tableColumn.identifier isEqualToString:@"SongDuration"] )
    {
        cellView.textField.stringValue = [CommonHelper convertTimeFromSeconds:[[_list objectAtIndex:row] valueForKey:@"duration"]];
        return cellView;
    }
    return cellView;
}

-(void)showLoadingWithText:(NSString*)text
{
    [_loadingBar setHidden:NO];
    [_loadingTitle setHidden:NO];
    [_loadingTitle setStringValue:text];
}

-(void)hideLoading
{
    [_loadingBar setHidden:YES];
    [_loadingTitle setHidden:YES];
}

-(void)startDownloadInBackground
{
    NSURL *url = [self makeURL];
    dispatch_queue_t queue = dispatch_queue_create("com.mihaelisaev.VK-Player", NULL);
    dispatch_async(queue, ^{
        NSData *serverData = [self getDataFromServer:url];
        if(nil != serverData)
            [self fetchedData:serverData];
    });
}

-(NSData*)getDataFromServer:(NSURL*)url
{
    [self performSelectorOnMainThread:@selector(showLoadingWithText:) withObject:@"загрузка списка песен" waitUntilDone:NO];
    NSData *responseData = [NSData dataWithContentsOfURL: url];
    [self performSelectorOnMainThread:@selector(hideLoading) withObject:nil waitUntilDone:NO];
    if(responseData == nil)
        NSLog(@"responseData=nil: %@", responseData);
    return responseData;
}

-(NSURL*)makeURL
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/audio.get?access_token=%@", [ad retrieveString:@"accessToken"]]];
    NSLog(@"makeURL url: %@", url);
    return url;
}

-(void)setCurrentPlayedInProfileStatus
{
    dispatch_queue_t queue = dispatch_queue_create("com.mihaelisaev.VK-Player", NULL);
    dispatch_async(queue, ^{
        NSError* error;
        NSData *responseData = [NSData dataWithContentsOfURL: [NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/status.set?access_token=%@&audio=%@_%@&text=vkplayer", [ad retrieveString:@"accessToken"], [[_list objectAtIndex:songRow] valueForKey:@"owner_id"], [[_list objectAtIndex:songRow] valueForKey:@"aid"]]]];
        //NSData *responseData = [NSData dataWithContentsOfURL: [NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/status.set?access_token=%@&text=vkplayer", [ad retrieveString:@"accessToken"]]]];
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];
        NSLog(@"status.set: %@", [json objectForKey:@"response"]);
    });
}

-(void)cleanPlayedInProfileStatus
{
    dispatch_queue_t queue = dispatch_queue_create("com.mihaelisaev.VK-Player", NULL);
    dispatch_async(queue, ^{
        NSError* error;
        NSData *responseData = [NSData dataWithContentsOfURL: [NSURL URLWithString:[NSString stringWithFormat:@"https://api.vk.com/method/status.set?access_token=%@", [ad retrieveString:@"accessToken"]]]];
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];
        NSLog(@"status.set: %@", [json objectForKey:@"response"]);
    });
}

- (void)fetchedData:(NSData *)responseData {
    NSError* error;
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];
    NSArray* songs = [json objectForKey:@"response"];
    NSLog(@"json Songs count = %ld", songs.count);
    NSManagedObjectContext *tempContext = [[NSManagedObjectContext alloc] init];
    [tempContext setPersistentStoreCoordinator:[ad persistentStoreCoordinator]];
    for (int i=0; i<songs.count; i++) {
        NSDictionary * songsObj = [songs objectAtIndex:i];
        [entitySongs addOrUpdateWithAid:[NSDecimalNumber decimalNumberWithDecimal:[[songsObj objectForKey:@"aid"] decimalValue]]
                                ownerId:[NSDecimalNumber decimalNumberWithDecimal:[[songsObj objectForKey:@"owner_id"] decimalValue]]
                                 artist:[songsObj objectForKey:@"artist"]
                                  title:[songsObj objectForKey:@"title"]
                               duration:[NSDecimalNumber decimalNumberWithDecimal:[[songsObj objectForKey:@"duration"] decimalValue]]
                                    URL:[songsObj objectForKey:@"url"]
                               lyricsId:[songsObj objectForKey:@"lyrics_id"]
                                    num:[NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%d", i]]
                                     ad:ad
                                    moc:tempContext];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tempContextSaved:) name:NSManagedObjectContextDidSaveNotification object:tempContext];
    [tempContext save:&error];
    if (error)
        NSLog(@"fetchData tempContext save error: %@", [error localizedDescription]);
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextDidSaveNotification object:tempContext];
    [self getFromCoreData];
}

- (void)tempContextSaved:(NSNotification *)notification {
    [[ad managedObjectContext] mergeChangesFromContextDidSaveNotification:notification];
}

-(void)mediaKeyTap:(SPMediaKeyTap*)keyTap receivedMediaKeyEvent:(NSEvent*)event;
{
	NSAssert([event type] == NSSystemDefined && [event subtype] == SPSystemDefinedEventMediaKeys, @"Unexpected NSEvent in mediaKeyTap:receivedMediaKeyEvent:");
	// here be dragons...
	int keyCode = (([event data1] & 0xFFFF0000) >> 16);
	int keyFlags = ([event data1] & 0x0000FFFF);
	BOOL keyIsPressed = (((keyFlags & 0xFF00) >> 8)) == 0xA;
	int keyRepeat = (keyFlags & 0x1);
	
	if (keyIsPressed) {
		NSString *debugString = [NSString stringWithFormat:@"%@", keyRepeat?@", repeated.":@"."];
		switch (keyCode) {
			case NX_KEYTYPE_PLAY:
				//debugString = [@"Play/pause pressed" stringByAppendingString:debugString];
                [self playAction];
				break;
				
			case NX_KEYTYPE_FAST:
				//debugString = [@"Ffwd pressed" stringByAppendingString:debugString];
                [self playNext];
				break;
				
			case NX_KEYTYPE_REWIND:
				//debugString = [@"Rewind pressed" stringByAppendingString:debugString];
                [self playPrev];
				break;
			default:
				debugString = [NSString stringWithFormat:@"Key %d pressed%@", keyCode, debugString];
				break;
                // More cases defined in hidsystem/ev_keymap.h
		}
		NSLog(@"key: %@", debugString);
	}
}

@end
