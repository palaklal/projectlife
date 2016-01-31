# project-life
 Discover your inner green thumb with Project Life, a fun iPhone game that lets you grow a baby plant through all four seasons of life. Your goal is to navigate the plant across the screen to capture as much falling nutrients and avoid all the obstacles that may cause it harm, all within the time limit. When the plant grows to a certain height, it passes its current season of life and moves on to the next level/season. As you move through the seasons, watch in amazement as your plant blossoms from an adorable infant to a moody adolescent to a Fortune 500 CEO, before finally entering fully-bloomed, blissful retirement. 
  
  Project Life was created as a group project. It was developed using Xcode in Objective C. Sprite Kit was leveraged to handle the physics, core game logic, and sound effects. Background music was added using AVFoundation. We used Vivaldi's Four Seasons and the My Neighbor Totoro Theme Song. 
NOTE: this game was developed for the iPhone 6. 

  Although I had a hand in the core game logic as well, my main contributions were the save/load and social media sharing functionalities. 

# Save/Load
 The user has the option to exit the app whenever they desire and the game will automatically save itself (the plant's health and position, the nutrients'/obstacles' position, the current level, and the remaining time for that level) with the option to reload the game once they return to the home screen. The NSNotificationCenter was used to ascertain when the game was being exited. We used NSKeyedArchiver to convert the arrays into a savable format and NSUserDefaults to save/load all the information. 
 
# Social Media
 After players have completed all the levels and have successfully grown a blooming plant, they can post the victory screen on Facebook. To implement this, we used NSNotificationCenter to connect the SpriteKit Scene and the View Controller. Then within the view controller, we used the Social framework to actually post onto Facebook. 
 
