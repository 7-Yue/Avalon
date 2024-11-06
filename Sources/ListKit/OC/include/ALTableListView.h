#import <UIKit/UIKit.h>
#if __has_include(<AvalonFramework/ALTableListProtocol.h>)
    #import <AvalonFramework/ALTableListProtocol.h>
#else
    #import "ALTableListProtocol.h"
#endif

NS_SWIFT_UNAVAILABLE("仅OC可用")
@interface ALTableListView : UIView
@property(nonatomic, strong, readonly, nonnull) __kindof UITableView *tableView;
@property(nonatomic, strong, readonly, nullable) id<ALTableListDataProtocol> data;
@end

NS_SWIFT_UNAVAILABLE("仅OC可用")
@interface ALTableListView (Action)

/// 初始化
/// - Parameters:
///   - frame: 布局
///   - style: 样式
///   - tableViewProxy: 用于延展内部没有实现的tableView代理函数（DataSource Delegate）
- (instancetype _Nonnull)initWithFrame:(CGRect)frame
                                 style:(UITableViewStyle)style
                        tableViewProxy:(id _Nullable) tableViewProxy;

/// 绑定新的数据会立马刷新
/// - Parameters:
///   - data: 数据
- (void)bindWithData:(id <ALTableListDataProtocol> _Nullable) data;

@end


