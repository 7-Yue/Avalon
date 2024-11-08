#import <UIKit/UIKit.h>

@protocol ALTableListDataSectionProtocol;
@protocol ALTableListDataRowsProtocol;
@protocol ALTableListCellProtocol;
@protocol ALTableListHeaderProtocol;
@protocol ALTableListFooterProtocol;

// MARK: -- ALTableListDataProtocol
NS_SWIFT_UNAVAILABLE("仅OC可用")
@protocol ALTableListDataProtocol <NSObject>

@required
    @property(nonatomic, weak, readwrite, nullable) UITableView *tablewView;
    @property(nonatomic, copy, readonly, nullable) NSArray<id <ALTableListDataSectionProtocol>> *sections;

@optional
//  TODO:   如果需要通过更新数据源，从而达到直接更新UI的效果，需要一个在此扩展协议，并且实现内部使用tablewView完成UI更新
//    - (void)reloadTablewView;
//    - (void)addToLastSectionWithRows:(NSArray<id <ALTableListDataRowsProtocol>> *_Nullable) rows;
//    - (void)removeFromLastSectionWithRowsRange:(NSRange) range;

@end

// MARK: -- ALTableListDataSectionProtocol
NS_SWIFT_UNAVAILABLE("仅OC可用")
@protocol ALTableListDataSectionProtocol <NSObject>

@required
    @property(nonatomic, copy, readonly, nullable) NSArray<id <ALTableListDataRowsProtocol>> *rows;

@optional
    @property(nonatomic, strong, readonly, nullable) Class<ALTableListHeaderProtocol> relatedHeader;
    @property(nonatomic, strong, readonly, nullable) Class<ALTableListFooterProtocol> relatedFooter;
    @property(nonatomic, assign, readonly) double headerHeight;
    @property(nonatomic, assign, readonly) double footerHeight;

@end

// MARK: -- ALTableListDataRowsProtocol
NS_SWIFT_UNAVAILABLE("仅OC可用")
@protocol ALTableListDataRowsProtocol <NSObject>

@required
    @property(nonatomic, strong, readonly, nonnull) Class<ALTableListCellProtocol> relatedCell;
    @property(nonatomic, assign, readonly) double cellHeight;

@end

// MARK: -- ALTableListCellProtocol
NS_SWIFT_UNAVAILABLE("仅OC可用")
@protocol ALTableListCellProtocol <NSObject>

@required
    - (void)cellBuildWithData:(id<ALTableListDataRowsProtocol> _Nullable) data
                    indexPath:(NSIndexPath * _Nonnull) indexPath;

@optional
    - (void)cellWillDisplay;
    - (void)cellEndDisplay;

@end

// MARK: -- ALTableListHeaderProtocol
NS_SWIFT_UNAVAILABLE("仅OC可用")
@protocol ALTableListHeaderProtocol <NSObject>

@required
    - (void)headerBuildData:(id<ALTableListDataSectionProtocol> _Nullable) data
                    section:(NSInteger) section;

@optional
    - (void)headerWillDisplay;
    - (void)headerEndDisplay;

@end

// MARK: -- ALTableListFooterProtocol
NS_SWIFT_UNAVAILABLE("仅OC可用")
@protocol ALTableListFooterProtocol <NSObject>

@required
    - (void)footerBuild:(id<ALTableListDataSectionProtocol> _Nullable) data
                section:(NSInteger) section;

@optional
    - (void)footerWillDisplay;
    - (void)footerEndDisplay;

@end




