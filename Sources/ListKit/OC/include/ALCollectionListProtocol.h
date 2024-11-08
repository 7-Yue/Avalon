#import <UIKit/UIKit.h>
#import <CoreFoundation/CoreFoundation.h>

@protocol ALCollectionListDataSectionProtocol;
@protocol ALCollectionListDataRowProtocol;
@protocol ALCollectionListCellProtocol;
@protocol ALCollectionListHeaderProtocol;
@protocol ALCollectionListFooterProtocol;

// MARK: -- ALCollectionListDataProtocol
NS_SWIFT_UNAVAILABLE("仅OC可用")
@protocol ALCollectionListDataProtocol <NSObject>

@required
    @property(nonatomic, weak, readwrite, nullable) UICollectionView *collectionView;
    @property(nonatomic, copy, readonly, nullable) NSArray<id <ALCollectionListDataSectionProtocol>> *sections;

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
    @property(nonatomic, strong, readonly, nullable) Class<ALCollectionListHeaderProtocol> relatedHeader;
    @property(nonatomic, strong, readonly, nullable) Class<ALCollectionListFooterProtocol> relatedFooter;
@end

// MARK: -- ALCollectionListDataRowProtocol
NS_SWIFT_UNAVAILABLE("仅OC可用")
@protocol ALCollectionListDataRowProtocol <NSObject>

@required
    @property(nonatomic, strong, readonly, nonnull) Class<ALCollectionListCellProtocol> relatedCell;

@optional
    @property(nonatomic, assign, readonly) CGSize cellSize;
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

// MARK: -- ALCollectionListHeaderProtocol
NS_SWIFT_UNAVAILABLE("仅OC可用")
@protocol ALCollectionListHeaderProtocol <NSObject>

@required
    - (void)headerBuildData:(id<ALCollectionListDataSectionProtocol> _Nullable) data
                    section:(NSInteger) section;

@optional
    - (void)headerWillDisplay;
    - (void)headerEndDisplay;

@end

// MARK: -- ALTableListFooterProtocol
NS_SWIFT_UNAVAILABLE("仅OC可用")
@protocol ALCollectionListFooterProtocol <NSObject>

@required
    - (void)footerBuild:(id<ALCollectionListDataSectionProtocol> _Nullable) data
                section:(NSInteger) section;

@optional
    - (void)footerWillDisplay;
    - (void)footerEndDisplay;

@end
