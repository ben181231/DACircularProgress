//
//  DACircularProgressView.m
//  DACircularProgress
//
//  Created by Daniel Amitay on 2/6/12.
//  Copyright (c) 2012 Daniel Amitay. All rights reserved.
//

#import "DACircularProgressView.h"

#import <QuartzCore/QuartzCore.h>

@interface DACircularProgressLayer : CALayer

@property(nonatomic, strong) UIColor *trackTintColor;
@property(nonatomic, strong) UIColor *progressTintColor;
@property(nonatomic) NSInteger roundedCorners;
@property(nonatomic) CGFloat thicknessRatio;
@property(nonatomic) CGFloat progress;
@property(nonatomic) NSInteger clockwiseProgress;
@property(nonatomic) CGFloat rotationInDegree;
@property(nonatomic) CGPoint centerPoint;
@property(nonatomic) CGPoint startPoint;
@property(nonatomic) CGPoint endPoint;

@end

@implementation DACircularProgressLayer

@dynamic trackTintColor;
@dynamic progressTintColor;
@dynamic roundedCorners;
@dynamic thicknessRatio;
@dynamic progress;
@dynamic clockwiseProgress;


+ (BOOL)needsDisplayForKey:(NSString *)key
{
    if ([key isEqualToString:@"progress"]) {
        return YES;
    } else {
        return [super needsDisplayForKey:key];
    }
}

- (void)drawInContext:(CGContextRef)context
{
    CGRect rect = self.bounds;
    CGFloat minSide = MIN(rect.size.height, rect.size.width);
    CGPoint centerPoint = self.centerPoint = CGPointMake(minSide/ 2.0f, minSide / 2.0f);
    CGFloat radius = minSide / 2.0f;
    
    BOOL clockwise = (self.clockwiseProgress != 0);
    
    CGFloat progress = MIN(self.progress, 1.0f - FLT_EPSILON);
    if(self.roundedCorners){
        progress = MAX(FLT_EPSILON, progress);
    }

    CGFloat radians = 0;
    if (clockwise)
    {
        radians = (float)((progress * 2.0f * M_PI) - M_PI_2);
    }
    else
    {
        radians = (float)(3 * M_PI_2 - (progress * 2.0f * M_PI));
    }
    
    CGFloat rotation = 0.0f;
    if(self.rotationInDegree > 0.0f){
        rotation = self.rotationInDegree / 180.0 * M_PI;
        radians += rotation;

        if(radians > 2 * M_PI){
            radians -= 2 * M_PI;
        }
    }

    CGContextSetFillColorWithColor(context, self.trackTintColor.CGColor);
    CGMutablePathRef trackPath = CGPathCreateMutable();
    CGPathMoveToPoint(trackPath, NULL, centerPoint.x, centerPoint.y);
    CGPathAddArc(trackPath, NULL, centerPoint.x, centerPoint.y, radius, (float)(2.0f * M_PI), 0.0f, TRUE);
    CGPathCloseSubpath(trackPath);
    CGContextAddPath(context, trackPath);
    CGContextFillPath(context);
    CGPathRelease(trackPath);
    
    if (progress > 0.0f) {
        CGContextSetFillColorWithColor(context, self.progressTintColor.CGColor);
        CGMutablePathRef progressPath = CGPathCreateMutable();
        CGPathMoveToPoint(progressPath, NULL, centerPoint.x, centerPoint.y);
        CGPathAddArc(progressPath, NULL, centerPoint.x, centerPoint.y, radius, (float)(3.0f * M_PI_2) + rotation, radians, !clockwise);
        CGPathCloseSubpath(progressPath);
        CGContextAddPath(context, progressPath);
        CGContextFillPath(context);
        CGPathRelease(progressPath);
    }

    CGFloat startXOffset =
        radius * (1.0f + ((1.0f - (self.thicknessRatio / 2.0f)) * cosf(rotation-M_PI_2)));
    CGFloat startYOffset =
        radius * (1.0f + ((1.0f - (self.thicknessRatio / 2.0f)) * sinf(rotation-M_PI_2)));
    CGFloat endXOffset =
        radius * (1.0f + ((1.0f - (self.thicknessRatio / 2.0f)) * cosf(radians)));
    CGFloat endYOffset =
        radius * (1.0f + ((1.0f - (self.thicknessRatio / 2.0f)) * sinf(radians)));

    self.startPoint = CGPointMake(startXOffset, startYOffset);
    self.endPoint = CGPointMake(endXOffset, endYOffset);

    if (self.roundedCorners) {
        CGFloat pathWidth = radius * self.thicknessRatio;

        if(ABS(progress) == FLT_EPSILON){
            pathWidth /= 2.0f;
        }

        CGRect startEllipseRect = (CGRect) {
            .origin.x = self.startPoint.x - pathWidth / 2.0f,
            .origin.y = self.startPoint.y - pathWidth / 2.0f,
            .size.width = pathWidth,
            .size.height = pathWidth
        };
        CGContextAddEllipseInRect(context, startEllipseRect);
        CGContextFillPath(context);
        
        CGRect endEllipseRect = (CGRect) {
            .origin.x = self.endPoint.x - pathWidth / 2.0f,
            .origin.y = self.endPoint.y - pathWidth / 2.0f,
            .size.width = pathWidth,
            .size.height = pathWidth
        };
        CGContextAddEllipseInRect(context, endEllipseRect);
        CGContextFillPath(context);
    }
    
    CGContextSetBlendMode(context, kCGBlendModeClear);
    CGFloat innerRadius = radius * (1.0f - self.thicknessRatio);
    CGRect clearRect = (CGRect) {
        .origin.x = centerPoint.x - innerRadius,
        .origin.y = centerPoint.y - innerRadius,
        .size.width = innerRadius * 2.0f,
        .size.height = innerRadius * 2.0f
    };
    CGContextAddEllipseInRect(context, clearRect);
    CGContextFillPath(context);
}

