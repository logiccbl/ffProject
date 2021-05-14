//
//  ViewController.m
//  ff_RW_Sample
//
//  Created by Rube Williams on 4/6/21.
//

#import "ViewController.h"

#import "ff_RW_Sample-Swift.h"

#import "AppDelegate.h"

@interface ViewController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, FileDelegate>

@property (nonatomic, strong)   UILabel     *   titleView;
@property (nonatomic, strong)   NSTimer     *   timerNoticeHideTimer;

@property (nonatomic,  strong)  NSArray     *   favoritesArray;
@property (nonatomic,  strong)  NSArray     *   historyArray;

@property (weak, nonatomic) IBOutlet UITextField *identifierTextField;
@property (weak , nonatomic) IBOutlet UISegmentedControl * userFilterSelector;
@property (nonatomic)   NSInteger contentFilterIndex;
@property (nonatomic, weak)   IBOutlet UITableView *   tableView;

@property (weak, nonatomic) IBOutlet UILabel *eventNoticeLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *busyIndicatorView;


#pragma mark constraints

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mainContentViewContainerBottomConstraint;

@property (strong, nonatomic)       DetailVC * detailVC;
@property (strong, nonatomic)       NSDictionary * cache;
@property (strong, nonatomic)       NSString * cacheString;

@property (strong, nonatomic)       NSManagedObjectContext  *   context;

@end

typedef enum {
    kFavorites,
    kHistory
} selectorFilters;

#define PLACEINDICATORLENGTH_SHORT 3
#define PLACEINDICATORLENGTH_LONG 4

#define EXERCISEENDPOINT_PREFIX @"https://qa.foreflight.com/weather/report"
#define EXERCIEHEADERFIELDNAME @"ff-coding-exercise"
#define EXERCISEHEADERFIELDVALUE @"1"

#define EX_MESSAGE_NOMESSAGE @"No Message"
#define EX_MESSAGE_NOTFOUND @"Not Found"
#define EX_MESSAGE_TIMEDOUT @"Time Out Failure"
#define EX_TIMER_MESSAGECLEAR 8.0

#define EX_SESSIONREQUESTTIMEOUT 10.0

#define EX_STOREDPREFERENCE_FAVORITES @"favorite places"
#define EX_STOREDPREFERENCE_FAVORITES_MAXCOUNT 20


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self preliminaries];
}

#pragma mark Overhead
-(void)preliminaries{
    [self establishViews];
    [self establishAsDelegate];
    [self establishNotifications];
    [self userWait:NO message:EX_MESSAGE_NOMESSAGE];
}

-(void)establishViews{
    
    _titleView = [[UILabel alloc]init];
    self.titleView.font = [UIFont fontWithName:@"Helvetica-Bold" size:30.0];
    self.titleView.text = @"Weather Finder";
    self.titleView.textColor = [UIColor whiteColor];
    self.navigationItem.titleView = self.titleView;
    [self.navigationController.navigationBar setBarTintColor:[self mainColorTheme]];
    self.view.backgroundColor = [self mainColorTheme];
}

-(void)userWait:(BOOL)isWait message:(NSString *)message{
    
    if ([self.timerNoticeHideTimer isValid]){
        [self.timerNoticeHideTimer invalidate];
    }
    
    
    self.busyIndicatorView.hidden = !isWait;
   
    BOOL hideNotice = [message isEqual:EX_MESSAGE_NOMESSAGE];
    if (!hideNotice){
        self.eventNoticeLabel.text = message;
        self.timerNoticeHideTimer = [NSTimer scheduledTimerWithTimeInterval:EX_TIMER_MESSAGECLEAR repeats:NO block:^(NSTimer * timer){
            dispatch_async(dispatch_get_main_queue(),^{
                [self userWait:NO message:EX_MESSAGE_NOMESSAGE];
            });
            self.identifierTextField.text = nil;
        }];
        
    }
    self.eventNoticeLabel.hidden = hideNotice;
    [self disableUserActions:isWait];
}

-(void)disableUserActions:(BOOL)shouldDisable{
    self.userFilterSelector.enabled = !shouldDisable;
    self.tableView.userInteractionEnabled = !shouldDisable;
    self.identifierTextField.enabled = !shouldDisable;
}

