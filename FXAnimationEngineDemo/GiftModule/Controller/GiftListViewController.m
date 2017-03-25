//
//  GiftListViewController.m
//  FXAnimationEngineDemo
//
//  Created by ShawnFoo on 17/3/2.
//  Copyright © 2017年 ShawnFoo. All rights reserved.
//

#import "GiftListViewController.h"
#import "Masonry.h"
#import "ReactiveCocoa.h"
#import "GiftListViewModel.h"
#import "GiftListCell.h"
#import "FXSwitch.h"

@interface GiftListViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) GiftListViewModel *viewModel;

@property (nonatomic, weak) UIVisualEffectView *bottomEffectView;
@property (nonatomic, weak) UICollectionView *giftCollectionView;
@property (nonatomic, weak) UIView *toolView;
@property (nonatomic, weak) FXSwitch *animTypeSwitch;
@property (nonatomic, weak) UIButton *sendButton;

@property (nonatomic, readonly) CGFloat bottomEffectViewMargin;
@property (nonatomic, readonly) NSUInteger giftListColumns;
@property (nonatomic, readonly) CGFloat toolViewHeight;
@property (nonatomic, readonly) CGFloat viewHeight;

@end

@implementation GiftListViewController

#pragma mark - Accessor
#pragma mark Constants
- (CGFloat)bottomEffectViewMargin {
    return 10;
}

- (NSUInteger)giftListColumns {
    return 4;
}

- (CGFloat)toolViewHeight {
    return 48;
}

#pragma mark Computed Property
- (CGFloat)viewHeight {
    return self.toolViewHeight + [GiftListCell cellHeight];
}

#pragma mark - LifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupViewModel];
    [self setupSubViews];
    [self registerEvents];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self presentGiftListViewController];
}

#pragma mark - Setup ViewModel
- (void)setupViewModel {
    self.viewModel = [[GiftListViewModel alloc] init];
    [self.viewModel asyncLoadGiftList];
}

#pragma mark - Setup SubViews
- (void)setupSubViews {
    [self setupBottomEffectView];
    
    self.view.backgroundColor = [UIColor clearColor];
    self.preferredContentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, self.viewHeight);
}
- (void)setupBottomEffectView {
    const CGFloat cCornerRadius = 8;
    
    UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
    effectView.layer.cornerRadius = cCornerRadius;
    effectView.layer.masksToBounds = YES;
    effectView.contentView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.4];
    
    [self.view addSubview:effectView];
    [effectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bottomEffectViewMargin);
        make.bottom.equalTo(self.bottomEffectViewMargin+self.viewHeight);
        make.right.equalTo(-self.bottomEffectViewMargin);
        make.height.equalTo(effectView.superview);
    }];
    self.bottomEffectView = effectView;
    
    [self setupToolView];
    [self setupGiftCollectionView];
}

- (void)setupToolView {
    UIView *toolView = [[UIView alloc] init];
    toolView.backgroundColor = [UIColor clearColor];
    
    [self.bottomEffectView.contentView addSubview:toolView];
    [toolView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(toolView.superview);
        make.height.equalTo(self.toolViewHeight);
    }];
    self.toolView = toolView;
    
    [self setupAnimTypeSwitchButton];
    [self setupSendButton];
}

- (void)setupAnimTypeSwitchButton {
    const CGFloat cHorizMargin = 12;
    const CGFloat cVertMargin = 8;
    const CGFloat cWidth = 116;
    
    FXSwitch *animTypeSwitch = [[FXSwitch alloc] init];
    animTypeSwitch.offTintColor = [UIColor darkGrayColor];
    animTypeSwitch.thumbHorizRatio = 0.8;
    animTypeSwitch.onText = @"FXAnimation";
    animTypeSwitch.offText = @"CAAnimation";
    animTypeSwitch.on = YES;
    
    [self.toolView addSubview:animTypeSwitch];
    [animTypeSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(cHorizMargin);
        make.top.equalTo(cVertMargin);
        make.bottom.equalTo(-cVertMargin);
        make.width.equalTo(cWidth);
    }];
    self.animTypeSwitch = animTypeSwitch;
}

- (void)setupSendButton {
    const CGFloat cHorizMargin = 12;
    const CGFloat cVertMargin = 8;
    const CGFloat cWidth = 100;
    
    UIButton *sendBt = [UIButton buttonWithType:UIButtonTypeCustom];
    [sendBt setTitle:@"Send" forState:UIControlStateNormal];
    [sendBt setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [sendBt setTitleColor:[UIColor groupTableViewBackgroundColor] forState:UIControlStateDisabled];
    [sendBt setBackgroundImage:[UIImage imageNamed:@"gift_send_button"] forState:UIControlStateNormal];
    [sendBt setBackgroundImage:[UIImage imageNamed:@"gift_send_button_disable"] forState:UIControlStateDisabled];
    
    [self.toolView addSubview:sendBt];
    [sendBt mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(-cHorizMargin);
        make.top.equalTo(cVertMargin);
        make.bottom.equalTo(-cVertMargin);
        make.width.equalTo(cWidth);
    }];
    self.sendButton = sendBt;
}

