//
//  MCSwipeTableViewCell.m
//  MCSwipeTableViewCell
//
//  Created by Ali Karagoz on 24/02/13.
//  Copyright (c) 2013 Mad Castle. All rights reserved.
//

#import "MCSwipeTableViewCell.h"
#import "TehdaLabel.h"
#import "TehdaItem.h"
#import "MasterViewController.h"

static CGFloat const kMCStop1 = 0.20; // Percentage limit to trigger the first action
static CGFloat const kMCStop2 = 0.75; // Percentage limit to trigger the second action
static CGFloat const kMCBounceAmplitude = 20.0; // Maximum bounce amplitude when using the MCSwipeTableViewCellModeSwitch mode
static NSTimeInterval const kMCBounceDuration1 = 0.2; // Duration of the first part of the bounce animation
static NSTimeInterval const kMCBounceDuration2 = 0.1; // Duration of the second part of the bounce animation
static NSTimeInterval const kMCDurationLowLimit = 0.25; // Lowest duration when swipping the cell because we try to simulate velocity
static NSTimeInterval const kMCDurationHightLimit = 0.1; // Highest duration when swipping the cell because we try to simulate velocity

@interface MCSwipeTableViewCell () <UIGestureRecognizerDelegate>
// Init
- (void)initializer;

// Handle Gestures
- (void)handlePanGestureRecognizer:(UIPanGestureRecognizer *)gesture;

// Utils
- (CGFloat)offsetWithPercentage:(CGFloat)percentage relativeToWidth:(CGFloat)width;
- (CGFloat)percentageWithOffset:(CGFloat)offset relativeToWidth:(CGFloat)width;
- (NSTimeInterval)animationDurationWithVelocity:(CGPoint)velocity;
- (MCSwipeTableViewCellDirection)directionWithPercentage:(CGFloat)percentage;
- (NSString *)imageNameWithPercentage:(CGFloat)percentage;
- (UIColor *)colorWithPercentage:(CGFloat)percentage;
- (MCSwipeTableViewCellState)stateWithPercentage:(CGFloat)percentage;
- (CGFloat)imageAlphaWithPercentage:(CGFloat)percentage;
- (BOOL)validateState:(MCSwipeTableViewCellState)state;

// Movement
- (void)slideImageWithPercentage:(CGFloat)percentage imageName:(NSString *)imageName isDragging:(BOOL)isDragging;
- (void)animateWithOffset:(CGFloat)offset;
- (void)moveWithDuration:(NSTimeInterval)duration andDirection:(MCSwipeTableViewCellDirection)direction;
- (void)bounceToOriginWithDirection:(MCSwipeTableViewCellDirection)direction;

// Delegate
- (void)notifyDelegate;

@property (nonatomic, assign) MCSwipeTableViewCellDirection direction;
@property (nonatomic, assign) CGFloat currentPercentage;

@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic, strong) UIImageView *slidingImageView;
@property (nonatomic, strong) NSString *currentImageName;
@property (nonatomic, strong) UIView *colorIndicatorView;

@end

@implementation MCSwipeTableViewCell
@synthesize itemLabel = _itemLabel;
@synthesize datButton = _datButton;


const float LABEL_LEFT_MARGIN = 15.0f;

#pragma mark - Initialization

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self)
    {
        
        [self initializer];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self)
    {
        [self initializer];
    }
    return self;
}

- (id)init
{
	self = [super init];
	
	if (self)
	{
		[self initializer];

	}
    
	return self;
}

 
#pragma mark Custom Initializer

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
 firstStateIconName:(NSString *)firstIconName
         firstColor:(UIColor *)firstColor