-(void)clearWaitState{
    if ([self.timerNoticeHideTimer isValid] || !self.busyIndicatorView.hidden){
        dispatch_async(dispatch_get_main_queue(),^{
            [self userWait:NO message:EX_MESSAGE_NOMESSAGE];
        });
        
    }
}

-(UIColor *)mainColorTheme{
    return [UIColor blueColor];
}

-(void)establishAsDelegate{
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.identifierTextField.delegate = self;
    
}

-(void)establishNotifications{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateForKeyboard:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateForKeyboard:) name:UIKeyboardWillHideNotification object:nil];
    
}
#define EX_FAVORITEPLACES @"favorite places"
-(NSArray *)favoritesArray{
    if(!_favoritesArray){
        _favoritesArray = [[NSUserDefaults standardUserDefaults] objectForKey:EX_FAVORITEPLACES];
        
        if(!_favoritesArray){
            _favoritesArray = [NSArray arrayWithObjects:
                               @"KPWM",
                               @"KAUS",
                               nil];
        }
    }
    return _favoritesArray;
}

-(NSArray *)historyArray{
    if(!_historyArray){
        _historyArray = [NSArray arrayWithObjects:
                         @"KPWM",
                         @"KAUS",
                         @"KPWM",
                         nil];
    }
    return _historyArray;
}

-(DetailVC *)detailVC{
    if (!_detailVC){
        _detailVC = [[DetailVC alloc]init];
    }
    return _detailVC;
}

-(NSManagedObjectContext *)context{
    if(!_context){
        _context = ((AppDelegate*)[[UIApplication sharedApplication] delegate]).persistentContainer.viewContext;
    }
    return _context;
}

#pragma mark Action

- (IBAction)userFilterSelected:(UISegmentedControl *)sender {
    [self clearWaitState];
    if (sender.selectedSegmentIndex > -1){
        self.contentFilterIndex = sender.selectedSegmentIndex;
        [self loadHistory];
        
        
        [self.tableView reloadData];
    }
}

- (void)loadHistory{
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Place" inManagedObjectContext:self.context];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor * sort = [NSSortDescriptor sortDescriptorWithKey:@"acquireDate" ascending:NO];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    
    self.historyArray = [self.context executeFetchRequest:fetchRequest error:nil];
    
    [self.context save:nil];
    
  
}

#pragma mark Tableview

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(self.contentFilterIndex == kFavorites){
        return self.favoritesArray.count;
    }
    else{
        return self.historyArray.count;
    }
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    [self clearWaitState];
    
    static NSString * favoritesCellIndentifier = @"FavoritesCell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:favoritesCellIndentifier];
    if(!cell){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:favoritesCellIndentifier];
    }
    
    UIListContentConfiguration * content = [cell defaultContentConfiguration];
    if(self.contentFilterIndex == kFavorites ){
        content.text = [self.favoritesArray objectAtIndex:indexPath.row];
        content.textProperties.font = [UIFont fontWithName:@"Helvetica-Bold" size:20.0];
        content.secondaryText = nil;
    }
    else{
        Place * place = [self.historyArray objectAtIndex:indexPath.row];
        content.text = place.name;
        content.textProperties.font = [UIFont fontWithName:@"Helvetica" size:18.0];
        content.secondaryText = [NSString stringWithFormat:@"%@", place.acquireDate];
        content.secondaryTextProperties.font = [UIFont fontWithName:@"Helvetica-Bold" size:16.0];
    }
    
    [cell setContentConfiguration:content];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString * ident = nil;
    if(self.contentFilterIndex == kFavorites){
        ident = [self.favoritesArray objectAtIndex:indexPath.row];
        [self hitEndpointWith:ident];
        self.identifierTextField.text = ident.uppercaseString;
    }
    else{
        ident = ((Place *)[self.historyArray objectAtIndex:indexPath.row]).name;
        NSString * string = ((Place *)[self.historyArray objectAtIndex:indexPath.row]).lastWeather;
        
        self.cache = [self dictionaryFromString:string];
        self.cacheString = string;
        [self callVC:1];
        [self clearWaitState];
    }
    
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


-(void)callVC:(int)isCurrent{
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    __weak ViewController * weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        DetailVC * vc = [storyboard instantiateViewControllerWithIdentifier:@"SecondVC"];
        [vc selectedPlaceCache:self.cache isCurrent:isCurrent];
        [self.navigationController pushViewController:vc animated:YES];
        self.identifierTextField.text = nil;
        vc.delegate = weakSelf;
    });

}

