import UIKit
import AvalonFramework

fileprivate class TableListDataRow: TableListDataRowProtocol {
    private(set) var cellType: (TableListCellProtocol).Type = TableListCell.self
    
    private(set) var cellHeight: CGFloat = 60
    
}

fileprivate class TableListDataSection: TableListDataSectionProtocol {
    private(set) var rows: [TableListDataRowProtocol]? = [TableListDataRow]()
    
    private(set) var relatedHeader: (TableListSupplementaryViewProtocol.Type)? = TableListHeader.self
    
    private(set) var relatedFooter: (TableListSupplementaryViewProtocol.Type)? = TableListFooter.self
    
    private(set) var headerHeight: CGFloat? = 40
    
    private(set) var footerHeight: CGFloat? = 20
    
    init() {
        rows?.append(TableListDataRow())
        rows?.append(TableListDataRow())
        rows?.append(TableListDataRow())
        rows?.append(TableListDataRow())
        rows?.append(TableListDataRow())
    }
}

fileprivate class TableListData: TableListDataProtocol {
    private(set) var sections: [TableListDataSectionProtocol]? = [TableListDataSection]()
    
    init() {
        sections?.append(TableListDataSection())
        sections?.append(TableListDataSection())
        sections?.append(TableListDataSection())
        sections?.append(TableListDataSection())
        sections?.append(TableListDataSection())
    }
}

fileprivate class TableListCell: UITableViewCell ,TableListCellProtocol {
    func config(rowData: TableListDataRowProtocol, indexPath: IndexPath) {
        self.textLabel?.text = "\(indexPath.section)-\(indexPath.row)"
    }
    
    func cellWillDisplay() {
        print("cellWillDisplay")
    }
    
    func cellEndDisplay() {
        print("cellEndDisplay")
    }
}

fileprivate class TableListHeader: UITableViewHeaderFooterView ,TableListSupplementaryViewProtocol {
    
    func config(sectionData: TableListDataSectionProtocol, section: Int) {
        print("TableListHeader config")
    }
    
    func viewWillDisplay() {
        print("headerWillDisplay")
    }
    
    func viewEndDisplay() {
        print("headerEndDisplay")
    }
}

fileprivate class TableListFooter: UITableViewHeaderFooterView ,TableListSupplementaryViewProtocol {
    func config(sectionData: TableListDataSectionProtocol, section: Int) {
        print("TableListFooter config")
    }
    
    func viewWillDisplay() {
        print("footerWillDisplay")
    }
    
    func viewEndDisplay() {
        print("footerEndDisplay")
    }
}

@objc(TestTableListSwiftVC)
class TestTableListSwiftVC: UIViewController {
    
    private lazy var tableListView = { () -> TableListView in
        let tableListView = TableListView(frame: .zero,
                                          style: .plain,
                                          tableViewProxy: self)
        return tableListView
    }()
    
    private let data = TableListData()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        view.addSubview(tableListView)
        tableListView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        tableListView.bindWithData(data: data)
    }
}

extension TestTableListSwiftVC: UITableViewDelegate {
    //  !!!: @objc是为了能够接受消息转发执行
    @objc(tableView:didSelectRowAtIndexPath:)
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        print("被点击了 \(indexPath)")
    }
}