secondStateIconName:(NSString *)secondIconName
        secondColor:(UIColor *)secondColor
      thirdIconName:(NSString *)thirdIconName
         thirdColor:(UIColor *)thirdColor
     fourthIconName:(NSString *)fourthIconName
        fourthColor:(UIColor *)fourthColor
{
    self = [self initWithStyle:style reuseIdentifier:reuseIdentifier];

    if (self)
    {
        [self setFirstStateIconName:firstIconName
                         firstColor:firstColor
                secondStateIconName:secondIconName
                        secondColor:secondColor
                      thirdIconName:thirdIconName 
                         thirdColor:thirdColor
                     fourthIconName:fourthIconName
                        fourthColor:fourthColor];
    }
    
    return self;
}

- (void)initializer
{
    // Custom UITextField because that other shit was interfering
    _itemLabel = [[TehdaLabel alloc] initWithFrame:CGRectNull];
    
    //_itemLabel.textColor = [UIColor blackColor];
    //_itemLabel.font = [UIFont fontWithName:@"Helvetica" size:12];
    //_itemLabel.backgroundColor = [UIColor clearColor];
    //[_itemLabel setRightView:noteImage];
    _itemLabel.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _itemLabel.returnKeyType = UIReturnKeyDone;
    _itemLabel.placeholder = @"Type some stuff here!";
    //[self addSubview:_itemLabel];
    [self.contentView addSubview:_itemLabel];
    
    [self.contentView addSubview:_datButton];
    
    _mode = MCSwipeTableViewCellModeSwitch;

    _colorIndicatorView = [[UIView alloc] initWithFrame:self.bounds];
    [_colorIndicatorView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth];
    [_colorIndicatorView setBackgroundColor:[UIColor clearColor]];
    
    // Come back to this
    [self insertSubview:_colorIndicatorView belowSubview:self.contentView];
    _slidingImageView = [[UIImageView alloc] init];
    [_slidingImageView setContentMode:UIViewContentModeCenter];
    [_colorIndicatorView addSubview:_slidingImageView];
    
    _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGestureRecognizer:)];
    [self addGestureRecognizer:_panGestureRecognizer];
    [_panGestureRecognizer setDelegate:self];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    // position the label
    //_itemLabel.frame = CGRectMake(15.0f, 0, self.bounds.size.width - 15.0f, self.bounds.size.height);
    _itemLabel.frame = CGRectMake(10, 0, 270.0, self.bounds.size.height);
}

#pragma mark - Handle Gestures

- (void)handlePanGestureRecognizer:(UIPanGestureRecognizer *)gesture
{
    UIGestureRecognizerState state          = [gesture state];
    CGPoint translation                     = [gesture translationInView:self];
    CGPoint velocity                        = [gesture velocityInView:self];
    CGFloat percentage                      = [self percentageWithOffset:CGRectGetMinX(self.contentView.frame) relativeToWidth:CGRectGetWidth(self.bounds)];
    NSTimeInterval animationDuration        = [self animationDurationWithVelocity:velocity];
    _direction = [self directionWithPercentage:percentage];
    
    if (state == UIGestureRecognizerStateBegan)
    {
    }
    else if (state == UIGestureRecognizerStateBegan || state == UIGestureRecognizerStateChanged)
    {
        CGPoint center = {self.contentView.center.x + translation.x, self.contentView.center.y};
        [self.contentView setCenter:center];
        [self animateWithOffset:CGRectGetMinX(self.contentView.frame)];
        [gesture setTranslation:CGPointZero inView:self];
    }
    else if (state == UIGestureRecognizerStateEnded || state == UIGestureRecognizerStateCancelled)
    {
        _currentImageName = [self imageNameWithPercentage:percentage];
        _currentPercentage = percentage;
        MCSwipeTableViewCellState state = [self stateWithPercentage:percentage];
        
        if (_mode == MCSwipeTableViewCellModeExit && _direction != MCSwipeTableViewCellDirectionCenter && [self validateState:state])
            [self moveWithDuration:animationDuration andDirection:_direction];
        else
            [self bounceToOriginWithDirection:_direction];
    }
}