@end

@interface DACircularProgressView ()

@end

@implementation DACircularProgressView

+ (void) initialize
{
    if (self == [DACircularProgressView class]) {
        DACircularProgressView *circularProgressViewAppearance = [DACircularProgressView appearance];
        [circularProgressViewAppearance setTrackTintColor:[[UIColor whiteColor] colorWithAlphaComponent:0.3f]];
        [circularProgressViewAppearance setProgressTintColor:[UIColor whiteColor]];
        [circularProgressViewAppearance setBackgroundColor:[UIColor clearColor]];
        [circularProgressViewAppearance setThicknessRatio:0.3f];
        [circularProgressViewAppearance setRoundedCorners:NO];
        [circularProgressViewAppearance setClockwiseProgress:YES];
        
        [circularProgressViewAppearance setIndeterminateDuration:2.0f];
        [circularProgressViewAppearance setIndeterminate:NO];
    }
}

+ (Class)layerClass
{
    return [DACircularProgressLayer class];
}

- (DACircularProgressLayer *)circularProgressLayer
{
    return (DACircularProgressLayer *)self.layer;
}

- (id)init
{
    return [super initWithFrame:CGRectMake(0.0f, 0.0f, 40.0f, 40.0f)];
}

- (void)didMoveToWindow
{
    CGFloat windowContentsScale = self.window.screen.scale;
    self.circularProgressLayer.contentsScale = windowContentsScale;
    [self.circularProgressLayer setNeedsDisplay];
}

- (CGPoint)centerPoint{
    return [self circularProgressLayer].centerPoint;
}

- (CGPoint)startPoint{
    return [self circularProgressLayer].startPoint;
}

- (CGPoint)endPoint{
    return [self circularProgressLayer].endPoint;
}

#pragma mark - Progress

- (CGFloat)progress
{
    return self.circularProgressLayer.progress;
}

- (void)setProgress:(CGFloat)progress
{
    [self setProgress:progress animated:NO];
}

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated
{
    [self setProgress:progress animated:animated initialDelay:0.0];
}

- (void)setProgress:(CGFloat)progress
           animated:(BOOL)animated
       initialDelay:(CFTimeInterval)initialDelay
{
    [self.layer removeAnimationForKey:@"indeterminateAnimation"];
    [self.circularProgressLayer removeAnimationForKey:@"progress"];
    
    CGFloat pinnedProgress = MIN(MAX(progress, 0.0f), 1.0f);
    if (animated) {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"progress"];
        animation.duration = fabsf(self.progress - pinnedProgress); // Same duration as UIProgressView animation
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        animation.fillMode = kCAFillModeForwards;
        animation.fromValue = [NSNumber numberWithFloat:self.progress];
        animation.toValue = [NSNumber numberWithFloat:pinnedProgress];
        animation.beginTime = CACurrentMediaTime() + initialDelay;
        animation.delegate = self;
        [self.circularProgressLayer addAnimation:animation forKey:@"progress"];
    } else {
        [self.circularProgressLayer setNeedsDisplay];
        self.circularProgressLayer.progress = pinnedProgress;
    }
}

- (void)animationDidStop:(CAAnimation *)animation finished:(BOOL)flag
{
   NSNumber *pinnedProgressNumber = [animation valueForKey:@"toValue"];
   self.circularProgressLayer.progress = [pinnedProgressNumber floatValue];
}

// helper function
static CGFloat angleForVector(const CGVector vect)
{
    CGVector vectMutable = vect;
    if (ABS(vectMutable.dx) < FLT_EPSILON) {
        vectMutable.dx = vectMutable.dx < 0 ? -FLT_EPSILON : FLT_EPSILON;
    }

    if (ABS(vectMutable.dy) < FLT_EPSILON) {
        vectMutable.dy = vectMutable.dy < 0 ? -FLT_EPSILON : FLT_EPSILON;
    }

    CGFloat result = atan2f(vectMutable.dx, vectMutable.dy);

    return ABS(result) < FLT_EPSILON ? 0 : result;
}

