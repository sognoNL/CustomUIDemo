//
//  YXSelectSheet.m
//  ECP4iPhone
//
//  Created by wmq-mac on 13-4-9.
//  Copyright (c) 2013年 jtang.com.cn. All rights reserved.
//

#import "YXSelectSheet.h"
#import "YXDefine.h"

#define kItemHeight 35
#define kPointWidth 156
#define kPointHeight 35
#define kLimitItem  4
#define deviceW  [UIScreen mainScreen].bounds.size.width

@interface SelectSheetItem : UIButton

@end
@implementation SelectSheetItem

@end


@interface YXSelectSheet ()
@property (nonatomic, strong) UIScrollView *mScrollView;
@property (nonatomic, strong) UIView *mBgView;

@property (nonatomic, assign) CGRect mGframe;
@property (nonatomic, strong) CALayer *mLayerPoint;
@property (nonatomic, assign) NSUInteger mLastIndex;
@end

@implementation YXSelectSheet

- (id)initWithTitle:(NSString *)title delegate:(id<YXSelectSheetDelegate>)delegate buttonTitles:(NSArray *)buttons
{
    self = [super initWithFrame:CGRectZero];
    if (self)
    {
        // Initialization code
        _mLastIndex = 0;
        _selectIndex = 0;
        _delegate = delegate;
        _mButtons = buttons;

        [self _loadItemView];
    }

    return self;
}

- (void)drawRect:(CGRect)rect
{
}

- (void)_loadItemView
{
    // 灰色背景
    _mBgView = [[UIView alloc] init];
    _mBgView.backgroundColor = [UIColor clearColor];
//    _bgView.alpha = 0.5f;

    // 背景添加取消手势
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]
                                          initWithTarget:self
                                          action:@selector(_cancelButtonPressed:)];
    [_mBgView addGestureRecognizer:tapGesture];

//    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    self.layer.cornerRadius = 5.0;
    _mScrollView = [[UIScrollView alloc] init];
    // 选中蓝点
    _mLayerPoint = [CALayer layer];
//    _mLayerPoint.contents = (id)[[UIImage imageNamed:@"jtSelectItemBg.png"] CGImage];
    [_mScrollView.layer addSublayer:_mLayerPoint];
    _mScrollView.showsVerticalScrollIndicator = NO;
   // [self addSubview:_scrollView];

    // 添加成员
    [self _loadButtonsPanel];
}

- (void)_loadButtonsPanel
{
    int n = 0;
    for (NSString *title in _mButtons)
    {
        SelectSheetItem *button = [SelectSheetItem buttonWithType:UIButtonTypeCustom];
        button.titleLabel.font = [UIFont systemFontOfSize:18];
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button setTitleColor:UIColorWithHex(0x00B48C) forState:UIControlStateHighlighted];
        [button setImage:[UIImage imageNamed:@"selectImg"] forState:UIControlStateNormal];
        [button setImageEdgeInsets:UIEdgeInsetsMake(2,0, 2, 2)];
        [button setTitle:title forState:UIControlStateNormal];
        button.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        [button setFrame:CGRectMake((deviceW -160)/2.0, n*kItemHeight + 4, 160, kItemHeight)];
        button.tag = n++;
        [_mScrollView addSubview:button];
        [button setNeedsDisplay];

        [button addTarget:self action:@selector(_buttonsTouchUp:) forControlEvents:UIControlEventTouchUpInside];
    }

    _mScrollView.contentSize = CGSizeMake(160, [_mButtons count]*kItemHeight);
}