#pragma mark secondary actions

-(void)updateForKeyboard:(NSNotification *)notification{
    
    CGRect keyboardFrame = [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey]CGRectValue];
    
    double offset = self.view.frame.size.height - keyboardFrame.origin.y;
    self.mainContentViewContainerBottomConstraint.constant = offset;
}


-(void)storeFavs:(NSString *)newFav makeFave:(BOOL)makeFave{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
       
        NSMutableArray * favorites = [self.favoritesArray mutableCopy];
        if (!favorites){
            favorites = [NSMutableArray array];
        }
        [favorites removeObject:newFav];
        if(makeFave){
            [favorites insertObject:newFav atIndex:0];
        }
        
        while(favorites.count > EX_STOREDPREFERENCE_FAVORITES_MAXCOUNT){
            [favorites removeLastObject];
        }
        self.favoritesArray = [favorites copy];
        
        if(self.contentFilterIndex == kFavorites){
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }
        
        [[NSUserDefaults standardUserDefaults] setObject:[self.favoritesArray copy] forKey:EX_FAVORITEPLACES];
        
    });
}
    
-(NSDictionary *)refreshRequest:(NSString *)placeIdent{
    return [self returnFromEndpointWithRefreshDataFor:placeIdent];
    
}


-(void)makeFavorite:(BOOL)makeFave placeIdent:(NSString *)placeIdent{
    [self storeFavs:placeIdent makeFave:makeFave];
}

-(BOOL)faveStatus:(NSString *)placeIdent{
    
    NSDictionary * dictionary = [NSDictionary dictionaryWithObjects:self.favoritesArray forKeys:self.favoritesArray];
    
    return [dictionary objectForKey:placeIdent] != nil;
}


-(void)dismissDetail{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)storeHistory:(NSString *)ident{
    
    Place * place = [Place createPlace:ident weather:self.cacheString acquireDate:[NSDate date] context:self.context];
}


#pragma mark textfield processing
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    if(textField.text.length == PLACEINDICATORLENGTH_SHORT || textField.text.length == PLACEINDICATORLENGTH_LONG){
        [self hitEndpointWith:[textField.text lowercaseString]];
    }
    return YES;
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    [self clearWaitState];
    return YES;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    BOOL returnVal = NO;
    [self clearWaitState];
    
    if(string.length > 0){
        if(textField.text.length < 4){
            BOOL isNumber = [[NSCharacterSet decimalDigitCharacterSet] characterIsMember:[string characterAtIndex:0]];
            if ([[NSCharacterSet uppercaseLetterCharacterSet] characterIsMember:[string characterAtIndex:0]] || isNumber){
                returnVal = YES;
            }
        }
    }
    else{
        returnVal = YES;
    }
    return returnVal;
}
    
#pragma mark hit endpoint

-(void)hitEndpointWith:(NSString *)placeIdentifier{
   
    dispatch_async(dispatch_get_main_queue(),^{
        [self userWait:YES message:EX_MESSAGE_NOMESSAGE];
    });
    NSString * urlString = [NSString stringWithFormat:@"%@/%@", EXERCISEENDPOINT_PREFIX, placeIdentifier];
    NSURL * url = [NSURL URLWithString:urlString];
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url];
    [request setValue:EXERCISEHEADERFIELDVALUE forHTTPHeaderField:EXERCIEHEADERFIELDNAME];
    
    NSURLSessionConfiguration * config = [NSURLSessionConfiguration defaultSessionConfiguration];
    [config setTimeoutIntervalForRequest:EX_SESSIONREQUESTTIMEOUT];
    NSURLSession * defaultSession = [NSURLSession sessionWithConfiguration:config];
    
    NSURLSessionDataTask * dataTask = [defaultSession dataTaskWithRequest:request completionHandler:^(NSData * dataReturned, NSURLResponse * reponseReturned, NSError * error){
        
        if(!error)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
               // NSLog(@"response --- %@", reponseReturned);
                //NSHTTPURLResponse *HTTPResponse = (NSHTTPURLResponse *)reponseReturned;
                //NSInteger statusCode = [HTTPResponse statusCode];
                //NSString * urlString = [[HTTPResponse URL]absoluteString];
                //NSDictionary * headers = [HTTPResponse allHeaderFields];
                //NSLog(@"Status Code %li", statusCode);
                //NSLog(@"URL %@", urlString);
                //NSLog(@"Headers %@", headers);
                NSString* newStr = [[NSString alloc] initWithData:dataReturned encoding:NSUTF8StringEncoding];
                
                //NSLog(@"STRING DATA %@", newStr);
                NSError * error1;
                NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:dataReturned options:0 error:&error1];
                //NSLog(@"For %@ Dictionary is %@", placeIdentifier, dict);
                
                if (!dict) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self userWait:NO message:EX_MESSAGE_NOTFOUND];
                    });
                }
                else{
                   
                    self.cache = dict;
                    self.cacheString = newStr;
                    [self callVC:0];
                    //[self storeFavs:placeIdentifier.uppercaseString];
                    [self storeHistory:placeIdentifier.uppercaseString];
                    [self clearWaitState];
                }
            });
        }
        else
        {
            NSLog(@"----- Error, \n** Session failed with Error %@", error);
            dispatch_async(dispatch_get_main_queue(), ^{
                [self userWait:NO message:EX_MESSAGE_TIMEDOUT];
            });
        }
        
    }];
    [dataTask resume];
}

