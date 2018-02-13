//
//  TransactionDetailCollectionViewCell.swift
//  breadwallet
//
//  Created by Adrian Corscadden on 2017-02-09.
//  Copyright © 2017 breadwallet LLC. All rights reserved.
//

import UIKit
import SafariServices

class TransactionDetailCollectionViewCell : UICollectionViewCell {

    //MARK: - Public
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: .UIKeyboardWillHide, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func set(transaction: Transaction, isBchSwapped: Bool, rate: Rate, rates: [Rate], maxDigits: Int) {
        timestamp.text = transaction.longTimestamp
        amount.text = String(format: transaction.direction.amountFormat, "\(transaction.amountDescription(isBchSwapped: isBchSwapped, rate: rate, maxDigits: maxDigits))")
        status.text = transaction.status
        comment.text = transaction.comment
        amountDetails.text = transaction.amountDetails(isBchSwapped: isBchSwapped, rate: rate, rates: rates, maxDigits: maxDigits)
        addressHeader.text = transaction.direction.addressHeader.capitalized
        fullAddress.setTitle(transaction.toAddress ?? "", for: .normal)
        txHash.setTitle(transaction.hash, for: .normal)
        availability.isHidden = !transaction.shouldDisplayAvailableToSpend
        blockHeight.text = transaction.blockHeight
        self.transaction = transaction
        self.rate = rate
    }

    var closeCallback: (() -> Void)? {
        didSet {
            header.closeCallback = closeCallback
        }
    }
    
    var txDetailCallback: (() -> Void)? {
        didSet {
            blockExplorerButton.tap = txDetailCallback
        }
    }

    var didBeginEditing: (() -> Void)?
    var didEndEditing: (() -> Void)?
    var modalTransitioningDelegate: ModalTransitionDelegate?

    var kvStore: BRReplicatedKVStore?
    var transaction: Transaction?
    var rate: Rate?
    var store: Store? {
        didSet {
            if oldValue == nil {
                guard let store = store else { return }
                header.faqInfo = (store, ArticleIds.transactionDetails)
            }
        }
    }

    //MARK: - Private
    private let header = ModalHeaderView(title: S.TransactionDetails.title, style: .dark)
    private let timestamp = UILabel(font: .customBold(size: 14.0), color: .grayTextTint)
    private let amount = UILabel(font: .customBold(size: 26.0), color: .darkText)
    private let separators = (0...5).map { _ in UIView(color: .secondaryShadow) }
    private let statusHeader = UILabel(font: .customBold(size: 14.0), color: .grayTextTint)
    private let status = UILabel.wrapping(font: .customBody(size: 13.0), color: .darkText)
    private let commentsHeader = UILabel(font: .customBold(size: 14.0), color: .grayTextTint)
    private let comment = UITextView()
    private let amountHeader = UILabel(font: .customBold(size: 14.0), color: .grayTextTint)
    private let amountDetails = UILabel.wrapping(font: .customBody(size: 13.0), color: .darkText)
    private let blockExplorerButton = UIButton(type: .system)
    private let moreContentView = UIView()
    private let addressHeader = UILabel(font: .customBold(size: 14.0), color: .grayTextTint)
    private let fullAddress = UIButton(type: .system)
    private let headerHeight: CGFloat = 48.0
    private let scrollViewContent = UIView()
    private let scrollView = UIScrollView()
    let txHash = UIButton(type: .system)
    private let txHashHeader = UILabel(font: .customBold(size: 14.0), color: .grayTextTint)
    private let availability = UILabel(font: .customBold(size: 13.0), color: .txListGreen)
    private let blockHeightHeader = UILabel(font: .customBold(size: 14.0), color: .grayTextTint)
    private let blockHeight = UILabel(font: .customBody(size: 13.0), color: .darkText)
    private var scrollViewHeight: NSLayoutConstraint?

    private func setup() {
        addSubviews()
        addConstraints()
        setData()
    }

    private func addSubviews() {
        contentView.addSubview(scrollView)
        contentView.addSubview(header)
        scrollView.addSubview(scrollViewContent)
        scrollViewContent.addSubview(timestamp)
        scrollViewContent.addSubview(amount)
        separators.forEach { scrollViewContent.addSubview($0) }
        scrollViewContent.addSubview(statusHeader)
        scrollViewContent.addSubview(status)
        scrollViewContent.addSubview(availability)
        scrollViewContent.addSubview(commentsHeader)
        scrollViewContent.addSubview(comment)
        scrollViewContent.addSubview(amountHeader)
        scrollViewContent.addSubview(amountDetails)
        scrollViewContent.addSubview(addressHeader)
        scrollViewContent.addSubview(fullAddress)
        scrollViewContent.addSubview(txHashHeader)
        scrollViewContent.addSubview(txHash)
        scrollViewContent.addSubview(blockHeightHeader)
        scrollViewContent.addSubview(blockHeight)
        scrollViewContent.addSubview(blockExplorerButton)
        //scrollViewContent.addSubview(moreContentView)
        //moreContentView.addSubview(blockExplorerButton)
    }

