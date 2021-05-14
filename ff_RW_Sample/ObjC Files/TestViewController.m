//
//  TestViewController.m
//  ff_RW_Sample
//
//  Created by Rube Williams on 4/13/21.
//

#import "TestViewController.h"

@interface TestViewController () <UITextFieldDelegate>

@property (nonatomic, strong)   UITextField * entryTextField;
@property (nonatomic, strong)   UIButton    * testButton;
@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor greenColor];
    
   // [self establishViews];
}

-(UITextField *) entryTextField{
    if(!_entryTextField){
        __weak TestViewController * weakSelf = self;
        _entryTextField = [UITextField new];
        _entryTextField.delegate = weakSelf;
        _entryTextField.textAlignment = UIListContentTextAlignmentCenter;
    }
    return _entryTextField;
}

-(UIButton *) testButton{
    if(!_testButton){
        _testButton = [UIButton new];
        [_testButton addTarget:self action:@selector(toggleViewColor:) forControlEvents:UIControlEventTouchUpInside];
        _testButton.backgroundColor = [UIColor blueColor];
        [_testButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_testButton setTitle:@"CHANGE" forState:UIControlStateNormal];
    }
    return _testButton;
}

-(void)establishViews{
    
    UIView * mainView = [UIView new];
    mainView.translatesAutoresizingMaskIntoConstraints = NO;
    mainView.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:mainView];
    
    [NSLayoutConstraint activateConstraints:[NSArray arrayWithObjects:
                                              [NSLayoutConstraint constraintWithItem:mainView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view.safeAreaLayoutGuide attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0],
                                              
                                              [NSLayoutConstraint constraintWithItem:mainView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1.0 constant:0],
                                              
                                              [NSLayoutConstraint constraintWithItem:mainView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view.safeAreaLayoutGuide attribute:NSLayoutAttributeTop multiplier:1.0 constant:0],
                                              
                                              [NSLayoutConstraint constraintWithItem:mainView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view.safeAreaLayoutGuide attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0],
                                              
                                              
                                              nil]];
    
    UIView * textEntryViewContainer = [UIView new];
    textEntryViewContainer.translatesAutoresizingMaskIntoConstraints = NO;
    textEntryViewContainer.backgroundColor = [UIColor lightGrayColor];
    
    [mainView addSubview:textEntryViewContainer];
    
    
    [NSLayoutConstraint constraintWithItem:textEntryViewContainer attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:180.].active = YES;
    
    [NSLayoutConstraint constraintWithItem:textEntryViewContainer attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:60.].active = YES;
    
    [NSLayoutConstraint constraintWithItem:textEntryViewContainer attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:mainView attribute:NSLayoutAttributeTop multiplier:1.0 constant:10.0].active = YES;
    
    [NSLayoutConstraint constraintWithItem:textEntryViewContainer attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:mainView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0].active = YES;
    
    
    self.entryTextField.translatesAutoresizingMaskIntoConstraints = NO;
    
    [textEntryViewContainer addSubview:self.entryTextField];
    
    [NSLayoutConstraint constraintWithItem:self.entryTextField attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:120.].active = YES;
    
    [NSLayoutConstraint constraintWithItem:self.entryTextField attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:40.].active = YES;
    
    [NSLayoutConstraint constraintWithItem:self.entryTextField attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:textEntryViewContainer attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:10.0].active = YES;
    
    [NSLayoutConstraint constraintWithItem:self.entryTextField attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:textEntryViewContainer attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0].active = YES;
    
    
    
    self.testButton.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.view addSubview:self.testButton];
    
    [NSLayoutConstraint constraintWithItem:self.testButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:100.].active = YES;
    
    [NSLayoutConstraint constraintWithItem:self.testButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:40.].active = YES;
    
    [NSLayoutConstraint constraintWithItem:self.testButton attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:textEntryViewContainer attribute:NSLayoutAttributeBottom multiplier:1.0 constant:40.0].active = YES;
    
    [NSLayoutConstraint constraintWithItem:self.testButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0].active = YES;
    
}

-(void)toggleViewColor:(UIButton *)sender{
    sender.selected = !sender.selected;
    
    if(sender.selected){
        self.view.backgroundColor = [UIColor cyanColor];
    }
    else{
        self.view.backgroundColor = [UIColor greenColor];
    }
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
