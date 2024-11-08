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

    if ([self.internalTarget respondsToSelector:selector]) {
        // 先尝试 internalTarget 调用
        [invocation invokeWithTarget:self.internalTarget];
    } else if ([self.externalTarget respondsToSelector:selector]) {
        // 再尝试 externalTarget 调用
        [invocation invokeWithTarget:self.externalTarget];
    }
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    // 确保 respondsToSelector 正确反映方法的实现位置
    return [self.internalTarget respondsToSelector:aSelector] ||
           [self.externalTarget respondsToSelector:aSelector];
}

@end

// MARK: -- ALCollectionListView

@interface ALCustomUICollectionView : UICollectionView

@end

@implementation ALCustomUICollectionView

- (void)setDelegate:(id<UICollectionViewDelegate>)delegate {
    if (delegate && ![delegate isKindOfClass:ALCollectionListView.class]) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:@"不再需要设置delegate"
                                     userInfo:nil];
    }
    [super setDelegate:delegate];
}

- (void)setDataSource:(id<UICollectionViewDataSource>)dataSource {
    if (dataSource && ![dataSource isKindOfClass:ALCollectionListView.class]) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:@"不再需要设置dataSource"
                                     userInfo:nil];
    }
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
    self.data.collectionView = nil;
    self.data = data;
    self.data.collectionView = self.collectionView;
    [self.collectionView reloadData];
}

// MARK: -- UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    id<ALCollectionListDataRowProtocol> rowData = self.data.sections[indexPath.section].rows[indexPath.row];
    if ([rowData respondsToSelector:@selector(cellSize)]) {
        return rowData.cellSize;
    } else if ([rowData respondsToSelector:@selector(dynamicCellSize)]) {
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
    if (![relatedCell isSubclassOfClass:UICollectionViewCell.class]) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:@"必须是UICollectionViewCell的子类"
                                     userInfo:nil];
    }
    if (![relatedCell conformsToProtocol:@protocol(ALCollectionListCellProtocol)]) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:@"必须遵循ALCollectionListCellProtocol协议"
                                     userInfo:nil];
    }
    if (![self.registerCellList containsObject:relatedCell]) {
        [collectionView registerClass:relatedCell forCellWithReuseIdentifier:NSStringFromClass(relatedCell)];
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
        if (![sectionData respondsToSelector:@selector(relatedHeader)]) {
            return nil;
        }
        Class relatedHeader = sectionData.relatedHeader;
        if (!relatedHeader) {
            return nil;
        }
        if (![relatedHeader isSubclassOfClass:UICollectionReusableView.class]) {
            @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                           reason:@"必须是UICollectionReusableView的子类"
                                         userInfo:nil];
        }
        if (![relatedHeader conformsToProtocol:@protocol(ALCollectionListHeaderProtocol)]) {
            @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                           reason:@"必须遵循ALCollectionListHeaderProtocol协议"
                                         userInfo:nil];
        }
        if (![self.registerHeaderViewList containsObject:relatedHeader]) {
            [collectionView registerClass:relatedHeader
               forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                      withReuseIdentifier:NSStringFromClass(relatedHeader)];
        }
        UICollectionReusableView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                              withReuseIdentifier:NSStringFromClass(relatedHeader)
                                                                                     forIndexPath:indexPath];
        if ([header conformsToProtocol:@protocol(ALCollectionListHeaderProtocol)]) {
            id<ALCollectionListHeaderProtocol> tempHeader = (id<ALCollectionListHeaderProtocol>)header;
            [tempHeader headerBuildData:sectionData section:indexPath.section];
        }
        return header;
    } else if (([kind isEqualToString:UICollectionElementKindSectionFooter])) {
        id<ALCollectionListDataSectionProtocol> sectionData = self.data.sections[indexPath.section];
        if (![sectionData respondsToSelector:@selector(relatedFooter)]) {
            return nil;
        }
        Class relatedFooter = sectionData.relatedFooter;
        if (!relatedFooter) {
            return nil;
        }
        if (![relatedFooter isSubclassOfClass:UICollectionReusableView.class]) {
            @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                           reason:@"必须是UICollectionReusableView的子类"
                                         userInfo:nil];
        }
        if (![relatedFooter conformsToProtocol:@protocol(ALCollectionListFooterProtocol)]) {
            @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                           reason:@"必须遵循ALCollectionListFooterProtocol协议"
                                         userInfo:nil];
        }
        if (![self.registerFooterViewList containsObject:relatedFooter]) {
            [collectionView registerClass:relatedFooter
               forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                      withReuseIdentifier:NSStringFromClass(relatedFooter)];
        }
        UICollectionReusableView *footer = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                                                                              withReuseIdentifier:NSStringFromClass(relatedFooter)
                                                                                     forIndexPath:indexPath];
        if ([footer conformsToProtocol:@protocol(ALCollectionListFooterProtocol)]) {
            id<ALCollectionListFooterProtocol> tempFooter = (id<ALCollectionListFooterProtocol>)footer;
            [tempFooter footerBuild:sectionData section:indexPath.section];
        }
        return footer;
    } else {
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
        if ([view conformsToProtocol:@protocol(ALCollectionListHeaderProtocol)] &&
            [view respondsToSelector:@selector(headerWillDisplay)]) {
            id<ALCollectionListHeaderProtocol> tempHeader = (id<ALCollectionListHeaderProtocol>)view;
            [tempHeader headerWillDisplay];
        }
    } else if ([elementKind isEqualToString:UICollectionElementKindSectionFooter]) {
        if ([view conformsToProtocol:@protocol(ALCollectionListFooterProtocol)] &&
            [view respondsToSelector:@selector(footerWillDisplay)]) {
            id<ALCollectionListFooterProtocol> tempFooter = (id<ALCollectionListFooterProtocol>)view;
            [tempFooter footerWillDisplay];
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
        if ([view conformsToProtocol:@protocol(ALCollectionListHeaderProtocol)] &&
            [view respondsToSelector:@selector(headerEndDisplay)]) {
            id<ALCollectionListHeaderProtocol> tempHeader = (id<ALCollectionListHeaderProtocol>)view;
            [tempHeader headerEndDisplay];
        }
    } else if ([elementKind isEqualToString:UICollectionElementKindSectionFooter]) {
        if ([view conformsToProtocol:@protocol(ALCollectionListFooterProtocol)] &&
            [view respondsToSelector:@selector(footerEndDisplay)]) {
            id<ALCollectionListFooterProtocol> tempFooter = (id<ALCollectionListFooterProtocol>)view;
            [tempFooter footerEndDisplay];
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
