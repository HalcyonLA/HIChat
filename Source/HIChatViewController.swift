//
//  HIChatViewController.swift
//  HIChat
//
//  Created by Vlad Getman on 15.08.16.
//  Copyright © 2016 HalcyonInnovation. All rights reserved.
//

import UIKit
import HalcyonInnovationKit

public enum HIChatHeaderType: Int {
    case none
    case dayInterval
    case eachMessage
    
    fileprivate func useHeader() -> Bool {
        return self != .none
    }
}

open class HIChatViewController: UIViewController {
    
    open fileprivate(set) var tableView: UITableView = UITableView(frame: CGRect.zero, style: .grouped)
    open fileprivate(set) var refreshControl: UIRefreshControl = UIRefreshControl()
    open fileprivate(set) var messageInputView: HIMessageInputView!
    
    open var headerType: HIChatHeaderType = .dayInterval
    
    fileprivate var conversation: [[HIMessage]] = []
    fileprivate var dateFormatter = DateFormatter()
    
    open var messageFont: UIFont = UIFont.systemFont(ofSize: 15)
    open var userNameFont: UIFont = UIFont.systemFont(ofSize: 10)
    
    static func bundle() -> Bundle {
        let podBundle = Bundle(for: HIChatViewController.self)
        let url = podBundle.url(forResource: "HIChat", withExtension: "bundle")!
        return Bundle(url: url)!
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        dateFormatter.dateFormat = "dd MMM, eee, HH:mm"
        
        view.backgroundColor = .white
        
        tableView.frame = view.bounds
        tableView.autoresizingMask = [.flexibleBottomMargin, .flexibleTopMargin, .flexibleLeftMargin, .flexibleRightMargin, .flexibleWidth, .flexibleHeight]
        view.insertSubview(tableView, at: 0)
        
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor.clear
        tableView.keyboardDismissMode = .interactive
        tableView.estimatedSectionFooterHeight = 0
        tableView.estimatedSectionHeaderHeight = 0
        tableView.dataSource = self
        tableView.delegate = self
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.width, height: 8))
        headerView.backgroundColor = UIColor.clear
        tableView.tableHeaderView = headerView
        
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.width, height: 8))
        footerView.backgroundColor = UIColor.clear
        tableView.tableFooterView = footerView
        
        refreshControl.addTarget(self, action: #selector(didRequestOlderMessages), for: .valueChanged)
        refreshControl.layer.masksToBounds = true
        tableView.insertSubview(refreshControl, at: 0)
        
        tableView.registerReusable(HIMessageTextCell.self, withNib: false)
        tableView.registerReusable(HIMessagePhotoCell.self, withNib: false)
        tableView.registerReusableHeaderFooterViewClass(HIMessageHeaderView.self, withNib: false)
        
        messageInputView = HIMessageInputView(controller: self)
        messageInputView.tableView = tableView
        messageInputView.delegate = self
        view.insertSubview(messageInputView, aboveSubview: tableView)
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        messageInputView.enableKeyboardObservers = true
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        messageInputView.enableKeyboardObservers = false
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if #available(iOS 11.0, *) {
            let safeAreaInsets = UIApplication.shared.keyWindow!.safeAreaInsets
            if safeAreaInsets.bottom > 0 {
                var rect = tableView.frame
                rect.size.height = view.bounds.height - safeAreaInsets.bottom
                tableView.frame = rect
            }
        }
        tableView.tv_scrollToEnd(animated: false)
    }
    
    @objc open func didRequestOlderMessages() {
        refreshControl.endRefreshing()
    }
    
    open func cellClassForCustomType(_ message: HIMessage) -> HIMessageBaseCell.Type {
        return HIMessageBaseCell.self
    }
    
    open func sendMessage(_ message: HIMessage, scrollToBottom: Bool = true) {
        insertMessage(message)
        if scrollToBottom {
            tableView.tv_scrollToEnd(animated: true)
        }
    }
    
    open func receiveMessage(_ message: HIMessage, scrollToBottom: Bool = true) {
        insertMessage(message)
        if scrollToBottom {
            tableView.tv_scrollToEnd(animated: true)
        }
    }
    
    open func refreshMessages(_ animated: Bool = false, scrolling: Bool = true) {
        synced(self) {
            invalidateConversation()
            
            tableView.reloadData()
            if scrolling {
                tableView.scrollToEnd(animated: animated)
            }
        }
    }
    
    fileprivate func insertMessage(_ message: HIMessage) {
        synced(self) { 
            var insertSection = true
            if conversation.count > 0 {
                if conversation.last!.last!.date.isTheSameDay(message.date) {
                    insertSection = false
                }
            }
            tableView.beginUpdates()
            
            if insertSection {
                conversation.append([message])
                tableView.insertSections(IndexSet(integer: conversation.count - 1), with: .top)
            } else {
                var group = conversation.last!
                group.append(message)
                conversation[conversation.count - 1] = group
                let indexPath = IndexPath(row: group.count - 1, section: conversation.count - 1)
                tableView.insertRows(at: [indexPath], with: .top)
            }
            
            tableView.endUpdates()
        }
    }
    
    open func removeMessage(_ message: HIMessage) {
        synced(self) { 
            for (i, var group) in conversation.enumerated() {
                if let index = group.index(where: { (msg) -> Bool in
                    return msg === message
                }) {
                    tableView.beginUpdates()
                    if group.count == 1 {
                        conversation.remove(at: i)
                        tableView.deleteSections(IndexSet(integer: i), with: .top)
                    } else {
                        let indexPath = IndexPath(row: index, section: i)
                        group.remove(at: index)
                        conversation[i] = group
                        tableView.deleteRows(at: [indexPath], with: .top)
                    }
                    tableView.endUpdates()
                    return
                }
            }
        }
    }
    
    fileprivate func invalidateConversation() {
        var conversation: [[HIMessage]] = []
        let messages = self.messagesArray()
        
        if messages.count > 0 {
            switch headerType {
            case .none:
                conversation.append(messages)
                
            case .dayInterval:
                var groupIndex = 0
                for (i, message) in messages.enumerated() {
                    if i == 0 {
                        conversation.append([message])
                    } else {
                        let prevMessage = messages[i - 1]
                        if prevMessage.date.isTheSameDay(message.date) {
                            var group = conversation[groupIndex]
                            group.append(message)
                            conversation[groupIndex] = group
                        } else {
                            conversation.append([message])
                            groupIndex += 1
                        }
                    }
                }
                
            case .eachMessage:
                for message in messages {
                    conversation.append([message])
                }
            }
        }
        self.conversation = conversation
    }
}

