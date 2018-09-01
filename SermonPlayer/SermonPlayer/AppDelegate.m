//
//  AppDelegate.m
//  SermonPlayer
//
//  Created by Jason Terhorst on 9/1/18.
//  Copyright © 2018 WorshipKit. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;

@property (nonatomic, weak) IBOutlet NSWindow * videoWindow;
@property (nonatomic, weak) IBOutlet AVPlayerView * videoPlayerView;

@property (nonatomic, weak) IBOutlet NSTextField * elapsedTimeLabel;
@property (nonatomic, weak) IBOutlet NSTextField * remainingTimeLabel;
@property (nonatomic, weak) IBOutlet NSSlider * volumeSlider;
@property (nonatomic, weak) IBOutlet NSButton * playButton;
@property (nonatomic, weak) IBOutlet NSButton * pauseButton;
@property (nonatomic, weak) IBOutlet NSButton * resetButton;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _videoPlayerView.controlsStyle = AVPlayerViewControlsStyleNone;
    
    [_videoWindow setFrame:[[[NSScreen screens] objectAtIndex:1] frame] display:YES];
    [_videoWindow setLevel:NSStatusWindowLevel];
    [_videoWindow orderFront:nil];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (IBAction)openFile:(id)sender {
    NSOpenPanel * openPanel = [NSOpenPanel openPanel];
    [openPanel setAllowedFileTypes:@[@"mp4",@"m4v",@"mov",@"avi"]];
    [openPanel setAllowsMultipleSelection:NO];
    NSModalResponse result = [openPanel runModal];
    if (result == NSModalResponseOK) {
        NSURL * videoFileURL = [openPanel URL];
        if (_videoPlayerView.player) {
            [_videoPlayerView.player replaceCurrentItemWithPlayerItem:[AVPlayerItem playerItemWithURL:videoFileURL]];
        } else {
            [_videoPlayerView setPlayer:[AVPlayer playerWithURL:videoFileURL]];
        }
        _videoPlayerView.player.actionAtItemEnd = AVPlayerActionAtItemEndPause;
        [_videoPlayerView.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1, 1) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
            [self _updateTimeLabels:time];
        }];
    }
}

- (NSString *)_stringValueForSeconds:(CGFloat)seconds {
    int minutes = seconds/60;
    int remainingSeconds = seconds - (minutes * 60);
    return [NSString stringWithFormat:@"%02d:%02d", minutes, remainingSeconds];
}

- (void)_updateTimeLabels:(CMTime)currentTime {
    CGFloat secondsElapsed = CMTimeGetSeconds(currentTime);
    CGFloat secondsRemaining = CMTimeGetSeconds(_videoPlayerView.player.currentItem.duration) - secondsElapsed;
    [self->_elapsedTimeLabel setStringValue:[self _stringValueForSeconds:secondsElapsed]];
    [self->_remainingTimeLabel setStringValue:[NSString stringWithFormat:@"-%@", [self _stringValueForSeconds:secondsRemaining]]];
}

- (IBAction)play:(id)sender {
    [_videoPlayerView.player play];
}

- (IBAction)pause:(id)sender {
    [_videoPlayerView.player pause];
}

- (IBAction)resetPlayer:(id)sender {
    [_videoPlayerView.player seekToTime:kCMTimeZero];
}

- (IBAction)changeVolume:(id)sender {
    [_videoPlayerView.player setVolume:[_volumeSlider floatValue]];
}

@end
