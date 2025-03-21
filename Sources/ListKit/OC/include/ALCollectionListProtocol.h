#import <UIKit/UIKit.h>
#import <CoreFoundation/CoreFoundation.h>

@protocol ALCollectionListDataSectionProtocol;
@protocol ALCollectionListDataRowProtocol;
@protocol ALCollectionListCellProtocol;
@protocol ALCollectionListSupplementaryViewProtocol;

// MARK: -- ALCollectionListDataProtocol
NS_SWIFT_UNAVAILABLE("仅OC可用")
@protocol ALCollectionListDataProtocol <NSObject>

@required
    @property(nonatomic, copy, readonly, nullable) NSArray<id <ALCollectionListDataSectionProtocol>> *sections;
@optional

@end

// MARK: -- ALCollectionListDataSectionProtocol
NS_SWIFT_UNAVAILABLE("仅OC可用")
@protocol ALCollectionListDataSectionProtocol <NSObject>

@required
    @property(nonatomic, copy, readonly, nullable) NSArray<id <ALCollectionListDataRowProtocol>> *rows;
@optional
    @property(nonatomic, assign, readonly) UIEdgeInsets inset;
    @property(nonatomic, assign, readonly) double minimumLineSpacing;
    @property(nonatomic, assign, readonly) double minimumInteritemSpacing;
    @property(nonatomic, assign, readonly) CGSize headerSize;
    @property(nonatomic, assign, readonly) CGSize footerSize;
    @property(nonatomic, strong, readonly, nullable) Class<ALCollectionListSupplementaryViewProtocol> relatedHeader;
    @property(nonatomic, strong, readonly, nullable) Class<ALCollectionListSupplementaryViewProtocol> relatedFooter;
@end

// MARK: -- ALCollectionListDataRowProtocol
NS_SWIFT_UNAVAILABLE("仅OC可用")
@protocol ALCollectionListDataRowProtocol <NSObject>

@required
    @property(nonatomic, strong, readonly, nonnull) Class<ALCollectionListCellProtocol> relatedCell;

@optional
    @property(nonatomic, copy, readonly, nullable) CGSize (^dynamicCellSize)(CGSize UICollectionViewSize);

@end

// MARK: -- ALCollectionListCellProtocol
NS_SWIFT_UNAVAILABLE("仅OC可用")
@protocol ALCollectionListCellProtocol <NSObject>

@required
    - (void)cellBuildWithData:(id<ALCollectionListDataRowProtocol> _Nullable) data
                    indexPath:(NSIndexPath * _Nonnull) indexPath;

@optional
    - (void)cellWillDisplay;
    - (void)cellEndDisplay;

@end

// MARK: -- ALCollectionListSupplementaryViewProtocol
NS_SWIFT_UNAVAILABLE("仅OC可用")
@protocol ALCollectionListSupplementaryViewProtocol <NSObject>

@required
    - (void)buildData:(id<ALCollectionListDataSectionProtocol> _Nullable) data
              section:(NSInteger) section;

@optional
    - (void)viewWillDisplay;
    - (void)viewEndDisplay;

@end