extension HIChatViewController: UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return conversation.count
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversation[section].count
    }
    
    @objc(tableView:heightForRowAtIndexPath:) public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let message = conversation[indexPath.section][indexPath.row]
        var height = heightForMessage(message) + HIMessageBaseCell.margins.bottom + HIMessageBaseCell.margins.top
        if message.userName != nil {
            height += userNameFont.lineHeight
        }
        return height
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if headerType.useHeader() {
            return 40
        }
        return 0.01
    }
    
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = conversation[indexPath.section][indexPath.row]
        let cell: HIMessageBaseCell
        switch message.type {
        case .text:
            cell = tableView.dequeueReusableCellWithClass(HIMessageTextCell.self, indexPath: indexPath)
            
        case .photo:
            cell = tableView.dequeueReusableCellWithClass(HIMessagePhotoCell.self, indexPath: indexPath)
            
        case .custom:
            cell = tableView.dequeueReusableCellWithClass(cellClassForCustomType(message), indexPath: indexPath)
        }
        cell.dataSourse = self
        cell.delegate = self
        cell.textFont = messageFont
        cell.userNameFont = userNameFont
        
        cell.message = message
        
        let delegate = self as HIMessageDataSource
        if delegate.responds(to: #selector(HIMessageDataSource.configureCell(_:forMessage:))) {
            delegate.configureCell!(cell, forMessage: message)
        }
        
        return cell
    }
}

extension HIChatViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if headerType.useHeader() {
            let headerView = tableView.dequeueReusableHeaderFooterViewWithClass(HIMessageHeaderView.self)
            
            let date = conversation[section].first!.date
            
            headerView?.label.text = dateFormatter.string(from: date)
            
            return headerView
        }
        return nil
    }
}

extension HIChatViewController: HIMessageDelegate {
    
    open func inputView(_ inputView: HIMessageInputView, didSendMessage message: String) {
        
    }
    
    open func inputViewDidSelectMediaButton(_ inputView: HIMessageInputView) {
        
    }
    
    open func didSelectMediaInMessageCell(_ cell: HIMessageBaseCell) {
        
    }
    
    open func didSelectAvatarInMessageCell(_ cell: HIMessageBaseCell) {
        
    }
    
    open func didDeleteMessageInCell(_ cell: HIMessageBaseCell) {
        
    }
    
    open func didRetryRequestedMessageInCell(_ cell: HIMessageBaseCell) {
        
    }
    
    open func shouldBeCellFirstResponder(_ cell: HIMessageBaseCell) -> Bool {
        let isFirstResponder = messageInputView.textView.isFirstResponder
        if isFirstResponder {
            messageInputView.textView.overrideNextResponder = cell
        }
        return !isFirstResponder
    }
}

extension HIChatViewController: HIMessageDataSource {
    open func messagesArray() -> [HIMessage] {
        return []
    }
    
    open func heightForMessage(_ message: HIMessage) -> CGFloat {
        switch message.type {
        case .text:
            let height = message.messageText!.heightForWidth(HIMessageBaseCell.maxWidth - 25, font: messageFont) + 16
            return height
            
        case .photo:
            let size = mediaSize(forMessage: message)
            if size != .zero {
                return size.height
            }
            let height = mediaMessageWidth()
            return height
            
        default:
            return 44
        }
    }
    
    open func mediaMessageWidth() -> CGFloat {
        return HIMessageBaseCell.maxWidth
    }
    
    open func mediaSize(forMessage message: HIMessage) -> CGSize {
        return .zero
    }
    
    open func avatarsMode() -> HIMessageAvatarsMode {
        return .none
    }
}
