import UIKit

public protocol CollectionListDataProtocol {
    var sections: [CollectionListDataSectionProtocol]? { get }
}

public protocol CollectionListDataSectionProtocol {
    var rows: [CollectionListDataRowProtocol]? { get }
    var relatedHeader: CollectionListSupplementaryViewProtocol.Type? { get }
    var relatedFooter: CollectionListSupplementaryViewProtocol.Type? { get }
    var inset: UIEdgeInsets? { get }
    var minimumLineSpacing: CGFloat? { get }
    var minimumInteritemSpacing: CGFloat? { get }
    var headerSize: CGSize? { get }
    var footerSize: CGSize? { get }
}

public protocol CollectionListDataRowProtocol {
    typealias CollectionViewSize = CGSize
    var cellType: CollectionListCellProtocol.Type { get }
    var cellSize: ((CollectionViewSize) -> CGSize)? { get }
}

public protocol CollectionListSupplementaryViewProtocol where Self: UICollectionReusableView  {
    func config(sectionData: CollectionListDataSectionProtocol, section: Int)
    func viewWillDisplay()
    func viewEndDisplay()
}

public protocol CollectionListCellProtocol where Self: UICollectionViewCell  {
    func config(rowData: CollectionListDataRowProtocol, indexPath: IndexPath)
    func cellWillDisplay()
    func cellEndDisplay()
}
