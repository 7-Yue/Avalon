#import <UIKit/UIKit.h>

@protocol ALTableListDataSectionProtocol;
@protocol ALTableListDataRowsProtocol;
@protocol ALTableListCellProtocol;
@protocol ALTableListSupplementaryViewProtocol;

// MARK: -- ALTableListDataProtocol
NS_SWIFT_UNAVAILABLE("仅OC可用")
@protocol ALTableListDataProtocol <NSObject>

@required
    @property(nonatomic, copy, readonly, nullable) NSArray<id <ALTableListDataSectionProtocol>> *sections;

@optional

@end

// MARK: -- ALTableListDataSectionProtocol
NS_SWIFT_UNAVAILABLE("仅OC可用")
@protocol ALTableListDataSectionProtocol <NSObject>

@required
    @property(nonatomic, copy, readonly, nullable) NSArray<id <ALTableListDataRowsProtocol>> *rows;

@optional
    @property(nonatomic, strong, readonly, nullable) Class<ALTableListSupplementaryViewProtocol> relatedHeader;
    @property(nonatomic, strong, readonly, nullable) Class<ALTableListSupplementaryViewProtocol> relatedFooter;
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

// MARK: -- ALTableListSupplementaryViewProtocol
NS_SWIFT_UNAVAILABLE("仅OC可用")
@protocol ALTableListSupplementaryViewProtocol <NSObject>

@required
    - (void)buildData:(id<ALTableListDataSectionProtocol> _Nullable) data
              section:(NSInteger) section;

@optional
    - (void)viewWillDisplay;
    - (void)viewEndDisplay;

@end



