//
//  FeedCellView.swift
//  CZInstagram
//
//  Created by Cheng Zhang on 1/4/17.
//  Copyright © 2017 Cheng Zhang. All rights reserved.
//

import CZUtils
import ReactiveListViewKit
import SDWebImage

class FeedDetailsCellView: CZNibLoadableView, CZFeedCellViewSizeCalculatable {
    @IBOutlet var stackView: UIStackView!
    @IBOutlet var userInfoStackView: UIStackView!
    @IBOutlet var contentStackView: UIStackView!
    @IBOutlet var userNameLabel: UILabel!
    @IBOutlet var contentLabel: UILabel!
    @IBOutlet var portaitView: UIImageView!
    @IBOutlet var bottomDivider: UIView!

    private var viewModel: FeedDetailsCellViewModel    
    var diffId: String {return viewModel.diffId}
    var onAction: OnAction?

    required init(viewModel: CZFeedViewModelable?, onAction: OnAction?) {
        guard let viewModel = viewModel as? FeedDetailsCellViewModel else {
            fatalError("Incorrect ViewModel type.")
        }
        self.viewModel = viewModel
        self.onAction = onAction
        super.init(frame: .zero)
        config(with: viewModel)
    }

    required init?(coder aDecoder: NSCoder) { fatalError("Must call designated initializer `init(viewModel:onAction:)`")  }

    func config(with viewModel: CZFeedViewModelable?) {
        guard let viewModel = viewModel as? FeedDetailsCellViewModel else {
            fatalError("Incorrect ViewModel type.")
        }
        if let portraitUrl = viewModel.portraitUrl {
            portaitView.sd_setImage(with: portraitUrl)
        }
        portaitView.roundToCircle()
        userNameLabel.text = viewModel.userName
        contentLabel.text = viewModel.content
    }

    /// prevViewModel is used for diff Algo
    func config(with viewModel: CZFeedViewModelable?, prevViewModel: CZFeedViewModelable?) {}

    static func sizeThatFits(_ containerSize: CGSize, viewModel: CZFeedViewModelable) -> CGSize {
        let tmpView = FeedDetailsCellView(viewModel: viewModel, onAction: nil)
        tmpView.translatesAutoresizingMaskIntoConstraints = false
        tmpView.layoutIfNeeded()
        var size = tmpView.systemLayoutSizeFitting(CGSize(width: containerSize.width, height: 0))
        size.width = containerSize.width
        return size
    }
}

// MARK: - Private methods
private extension FeedDetailsCellView {

}
