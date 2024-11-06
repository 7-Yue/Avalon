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

// MARK: -- ALCustomUITableView

@interface ALCustomUITableView : UITableView

@end

@implementation ALCustomUITableView

- (void)setDelegate:(id<UITableViewDelegate>)delegate {
    if (delegate && ![delegate isKindOfClass:ALTableListView.class]) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:@"不再需要设置delegate"
                                     userInfo:nil];
    }
    [super setDelegate:delegate];
}

- (void)setDataSource:(id<UITableViewDataSource>)dataSource {
    if (dataSource && ![dataSource isKindOfClass:ALTableListView.class]) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:@"不再需要设置dataSource"
                                     userInfo:nil];
    }
    [super setDataSource:dataSource];
}

@end

// MARK: -- ALTableListView

@interface ALTableListView () <UITableViewDelegate, UITableViewDataSource>
@property(nonatomic, strong, readwrite, nonnull) ALTableListViewProxy *proxy;
@property(nonatomic, strong, readwrite, nullable) id<ALTableListDataProtocol> data;
@property(nonatomic, strong, readwrite, nonnull) __kindof UITableView *tableView;
@property(nonatomic, assign, readwrite) UITableViewStyle style;
@property(nonatomic, strong, readwrite, nonnull) NSMutableArray *registerCellList;
@property(nonatomic, strong, readwrite, nonnull) NSMutableArray *registerHeaderFooterViewList;
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
    self.data.tablewView = nil;
    self.data = data;
    self.data.tablewView = self.tableView;
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
    if (![relatedCell isSubclassOfClass:UITableViewCell.class]) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:@"必须是UITableViewCell的子类"
                                     userInfo:nil];
    }
    if (![relatedCell conformsToProtocol:@protocol(ALTableListCellProtocol)]) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:@"必须遵循ALTableListCellProtocol协议"
                                     userInfo:nil];
    }
    if (![self.registerCellList containsObject:relatedCell]) {
        [tableView registerClass:relatedCell forCellReuseIdentifier:NSStringFromClass(relatedCell)];
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
    if (![relatedHeader isSubclassOfClass:UITableViewHeaderFooterView.class]) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:@"必须是UITableViewHeaderFooterView的子类"
                                     userInfo:nil];
    }
    if (![relatedHeader conformsToProtocol:@protocol(ALTableListHeaderProtocol)]) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:@"必须遵循ALTableListHeaderProtocol协议"
                                     userInfo:nil];
    }
    if (![self.registerHeaderFooterViewList containsObject:relatedHeader]) {
        [tableView registerClass:relatedHeader forHeaderFooterViewReuseIdentifier:NSStringFromClass(relatedHeader)];
    }
    UITableViewHeaderFooterView *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:NSStringFromClass(relatedHeader)];
    if ([header conformsToProtocol:@protocol(ALTableListHeaderProtocol)]) {
        id<ALTableListHeaderProtocol> tempHeader = (id<ALTableListHeaderProtocol>)header;
        [tempHeader headerBuildData:sectionData section:section];
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
    if (![relatedFooter isSubclassOfClass:UITableViewHeaderFooterView.class]) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:@"必须是UITableViewHeaderFooterView的子类"
                                     userInfo:nil];
    }
    if (![relatedFooter conformsToProtocol:@protocol(ALTableListFooterProtocol)]) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                       reason:@"必须遵循ALTableListFooterProtocol协议"
                                     userInfo:nil];
    }
    if (![self.registerHeaderFooterViewList containsObject:relatedFooter]) {
        [tableView registerClass:relatedFooter forHeaderFooterViewReuseIdentifier:NSStringFromClass(relatedFooter)];
    }
    UITableViewHeaderFooterView *footer = [tableView dequeueReusableHeaderFooterViewWithIdentifier:NSStringFromClass(relatedFooter)];
    if ([footer conformsToProtocol:@protocol(ALTableListFooterProtocol)]) {
        id<ALTableListFooterProtocol> tempFooter = (id<ALTableListFooterProtocol>)footer;
        [tempFooter footerBuild:sectionData section:section];
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
    if ([view conformsToProtocol:@protocol(ALTableListHeaderProtocol)] &&
        [view respondsToSelector:@selector(headerWillDisplay)]) {
        id<ALTableListHeaderProtocol> tempHeader = (id<ALTableListHeaderProtocol>)view;
        [tempHeader headerWillDisplay];
    }
}
- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section {
    if ([view conformsToProtocol:@protocol(ALTableListFooterProtocol)] &&
        [view respondsToSelector:@selector(footerWillDisplay)]) {
        id<ALTableListFooterProtocol> tempFooter = (id<ALTableListFooterProtocol>)view;
        [tempFooter footerWillDisplay];
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
    if ([view conformsToProtocol:@protocol(ALTableListHeaderProtocol)] &&
        [view respondsToSelector:@selector(headerEndDisplay)]) {
        id<ALTableListHeaderProtocol> tempHeader = (id<ALTableListHeaderProtocol>)view;
        [tempHeader headerEndDisplay];
    }
}
- (void)tableView:(UITableView *)tableView didEndDisplayingFooterView:(UIView *)view forSection:(NSInteger)section {
    if ([view conformsToProtocol:@protocol(ALTableListFooterProtocol)] &&
        [view respondsToSelector:@selector(footerEndDisplay)]) {
        id<ALTableListFooterProtocol> tempFooter = (id<ALTableListFooterProtocol>)view;
        [tempFooter footerEndDisplay];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    id<ALTableListDataRowsProtocol> rowData = self.data.sections[indexPath.section].rows[indexPath.row];
    return rowData.cellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    id<ALTableListDataSectionProtocol> sectionData = self.data.sections[section];
    if (sectionData.headerHeight == 0) {
        return CGFLOAT_MIN;
    } else {
        return sectionData.headerHeight;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    id<ALTableListDataSectionProtocol> sectionData = self.data.sections[section];
    if (sectionData.footerHeight == 0) {
        return CGFLOAT_MIN;
    } else {
        return sectionData.footerHeight;
    }
}

// MARK: -- Setter && Getter

- (NSMutableArray *)registerCellList {
    if(!_registerCellList) {
        _registerCellList = [NSMutableArray array];
    }
    return _registerCellList;
}

- (NSMutableArray *)registerHeaderFooterViewList {
    if(!_registerHeaderFooterViewList) {
        _registerHeaderFooterViewList = [NSMutableArray array];
    }
    return _registerHeaderFooterViewList;
}

@end
