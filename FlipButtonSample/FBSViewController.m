
#import "FBSViewController.h"

@interface FBSViewController ()

@property (strong, nonatomic) UIView *frontView;
@property (strong, nonatomic) UIView *backView;

@end

@implementation FBSViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setup];
}


/**
 *  アニメーションのトグル
 */
- (void)toggle:(id)sender
{
    static BOOL toggleFlg = NO;

    [CATransaction begin];
    
	CATransform3D toFrontTransform = CATransform3DMakeRotation(M_PI * 2, 1.0, 0.0, 0.0);
	CATransform3D toBackTransform  = CATransform3DMakeRotation(M_PI,     1.0, 0.0, 0.0);
	
	// BasicAnimationを開始
	CABasicAnimation *toFrontAnim = [CABasicAnimation animationWithKeyPath:@"transform"];
	CABasicAnimation *toBackAnim  = [CABasicAnimation animationWithKeyPath:@"transform"];
    
	// アニメーション終了後の状態を維持
	toFrontAnim.removedOnCompletion = NO;
	toFrontAnim.fillMode            = kCAFillModeForwards;
	toBackAnim.removedOnCompletion  = NO;
	toBackAnim.fillMode             = kCAFillModeForwards;
    
    static const CFTimeInterval duration = 0.5;
    
	toFrontAnim.toValue   = [NSNumber valueWithCATransform3D:toFrontTransform];
	toFrontAnim.duration  = duration;
    
	toBackAnim.toValue    = [NSNumber valueWithCATransform3D:toBackTransform];
	toBackAnim.duration   = duration;
    
	// アニメーション終了時の処理
    [CATransaction setCompletionBlock:^{
        // アニメーション後の状態を設定
        if (toggleFlg) {
            self.frontView.layer.transform = CATransform3DMakeRotation(M_PI, 1.0, 0.0, 0);
            self.backView.layer.transform  = CATransform3DMakeRotation(0,    1.0, 0.0, 0);
            self.frontView.hidden = YES;
        }
        else {
            self.frontView.layer.transform = CATransform3DMakeRotation(0,    1.0, 0.0, 0);
            self.backView.layer.transform  = CATransform3DMakeRotation(M_PI, 1.0, 0.0, 0);
            self.backView.hidden = YES;
        }
    }];
    
    self.frontView.hidden = NO;
    self.backView.hidden  = NO;
    
    if ((toggleFlg = !toggleFlg)) {
        [self.frontView.layer addAnimation:toBackAnim  forKey:@"toBack"];
        [self.backView.layer  addAnimation:toFrontAnim forKey:@"toFront"];
    }
    else {
        [self.frontView.layer addAnimation:toFrontAnim forKey:@"toBack"];
        [self.backView.layer  addAnimation:toBackAnim  forKey:@"toFront"];
    }
    
    
    // アニメーションをコミット
	[CATransaction commit];
}


/**
 *  Viewのセットアップ
 */
- (void)setup
{
    CGRect viewFrame = CGRectMake(0, 100, self.view.bounds.size.width, 44);
    CGRect btnFrame = CGRectMake(0, 0, viewFrame.size.width, viewFrame.size.height);
    
    // フリップするふたつのビューを生成
	self.frontView = [[UIView alloc] initWithFrame:viewFrame];
	self.frontView.backgroundColor   = [UIColor redColor];
    self.frontView.layer.doubleSided = NO; // 背面をレンダリングしない
    
	self.backView = [[UIView alloc] initWithFrame:viewFrame];
	self.backView.backgroundColor   = [UIColor blueColor];
    self.backView.layer.doubleSided = NO; // 背面をレンダリングしない
    self.backView.layer.transform   = CATransform3DMakeRotation(M_PI, 1.0, 0.0, 0); // X軸に対して180度回転
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = btnFrame;
    [backBtn setTitle:@"フリップ" forState:UIControlStateNormal];
    [backBtn addTarget:self
                action:@selector(toggle:)
  forControlEvents:UIControlEventTouchUpInside];
    [self.backView addSubview:backBtn];
    
    UIButton *frontBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    frontBtn.frame = btnFrame;
    [frontBtn setTitle:@"フリップ" forState:UIControlStateNormal];
    [frontBtn addTarget:self
                 action:@selector(toggle:)
  forControlEvents:UIControlEventTouchUpInside];
    [self.frontView addSubview:frontBtn];

    // ビューを追加
	[self.view addSubview:self.backView];
	[self.view addSubview:self.frontView];
    
    
	// パースペクティブを設定
	CATransform3D perspective = CATransform3DIdentity; //Identityは3Dマトリクスの初期値。数字で言えば`1`と同じ。演算しても結果が変わらない
	perspective.m34 = 1.0 / 1000;
	self.view.layer.sublayerTransform = perspective;
}

@end
