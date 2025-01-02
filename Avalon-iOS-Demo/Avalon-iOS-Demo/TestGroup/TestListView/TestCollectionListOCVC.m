#import "TestCollectionListOCVC.h"
#import <AvalonFramework/AvalonFramework.h>
#import "Masonry.h"

//  MARK:   --  TestCollectionListCell
@interface TestCollectionListCell : UICollectionViewCell <ALCollectionListCellProtocol>

@property (nonatomic, strong) UILabel *label;

@end

@implementation TestCollectionListCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.label = [[UILabel alloc] initWithFrame:CGRectZero];
        self.label.textColor = [UIColor.blackColor colorWithAlphaComponent:0.3];
        self.label.font = [UIFont systemFontOfSize:10];
        self.label.numberOfLines = 0;
        [self.contentView addSubview:self.label];
        [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentView);
        }];
    }
    return self;
}

- (void)cellBuildWithData:(id<ALCollectionListDataRowProtocol>)data indexPath:(NSIndexPath *)indexPath {
    self.contentView.backgroundColor = [UIColor.lightGrayColor colorWithAlphaComponent:0.3];
    self.label.text = [NSString stringWithFormat:@"%@", indexPath];
}


@end

//  MARK:   --  TestCollectionListRowData
@interface TestCollectionListRowData : NSObject <ALCollectionListDataRowProtocol>

@end

@implementation TestCollectionListRowData

- (Class<ALCollectionListCellProtocol>)relatedCell {
    return TestCollectionListCell.class;
}

- (CGSize (^)(CGSize))dynamicCellSize {
    return ^CGSize (CGSize collectionViewSize) {
        return CGSizeMake(100, 80);
    };
}

@end

//  MARK:   --  TestCollectionListSectionHeader
@interface TestCollectionListSectionHeader : UICollectionReusableView <ALCollectionListHeaderProtocol>

@end

@implementation TestCollectionListSectionHeader

- (void)headerBuildData:(id<ALCollectionListDataSectionProtocol>)data section:(NSInteger)section {
    self.backgroundColor = [UIColor.redColor colorWithAlphaComponent:0.3];
}

@end

//  MARK:   --  TestCollectionListSectionFooter
@interface TestCollectionListSectionFooter : UICollectionReusableView <ALCollectionListFooterProtocol>

@end

@implementation TestCollectionListSectionFooter

- (void)footerBuild:(id<ALCollectionListDataSectionProtocol>)data section:(NSInteger)section {
    self.backgroundColor = [UIColor.greenColor colorWithAlphaComponent:0.3];
}

@end

//  MARK:   --  TestCollectionListSectionData
@interface TestCollectionListSectionData : NSObject<ALCollectionListDataSectionProtocol>
@property(nonatomic, copy, readwrite, nullable) NSArray<id <ALCollectionListDataRowProtocol>> *rows;
@end

@implementation TestCollectionListSectionData

- (instancetype)init {
    self = [super init];
    if (self) {
        self.rows = @[
            [TestCollectionListRowData new],
            [TestCollectionListRowData new],
            [TestCollectionListRowData new],
            [TestCollectionListRowData new],
            [TestCollectionListRowData new],
        ];
    }
    return self;
}

- (UIEdgeInsets)inset {
    return UIEdgeInsetsMake(10, 30, 10, 30);
}

- (double)minimumLineSpacing {
    return 20;
}

- (double)minimumInteritemSpacing {
    return 10;
}

- (CGSize)headerSize {
    return CGSizeMake(30, 30);
}

- (CGSize)footerSize {
    return CGSizeMake(50, 50);
}

- (Class<ALCollectionListHeaderProtocol>)relatedHeader {
    return TestCollectionListSectionHeader.class;
}

- (Class<ALCollectionListFooterProtocol>)relatedFooter {
    return TestCollectionListSectionFooter.class;
}

@end

//  MARK:   --  TestCollectionListData
@interface TestCollectionListData : NSObject <ALCollectionListDataProtocol>
@property(nonatomic, weak, readwrite, nullable) UICollectionView *collectionView;
@property(nonatomic, copy, readwrite, nullable) NSArray<id <ALCollectionListDataSectionProtocol>> *sections;
@end

@implementation TestCollectionListData
- (instancetype)init {
    self = [super init];
    if (self) {
        self.sections = @[
            [TestCollectionListSectionData new],
            [TestCollectionListSectionData new],
            [TestCollectionListSectionData new],
            [TestCollectionListSectionData new],
        ];
    }
    return self;
}

@end

//  MARK:   --  TestCollectionListOCVC
@interface TestCollectionListOCVC ()
@property (nonatomic, strong) ALCollectionListView *collectionListView;
@property (nonatomic, strong) TestCollectionListData *data;
@end

@implementation TestCollectionListOCVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;

    [self.view addSubview:self.collectionListView];
    [self.collectionListView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [self.collectionListView bindWithData:self.data];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"被点击了");
}


- (ALCollectionListView *)collectionListView {
    if(!_collectionListView) {
        _collectionListView = [[ALCollectionListView alloc] initWithFrame:CGRectZero
                                                          scrollDirection:UICollectionViewScrollDirectionVertical
                                                      collectionViewProxy:self];
    }
    return _collectionListView;
}

- (TestCollectionListData *)data {
    if (!_data) {
        _data = [[TestCollectionListData alloc] init];
    }
    return _data;
}
@end
