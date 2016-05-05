//
//  ZLMainViewController.m
//  ZLNetEase
//
//  Created by apple on 16/4/29.
//  Copyright © 2016年 ANGELEN. All rights reserved.
//

#import "ZLMainViewController.h"
#import "ZLContentTableViewController.h"
#import "ZLTitleLabel.h"

#define WW [UIScreen mainScreen].bounds.size.width
#define HH [UIScreen mainScreen].bounds.size.height

static CGFloat const kTitleScrollViewHeight = 40;
static CGFloat const kIndicatorViewHeight = 2;

@interface ZLMainViewController ()<UIScrollViewDelegate>

@property (nonatomic, strong) UIView *titleView;
@property (nonatomic, strong) UIScrollView *contentScrollView;
@property (nonatomic, strong) UIView *indicatorView;
@property (nonatomic, strong) NSArray *titleList;

@property (nonatomic, strong) ZLContentTableViewController *contentTVC;

@end

@implementation ZLMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"伪网易新闻";
    self.titleList = @[@[@"首页", @"http://angelen.me/app/"],
                       @[@"通讯录", @"http://www.jianshu.com/p/16fa56eacb5e"],
                       @[@"朋友圈", @"http://www.jianshu.com/p/ea4dfb803391"],
                       @[@"我的", @"http://angelen.me/app/"]];
        
    // iOS 7.0 above
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = NO;
    
    self.titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WW, kTitleScrollViewHeight)];
    self.titleView.backgroundColor = [UIColor greenColor];
    [self.view addSubview:self.titleView];
    
    self.indicatorView = [[UIView alloc] initWithFrame:CGRectMake(0, kTitleScrollViewHeight - kIndicatorViewHeight, WW / self.titleList.count, kIndicatorViewHeight)];
    self.indicatorView.backgroundColor = [UIColor redColor];
    [self.view addSubview:self.indicatorView];
    
    self.contentScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 40, WW, [UIScreen mainScreen].bounds.size.height - kTitleScrollViewHeight - 44 - 20)];
    self.contentScrollView.scrollsToTop = NO;
    self.contentScrollView.delegate = self;
    [self.view addSubview:self.contentScrollView];
    
    [self addContentViewControllers];
    [self addTitles];
    
    CGFloat contentX = self.childViewControllers.count * [UIScreen mainScreen].bounds.size.width;
    self.contentScrollView.contentSize = CGSizeMake(contentX, 0);
    self.contentScrollView.pagingEnabled = YES;
    
    // 添加默认控制器
    UIViewController *vc = [self.childViewControllers firstObject];
    vc.view.frame = self.contentScrollView.bounds;
    [self.contentScrollView addSubview:vc.view];
    self.contentScrollView.showsHorizontalScrollIndicator = NO;
    self.contentTVC = self.childViewControllers[0];
}

/**
 *  添加顶部标题s
 */
- (void)addTitles {
    for (int index = 0; index < self.titleList.count; index++) {
        CGFloat titleWidth = WW / self.titleList.count;
        CGFloat titleHeight = kTitleScrollViewHeight;
        CGFloat titleX = index * titleWidth;
        CGFloat titleY = 0;
        
        ZLTitleLabel *titleLabel = [[ZLTitleLabel alloc] initWithFrame:CGRectMake(titleX, titleY, titleWidth, titleHeight)];
        titleLabel.text = self.titleList[index][0];
        titleLabel.tag = index;
        titleLabel.userInteractionEnabled = YES;
        // 目测用 UIButton 也是可以的，也比较方便
        [titleLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTitleTap:)]];
        
        [self.titleView addSubview:titleLabel];
    }
}

/**
 *  添加内容控制器s
 */
- (void)addContentViewControllers {
    for (int index = 0; index < self.titleList.count; index++) {
        ZLContentTableViewController *tvc = [ZLContentTableViewController new];
        tvc.title = self.titleList[index][0];
        tvc.url = self.titleList[index][1];
        [self addChildViewController:tvc];
    }
}

/**
 *  点击 Title 回调
 *
 *  @param recognizer recognizer description
 */
- (void)onTitleTap:(UITapGestureRecognizer *)recognizer {
    ZLTitleLabel *titleLabel = (ZLTitleLabel *)recognizer.view;
    CGFloat offsetX = titleLabel.tag * self.contentScrollView.frame.size.width;
    CGFloat offsetY = self.contentScrollView.contentOffset.y;
    CGPoint offsetPoint = CGPointMake(offsetX, offsetY);
    [self.contentScrollView setContentOffset:offsetPoint animated:YES];
    
    [self setScrollToTopWithTableViewIndex:titleLabel.tag];
}

- (void)setScrollToTopWithTableViewIndex:(NSInteger)index {
    self.contentTVC.tableView.scrollsToTop = NO;
    self.contentTVC = self.childViewControllers[index];
    self.contentTVC.tableView.scrollsToTop = YES;
}

#pragma mark UIScrollView Delegate

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    // 获得索引
    NSUInteger index = scrollView.contentOffset.x / self.contentScrollView.frame.size.width;
    
    ZLContentTableViewController *contentTVC = self.childViewControllers[index];
    contentTVC.index = index;
    
    [self setScrollToTopWithTableViewIndex:index];
    if (contentTVC.view.superview) {
        return;
    }
    contentTVC.view.frame = scrollView.bounds;
    [self.contentScrollView addSubview:contentTVC.view];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self scrollViewDidEndScrollingAnimation:scrollView];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    CGFloat contentOffsetX = scrollView.contentOffset.x;
    NSLog(@"嘻嘻嘻嘻嘻->%f", contentOffsetX);
    if (contentOffsetX < 0) {
        contentOffsetX = 0;
    } else if (contentOffsetX > WW * (self.titleList.count - 1)) {
        contentOffsetX = WW * (self.titleList.count - 1);
    }
    
    [UIView beginAnimations:@"move" context:nil];
    [UIView setAnimationDuration:0.5];// 设置为 0，就不会有移动的“惯性”；更好看一点，可以设置一个小一点的数值
    [UIView setAnimationDelegate:self];
    self.indicatorView.transform = CGAffineTransformMakeTranslation(contentOffsetX / self.titleList.count, 0);
    [UIView commitAnimations];
}

@end
