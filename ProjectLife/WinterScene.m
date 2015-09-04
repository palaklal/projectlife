//
//  WinterScene.m
//  ProjectLife
//
//  Copyright (c) 2015 nyu.edu. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

#import "LoseScene.h"
#import "WinterScene.h"
#import "BloomScene.h"

@interface WinterScene ()<SKPhysicsContactDelegate> {SKSpriteNode *_plant;}

@property (nonatomic, strong) SKSpriteNode *background;
@property BOOL lost;
@property BOOL won;

@property (nonatomic) NSTimeInterval lastSpawnTimeInterval;
@property (nonatomic) NSTimeInterval lastUpdateTimeInterval;

@property (nonatomic, strong) AVAudioPlayer *player;


@end

static const uint32_t nutrientCategory     =  0x1 << 0;
static const uint32_t plantCategory        =  0x1 << 1;

@implementation WinterScene
{
    SKLabelNode *countDown;
    BOOL justStarted;
    NSTimeInterval startTime;
    NSInteger totalTime;
    NSInteger plantHealth;
}

//INIT
- (id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        [self startBackgroundMusic];
        
        //Loading the background
        _background = [SKSpriteNode spriteNodeWithImageNamed:@"WINTER"];
        [_background setName:@"background"];
        [_background setAnchorPoint:CGPointZero];
        _background.zPosition = -2;
        [self addChild:_background];
        
        //Set up plant
        plantHealth = 0;
        [self setupPlant];
        
        //Add physics
        self.physicsWorld.gravity = CGVectorMake(0.0f, -2.0f);
        self.physicsWorld.contactDelegate = self;
        
        //Set up countdown label
        countDown = [SKLabelNode labelNodeWithFontNamed:@"Futura-Medium"];
        countDown.fontSize = 55;
        countDown.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMaxY(self.frame)*0.90);
        countDown.fontColor = [SKColor blackColor ];
        countDown.zPosition = 100;
        [self addChild:countDown];
        
        //Set up time
        totalTime = 60;
        justStarted = YES;
        //Set up for when it's being loaded from a save
        stopTime = 0;
        first = YES;
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        int seasonNumber = (int)[prefs integerForKey:@"seasonFlag"];
        if (seasonNumber == 4) { 
            [self load];
        }
    }
    //if User presses Home or quits the App, save the game state
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(save)
     name:UIApplicationDidEnterBackgroundNotification
     object:nil];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(save)
     name:UIApplicationWillResignActiveNotification
     object:nil];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(save)
     name:UIApplicationWillTerminateNotification
     object:nil];
    
    return self;
}

//PLAY BACKGROUND MUSIC
- (void)startBackgroundMusic
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"winter" ofType:@"wav"];
    NSError *error = nil;
    NSURL *url = [NSURL fileURLWithPath:path];
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    [self.player prepareToPlay];
    
    //Loop music
    self.player.numberOfLoops = -1;
    [self.player setVolume:1.0];
    [self.player play];
}

//SET UP PLANT
- (void) setupPlant {
    
    _plant =[SKSpriteNode spriteNodeWithImageNamed:@"elder.png"];
    [_plant setPosition:CGPointMake(self.frame.size.width/2, -self.frame.size.height/3.25)];
    
    //Set up physics body
    CGPoint anchor = CGPointMake(10, self.frame.size.height/2.4);
    _plant.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:_plant.size.width/4.5 center:anchor];
    _plant.physicsBody.dynamic = NO;
    _plant.physicsBody.categoryBitMask = plantCategory;
    _plant.physicsBody.contactTestBitMask = nutrientCategory;
    _plant.physicsBody.collisionBitMask = 0;
    
    [self addChild:_plant];
    
}

//FOR SWIPING
- (void)didMoveToView:(SKView *)view {
    UIPanGestureRecognizer *gestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(movePlant:)];
    [[self view] addGestureRecognizer:gestureRecognizer];
}

