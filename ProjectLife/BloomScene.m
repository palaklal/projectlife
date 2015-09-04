//
//  BloomScene.m
//  ProjectLife
//
//  Copyright (c) 2015 nyu.edu. All rights reserved.
//

#import "BloomScene.h"

@implementation BloomScene
- (id) initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size]) {
        [self startBackgroundMusic];
        
        _background = [SKSpriteNode spriteNodeWithImageNamed:@"BLOOM"];
        [_background setName:@"background"];
        [_background setAnchorPoint:CGPointZero];
        [self addChild:_background];
        
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs setInteger:0 forKey:@"seasonFlag"];//reset flag
        
        SKLabelNode* winLabel = [SKLabelNode labelNodeWithFontNamed:@"Futura-Medium"];
        winLabel.fontSize = 30;
        winLabel.fontColor = [SKColor colorWithRed:0.349 green:0.522 blue:0.153 alpha:1];
        winLabel.text = @"You win!";
        winLabel.position = CGPointMake(self.size.width/2, (3.0 / 4.0 * self.size.height) + 40);
        [self addChild:winLabel];
        
        //add option/button to share Bloom picture (the background) on Facebook!
        SKLabelNode* facebookShareLabel = [SKLabelNode labelNodeWithFontNamed:@"Futura-Medium"];
        facebookShareLabel.fontSize = 15;
        facebookShareLabel.fontColor = [SKColor colorWithRed:0.349 green:0.153 blue:0.522 alpha:1];
        facebookShareLabel.text = @"Click here to share on Facebook!";
        facebookShareLabel.name = @"facebook share button";
        facebookShareLabel.position = CGPointMake(self.size.width/2, 3.0 / 4.0 * self.size.height);
        [self addChild:facebookShareLabel];

    }
    
    return self;
}

- (void)startBackgroundMusic
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"totoro-music" ofType:@"wav"];
    NSError *error = nil;
    NSURL *url = [NSURL fileURLWithPath:path];
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    [self.player prepareToPlay];
    
    // this will play the music infinitely
    self.player.numberOfLoops = -1;
    [self.player setVolume:1.0];
    [self.player play];
    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:location];
    
    //if facebookShareLabel is pressed
    if ([node.name isEqualToString:@"facebook share button"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"CreatePost" object:self];
    }
}

//ADD QUIT GAME FEATURE


@end
