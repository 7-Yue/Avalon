import UIKit

public protocol TableListDataProtocol {
    var sections: [TableListDataSectionProtocol]? { get }
}

public protocol TableListDataSectionProtocol {
    var rows: [TableListDataRowProtocol]? { get }
    var relatedHeader: TableListSupplementaryViewProtocol.Type? { get }
    var relatedFooter: TableListSupplementaryViewProtocol.Type? { get }
    var headerHeight: CGFloat? { get }
    var footerHeight: CGFloat? { get }
}

public protocol TableListSupplementaryViewProtocol where Self: UITableViewHeaderFooterView  {
    func config(sectionData: TableListDataSectionProtocol, section: Int)
    func viewWillDisplay()
    func viewEndDisplay()
}

public protocol TableListDataRowProtocol {
    var cellType: (TableListCellProtocol).Type { get }
    var cellHeight: CGFloat { get }
}

public protocol TableListCellProtocol where Self: UITableViewCell  {
    func config(rowData: TableListDataRowProtocol, indexPath: IndexPath)
    func cellWillDisplay()
    func cellEndDisplay()
}
