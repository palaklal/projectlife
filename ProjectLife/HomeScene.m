//
//  GameScene.m
//  ProjectLife
//
//  Copyright (c) 2015 nyu.edu. All rights reserved.
//

#import "HomeScene.h"
#import "SpringScene.h"
#import "SummerScene.h"
#import "FallScene.h"
#import "WinterScene.h"
#import "BloomScene.h"


@implementation HomeScene

- (id) initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size]) {
        
        //set the background
        _background = [SKSpriteNode spriteNodeWithImageNamed:@"HOME"];
        [_background setName:@"background"];
        [_background setAnchorPoint:CGPointZero];
        [self addChild:_background];
        
        int offset = 65;
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        int seasonNumber = (int)[prefs integerForKey:@"seasonFlag"];
        if ((seasonNumber) && (seasonNumber > 0)) { //only have a resume button if there's a valid saved game
            //Set up Resume Game button
            SKSpriteNode *resumeButton = [SKSpriteNode spriteNodeWithImageNamed:@"resume-button.png"];
            resumeButton.xScale = .35;
            resumeButton.yScale = .35;
            resumeButton.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)+10);
            resumeButton.name = @"resumeGame";
            [self addChild:resumeButton];
        }
        else {
            offset = 30; //center New Game Button more
        }
        
        //Set up New Game button
        SKSpriteNode *button = [SKSpriteNode spriteNodeWithImageNamed:@"newgame-button.png"];
        button.xScale = .35;
        button.yScale = .35;
        button.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame) + offset);
        button.name = @"newGame";
        [self addChild:button];
        
        [self startBackgroundMusic];
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


//Start game when New Game button is pressed
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:location];
    
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    //if newGame button is pressed, send to Spring level
    if ([node.name isEqualToString:@"newGame"]) {
        //NSLog(@"New Game pressed");
        [prefs setInteger:0 forKey:@"seasonFlag"];//reset flag 
        SKScene *springScene = [[SpringScene alloc] initWithSize:self.size];
        SKTransition *transition = [SKTransition doorsOpenHorizontalWithDuration:1.0];
        [self.view presentScene:springScene transition:transition];
    }
    
    //if resumeGame button is pressed, send to whatever level it was on 
    if ([node.name isEqualToString:@"resumeGame"]) {
        //NSLog(@"Resume Game pressed");
        int seasonNumber = (int)[prefs integerForKey:@"seasonFlag"];
        SKScene *seasonScene = [[SKScene alloc] init];
        if (seasonNumber == 1) {
            seasonScene = [[SpringScene alloc] initWithSize:self.size];
        }
        else if (seasonNumber == 2) {
            seasonScene = [[SummerScene alloc] initWithSize:self.size];
        }
        else if (seasonNumber == 3) {
            seasonScene = [[FallScene alloc] initWithSize:self.size];
        }
        else if (seasonNumber == 4) {
            seasonScene = [[WinterScene alloc] initWithSize:self.size];
        }
        else {
            NSLog(@"No season to be shown");
            seasonScene = [[SpringScene alloc] initWithSize:self.size];
        }
        
        SKTransition *transition = [SKTransition doorsOpenHorizontalWithDuration:1.0];
        
        [self.view presentScene:seasonScene transition:transition];

    }
}

@end