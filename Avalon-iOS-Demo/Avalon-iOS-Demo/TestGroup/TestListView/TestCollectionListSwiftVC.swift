import UIKit
import AvalonFramework
import SnapKit

fileprivate class CollectionListData: CollectionListDataProtocol {
    var sections: [CollectionListDataSectionProtocol]? = [CollectionListSectionData]()
    
    init() {
        sections?.append(CollectionListSectionData())
        sections?.append(CollectionListSectionData())
        sections?.append(CollectionListSectionData())
        sections?.append(CollectionListSectionData())
        sections?.append(CollectionListSectionData())
    }
}

fileprivate class CollectionListSectionData: CollectionListDataSectionProtocol {
    var rows: [CollectionListDataRowProtocol]? = [CollectionListRowData]()
    
    var relatedHeader: CollectionListSupplementaryViewProtocol.Type? = CollectionListHeader.self
    
    var relatedFooter: CollectionListSupplementaryViewProtocol.Type? = CollectionListFooter.self
    
    var inset: UIEdgeInsets? = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
    
    var minimumLineSpacing: CGFloat? = 10
    
    var minimumInteritemSpacing: CGFloat? = 20
    
    var headerSize: CGSize? = CGSize(width: 100, height: 40)
    var footerSize: CGSize? = CGSize(width: 200, height: 60)
    
    init() {
        rows?.append(CollectionListRowData())
        rows?.append(CollectionListRowData())
        rows?.append(CollectionListRowData())
        rows?.append(CollectionListRowData())
        rows?.append(CollectionListRowData())
    }
    
}

fileprivate class CollectionListRowData: CollectionListDataRowProtocol {
    var cellType: CollectionListCellProtocol.Type = CollectionListCell.self
    var cellSize: ((CollectionViewSize) -> CGSize)? {
        return { collectionViewSize in
            return CGSize(width: 60, height: 60)
         }
    }
}

fileprivate class CollectionListCell: UICollectionViewCell, CollectionListCellProtocol {
    private lazy var label = { () -> UILabel in
        let label = UILabel(frame: .zero)
        return label
    }()
    
    func config(rowData: CollectionListDataRowProtocol, indexPath: IndexPath) {
        contentView.addSubview(label)
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        label.text = "\(indexPath.section)-\(indexPath.row)"
    }
    
    func cellWillDisplay() {
        print("cellWillDisplay")
    }
    
    func cellEndDisplay() {
        print("cellEndDisplay")
    }
}

fileprivate class CollectionListHeader: UICollectionReusableView, CollectionListSupplementaryViewProtocol {
    func config(sectionData: CollectionListDataSectionProtocol, section: Int) {
        backgroundColor = .yellow
    }
    
    func viewWillDisplay() {
        print("heafer viewWillDisplay")
    }
    
    func viewEndDisplay() {
        print("heafer viewEndDisplay")
    }
    
}

fileprivate class CollectionListFooter: UICollectionReusableView, CollectionListSupplementaryViewProtocol {
    func config(sectionData: CollectionListDataSectionProtocol, section: Int) {
        backgroundColor = .red
    }
    
    func viewWillDisplay() {
        print("footer viewWillDisplay")
    }
    
    func viewEndDisplay() {
        print("footer viewEndDisplay")
    }
    
    
}

@objc(TestCollectionListSwiftVC)
class TestCollectionListSwiftVC: UIViewController {
    private lazy var collectionListView = { () -> CollectionListView in
        let collectionListView = CollectionListView(frame: .zero,
                                                    scrollDirection: .vertical,
                                                    collectionViewProxy: self)
        return collectionListView
    }()
    
    private let data = CollectionListData()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        view.addSubview(collectionListView)
        collectionListView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        collectionListView.bindWithData(data: data)
    }

}

extension TestCollectionListSwiftVC {
    //  !!!: @objc是为了能够接受消息转发执行
    @objc(collectionView: didSelectItemAtIndexPath:)
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        print("被点击了 \(indexPath)")
    }
}