//MOVE PLANT
- (void)movePlant:(UIPanGestureRecognizer *)recognizer {
    
    CGPoint translation = [recognizer translationInView:recognizer.view];
    translation = CGPointMake(translation.x, 0);
    
    //Ensure that plant does not move off the screen
    if(_plant.position.x + translation.x >= self.size.width-50 || _plant.position.x + translation.x < 50) {
        translation.x = 0;
    }
    
    CGPoint position = [_plant position];
    [_plant setPosition:CGPointMake(position.x + translation.x, position.y)];
    
    [recognizer setTranslation:CGPointZero inView:recognizer.view];
    
}

//remove swiping UIPanGestureRecognizer
-(void)removeGestureRecognizers {
    for (UIPanGestureRecognizer *recognizer in [[self view] gestureRecognizers]) {
        //NSLog(@"removing gesture recognizer");
        [[self view] removeGestureRecognizer:recognizer];
    }
}

//FALLING NUTRIENTS
- (void)addNutrient {
    
    //Create nutrient
    SKSpriteNode * nutrient;
    
    double val = (double)rand() / RAND_MAX;
    
    if(val < 0.20){
        nutrient = [SKSpriteNode spriteNodeWithImageNamed:@"sunlight.png"];
        nutrient.name = @"sun";
    }else if (val < 0.40) {
        nutrient = [SKSpriteNode spriteNodeWithImageNamed:@"water.png"];
        nutrient.name = @"rain";
    }else if (val < 0.60){
        nutrient = [SKSpriteNode spriteNodeWithImageNamed:@"snow.png"];
        nutrient.name = @"snow";
    }else if(val < 0.80){
        nutrient = [SKSpriteNode spriteNodeWithImageNamed:@"ice.png"];
        nutrient.name = @"ice";
    }else {
        nutrient = [SKSpriteNode spriteNodeWithImageNamed:@"frost.png"];
        nutrient.name = @"frost";
    }
    
    
    //Determine where to spawn nutrient along the X axis
    int rangeX = self.frame.size.width - nutrient.size.width;
    int obstacleX = (arc4random() % rangeX) + nutrient.size.width;
    
    //Create the nutrient slightly off-screen along the right edge,
    //and along a random position along the X axis as calculated above
    nutrient.position = CGPointMake(obstacleX, self.frame.size.height + nutrient.size.height/2);
    [self addChild:nutrient];
    
    // Add physics
    nutrient.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:nutrient.size.width/2];
    nutrient.physicsBody.categoryBitMask = nutrientCategory;
    nutrient.physicsBody.contactTestBitMask = plantCategory;
    nutrient.physicsBody.collisionBitMask = 3;
    nutrient.physicsBody.dynamic = YES;
    nutrient.physicsBody.allowsRotation = YES;
    nutrient.physicsBody.restitution = 1.0f;
    
    
}

//UPDATE
- (void)update:(NSTimeInterval)currentTime {
    
    //Create new nutrient
    [self createNutrient:currentTime];
    
    //update remaining time
    [self timer:currentTime];
    
    if ([self isGameOver]) [self endGame];
    if ([self isWon]) [self nextLevel];
    
}

//SPAWN NEW NUTRIENT
- (void)createNutrient:(NSTimeInterval)currentTime
{
    CFTimeInterval lastTime = currentTime - self.lastUpdateTimeInterval;
    self.lastUpdateTimeInterval = currentTime;
    
    if (lastTime > 1) {
        lastTime = 1.0 / 60.0;
        self.lastUpdateTimeInterval = currentTime;
        
    }
    
    //spawn new nutrient
    self.lastSpawnTimeInterval += lastTime;
    if (self.lastSpawnTimeInterval > 1) {
        self.lastSpawnTimeInterval = 0;
        [self addNutrient];
    }
}


//DISPLAY REMAINING TIME
- (void)timer:(NSTimeInterval)currentTime
{
    if(justStarted) {
        startTime = currentTime;
        justStarted = NO;
    }
    
    countdownTime = (int)(currentTime-startTime);
    //if the user is loading back the game from a saved state, set it to the old remaining time
    if (stopTime > 0) {
        if (first) {
            totalTime = remainingTime;
            
        }
        first = NO;
    }
    remainingTime = (int)(totalTime - countdownTime);
    
    if(remainingTime >= 0){
        countDown.text = [NSString stringWithFormat:@"%i", remainingTime];
    } else {
        countDown.text = [NSString stringWithFormat:@"TIME'S UP"];
    }
    
    
}

