//
//  BloomScene.h
//  ProjectLife
//
//  Copyright (c) 2015 nyu.edu. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import <AVFoundation/AVFoundation.h>

@interface BloomScene : SKScene
@property (nonatomic, strong) AVAudioPlayer *player;
@property (nonatomic, strong) SKSpriteNode *background;
@end
