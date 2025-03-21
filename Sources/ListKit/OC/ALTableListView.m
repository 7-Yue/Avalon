#import "ALTableListView.h"

// MARK: -- ALTableListViewProxy

@interface ALTableListViewProxy : NSProxy
@property (nonatomic, weak) id internalTarget;
@property (nonatomic, weak) id externalTarget;
@end

@implementation ALTableListViewProxy

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

// MARK: -- ALCustomUITableView

@interface ALCustomUITableView : UITableView

@end

@implementation ALCustomUITableView

- (void)setDelegate:(id<UITableViewDelegate>)delegate { 
    NSAssert(!delegate || delegate.class == ALTableListViewProxy.class, @"不再需要设置delegate");
    [super setDelegate:delegate];
}

- (void)setDataSource:(id<UITableViewDataSource>)dataSource {
    NSAssert(!dataSource || dataSource.class == ALTableListViewProxy.class, @"不再需要设置dataSource");
    [super setDataSource:dataSource];
}

@end

// MARK: -- ALTableListView

@interface ALTableListView () <UITableViewDelegate, UITableViewDataSource>
@property(nonatomic, strong, readwrite, nonnull) ALTableListViewProxy *proxy;
@property(nonatomic, strong, readwrite, nullable) id<ALTableListDataProtocol> data;
@property(nonatomic, strong, readwrite, nonnull) __kindof UITableView *tableView;
@property(nonatomic, strong, readwrite, nonnull) NSMutableArray *registerCellList;
@property(nonatomic, strong, readwrite, nonnull) NSMutableArray *registerHeaderViewList;
@property(nonatomic, strong, readwrite, nonnull) NSMutableArray *registerFooterViewList;
@end

@implementation ALTableListView

- (instancetype)initWithFrame:(CGRect)frame
                        style:(UITableViewStyle)style
               tableViewProxy:(id) tableViewProxy {
    self = [super initWithFrame:frame];
    if (self) {
        self.proxy = [[ALTableListViewProxy alloc] initWithInternalTarget:self externalTarget:tableViewProxy];
        self.tableView = ({
            UITableView *tableView = [[ALCustomUITableView alloc] initWithFrame:self.bounds style:style];
            tableView.delegate = (id<UITableViewDelegate>)self.proxy;
            tableView.dataSource = (id<UITableViewDataSource>)self.proxy;
            tableView.estimatedRowHeight = 0;
            tableView.estimatedSectionHeaderHeight = 0;
            tableView.estimatedSectionFooterHeight = 0;
            if (@available(iOS 15.0, *)) {
                tableView.sectionHeaderTopPadding = 0;
            }
            if (@available(iOS 11.0, *)) {
                tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
            } else {
                tableView.contentInset = UIEdgeInsetsZero;
            }
            tableView;
        });
        [self addSubview:self.tableView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.tableView.frame = self.bounds;
}

- (void)bindWithData:(id<ALTableListDataProtocol>)data {
    self.data = data;
    [self.tableView reloadData];
}

// MARK: -- UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.data.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.data.sections[section].rows.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id<ALTableListDataRowsProtocol> rowData = self.data.sections[indexPath.section].rows[indexPath.row];
    Class relatedCell = rowData.relatedCell;
    NSAssert([relatedCell isSubclassOfClass:UITableViewCell.class], @"必须是UITableViewCell的子类");
    NSAssert([relatedCell conformsToProtocol:@protocol(ALTableListCellProtocol)], @"必须遵循ALTableListCellProtocol协议");
    if (![self.registerCellList containsObject:relatedCell]) {
        [tableView registerClass:relatedCell forCellReuseIdentifier:NSStringFromClass(relatedCell)];
        [self.registerCellList addObject:relatedCell];
    }
    UITableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:NSStringFromClass(relatedCell)
                                                           forIndexPath:indexPath];
    if ([cell conformsToProtocol:@protocol(ALTableListCellProtocol)]) {
        id<ALTableListCellProtocol> tempCell = (id<ALTableListCellProtocol>)cell;
        [tempCell cellBuildWithData:rowData indexPath:indexPath];
    }
    return cell;
}

