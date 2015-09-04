//
//  LoseLevel.m
//  ProjectLife
//
//  Copyright (c) 2015 nyu.edu. All rights reserved.
//

#import "LoseScene.h"
#import "SpringScene.h"

@implementation LoseScene

- (id) initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size]) {
        
        self.backgroundColor = [SKColor colorWithRed:0.694 green:0.937 blue:0.561 alpha:1];
        
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs setInteger:0 forKey:@"seasonFlag"];//reset flag
        
        SKLabelNode* gameOverLabel = [SKLabelNode labelNodeWithFontNamed:@"Futura-Medium"];
        gameOverLabel.fontSize = 25;
        gameOverLabel.fontColor = [SKColor colorWithRed:0.349 green:0.522 blue:0.153 alpha:1];
        gameOverLabel.text = @"You Lose! Tap to play again.";
        gameOverLabel.position = CGPointMake(self.size.width/2, 2.0 / 3.0 * self.size.height);
        [self addChild:gameOverLabel];
        //SpringScene* springScene = [[SpringScene alloc] initWithSize:self.size];
        //[self.view presentScene:springScene transition:[SKTransition doorsOpenHorizontalWithDuration:1.0]];
    }
    
    
    return self;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    SpringScene* springScene = [[SpringScene alloc] initWithSize:self.size];
    springScene.scaleMode = SKSceneScaleModeAspectFill;
    [self.view presentScene:springScene transition:[SKTransition doorsCloseHorizontalWithDuration:1.0]];
}

@end