-(NSDictionary *)dictionaryFromString:(NSString *)string{
    
    NSData * data = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSError * error1;
    return [NSJSONSerialization JSONObjectWithData:data options:0 error:&error1];
}
    
    -(NSDictionary *)returnFromEndpointWithRefreshDataFor:(NSString *)placeIdentifier{
      
        dispatch_async(dispatch_get_main_queue(),^{
            [self userWait:YES message:EX_MESSAGE_NOMESSAGE];
        });
        
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        
        NSString * urlString = [NSString stringWithFormat:@"%@/%@", EXERCISEENDPOINT_PREFIX, placeIdentifier];
        NSURL * url = [NSURL URLWithString:urlString];
        NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url];
        [request setValue:EXERCISEHEADERFIELDVALUE forHTTPHeaderField:EXERCIEHEADERFIELDNAME];
        
        NSURLSessionConfiguration * config = [NSURLSessionConfiguration defaultSessionConfiguration];
        [config setTimeoutIntervalForRequest:EX_SESSIONREQUESTTIMEOUT];
        NSURLSession * defaultSession = [NSURLSession sessionWithConfiguration:config];
        
        NSURLSessionDataTask * dataTask = [defaultSession dataTaskWithRequest:request completionHandler:^(NSData * dataReturned, NSURLResponse * reponseReturned, NSError * error){
            
            if(!error)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                   // NSLog(@"response --- %@", reponseReturned);
                    //NSHTTPURLResponse *HTTPResponse = (NSHTTPURLResponse *)reponseReturned;
                   // NSInteger statusCode = [HTTPResponse statusCode];
                    //NSString * urlString = [[HTTPResponse URL]absoluteString];
                    //NSDictionary * headers = [HTTPResponse allHeaderFields];
                   // NSLog(@"Status Code %li", statusCode);
                    //NSLog(@"URL %@", urlString);
                    //NSLog(@"Headers %@", headers);
                    NSString* newStr = [[NSString alloc] initWithData:dataReturned encoding:NSUTF8StringEncoding];
                    //NSLog(@"STRING DATA %@", newStr);
                    NSError * error1;
                    NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:dataReturned options:0 error:&error1];
                    //NSLog(@"For %@ Dictionary is %@", placeIdentifier, dict);
                    
                    if (!dict) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self userWait:NO message:EX_MESSAGE_NOTFOUND];
                        });
                    }
                    else{
                       
                        self.cache = dict;
                        self.cacheString = newStr;
                        [self clearWaitState];
                        
                        dispatch_semaphore_signal(semaphore);
                        
                        
                    }
                });
            }
            else
            {
                NSLog(@"----- Error, \n** Session failed with Error %@", error);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self userWait:NO message:EX_MESSAGE_TIMEDOUT];
                });
            }
            
        }];
        [dataTask resume];
        
        dispatch_time_t waitTime = dispatch_time(DISPATCH_TIME_NOW, 4LL * NSEC_PER_SEC);
        
        dispatch_semaphore_wait(semaphore, waitTime);
        
        return self.cache;
    }

@end

