#import "ALCollectionListView.h"

// MARK: -- ALCollectionListViewProxy

@interface ALCollectionListViewProxy : NSProxy
@property (nonatomic, weak) id internalTarget;
@property (nonatomic, weak) id externalTarget;
@end

@implementation ALCollectionListViewProxy

- (instancetype)initWithInternalTarget:(id) internalTarget externalTarget:(id) externalTarget {
    self.internalTarget = internalTarget;
    self.externalTarget = externalTarget;
    return self;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    // 检查代理方法是否在 internalTarget 或 externalTarget 中实现
    NSMethodSignature *signature = [self.internalTarget methodSignatureForSelector:sel];
    if (!signature) {
        signature = [self.externalTarget methodSignatureForSelector:sel];
    }
    return signature;
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    SEL selector = [invocation selector];

    if ([self.externalTarget respondsToSelector:selector]) {
        // 先尝试 externalTarget 调用
        [invocation invokeWithTarget:self.externalTarget];
    } else if ([self.internalTarget respondsToSelector:selector]) {
        // 再尝试 internalTarget 调用
        [invocation invokeWithTarget:self.internalTarget];
    }
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    // 确保 respondsToSelector 正确反映方法的实现位置
    return [self.externalTarget respondsToSelector:aSelector] ||
        [self.internalTarget respondsToSelector:aSelector];
}

@end

// MARK: -- ALCollectionListView

@interface ALCustomUICollectionView : UICollectionView

@end

@implementation ALCustomUICollectionView

- (void)setDelegate:(id<UICollectionViewDelegate>)delegate {
    NSAssert(!delegate || delegate.class == ALCollectionListViewProxy.class, @"不再需要设置delegate");
    [super setDelegate:delegate];
}

- (void)setDataSource:(id<UICollectionViewDataSource>)dataSource {
    NSAssert(!dataSource || dataSource.class == ALCollectionListViewProxy.class, @"不再需要设置dataSource");
    [super setDataSource:dataSource];
}

@end

// MARK: -- ALCollectionListView

@interface ALCollectionListView () <
    UICollectionViewDelegateFlowLayout,
    UICollectionViewDelegate,
    UICollectionViewDataSource
>
@property(nonatomic, strong, readwrite, nonnull) ALCollectionListViewProxy *proxy;
@property(nonatomic, strong, readwrite, nullable) id<ALCollectionListDataProtocol> data;
@property(nonatomic, strong, readwrite, nonnull) __kindof UICollectionView *collectionView;
@property(nonatomic, strong, readwrite, nonnull) NSMutableArray *registerCellList;
@property(nonatomic, strong, readwrite, nonnull) NSMutableArray *registerHeaderViewList;
@property(nonatomic, strong, readwrite, nonnull) NSMutableArray *registerFooterViewList;

@end

@implementation ALCollectionListView

