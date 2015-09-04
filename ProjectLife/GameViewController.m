//
//  GameViewController.m
//  ProjectLife
//
//  Copyright (c) 2015 nyu.edu. All rights reserved.
//

#import "GameViewController.h"
#import "HomeScene.h"



@implementation GameViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Configure the view.
    SKView * skView = (SKView *)self.view;
    skView.showsFPS = NO;
    skView.showsNodeCount = NO;
    /* Sprite Kit applies additional optimizations to improve rendering performance */
    skView.ignoresSiblingOrder = YES;
    skView.showsPhysics = NO;

    // Create and configure the scene.
    SKScene *scene = [HomeScene sceneWithSize:skView.bounds.size];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    
    // Present the scene.
    [skView presentScene:scene];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(createPost:)
                                                 name:@"CreatePost"
                                               object:nil];
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

-(void)createPost:(NSNotification *)notification
{
    // post Victory image on Facebook!
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        SLComposeViewController *mySLComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        [mySLComposerSheet addImage:[UIImage imageNamed:@"victory"]];
        [self presentViewController:mySLComposerSheet animated:YES completion:nil];
        [mySLComposerSheet setCompletionHandler:^(SLComposeViewControllerResult result) {
            if (result == SLComposeViewControllerResultDone) {
                NSString *successMessage = @"You successfully shared your victory on Facebook!";
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"^_^" message:successMessage delegate:nil cancelButtonTitle:@"Great!" otherButtonTitles:nil];
                [alertView show];
            }
            else if (result == SLComposeViewControllerResultCancelled)
            {
                NSString *failureMessage = @"Facebook post was unsuccessful.";
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"-_-" message:failureMessage delegate:nil cancelButtonTitle:@"Alrighty then" otherButtonTitles:nil];
                [alertView show];
            }
        }];
    }
    else {
        NSString *message = @"It seems that either Facebook is unavailable at the moment or you have not yet added your Facebook account to this device. Please go to Settings and add your Facebook account to this device!";
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    }
    
}

@end