#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
	if (gestureRecognizer == _panGestureRecognizer)
    {
		UIScrollView *superview = (UIScrollView *)self.superview;
		CGPoint translation = [(UIPanGestureRecognizer *)gestureRecognizer translationInView:superview];
		
		// Make sure it is scrolling horizontally
		return ((fabs(translation.x) / fabs(translation.y) > 1) ? YES : NO && (superview.contentOffset.y == 0.0 && superview.contentOffset.x == 0.0));
	}
	return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

#pragma mark - Utils

- (CGFloat)offsetWithPercentage:(CGFloat)percentage relativeToWidth:(CGFloat)width
{
    CGFloat offset = percentage * width;
    
    if (offset < -width) offset = -width;
    else if (offset > width) offset = 1.0;
    
    return offset;
}

- (CGFloat)percentageWithOffset:(CGFloat)offset relativeToWidth:(CGFloat)width
{
    CGFloat percentage = offset / width;
    
    if (percentage < -1.0) percentage = -1.0;
    else if (percentage > 1.0) percentage = 1.0;
    
    return percentage;
}

- (NSTimeInterval)animationDurationWithVelocity:(CGPoint)velocity
{
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat animationDurationDiff = kMCDurationHightLimit - kMCDurationLowLimit;
    CGFloat horizontalVelocity = velocity.x;
    
    if (horizontalVelocity < -width) horizontalVelocity = -width;
    else if (horizontalVelocity > width) horizontalVelocity = width;
    
    return (kMCDurationHightLimit + kMCDurationLowLimit) - fabs(((horizontalVelocity  / width) * animationDurationDiff));
}

- (MCSwipeTableViewCellDirection)directionWithPercentage:(CGFloat)percentage
{
    if (percentage < -kMCStop1)
        return MCSwipeTableViewCellDirectionLeft;
    else if (percentage > kMCStop1)
        return MCSwipeTableViewCellDirectionRight;
    else
        return MCSwipeTableViewCellDirectionCenter;
}

- (NSString *)imageNameWithPercentage:(CGFloat)percentage
{
    NSString *imageName;
    
    // Image
    if (percentage >= 0 && percentage < kMCStop2)
        imageName = _firstIconName;
    else if (percentage >= kMCStop2)
        imageName = _secondIconName;
    else if (percentage < 0 && percentage > -kMCStop2)
        imageName = _thirdIconName;
    else if (percentage <= -kMCStop2)
        imageName = _fourthIconName;
    
    return imageName;
}

- (CGFloat)imageAlphaWithPercentage:(CGFloat)percentage
{
    CGFloat alpha = 0.0;
    
    if (percentage >= 0 && percentage < kMCStop1)
        alpha = percentage / kMCStop1;
    else if (percentage < 0 && percentage > -kMCStop1)
        alpha = fabsf(percentage / kMCStop1);
    else alpha = 1.0;
        
    return alpha;
}

- (UIColor *)colorWithPercentage:(CGFloat)percentage
{
    UIColor *color;
    
    // Background Color
    if (percentage >= kMCStop1 && percentage < kMCStop2)
        color = _firstColor;
    else if (percentage >= kMCStop2)
        color = _secondColor;
    else if (percentage < -kMCStop1 && percentage > -kMCStop2)
        color = _thirdColor;
    else if (percentage <= -kMCStop2)
        color = _fourthColor;
    else
        color = [UIColor clearColor];
    
    return color;
}

- (MCSwipeTableViewCellState)stateWithPercentage:(CGFloat)percentage
{
    MCSwipeTableViewCellState state;
    
    state = MCSwipeTableViewCellStateNone;
    
    if (percentage >= kMCStop1 && [self validateState:MCSwipeTableViewCellState1])
        state = MCSwipeTableViewCellState1;
    
    if (percentage >= kMCStop2 && [self validateState:MCSwipeTableViewCellState2])
        state = MCSwipeTableViewCellState2;
    
    if (percentage <= -kMCStop1 && [self validateState:MCSwipeTableViewCellState3])
        state = MCSwipeTableViewCellState3;
    
    if (percentage <= -kMCStop2 && [self validateState:MCSwipeTableViewCellState4])
        state = MCSwipeTableViewCellState4;

    return state;
}