- (void)setupGiftCollectionView {
    const CGFloat cItemWidth = ([UIScreen mainScreen].bounds.size.width - 2*self.bottomEffectViewMargin) / self.giftListColumns;
    const CGFloat cViewHeight = [GiftListCell cellHeight];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = CGSizeMake(cItemWidth, [GiftListCell cellHeight]);
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 0;
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    collectionView.backgroundColor = [UIColor clearColor];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    [collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([GiftListCell class]) bundle:nil]
     forCellWithReuseIdentifier:[GiftListCell identifier]];
    
    [self.bottomEffectView.contentView addSubview:collectionView];
    [collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(collectionView.superview);
        make.bottom.equalTo(self.toolView.mas_top);
        make.height.equalTo(cViewHeight);
    }];
    self.giftCollectionView = collectionView;
}

#pragma mark - Show/Hide
- (void)presentGiftListViewController {
    const NSTimeInterval cDuration = 0.4;
    
    [UIView animateWithDuration:cDuration
                          delay:0.3
         usingSpringWithDamping:0.8
          initialSpringVelocity:0.1
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         [self.bottomEffectView mas_updateConstraints:^(MASConstraintMaker *make) {
                             make.bottom.equalTo(-self.bottomEffectViewMargin);
                         }];
                         [self.bottomEffectView.superview layoutIfNeeded];
                     }
                     completion:nil];
}

- (void)dismissGiftListViewController {
    const NSTimeInterval cDuration = 0.2;
    
    [UIView animateWithDuration:cDuration
                     animations:^{
                         [self.bottomEffectView mas_updateConstraints:^(MASConstraintMaker *make) {
                             make.bottom.equalTo(self.bottomEffectViewMargin + self.viewHeight);
                         }];
                         [self.bottomEffectView.superview layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {
                         [self willMoveToParentViewController:nil];
                         [self.view removeFromSuperview];
                         [self removeFromParentViewController];
                     }];
}

#pragma mark - Events
- (void)registerEvents {
    [self handleLoadGiftListResult];
    [self handleSelectedGiftItemChanged];
}

- (void)handleLoadGiftListResult {
    @weakify(self);
    [[RACObserve(self.viewModel, loadGiftListResult)
      skip:1]
     subscribeNext:^(NSNumber *x) {
         @strongify(self);
         NSUInteger result = x.integerValue;
         if (!result) {
             [self.giftCollectionView reloadData];
         }
         /*
          handle other results here
          */
     }];
}

- (void)handleSelectedGiftItemChanged {
    @weakify(self);
    NSKeyValueObservingOptions kvoOptions = NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld | NSKeyValueObservingOptionInitial;
    RACSignal *selectedGiftItemSignal = [self.viewModel rac_valuesAndChangesForKeyPath:@keypath(self.viewModel, selectedGiftItem)
                                                                               options:kvoOptions
                                                                              observer:self];
    
    // Select/Deselect Cell
    [selectedGiftItemSignal subscribeNext:^(RACTuple *x) {
        @strongify(self);
        RACTupleUnpack(GiftItem *curSelectedItem, NSDictionary *keyValueChangeDictionary) = x;
        GiftItem *lastSelectedItem = keyValueChangeDictionary[NSKeyValueChangeOldKey];
        if (lastSelectedItem && lastSelectedItem != (id)[NSNull null]) {
            GiftListCell *lastSelectedCell = (GiftListCell *)[self.giftCollectionView cellForItemAtIndexPath:[self.viewModel indexPathOfModel:lastSelectedItem]];
            [lastSelectedCell updateAppearenceWithSelected:NO];
        }
        if (curSelectedItem) {
            GiftListCell *curSelectedCell = (GiftListCell *)[self.giftCollectionView cellForItemAtIndexPath:[self.viewModel indexPathOfModel:curSelectedItem]];
            [curSelectedCell updateAppearenceWithSelected:YES];
        }
    }];
    
    // SendButton Click Event
    self.sendButton.rac_command =
    [[RACCommand alloc] initWithEnabled:[selectedGiftItemSignal map:^id(RACTuple *value) {
        GiftItem *selectedItem = value.first;
        return @(selectedItem != nil);
    }] signalBlock:^RACSignal *(id input) {
        @strongify(self);
        [self userDidClickSendButtonWithGiftItem:self.viewModel.selectedGiftItem
                                 playFXAnimation:self.animTypeSwitch.isOn];
        return [RACSignal empty];
    }];
}

#pragma mark - UICollectionView DataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [self.viewModel sectionCount];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.viewModel itemsCountInSection:section];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    GiftListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[GiftListCell identifier]
                                                                   forIndexPath:indexPath];
    id model = [self.viewModel modelAtIndexPath:indexPath];
    [cell setupCellWithGiftItem:model selected:model == self.viewModel.selectedGiftItem];
    
    return cell;
}

#pragma mark - UICollectionView Delegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.viewModel setSelected:YES atIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.viewModel setSelected:NO atIndexPath:indexPath];
}

#pragma mark - Delegate Methods
- (void)userDidClickSendButtonWithGiftItem:(GiftItem *)item playFXAnimation:(BOOL)playFXAnimation {}

@end