//DETECT COLLISION
- (void)didBeginContact:(SKPhysicsContact *)contact
{
    BOOL grow = NO;
    
    //Nutrient disappears as it is absorbed by plant
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask){
        if(![contact.bodyA.node.name isEqualToString:@"snow"] && ![contact.bodyA.node.name isEqualToString:@"ice"] && ![contact.bodyA.node.name isEqualToString:@"frost"]){
            [contact.bodyA.node removeFromParent];
            plantHealth++;
            grow = YES;
            
        }else {
            plantHealth--;
        }
    } else {
        if(![contact.bodyB.node.name isEqualToString:@"snow"] && ![contact.bodyB.node.name isEqualToString:@"ice"] && ![contact.bodyB.node.name isEqualToString:@"frost"]){
            [contact.bodyB.node removeFromParent];
            plantHealth++;
            grow = YES;
        } else {
            plantHealth--;
        }
    }
    
    //Animate plant
    if(grow) {
        SKAction *smile = [SKAction animateWithTextures:@[[SKTexture textureWithImageNamed:@"elder.png"],
                                                          [SKTexture textureWithImageNamed:@"elder-smile1.png"],
                                                          [SKTexture textureWithImageNamed:@"elder-smile2.png"]]timePerFrame:0.033];
        SKAction *smileanim = [SKAction sequence:@[smile, [SKAction waitForDuration:1.0], [smile reversedAction]]];
        [_plant runAction:smileanim];
    } else {
        SKAction *frown = [SKAction animateWithTextures:@[[SKTexture textureWithImageNamed:@"elder.png"],
                                                          [SKTexture textureWithImageNamed:@"elder-frown1.png"],
                                                          [SKTexture textureWithImageNamed:@"elder-frown2.png"]]timePerFrame:0.033];
        SKAction *frownanim = [SKAction sequence:@[frown, [SKAction waitForDuration:1.0], [frown reversedAction]]];
        [_plant runAction:frownanim];
    }
    
    [self growPlant:grow];
    
}

//GROW PLANT
-(void) growPlant:(BOOL) grow {
    
    CGPoint location;
    
    //Grow or shrink plant depending on what has been caught
    if(grow){
        //NSLog(@"GROW");
        location = CGPointMake(_plant.position.x, _plant.position.y+(_plant.size.height/12));
        SKAction *growthSound = [SKAction playSoundFileNamed:@"growth.wav" waitForCompletion:NO];
        [_plant runAction:growthSound];
    } else {
        //NSLog(@"SHRINK");
        location = CGPointMake(_plant.position.x, _plant.position.y-(_plant.size.height/11));
        SKAction *collisionSound = [SKAction playSoundFileNamed:@"collision.wav" waitForCompletion:NO];
        [_plant runAction:collisionSound];
    }
    
    SKAction *action = [SKAction moveTo:location duration:0.5];
    [_plant runAction:action];
    
}

//CHECK IF PLANT HAS CAUGHT ENOUGH NUTRIENTS
-(BOOL) isWon {
    
    //NSString *health = [NSString stringWithFormat: @"%ld", (long)plantHealth];
    //NSLog(health);
    
    if(plantHealth >= 10) {
        return YES;
    }
    
    return NO;
}

//TRANSITION TO NEXT LEVEL
-(void) nextLevel {
    if(!self.won){
        self.won = YES;
        
        [self removeGestureRecognizers];
        
        //Transition to Win Screen
        BloomScene *bloomScene = [[BloomScene alloc] initWithSize:self.size];
        SKTransition *transition = [SKTransition pushWithDirection:SKTransitionDirectionDown duration:1.0];
        [self.view presentScene:bloomScene transition:transition];
    }
    
}

//CHECK IF GAME OVER
-(BOOL)isGameOver {
    if(remainingTime < 0 || _plant.position.y < (-self.frame.size.height/3.5)-(_plant.size.height/11)){
        return YES;
    }
    
    return NO;
}

