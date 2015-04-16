//
//  YXSelectSheet.h
//  ECP4iPhone
//
//  Created by wmq-mac on 13-4-9.
//  Copyright (c) 2013年 jtang.com.cn. All rights reserved.
//

#import <UIKit/UIKit.h>
/// 联系人选择器选择分组控件
@class YXSelectSheet;

@protocol YXSelectSheetDelegate <NSObject>
@optional

/// 选中
- (void)selectSheet:(YXSelectSheet *)selectSheet clickedButtonAtIndex:(NSInteger)buttonIndex;

/// 取消选择上
- (void)selectSheetCancel:(YXSelectSheet *)selectSheet;

/// 通过回调控制小箭头
- (void)titleBtnDrop:(BOOL)isDrop;
@end

/// 添加联系人选择器选择分组控件
@interface YXSelectSheet : UIView
/// 委托
@property (nonatomic, assign) id<YXSelectSheetDelegate> delegate;

/// 选中索引
@property (nonatomic, assign) NSUInteger selectIndex;

@property (nonatomic, strong) NSArray *mButtons;

/// 初始化
- (id)initWithTitle:(NSString *)title
           delegate:(id<YXSelectSheetDelegate>)delegate
       buttonTitles:(NSArray *)buttons;

/// 显示
- (void)showInView:(UIView *)view;
/// 隐藏
- (void)actionSheetAnimation:(BOOL)hide;
@end