// MARK: -- UITableViewDelegate

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    id<ALTableListDataSectionProtocol> sectionData = self.data.sections[section];
    if (![sectionData respondsToSelector:@selector(relatedHeader)]) {
        return nil;
    }
    Class relatedHeader = sectionData.relatedHeader;
    if (!relatedHeader) {
        return nil;
    }
    NSAssert([relatedHeader isSubclassOfClass:UITableViewHeaderFooterView.class], @"必须是UITableViewHeaderFooterView的子类");
    NSAssert([relatedHeader conformsToProtocol:@protocol(ALTableListSupplementaryViewProtocol)], @"必须遵循ALTableListSupplementaryViewProtocol协议");
    if (![self.registerHeaderViewList containsObject:relatedHeader]) {
        [tableView registerClass:relatedHeader forHeaderFooterViewReuseIdentifier:NSStringFromClass(relatedHeader)];
        [self.registerHeaderViewList addObject:relatedHeader];
    }
    UITableViewHeaderFooterView *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:NSStringFromClass(relatedHeader)];
    if ([header conformsToProtocol:@protocol(ALTableListSupplementaryViewProtocol)]) {
        id<ALTableListSupplementaryViewProtocol> tempHeader = (id<ALTableListSupplementaryViewProtocol>)header;
        [tempHeader buildData:sectionData section:section];
    }
    return header;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    id<ALTableListDataSectionProtocol> sectionData = self.data.sections[section];
    if (![sectionData respondsToSelector:@selector(relatedFooter)]) {
        return nil;
    }
    Class relatedFooter = sectionData.relatedFooter;
    if (!relatedFooter) {
        return nil;
    }
    NSAssert([relatedFooter isSubclassOfClass:UITableViewHeaderFooterView.class], @"必须是UITableViewHeaderFooterView的子类");
    NSAssert([relatedFooter conformsToProtocol:@protocol(ALTableListSupplementaryViewProtocol)], @"必须遵循ALTableListSupplementaryViewProtocol协议");
    if (![self.registerFooterViewList containsObject:relatedFooter]) {
        [tableView registerClass:relatedFooter forHeaderFooterViewReuseIdentifier:NSStringFromClass(relatedFooter)];
        [self.registerFooterViewList addObject:relatedFooter];
    }
    UITableViewHeaderFooterView *footer = [tableView dequeueReusableHeaderFooterViewWithIdentifier:NSStringFromClass(relatedFooter)];
    if ([footer conformsToProtocol:@protocol(ALTableListSupplementaryViewProtocol)]) {
        id<ALTableListSupplementaryViewProtocol> tempFooter = (id<ALTableListSupplementaryViewProtocol>)footer;
        [tempFooter buildData:sectionData section:section];
    }
    return footer;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell conformsToProtocol:@protocol(ALTableListCellProtocol)] &&
        [cell respondsToSelector:@selector(cellWillDisplay)]) {
        id<ALTableListCellProtocol> tempCell = (id<ALTableListCellProtocol>)cell;
        [tempCell cellWillDisplay];
    }
}
- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    if ([view conformsToProtocol:@protocol(ALTableListSupplementaryViewProtocol)] &&
        [view respondsToSelector:@selector(viewWillDisplay)]) {
        id<ALTableListSupplementaryViewProtocol> tempHeader = (id<ALTableListSupplementaryViewProtocol>)view;
        [tempHeader viewWillDisplay];
    }
}
- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section {
    if ([view conformsToProtocol:@protocol(ALTableListSupplementaryViewProtocol)] &&
        [view respondsToSelector:@selector(viewWillDisplay)]) {
        id<ALTableListSupplementaryViewProtocol> tempFooter = (id<ALTableListSupplementaryViewProtocol>)view;
        [tempFooter viewWillDisplay];
    }
}
- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath*)indexPath {
    if ([cell conformsToProtocol:@protocol(ALTableListCellProtocol)] &&
        [cell respondsToSelector:@selector(cellEndDisplay)]) {
        id<ALTableListCellProtocol> tempCell = (id<ALTableListCellProtocol>)cell;
        [tempCell cellEndDisplay];
    }
}
- (void)tableView:(UITableView *)tableView didEndDisplayingHeaderView:(UIView *)view forSection:(NSInteger)section {
    if ([view conformsToProtocol:@protocol(ALTableListSupplementaryViewProtocol)] &&
        [view respondsToSelector:@selector(viewEndDisplay)]) {
        id<ALTableListSupplementaryViewProtocol> tempHeader = (id<ALTableListSupplementaryViewProtocol>)view;
        [tempHeader viewEndDisplay];
    }
}
- (void)tableView:(UITableView *)tableView didEndDisplayingFooterView:(UIView *)view forSection:(NSInteger)section {
    if ([view conformsToProtocol:@protocol(ALTableListSupplementaryViewProtocol)] &&
        [view respondsToSelector:@selector(viewEndDisplay)]) {
        id<ALTableListSupplementaryViewProtocol> tempFooter = (id<ALTableListSupplementaryViewProtocol>)view;
        [tempFooter viewEndDisplay];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    id<ALTableListDataRowsProtocol> rowData = self.data.sections[indexPath.section].rows[indexPath.row];
    return rowData.cellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    id<ALTableListDataSectionProtocol> sectionData = self.data.sections[section];
    if([sectionData respondsToSelector:@selector(headerHeight)]) {
        return sectionData.headerHeight == 0 ? CGFLOAT_MIN : sectionData.headerHeight;
    } else {
        return CGFLOAT_MIN;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    id<ALTableListDataSectionProtocol> sectionData = self.data.sections[section];
    if([sectionData respondsToSelector:@selector(footerHeight)]) {
        return sectionData.footerHeight == 0 ? CGFLOAT_MIN : sectionData.footerHeight;
    } else {
        return CGFLOAT_MIN;
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
