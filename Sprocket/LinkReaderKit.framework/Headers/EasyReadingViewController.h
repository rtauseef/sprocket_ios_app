//
//  EasyReadingViewController.h
//  LinkReaderSDK
//
//  Copyright (c) 2015 HP. All rights reserved.
//

#import <UIKit/UIKit.h>



/**
 This protocol should only be adhered to when using the easyReadingViewController for scanning and payoff presentation.

 @since 1.0
 */
@protocol EasyReadingDelegate <NSObject>


/**
 This method is called when an error in the easyReadingViewController has occurred and should be dealt with by the client (i.e., your) application. In the case of an authentication errors, you may wish to attempt reauthentication using `-(void)reauthenticate` In the case of a payoff-related error, you will need to provide the appropriate notification to your users and call the -resumeScanning method at the appropriate time.
 
 The possible error domains received here are:
 
 - LRAuthorizationErrorDomain : See `LRManager`
 
 - LRPayoffResolverErrorDomain : See `LRDetection`
 
 - LRPayoffErrorDomain : See `LRDetection`
 
 - LRCameraErrorDomain : See `LRCaptureManager`
 
 @param error NSError with code and description

 @since 1.0
 */
- (void)readerError:(NSError *)error;

@optional

/**
 When the user presses the done button, this method is called. In most cases, it is not required to implement this protocol method because the view controller will dismiss itself in modal presentations, or will not be visible (e.g., the VC is part of a navigation stack).
 
 @warning If you implement this method, the default nature to dismiss itself will be overridden and you must handle dismissing the view controller yourself.
 
 @since 1.0
 */
- (void)readerFinished;

@end




/**
 This view controller is preconfigured with a camera session preview and handles detection and payoff presentation without requiring input from the host application.
 

 EasyReadingViewController is intended to be a simple plug-n-play solution to scanning and payoff display.
 
 Please read the Getting Started documentation for guidance on using the LinkReaderKit embedded framework.
 
 # Basic Usage - Presenting Modally
 
     ```
     // 1. Pass your credentials and a delegate to receive important callbacks, get a view controller
     
     EasyReadingViewController *vc = [[EasyReadingViewController alloc] initWithClientID:kTestClientID secret:kTestSecret delegate:self success:^{
        NSLog(@"Authorization complete!");

     } failure:^(NSError *error) {
        // Handle Error

    }];

     // 2. Set the frame (will probably be full-screen)
     vc.view.frame = self.view.bounds;
     
     // 3. Present the view controller
     [self presentViewController:vc animated:YES completion:^{
     NSLog(@"Easy as π!");
     }];
     
     ```
 
 The `EasyReadingDelegate` also requires implementing `-readerError:`
 
     ```
     
     // 4. If something goes wrong, we'll tell you
     -(void)readerError:(NSError *)error {
     [[[UIAlertView alloc] initWithTitle:@"Easy Reading Error" message:@"Sorry, but there was a problem." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
     }
     
     ```
 
 Run the application. Note: the video preview and scanning capability are only available on-device, and therefore will not run in the Simulator. You will be able to present the preconfigured view controller, but you will only see a black background.
 
 ---
 
 ## Inserting Into Another View Controller
 
 In some cases, it may be desirable to insert the EasyReadingViewController's view directly into the view hierarchy of another view controller. In this case, create an instance of the EasyReadingViewController (ERCV) as you would normally. Next, add ERVC as a child view controller:
    
    ```
    -(void)viewDidLoad {
        [super viewDidLoad];
         self.easyReading = [[EasyReadingViewController alloc] initWithClientID:kTestClientID secret:kTestSecret delegate:self success:^{
            NSLog(@"Authorization complete!");
         } failure:^(NSError *error) {
            // Handle error
        }];

        [myViewController addChildViewController: self.easyReading];
        [self.view addSubview:self.easyReading.view];

    }

    -(void)viewWillAppear:(BOOL)animated {
        [super viewWillAppear:animated];
        
        //Set the desired bounds; This could be full-screen, or just a portion
        self.easyReading.view.frame = self.view.bounds;
     }

    ```
 
 
 @since 1.0
 */

@interface EasyReadingViewController : UIViewController

/**
 For projects where minimal interaction with LinkReaderKit is desired, this class method will return a preconfigured view controller that can be presented onscreen. The view controller will handle video preview setup and will display payoffs without any interaction required by the client (ie, your) application. 
 
 @param clientID    The clientID provided in your account
 @param secret      The client secret provided in your account
 @param delegate    A delegate object to receive notifications
 @param success block performed when authentication has successfully occurred
 @param failure block performed when authentication has failed
 - error : Error describing the failure reason

 @return UIViewController preconfigured for scanning and payoff display
 
 @since 1.0
 */
- (instancetype)initWithClientID:(NSString *)clientID secret:(NSString *)secret delegate:(id<EasyReadingDelegate>)delegate success:(void (^)(void))success failure:(void (^)(NSError * error))failure;

/**
 The done button is normally only hidden on UINavigationController stacks. In the case of modal presentations, the done button will dismiss its modal presentation. In some cases, such as when the EasyReadingViewController is a child of a UITabBarController, you may need to hide the Done button

 @param hidden TRUE if you wish to force the button to always be hidden
 
 @since 1.0
 */
- (void)forceDoneButtonHidden:(BOOL)hidden;


/**
 In some situations reauthentication may be desired. For instance, in cases where the network has come back online. The credentials and delegate provided in initialization will be reused.
 
 @param success block performed when authentication has successfully occurred
 @param failure block performed when authentication has failed
    - error : Error describing the failure reason

  @since 1.0
 */
- (void)reauthenticateWithSuccess:(void (^)(void))success failure:(void (^)(NSError * error))failure;

/**
 When a payoff is detected, scanning is paused to prevent repetitive triggering. In the case of a payoff-related error, scanning will need to be resumed once the error has been properly handled. This method is not required under normal scan-payoff flows. Once the payoff display dismisses, the viewer returns to scanning mode.
 
 @since 1.0
 */
- (void)resumeScanning;

@end