#pragma mark - action
- (void)showInView:(UIView *)view
{
    if (self.frame.origin.y == -8 && self.frame.size.height != 0)
    {
        [self actionSheetAnimation:YES];
        return;
    }

    self.mGframe = view.bounds;

    // 灰色透明背景
    [self.mBgView setFrame:self.mGframe];
    [view addSubview:self.mBgView];
    NSUInteger itemCount = [self.mButtons count];
    CGFloat sh = 0.5f;
    if (itemCount > kLimitItem)
    {
        sh = kLimitItem*kItemHeight + kItemHeight/2;
        self.mScrollView.scrollEnabled = YES;
    }
    else
    {
        sh = itemCount*kItemHeight + kItemHeight/2;
        self.mScrollView.scrollEnabled = NO;
    }

    // 设置界面元素位置
    
    self.frame = CGRectMake(0, -(kItemHeight *4), deviceW, sh);
    self.mScrollView.frame = CGRectMake(0, 8, deviceW, kItemHeight *4+10);
    //设置view的背景色
    self.mScrollView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.9];
    [self.mLayerPoint setFrame:CGRectMake(0, -5, kPointWidth, kPointHeight)];

    UIImageView *bgView = [[UIImageView alloc] initWithFrame:self.bounds];
    UIImage *image = [UIImage imageNamed:@"jtSelectActionBg.png"];
    bgView.image = [image stretchableImageWithLeftCapWidth:0 topCapHeight:16];
    [self addSubview:bgView];
    [self addSubview:self.mScrollView];

    self.alpha = 1.0;
    [view addSubview:self];

    // 显示动画
    [self actionSheetAnimation:NO];
}


- (void)actionSheetAnimation:(BOOL)hide
{
    CGRect tframe = self.frame;

    if (hide)
    {
        [UIView beginAnimations:@"actionSheet.remove" context:nil];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(_exit)];

        self.mBgView.alpha = 0.0f;
        self.frame = CGRectMake(0, -(kItemHeight * 4)+8, tframe.size.width,tframe.size.height);

        [UIView commitAnimations];
    }
    else
    {
        [UIView beginAnimations:@"actionSheet.load" context:nil];

        self.mBgView.alpha = 0.5f;
        self.frame = CGRectMake(0, 0-8, tframe.size.width,tframe.size.height);
        [UIView commitAnimations];
    }
    [self _titleBtnDrop:!hide];
}

- (void)_exit
{
    [self.mBgView removeFromSuperview];
    [self removeFromSuperview];
}

- (void)_titleBtnDrop:(BOOL)isDrop
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(titleBtnDrop:)])
    {
        [self.delegate titleBtnDrop:isDrop];
    }
}

- (void)_touchOfIndex
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(selectSheet:clickedButtonAtIndex:)])
    {
        [self.delegate selectSheet:self clickedButtonAtIndex:(_selectIndex)];
    }

    // 退出动画
    [self actionSheetAnimation:YES];
}

- (int)_indexTouchOfPoint:(CGPoint)point
{
    return point.y/kItemHeight;
}

- (void)setSelectIndex:(NSUInteger)selectIndex
{
    _selectIndex = selectIndex;

    self.userInteractionEnabled = NO;
    CGFloat offy = self.selectIndex*kItemHeight;

    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        self.userInteractionEnabled = YES;
    }];

    CGFloat rectY = offy + (kItemHeight - kPointHeight) / 2 + 3;
    [self.mLayerPoint setFrame:CGRectMake(5, rectY, kPointWidth, kPointHeight)];

    [CATransaction commit];


    UIButton *lastLabel = self.mScrollView.subviews[self.mLastIndex];
    [lastLabel setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [lastLabel setHighlighted:NO];

    UIButton *label = self.mScrollView.subviews[self.selectIndex];
    [label setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [label setHighlighted:YES];

    self.mLastIndex = self.selectIndex;
}

#pragma mark - Buttons
- (void)_buttonsTouchDown:(SelectSheetItem *)sender
{
}

- (void)_buttonsTouchUp:(SelectSheetItem *)sender
{
    self.selectIndex = sender.tag;
    [self performSelector:@selector(_touchOfIndex) withObject:nil afterDelay:0.2f];
}

- (void)_cancelButtonPressed:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(actionSheetCancel:)])
    {
        [self.delegate selectSheetCancel:self];
    }

    // 退出动画
    [self actionSheetAnimation:YES];
}

@end