- (BOOL)validateState:(MCSwipeTableViewCellState)state
{
    BOOL isValid = YES;
    
    switch (state)
    {
        case MCSwipeTableViewCellStateNone:
        {
            isValid = NO;
        }
        break;
            
        case MCSwipeTableViewCellState1:
        {
            if (!_firstColor && !_firstIconName)
                isValid = NO;
        }
        break;
            
        case MCSwipeTableViewCellState2:
        {
            if (!_secondColor && !_secondIconName)
                isValid = NO;
        }
        break;
            
        case MCSwipeTableViewCellState3:
        {
            if (!_thirdColor && !_thirdIconName)
                isValid = NO;
        }
        break;
            
        case MCSwipeTableViewCellState4:
        {
            if (!_fourthColor && !_fourthIconName)
                isValid = NO;
        }
        break;
            
        default:
            break;
    }
    
    return isValid;
}

#pragma mark - Movement

- (void)animateWithOffset:(CGFloat)offset
{
    CGFloat percentage = [self percentageWithOffset:offset relativeToWidth:CGRectGetWidth(self.bounds)];
    
    // Image Name
    NSString *imageName = [self imageNameWithPercentage:percentage];
    
    // Image Position
    if (imageName != nil)
    {
        [_slidingImageView setImage:[UIImage imageNamed:imageName]];
        [_slidingImageView setAlpha:[self imageAlphaWithPercentage:percentage]];
    }
    [self slideImageWithPercentage:percentage imageName:imageName isDragging:YES];
    
    // Color
    UIColor *color = [self colorWithPercentage:percentage];
    if (color != nil)
    {
        [_colorIndicatorView setBackgroundColor:color];
    }
}


- (void)slideImageWithPercentage:(CGFloat)percentage imageName:(NSString *)imageName isDragging:(BOOL)isDragging
{
    UIImage *slidingImage = [UIImage imageNamed:imageName];
    CGSize slidingImageSize = slidingImage.size;
    CGRect slidingImageRect = CGRectZero;
    
    CGPoint position = CGPointZero;
    
    position.y = CGRectGetHeight(self.bounds) / 2.0;
    
    if (isDragging)
    {
        if (percentage >= 0 && percentage < kMCStop1)
        {
            position.x = [self offsetWithPercentage:(kMCStop1 / 2) relativeToWidth:CGRectGetWidth(self.bounds)];
        }
        
        else if (percentage >= kMCStop1)
        {
            position.x = [self offsetWithPercentage:percentage - (kMCStop1 / 2) relativeToWidth:CGRectGetWidth(self.bounds)];
        }
        else if (percentage < 0 && percentage >= -kMCStop1)
        {
            position.x = CGRectGetWidth(self.bounds) - [self offsetWithPercentage:(kMCStop1 / 2) relativeToWidth:CGRectGetWidth(self.bounds)];
        }
        
        else if (percentage < -kMCStop1)
        {
            position.x = CGRectGetWidth(self.bounds) + [self offsetWithPercentage:percentage + (kMCStop1 / 2) relativeToWidth:CGRectGetWidth(self.bounds)];
        }
    }
    else
    {
        if (_direction == MCSwipeTableViewCellDirectionRight)
        {
            position.x = [self offsetWithPercentage:percentage - (kMCStop1 / 2) relativeToWidth:CGRectGetWidth(self.bounds)];
        }
        else if (_direction == MCSwipeTableViewCellDirectionLeft)
        {
            position.x = CGRectGetWidth(self.bounds) + [self offsetWithPercentage:percentage + (kMCStop1 / 2) relativeToWidth:CGRectGetWidth(self.bounds)];
        }
        else
        {
            return;
        }
    }
    
    
    slidingImageRect = CGRectMake(position.x - slidingImageSize.width / 2.0,
                                  position.y - slidingImageSize.height / 2.0,
                                  slidingImageSize.width,
                                  slidingImageSize.height);
    
    slidingImageRect = CGRectIntegral(slidingImageRect);
    [_slidingImageView setFrame:slidingImageRect];
}


