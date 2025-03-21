#import "TestTableListOCVC.h"
#import <AvalonFramework/AvalonFramework.h>
#import "Masonry.h"

//  MARK:   --  TestTableListCell
@interface TestTableListCell : UITableViewCell <ALTableListCellProtocol>

@end

@implementation TestTableListCell

- (void)cellBuildWithData:(id<ALTableListDataRowsProtocol>)data indexPath:(NSIndexPath *)indexPath {
    self.contentView.backgroundColor = [UIColor.lightGrayColor colorWithAlphaComponent:0.3];
    self.textLabel.text = [NSString stringWithFormat:@"%@", indexPath];
    self.textLabel.font = [UIFont systemFontOfSize:10];
    self.textLabel.numberOfLines = 0;
}

@end

//  MARK:   --  TestTableListRowData
@interface TestTableListRowData : NSObject <ALTableListDataRowsProtocol>

@end
@implementation TestTableListRowData

- (Class<ALTableListCellProtocol>)relatedCell {
    return TestTableListCell.class;
}

- (double)cellHeight {
    return 120;
}

@end

//  MARK:   --  TestTableListHeader
@interface TestTableListHeader : UITableViewHeaderFooterView <ALTableListSupplementaryViewProtocol>

@end
@implementation TestTableListHeader

- (void)buildData:(id<ALTableListDataSectionProtocol>)data section:(NSInteger)section {
    self.contentView.backgroundColor = [UIColor.redColor colorWithAlphaComponent:0.3];
}

@end

//  MARK:   --  TestTableListFooter
@interface TestTableListFooter : UITableViewHeaderFooterView <ALTableListSupplementaryViewProtocol>

@end
@implementation TestTableListFooter

- (void)buildData:(id<ALTableListDataSectionProtocol>)data section:(NSInteger)section {
    self.contentView.backgroundColor = [UIColor.greenColor colorWithAlphaComponent:0.3];
}

@end


//  MARK:   --  TestTableListSectionData
@interface TestTableListSectionData : NSObject <ALTableListDataSectionProtocol>
@property(nonatomic, copy, readwrite, nullable) NSArray<id <ALTableListDataRowsProtocol>> *rows;
@end

@implementation TestTableListSectionData

- (instancetype)init {
    self = [super init];
    if (self) {
        self.rows = @[
            [TestTableListRowData new],
            [TestTableListRowData new],
            [TestTableListRowData new],
        ];
    }
    return self;
}

- (double)headerHeight {
    return 40;
}

- (double)footerHeight {
    return 20;
}

- (Class<ALTableListSupplementaryViewProtocol>)relatedHeader {
    return TestTableListHeader.class;
}
- (Class<ALTableListSupplementaryViewProtocol>)relatedFooter {
    return TestTableListFooter.class;
}

@end

//  MARK:   --  TestTableListData
@interface TestTableListData : NSObject <ALTableListDataProtocol>
@property(nonatomic, copy, readwrite, nullable) NSArray<id <ALTableListDataSectionProtocol>> *sections;
@property(nonatomic, weak, readwrite, nullable) UITableView *tablewView;
@end

@implementation TestTableListData

- (instancetype)init {
    self = [super init];
    if (self) {
        self.sections = @[
            [TestTableListSectionData new],
            [TestTableListSectionData new],
            [TestTableListSectionData new],
            [TestTableListSectionData new],
            [TestTableListSectionData new],
        ];
    }
    return self;
}

@end


//  MARK:   --  TestTableListOCVC
@interface TestTableListOCVC ()

@property (nonatomic, strong) ALTableListView *tableListView;
@property (nonatomic, strong) TestTableListData *data;

@end

@implementation TestTableListOCVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;

    [self.view addSubview:self.tableListView];
    [self.tableListView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [self.tableListView bindWithData:self.data];
}

//  内部通过Proxy延展了tableview的代理函数，如果内部没有帮助实现的，外部可以直接实现函数即可
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"点击啦");
}

- (ALTableListView *)tableListView {
    if(!_tableListView) {
        _tableListView = [[ALTableListView alloc] initWithFrame:CGRectZero
                                                          style:UITableViewStylePlain
                                                 tableViewProxy:self];
    }
    return _tableListView;
}

- (TestTableListData *)data {
    if (!_data) {
        _data = [[TestTableListData alloc] init];
    }
    return _data;
}


@end