- (instancetype)initWithFrame:(CGRect)frame
              scrollDirection:(UICollectionViewScrollDirection) scrollDirection
          collectionViewProxy:(id) collectionViewProxy {
    self = [super initWithFrame:frame];
    if (self) {
        self.proxy = [[ALCollectionListViewProxy alloc] initWithInternalTarget:self
                                                                externalTarget:collectionViewProxy];
        self.collectionView = ({
            UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
            layout.scrollDirection = scrollDirection;
            layout.estimatedItemSize = CGSizeZero;
            ALCustomUICollectionView *collectionView = [[ALCustomUICollectionView alloc] initWithFrame:frame
                                                                                  collectionViewLayout:layout];
            collectionView.delegate = (id<UICollectionViewDelegate>)self.proxy;
            collectionView.dataSource = (id<UICollectionViewDataSource>)self.proxy;
            if (@available(iOS 11.0, *)) {
                collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
            } else {
                collectionView.contentInset = UIEdgeInsetsZero;
            }
            collectionView;
        });
        [self addSubview:self.collectionView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.collectionView.frame = self.bounds;
}

- (void)bindWithData:(id<ALCollectionListDataProtocol>)data {
    self.data = data;
    [self.collectionView reloadData];
}

// MARK: -- UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    id<ALCollectionListDataRowProtocol> rowData = self.data.sections[indexPath.section].rows[indexPath.row];
    if ([rowData respondsToSelector:@selector(dynamicCellSize)]) {
        return rowData.dynamicCellSize(collectionView.frame.size);
    } else {
        return CGSizeZero;
    }
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout*)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section {
    id<ALCollectionListDataSectionProtocol> sectionData = self.data.sections[section];
    if([sectionData respondsToSelector:@selector(inset)]) {
        return sectionData.inset;
    } else {
        return UIEdgeInsetsZero;
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    id<ALCollectionListDataSectionProtocol> sectionData = self.data.sections[section];
    if([sectionData respondsToSelector:@selector(minimumLineSpacing)]) {
        return sectionData.minimumLineSpacing;
    } else {
        return 0;
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    id<ALCollectionListDataSectionProtocol> sectionData = self.data.sections[section];
    if([sectionData respondsToSelector:@selector(minimumInteritemSpacing)]) {
        return sectionData.minimumInteritemSpacing;
    } else {
        return 0;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    id<ALCollectionListDataSectionProtocol> sectionData = self.data.sections[section];
    if([sectionData respondsToSelector:@selector(headerSize)]) {
        return sectionData.headerSize;
    } else {
        return CGSizeZero;
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    id<ALCollectionListDataSectionProtocol> sectionData = self.data.sections[section];
    if([sectionData respondsToSelector:@selector(footerSize)]) {
        return sectionData.footerSize;
    } else {
        return CGSizeZero;
    }
}

// MARK: -- UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.data.sections.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.data.sections[section].rows.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    id<ALCollectionListDataRowProtocol> rowData = self.data.sections[indexPath.section].rows[indexPath.row];
    Class relatedCell = rowData.relatedCell;
    NSAssert([relatedCell isSubclassOfClass:UICollectionViewCell.class], @"必须是UICollectionViewCell的子类");
    NSAssert([relatedCell conformsToProtocol:@protocol(ALCollectionListCellProtocol)], @"必须遵循ALCollectionListCellProtocol协议");
    if (![self.registerCellList containsObject:relatedCell]) {
        [collectionView registerClass:relatedCell forCellWithReuseIdentifier:NSStringFromClass(relatedCell)];
        [self.registerCellList addObject:relatedCell];
    }
    UICollectionViewCell *cell =[collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(relatedCell)
                                                                          forIndexPath:indexPath];
    if ([cell conformsToProtocol:@protocol(ALCollectionListCellProtocol)]) {
        id<ALCollectionListCellProtocol> tempCell = (id<ALCollectionListCellProtocol>)cell;
        [tempCell cellBuildWithData:rowData indexPath:indexPath];
    }
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        id<ALCollectionListDataSectionProtocol> sectionData = self.data.sections[indexPath.section];
        Class relatedHeader;
        if (![sectionData respondsToSelector:@selector(relatedHeader)] ||
            !sectionData.relatedHeader) {
            relatedHeader = UICollectionReusableView.class;
        } else {
            relatedHeader = sectionData.relatedHeader;
            NSAssert([relatedHeader isSubclassOfClass:UICollectionReusableView.class], @"必须是UICollectionReusableView的子类");
            NSAssert([relatedHeader conformsToProtocol:@protocol(ALCollectionListSupplementaryViewProtocol)], @"必须遵循ALCollectionListSupplementaryViewProtocol协议");
        }
        if (![self.registerHeaderViewList containsObject:relatedHeader]) {
            [collectionView registerClass:relatedHeader
               forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                      withReuseIdentifier:NSStringFromClass(relatedHeader)];
            [self.registerHeaderViewList addObject:relatedHeader];
        }
        UICollectionReusableView *header =
        [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                           withReuseIdentifier:NSStringFromClass(relatedHeader)
                                                  forIndexPath:indexPath];
        if ([header conformsToProtocol:@protocol(ALCollectionListSupplementaryViewProtocol)]) {
            id<ALCollectionListSupplementaryViewProtocol> tempHeader = (id<ALCollectionListSupplementaryViewProtocol>)header;
            [tempHeader buildData:sectionData section:indexPath.section];
        }
        return header;
    } else if (([kind isEqualToString:UICollectionElementKindSectionFooter])) {
        id<ALCollectionListDataSectionProtocol> sectionData = self.data.sections[indexPath.section];
        Class relatedFooter;
        if (![sectionData respondsToSelector:@selector(relatedFooter)] ||
            !sectionData.relatedFooter) {
            relatedFooter = UICollectionReusableView.class;
        } else {
            relatedFooter = sectionData.relatedFooter;
            NSAssert([relatedFooter isSubclassOfClass:UICollectionReusableView.class], @"必须是UICollectionReusableView的子类");
            NSAssert([relatedFooter conformsToProtocol:@protocol(ALCollectionListSupplementaryViewProtocol)], @"必须遵循ALCollectionListSupplementaryViewProtocol协议");
        }
        if (![self.registerFooterViewList containsObject:relatedFooter]) {
            [collectionView registerClass:relatedFooter
               forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                      withReuseIdentifier:NSStringFromClass(relatedFooter)];
            [self.registerFooterViewList addObject:relatedFooter];
        }
        UICollectionReusableView *footer =
        [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                                           withReuseIdentifier:NSStringFromClass(relatedFooter)
                                                  forIndexPath:indexPath];
        if ([footer conformsToProtocol:@protocol(ALCollectionListSupplementaryViewProtocol)]) {
            id<ALCollectionListSupplementaryViewProtocol> tempFooter = (id<ALCollectionListSupplementaryViewProtocol>)footer;
            [tempFooter buildData:sectionData section:indexPath.section];
        }
        return footer;
    } else {
        NSAssert(NO, @"不支持footer和header以外的视图");
        return [UICollectionReusableView new];
    }
}

// MARK: -- UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView
       willDisplayCell:(UICollectionViewCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell conformsToProtocol:@protocol(ALCollectionListCellProtocol)] &&
        [cell respondsToSelector:@selector(cellWillDisplay)]) {
        id<ALCollectionListCellProtocol> tempCell = (id<ALCollectionListCellProtocol>)cell;
        [tempCell cellWillDisplay];
    }
}

- (void)collectionView:(UICollectionView *)collectionView
willDisplaySupplementaryView:(UICollectionReusableView *)view
        forElementKind:(NSString *)elementKind
           atIndexPath:(NSIndexPath *)indexPath {
    if ([elementKind isEqualToString:UICollectionElementKindSectionHeader]) {
        if ([view conformsToProtocol:@protocol(ALCollectionListSupplementaryViewProtocol)] &&
            [view respondsToSelector:@selector(viewWillDisplay)]) {
            id<ALCollectionListSupplementaryViewProtocol> tempHeader = (id<ALCollectionListSupplementaryViewProtocol>)view;
            [tempHeader viewWillDisplay];
        }
    } else if ([elementKind isEqualToString:UICollectionElementKindSectionFooter]) {
        if ([view conformsToProtocol:@protocol(ALCollectionListSupplementaryViewProtocol)] &&
            [view respondsToSelector:@selector(viewWillDisplay)]) {
            id<ALCollectionListSupplementaryViewProtocol> tempFooter = (id<ALCollectionListSupplementaryViewProtocol>)view;
            [tempFooter viewWillDisplay];
        }
    }
}

- (void)collectionView:(UICollectionView *)collectionView
  didEndDisplayingCell:(UICollectionViewCell *)cell
    forItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell conformsToProtocol:@protocol(ALCollectionListCellProtocol)] &&
        [cell respondsToSelector:@selector(cellEndDisplay)]) {
        id<ALCollectionListCellProtocol> tempCell = (id<ALCollectionListCellProtocol>)cell;
        [tempCell cellEndDisplay];
    }
}