    private func addConstraints() {
        header.constrainTopCorners(height: headerHeight)
        scrollViewHeight = scrollView.heightAnchor.constraint(equalTo: contentView.heightAnchor, constant: -headerHeight)
        scrollView.constrain([
            scrollView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: headerHeight),
            scrollView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            scrollViewHeight ])
        scrollViewContent.constrain([
            scrollViewContent.topAnchor.constraint(equalTo: scrollView.topAnchor),
            scrollViewContent.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            scrollViewContent.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            scrollViewContent.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            scrollViewContent.widthAnchor.constraint(equalTo: scrollView.widthAnchor) ])
        timestamp.constrain([
            timestamp.leadingAnchor.constraint(equalTo: scrollViewContent.leadingAnchor, constant: C.padding[2]),
            timestamp.topAnchor.constraint(equalTo: scrollViewContent.topAnchor, constant: C.padding[3]),
            timestamp.trailingAnchor.constraint(equalTo: scrollViewContent.trailingAnchor, constant: -C.padding[2]) ])
        amount.constrain([
            amount.leadingAnchor.constraint(equalTo: timestamp.leadingAnchor),
            amount.trailingAnchor.constraint(equalTo: timestamp.trailingAnchor),
            amount.topAnchor.constraint(equalTo: timestamp.bottomAnchor, constant: C.padding[1]) ])
        separators[0].constrain([
            separators[0].topAnchor.constraint(equalTo: amount.bottomAnchor, constant: C.padding[2]),
            separators[0].leadingAnchor.constraint(equalTo: amount.leadingAnchor),
            separators[0].trailingAnchor.constraint(equalTo: amount.trailingAnchor),
            separators[0].heightAnchor.constraint(equalToConstant: 1.0)])
        statusHeader.constrain([
            statusHeader.topAnchor.constraint(equalTo: separators[0].bottomAnchor, constant: C.padding[2]),
            statusHeader.leadingAnchor.constraint(equalTo: separators[0].leadingAnchor),
            statusHeader.trailingAnchor.constraint(equalTo: separators[0].trailingAnchor) ])
        status.constrain([
            status.topAnchor.constraint(equalTo: statusHeader.bottomAnchor),
            status.leadingAnchor.constraint(equalTo: statusHeader.leadingAnchor),
            status.trailingAnchor.constraint(equalTo: statusHeader.trailingAnchor) ])
        availability.constrain([
            availability.topAnchor.constraint(equalTo: status.bottomAnchor),
            availability.leadingAnchor.constraint(equalTo: status.leadingAnchor)])
        separators[1].constrain([
            separators[1].topAnchor.constraint(equalTo: availability.bottomAnchor, constant: C.padding[2]),
            separators[1].leadingAnchor.constraint(equalTo: status.leadingAnchor),
            separators[1].trailingAnchor.constraint(equalTo: status.trailingAnchor),
            separators[1].heightAnchor.constraint(equalToConstant: 1.0) ])
        commentsHeader.constrain([
            commentsHeader.topAnchor.constraint(equalTo: separators[1].bottomAnchor, constant: C.padding[2]),
            commentsHeader.leadingAnchor.constraint(equalTo: separators[1].leadingAnchor),
            commentsHeader.trailingAnchor.constraint(equalTo: separators[1].trailingAnchor) ])
        comment.constrain([
            comment.topAnchor.constraint(equalTo: commentsHeader.bottomAnchor),
            comment.leadingAnchor.constraint(equalTo: commentsHeader.leadingAnchor),
            comment.trailingAnchor.constraint(equalTo: commentsHeader.trailingAnchor) ])
        separators[2].constrain([
            separators[2].topAnchor.constraint(equalTo: comment.bottomAnchor, constant: C.padding[2]),
            separators[2].leadingAnchor.constraint(equalTo: comment.leadingAnchor),
            separators[2].trailingAnchor.constraint(equalTo: comment.trailingAnchor),
            separators[2].heightAnchor.constraint(equalToConstant: 1.0) ])
        amountHeader.constrain([
            amountHeader.topAnchor.constraint(equalTo: separators[2].bottomAnchor, constant: C.padding[2]),
            amountHeader.leadingAnchor.constraint(equalTo: separators[2].leadingAnchor),
            amountHeader.trailingAnchor.constraint(equalTo: separators[2].trailingAnchor) ])
        amountDetails.constrain([
            amountDetails.topAnchor.constraint(equalTo: amountHeader.bottomAnchor),
            amountDetails.leadingAnchor.constraint(equalTo: amountHeader.leadingAnchor),
            amountDetails.trailingAnchor.constraint(equalTo: amountHeader.trailingAnchor) ])
        separators[3].constrain([
            separators[3].topAnchor.constraint(equalTo: amountDetails.bottomAnchor, constant: C.padding[2]),
            separators[3].leadingAnchor.constraint(equalTo: amountDetails.leadingAnchor),
            separators[3].trailingAnchor.constraint(equalTo: amountDetails.trailingAnchor),
            separators[3].heightAnchor.constraint(equalToConstant: 1.0) ])
        addressHeader.constrain([
            addressHeader.topAnchor.constraint(equalTo: separators[3].bottomAnchor, constant: C.padding[2]),
            addressHeader.leadingAnchor.constraint(equalTo: separators[3].leadingAnchor),
            addressHeader.trailingAnchor.constraint(equalTo: separators[3].trailingAnchor) ])
        fullAddress.constrain([
            fullAddress.topAnchor.constraint(equalTo: addressHeader.bottomAnchor),
            fullAddress.leadingAnchor.constraint(equalTo: addressHeader.leadingAnchor),
            fullAddress.trailingAnchor.constraint(equalTo: addressHeader.trailingAnchor) ])
        separators[4].constrain([
            separators[4].topAnchor.constraint(equalTo: fullAddress.bottomAnchor, constant: C.padding[2]),
            separators[4].leadingAnchor.constraint(equalTo: fullAddress.leadingAnchor),
            separators[4].trailingAnchor.constraint(equalTo: fullAddress.trailingAnchor),
            separators[4].heightAnchor.constraint(equalToConstant: 1.0) ])
        txHashHeader.constrain([
            txHashHeader.topAnchor.constraint(equalTo: separators[4].bottomAnchor, constant: C.padding[2]),
            txHashHeader.leadingAnchor.constraint(equalTo: separators[4].leadingAnchor),
            txHashHeader.trailingAnchor.constraint(equalTo: separators[4].trailingAnchor)])
        txHash.constrain([
            txHash.topAnchor.constraint(equalTo: txHashHeader.bottomAnchor),
            txHash.leadingAnchor.constraint(equalTo: txHashHeader.leadingAnchor),
            txHash.trailingAnchor.constraint(equalTo: txHashHeader.trailingAnchor)])
        blockHeightHeader.constrain([
            blockHeightHeader.topAnchor.constraint(equalTo: txHash.bottomAnchor, constant: C.padding[1]),
            blockHeightHeader.leadingAnchor.constraint(equalTo: txHashHeader.leadingAnchor) ])
        blockHeight.constrain([
            blockHeight.leadingAnchor.constraint(equalTo: blockHeightHeader.leadingAnchor),
            blockHeight.topAnchor.constraint(equalTo: blockHeightHeader.bottomAnchor) ])
        blockExplorerButton.constrain([
            blockExplorerButton.topAnchor.constraint(equalTo: blockHeight.bottomAnchor, constant: C.padding[2]),
            blockExplorerButton.leadingAnchor.constraint(equalTo: blockHeight.leadingAnchor),
            blockExplorerButton.bottomAnchor.constraint(equalTo: scrollViewContent.bottomAnchor, constant: -C.padding[2]) ])
        /*
        moreContentView.constrain([
            moreContentView.leadingAnchor.constraint(equalTo: separators[3].leadingAnchor),
            moreContentView.topAnchor.constraint(equalTo: separators[3].bottomAnchor, constant: C.padding[2]),
            moreContentView.trailingAnchor.constraint(equalTo: separators[3].trailingAnchor),
            moreContentView.bottomAnchor.constraint(equalTo: scrollViewContent.bottomAnchor, constant: -C.padding[2]) ])
        blockExplorerButton.constrain([
            blockExplorerButton.leadingAnchor.constraint(equalTo: moreContentView.leadingAnchor),
            blockExplorerButton.topAnchor.constraint(equalTo: moreContentView.topAnchor),
            blockExplorerButton.bottomAnchor.constraint(equalTo: moreContentView.bottomAnchor) ])
    */
    }

    private func setData() {
        backgroundColor = .white

        statusHeader.text = S.TransactionDetails.statusHeader
        commentsHeader.text = S.TransactionDetails.commentsHeader
        amountHeader.text = S.TransactionDetails.amountHeader
        availability.text = S.Transaction.available

        comment.font = .customBody(size: 13.0)
        comment.textColor = .darkText
        comment.isScrollEnabled = false
        comment.returnKeyType = .done
        comment.delegate = self

        blockExplorerButton.setTitle(S.TransactionDetails.showBlockExplorer, for: .normal)
        blockExplorerButton.tintColor = .grayTextTint
        blockExplorerButton.titleLabel?.font = .customBold(size: 14.0)

        amount.minimumScaleFactor = 0.5
        amount.adjustsFontSizeToFitWidth = true

        fullAddress.titleLabel?.font = .customBody(size: 13.0)
        fullAddress.titleLabel?.numberOfLines = 0
        fullAddress.titleLabel?.lineBreakMode = .byCharWrapping
        fullAddress.tintColor = .darkText
        fullAddress.tap = strongify(self) { myself in
            myself.fullAddress.tempDisable()
            myself.store?.trigger(name: .lightWeightAlert(S.Receive.copied))
            UIPasteboard.general.string = myself.fullAddress.titleLabel?.text
        }
        fullAddress.contentHorizontalAlignment = .left

        txHashHeader.text = S.TransactionDetails.txHashHeader

        txHash.titleLabel?.font = .customBody(size: 13.0)
        txHash.titleLabel?.numberOfLines = 0
        txHash.titleLabel?.lineBreakMode = .byCharWrapping
        txHash.tintColor = .darkText
        txHash.contentHorizontalAlignment = .left
        txHash.tap = strongify(self) { myself in
            myself.txHash.tempDisable()
            myself.store?.trigger(name: .lightWeightAlert(S.Receive.copied))
            UIPasteboard.general.string = myself.txHash.titleLabel?.text
        }
        
        
        blockHeightHeader.text = S.TransactionDetails.blockHeightLabel
    }

    override func layoutSubviews() {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 6.0, height: 6.0)).cgPath
        let maskLayer = CAShapeLayer()
        maskLayer.path = path
        layer.mask = maskLayer
    }

    fileprivate func saveComment(comment: String) {
        guard let kvStore = self.kvStore else { return }
        if let metaData = transaction?.metaData {
            metaData.comment = comment
            do {
                let _ = try kvStore.set(metaData)
            } catch let error {
                print("could not update metadata: \(error)")
            }
        } else {
            guard let rate = self.rate else { return }
            guard let transaction = self.transaction else { return }
            let newMetaData = TxMetaData(transaction: transaction.rawTransaction, exchangeRate: rate.rate, exchangeRateCurrency: rate.code, feeRate: 0.0, deviceId: UserDefaults.standard.deviceID)
            newMetaData.comment = comment
            do {
                let _ = try kvStore.set(newMetaData)
            } catch let error {
                print("could not update metadata: \(error)")
            }
        }
        if let tx = transaction {
            store?.trigger(name: .txMemoUpdated(tx.hash))
        }
    }

    //MARK: - Keyboard Notifications
    @objc private func keyboardWillShow(notification: Notification) {
        modalTransitioningDelegate?.shouldDismissInteractively = false
        respondToKeyboardAnimation(notification: notification)
    }

    @objc private func keyboardWillHide(notification: Notification) {
        modalTransitioningDelegate?.shouldDismissInteractively = true
        respondToKeyboardAnimation(notification: notification)
    }

    private func respondToKeyboardAnimation(notification: Notification) {
        guard let info = KeyboardNotificationInfo(notification.userInfo) else { return }
        guard let height = scrollViewHeight else { return }
        height.constant = height.constant + info.deltaY
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TransactionDetailCollectionViewCell : UITextViewDelegate {

    func textViewDidBeginEditing(_ textView: UITextView) {
        didBeginEditing?()
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        didEndEditing?()
        guard let text = textView.text else { return }
        saveComment(comment: text)
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard text.rangeOfCharacter(from: CharacterSet.newlines) == nil else {
            textView.resignFirstResponder()
            return false
        }

        let count = (textView.text ?? "").utf8.count + text.utf8.count
        if count > C.maxMemoLength {
            return false
        } else {
            return true
        }
    }
}
