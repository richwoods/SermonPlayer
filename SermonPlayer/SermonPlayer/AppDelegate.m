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
@property (nonatomic, weak) IBOutlet NSButton * playPauseButton;
@property (nonatomic, weak) IBOutlet NSButton * resetButton;

@property (nonatomic, weak) IBOutlet NSTextField * filenameLabel;

@property (nonatomic, weak) IBOutlet NSSlider * durationSlider;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _videoPlayerView.controlsStyle = AVPlayerViewControlsStyleNone;
    NSRect frameRect = NSMakeRect(0, 0, 320, 240);
    if ([[NSScreen screens] count] > 1) {
        frameRect = [[[NSScreen screens] objectAtIndex:1] frame];
    }
    [_videoWindow setFrame:frameRect display:YES];
    [_videoWindow setLevel:NSStatusWindowLevel];
    [_videoWindow orderFront:nil];
    
    _filenameLabel.stringValue = @"";
    [self _updateTimeLabels:kCMTimeZero];
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
        _filenameLabel.stringValue = [[videoFileURL absoluteString] lastPathComponent];
        if (_videoPlayerView.player) {
            [_videoPlayerView.player replaceCurrentItemWithPlayerItem:[AVPlayerItem playerItemWithURL:videoFileURL]];
        } else {
            [_videoPlayerView setPlayer:[AVPlayer playerWithURL:videoFileURL]];
        }
        _videoPlayerView.player.actionAtItemEnd = AVPlayerActionAtItemEndPause;
        [_playPauseButton setImage:[NSImage imageNamed:@"play"]];
        [_videoPlayerView.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1, 1) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
            [self _updateTimeLabels:time];
        }];
        [self _updateTimeLabels:kCMTimeZero];
    }
}

- (NSString *)_stringValueForSeconds:(CGFloat)seconds {
    int minutes = seconds/60;
    int remainingSeconds = seconds - (minutes * 60);
    return [NSString stringWithFormat:@"%02d:%02d", minutes, remainingSeconds];
}

- (void)_updateTimeLabels:(CMTime)currentTime {
    CGFloat secondsElapsed = 0;
    CGFloat secondsRemaining = 0;
    CMTime duration = kCMTimeZero;
    if (_videoPlayerView.player.currentItem) {
        duration = _videoPlayerView.player.currentItem.duration;
        secondsElapsed = CMTimeGetSeconds(currentTime);
        secondsRemaining = CMTimeGetSeconds(duration) - secondsElapsed;
    }
    _durationSlider.maxValue = CMTimeGetSeconds(duration);
    _durationSlider.minValue = 0;
    _durationSlider.doubleValue = CMTimeGetSeconds(currentTime);
    [self->_elapsedTimeLabel setStringValue:[self _stringValueForSeconds:secondsElapsed]];
    [self->_remainingTimeLabel setStringValue:[NSString stringWithFormat:@"-%@", [self _stringValueForSeconds:secondsRemaining]]];
    if ([_videoPlayerView.player rate] != 0.0) {
        [_playPauseButton setImage:[NSImage imageNamed:@"pause"]];
    } else {
        [_playPauseButton setImage:[NSImage imageNamed:@"play"]];
    }
}

- (IBAction)updatePlayhead:(id)sender {
    CMTime playerDuration = _videoPlayerView.player.currentItem.duration;
    if (CMTIME_IS_INVALID(playerDuration)) {
        return;
    }
    
    double duration = CMTimeGetSeconds(playerDuration);
    if (isfinite(duration)) {
        float minValue = [_durationSlider minValue];
        float maxValue = [_durationSlider maxValue];
        float value = [_durationSlider doubleValue];
        
        double time = duration * (value - minValue) / (maxValue - minValue);
        
        [_videoPlayerView.player seekToTime:CMTimeMakeWithSeconds(time, NSEC_PER_SEC) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    }
    [_videoPlayerView.player pause];
}

- (IBAction)togglePlayback:(id)sender {
    if ([_videoPlayerView.player rate] != 0.0) {
        [_videoPlayerView.player pause];
        [_playPauseButton setImage:[NSImage imageNamed:@"play"]];
    } else {
        [_videoPlayerView.player play];
        [_playPauseButton setImage:[NSImage imageNamed:@"pause"]];
    }
}

- (IBAction)resetPlayer:(id)sender {
    [_videoPlayerView.player seekToTime:kCMTimeZero];
}

- (IBAction)changeVolume:(id)sender {
    [_videoPlayerView.player setVolume:[_volumeSlider floatValue]];
}

@end