- (void)collectionView:(UICollectionView *)collectionView
didEndDisplayingSupplementaryView:(UICollectionReusableView *)view
      forElementOfKind:(NSString *)elementKind
           atIndexPath:(NSIndexPath *)indexPath {
    if ([elementKind isEqualToString:UICollectionElementKindSectionHeader]) {
        if ([view conformsToProtocol:@protocol(ALCollectionListSupplementaryViewProtocol)] &&
            [view respondsToSelector:@selector(viewEndDisplay)]) {
            id<ALCollectionListSupplementaryViewProtocol> tempHeader = (id<ALCollectionListSupplementaryViewProtocol>)view;
            [tempHeader viewEndDisplay];
        }
    } else if ([elementKind isEqualToString:UICollectionElementKindSectionFooter]) {
        if ([view conformsToProtocol:@protocol(ALCollectionListSupplementaryViewProtocol)] &&
            [view respondsToSelector:@selector(viewEndDisplay)]) {
            id<ALCollectionListSupplementaryViewProtocol> tempFooter = (id<ALCollectionListSupplementaryViewProtocol>)view;
            [tempFooter viewEndDisplay];
        }
    }
}

// MARK: -- Setter && Getter

- (NSMutableArray *)registerCellList {
    if(!_registerCellList) {
        _registerCellList = [NSMutableArray array];
    }
    return _registerCellList;
}

- (NSMutableArray *)registerHeaderViewList {
    if(!_registerHeaderViewList) {
        _registerHeaderViewList = [NSMutableArray array];
    }
    return _registerHeaderViewList;
}

- (NSMutableArray *)registerFooterViewList {
    if(!_registerFooterViewList) {
        _registerFooterViewList = [NSMutableArray array];
    }
    return _registerFooterViewList;
}

@end