- (void)moveWithDuration:(NSTimeInterval)duration andDirection:(MCSwipeTableViewCellDirection)direction
{
    CGFloat origin;

    if (direction == MCSwipeTableViewCellDirectionLeft)
        origin = -CGRectGetWidth(self.bounds);
    else
        origin = CGRectGetWidth(self.bounds);
    
    CGFloat percentage = [self percentageWithOffset:origin relativeToWidth:CGRectGetWidth(self.bounds)];
    CGRect rect = self.contentView.frame;
    rect.origin.x = origin;
    
    // Color
    UIColor *color = [self colorWithPercentage:_currentPercentage];
    if (color != nil)
    {
        [_colorIndicatorView setBackgroundColor:color];
    }
    
    // Image
    if (_currentImageName != nil)
    {
        [_slidingImageView setImage:[UIImage imageNamed:_currentImageName]];
    }
    
    [UIView animateWithDuration:duration
                          delay:0.0
                        options:(UIViewAnimationOptionCurveEaseOut|UIViewAnimationOptionAllowUserInteraction)
                     animations:^
    {
        [self.contentView setFrame:rect];
        [_slidingImageView setAlpha:0];
        [self slideImageWithPercentage:percentage imageName:_currentImageName isDragging:NO];
    }
    completion:^(BOOL finished)
    {
        [self notifyDelegate];
    }];
}

- (void)bounceToOriginWithDirection:(MCSwipeTableViewCellDirection)direction
{
    CGFloat bounceDistance = kMCBounceAmplitude * _currentPercentage;
    
    [UIView animateWithDuration:kMCBounceDuration1
						  delay:0
						options:(UIViewAnimationOptionCurveEaseOut)
					 animations:^{
                         CGRect frame = self.contentView.frame;
                         frame.origin.x = -bounceDistance;
                         [self.contentView setFrame:frame];
                         [_slidingImageView setAlpha:0.0];
                         [self slideImageWithPercentage:0 imageName:_currentImageName isDragging:NO];
                     }
					 completion:^(BOOL finished) {
                         
						 [UIView animateWithDuration:kMCBounceDuration2
                                               delay:0
											 options:UIViewAnimationOptionCurveEaseIn
										  animations:^{
                                              CGRect frame = self.contentView.frame;
                                              frame.origin.x = 0;
                                              [self.contentView setFrame:frame];
                                          }
										  completion:^(BOOL finished){
                                              [self notifyDelegate];
                                          }];
                     }];
}

#pragma mark - Delegate Notification

- (void)notifyDelegate
{
    MCSwipeTableViewCellState state = [self stateWithPercentage:_currentPercentage];
    
    if (state != MCSwipeTableViewCellStateNone)
    {
        if (_delegate != nil && [_delegate respondsToSelector:@selector(swipeTableViewCell:didTriggerState:withMode:)])
        {
            [_delegate swipeTableViewCell:self didTriggerState:state withMode:_mode];
        }
    }
}

#pragma mark - Setter

- (void)setFirstStateIconName:(NSString *)firstIconName
                   firstColor:(UIColor *)firstColor
          secondStateIconName:(NSString *)secondIconName
                  secondColor:(UIColor *)secondColor
                thirdIconName:(NSString *)thirdIconName
                   thirdColor:(UIColor *)thirdColor
               fourthIconName:(NSString *)fourthIconName
                  fourthColor:(UIColor *)fourthColor
{
    [self setFirstIconName:firstIconName];
    [self setSecondIconName:secondIconName];
    [self setThirdIconName:thirdIconName];
    [self setFourthIconName:fourthIconName];
    
    [self setFirstColor:firstColor];
    [self setSecondColor:secondColor];
    [self setThirdColor:thirdColor];
    [self setFourthColor:fourthColor];
}

@end