// override
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    CGFloat radius = MIN(self.frame.size.width, self.frame.size.height) / 2.0f;
    CGFloat innerRingRadius = radius * (1 - self.thicknessRatio);
    CGPoint centerPoint = self.circularProgressLayer.centerPoint;
    CGPoint startPoint = self.circularProgressLayer.startPoint;
    CGPoint endPoint = self.circularProgressLayer.endPoint;

    CGFloat centerDistance = hypotf(point.x - centerPoint.x, point.y - centerPoint.y);
    if(centerDistance > radius){
        return nil;
    }

    if(centerDistance < innerRingRadius){
        return nil;
    }

    CGFloat startAngle = angleForVector((CGVector){centerPoint.x - startPoint.x,
                                                   centerPoint.y - startPoint.y});
    CGFloat endAngle = angleForVector((CGVector){centerPoint.x - endPoint.x,
                                                 centerPoint.y - endPoint.y});
    CGFloat currentAngle = angleForVector((CGVector){centerPoint.x - point.x,
                                                     centerPoint.y - point.y});

    startAngle -= self.rotationInDegree/180.0f*M_PI;
    endAngle -= self.rotationInDegree/180.0f*M_PI;
    currentAngle -= self.rotationInDegree/180.0f*M_PI;

    if(self.clockwiseProgress) {
        startAngle = M_PI * 2 - startAngle;
        endAngle = M_PI * 2 - endAngle;
        currentAngle = M_PI * 2 - currentAngle;
    }

    while (startAngle < 0) startAngle += M_PI * 2;
    while (endAngle < 0) endAngle += M_PI * 2;
    while (currentAngle < 0) currentAngle += M_PI * 2;

    while (startAngle > M_PI * 2) startAngle -= M_PI * 2;
    while (endAngle > M_PI * 2) endAngle -= M_PI * 2;
    while (currentAngle > M_PI * 2) currentAngle -= M_PI * 2;

    if(startAngle < currentAngle && currentAngle < endAngle){
        return self;
    }
    else{
        return nil;
    }
}

#pragma mark - UIAppearance methods

- (UIColor *)trackTintColor
{
    return self.circularProgressLayer.trackTintColor;
}

- (void)setTrackTintColor:(UIColor *)trackTintColor
{
    self.circularProgressLayer.trackTintColor = trackTintColor;
    [self.circularProgressLayer setNeedsDisplay];
}

- (UIColor *)progressTintColor
{
    return self.circularProgressLayer.progressTintColor;
}

- (void)setProgressTintColor:(UIColor *)progressTintColor
{
    self.circularProgressLayer.progressTintColor = progressTintColor;
    [self.circularProgressLayer setNeedsDisplay];
}

- (NSInteger)roundedCorners
{
    return self.roundedCorners;
}

- (void)setRoundedCorners:(NSInteger)roundedCorners
{
    self.circularProgressLayer.roundedCorners = roundedCorners;
    [self.circularProgressLayer setNeedsDisplay];
}

- (CGFloat)thicknessRatio
{
    return self.circularProgressLayer.thicknessRatio;
}

- (void)setThicknessRatio:(CGFloat)thicknessRatio
{
    self.circularProgressLayer.thicknessRatio = MIN(MAX(thicknessRatio, 0.f), 1.f);
    [self.circularProgressLayer setNeedsDisplay];
}

- (NSInteger)indeterminate
{
    CAAnimation *spinAnimation = [self.layer animationForKey:@"indeterminateAnimation"];
    return (spinAnimation == nil ? 0 : 1);
}

- (void)setIndeterminate:(NSInteger)indeterminate
{
    if (indeterminate) {
        if (!self.indeterminate) {
            CABasicAnimation *spinAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
            spinAnimation.byValue = [NSNumber numberWithDouble:indeterminate > 0 ? 2.0f*M_PI : -2.0f*M_PI];
            spinAnimation.duration = self.indeterminateDuration;
            spinAnimation.repeatCount = HUGE_VALF;
            [self.layer addAnimation:spinAnimation forKey:@"indeterminateAnimation"];
        }
    } else {
        [self.layer removeAnimationForKey:@"indeterminateAnimation"];
    }
}

- (CGFloat)rotationInDegree
{
    return self.circularProgressLayer.rotationInDegree;
}

- (void)setRotationInDegree:(CGFloat)rotationInDegree
{
    self.circularProgressLayer.rotationInDegree = rotationInDegree;
    [self.circularProgressLayer setNeedsDisplay];
}

- (NSInteger)clockwiseProgress
{
    return self.circularProgressLayer.clockwiseProgress;
}

- (void)setClockwiseProgress:(NSInteger)clockwiseProgres
{
    self.circularProgressLayer.clockwiseProgress = clockwiseProgres;
    [self.circularProgressLayer setNeedsDisplay];
}

@end