//DISPLAY LOSE SCREEN
-(void)endGame {
    if(!self.lost) {
        self.lost = YES;
        
        [self removeGestureRecognizers];
        
        //Transition to lose screen
        SKScene *loseScene = [[LoseScene alloc] initWithSize:self.size];
        SKTransition *transition = [SKTransition doorsCloseHorizontalWithDuration:1.0];
        [self.view presentScene:loseScene transition:transition];
    }
}

-(void)save {
    //save that you stopped the game, how much time you had left when you had stopped, what season you were on, the plant's position, the plant's health, and all the falling nutrients/obstacles when you exit the game
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setInteger:4 forKey:@"seasonFlag"]; //change for each Season
    stopTime = countdownTime + startTime;
    [prefs setInteger:remainingTime forKey:@"remainingTime"];
    [prefs setInteger:stopTime forKey:@"stopTime"];
    NSMutableArray *arrayOfNutrients = [[NSMutableArray alloc] init];
    [self enumerateChildNodesWithName:@"sun" usingBlock:^(SKNode *node, BOOL *stop) {
        if (node.position.y > 0)
        {
            [arrayOfNutrients addObject:node];
        }
        else {
            [node removeFromParent];
        }
    }];
    [self enumerateChildNodesWithName:@"rain" usingBlock:^(SKNode *node, BOOL *stop) {
        if (node.position.y > 0)
        {
            [arrayOfNutrients addObject:node];
        }
        else {
            [node removeFromParent];
        }
    }];
    [self enumerateChildNodesWithName:@"snow" usingBlock:^(SKNode *node, BOOL *stop) {
        if (node.position.y > 0)
        {
            [arrayOfNutrients addObject:node];
        }
        else {
            [node removeFromParent];
        }
    }];
    [self enumerateChildNodesWithName:@"ice" usingBlock:^(SKNode *node, BOOL *stop) {
        if (node.position.y > 0)
        {
            [arrayOfNutrients addObject:node];
        }
        else {
            [node removeFromParent];
        }
    }];
    [self enumerateChildNodesWithName:@"frost" usingBlock:^(SKNode *node, BOOL *stop) {
        if (node.position.y > 0)
        {
            [arrayOfNutrients addObject:node];
        }
        else {
            [node removeFromParent];
        }
    }];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:arrayOfNutrients];
    [prefs setObject:data forKey:@"arrayOfNutrients"];
    [prefs setInteger:_plant.position.x forKey:@"plantPositionX"];
    [prefs setInteger:_plant.position.y forKey:@"plantPositionY"];
    [prefs setInteger:plantHealth forKey:@"plantHealth"];
    [prefs synchronize];
}

-(void)load {
    //load back the saved state of the game when user presses Resume Game button
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    stopTime = (int)[prefs integerForKey:@"stopTime"];
    remainingTime = (int)[prefs integerForKey:@"remainingTime"];
    first = YES;
    float plantpositionx = [prefs integerForKey:@"plantPositionX"];
    float plantpositiony = [prefs integerForKey:@"plantPositionY"];
    [_plant setPosition:CGPointMake(plantpositionx, plantpositiony)];
    plantHealth = [prefs integerForKey:@"plantHealth"];
    //reload all the falling obstacles and nutrients from the last save
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"arrayOfNutrients"];
    NSArray *nutrients = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    for(SKSpriteNode *Nutrient in nutrients){
        [self addChild:Nutrient];
        Nutrient.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:Nutrient.size.width/2];
        Nutrient.physicsBody.categoryBitMask = nutrientCategory;
        Nutrient.physicsBody.contactTestBitMask = plantCategory;
        Nutrient.physicsBody.collisionBitMask = 3;
        Nutrient.physicsBody.dynamic = YES;
        Nutrient.physicsBody.allowsRotation = YES;
        Nutrient.physicsBody.restitution = 1.0f;
        
    }
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillTerminateNotification object:nil];
    //NSLog(@"Old Spring scene deallocated");
}

@end
