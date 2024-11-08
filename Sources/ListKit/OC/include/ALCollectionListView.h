#import <UIKit/UIKit.h>
#if __has_include(<AvalonFramework/ALTableListProtocol.h>)
    #import <AvalonFramework/ALCollectionListProtocol.h>
#else
    #import "ALCollectionListProtocol.h"
#endif

NS_SWIFT_UNAVAILABLE("仅OC可用")
@interface ALCollectionListView : UIView

/// 初始化
/// - Parameters:
///   - frame: 布局
///   - scrollDirection: 滚动方向
///   - collectionViewProxy: 用于延展内部没有实现的CollectionView代理函数（DataSource Delegate）
- (instancetype _Nonnull)initWithFrame:(CGRect)frame
                       scrollDirection:(UICollectionViewScrollDirection) scrollDirection
                   collectionViewProxy:(id _Nullable) collectionViewProxy;

/// 绑定新的数据会立马刷新
/// - Parameters:
///   - data: 数据
- (void)bindWithData:(id<ALCollectionListDataProtocol> _Nullable)data;

@end

