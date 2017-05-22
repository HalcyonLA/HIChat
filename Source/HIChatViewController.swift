//
//  HIChatViewController.swift
//  HIChat
//
//  Created by Vlad Getman on 15.08.16.
//  Copyright © 2016 HalcyonInnovation. All rights reserved.
//

import UIKit
import HalcyonInnovationKit

open class HIChatViewController: UIViewController {
    
    open fileprivate(set) var tableView: UITableView = UITableView(frame: CGRect.zero, style: .grouped)
    open fileprivate(set) var refreshControl: UIRefreshControl = UIRefreshControl()
    open fileprivate(set) var messageInputView: HIMessageInputView!
    
    fileprivate var conversation: [[HIMessage]] = []
    fileprivate var dateFormatter = DateFormatter()
    
    open var messageFont: UIFont = UIFont.systemFont(ofSize: 15)
    
    static func bundle() -> Bundle {
        let podBundle = Bundle(for: HIChatViewController.self)
        let url = podBundle.url(forResource: "HIChat", withExtension: "bundle")!
        return Bundle(url: url)!
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        tableView.frame = self.view.bounds
        tableView.autoresizingMask = [.flexibleBottomMargin, .flexibleTopMargin, .flexibleLeftMargin, .flexibleRightMargin, .flexibleWidth, .flexibleHeight]
        self.view.insertSubview(tableView, at: 0)
        
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor.clear
        tableView.keyboardDismissMode = .interactive
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
        self.view.insertSubview(messageInputView, aboveSubview: tableView)
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        messageInputView.enableKeyboardObservers = true
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        messageInputView.enableKeyboardObservers = false
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
            tableView.scrollToEnd(true)
        }
    }
    
    open func receiveMessage(_ message: HIMessage, scrollToBottom: Bool = true) {
        insertMessage(message)
        if scrollToBottom {
            tableView.scrollToEnd(true)
        }
    }
    
    open func refreshMessages(_ animated: Bool = false, scrolling: Bool = true) {
        synced(self) {
            invalidateConversation()
            
            tableView.reloadData()
            if scrolling {
                tableView.scrollToEnd(animated)
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
            if self.shouldUseDayInterval() {
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
            } else {
                conversation.append(messages)
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
        return heightForMessage(message) + HIMessageBaseCell.margins.bottom + HIMessageBaseCell.margins.top
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if self.shouldUseDayInterval() {
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
        
        cell.message = message
        
        let delegate = self as HIMessageDataSource
        if delegate.responds(to: #selector(HIMessageDataSource.configureCell(_:forMessageAtIndex:))) {
            let index = self.messagesArray().index(where: { (msg) -> Bool in
                return msg === message
            })
            delegate.configureCell!(cell, forMessageAtIndex: index!)
        }
        
        return cell
    }
}

extension HIChatViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if shouldUseDayInterval() {
            let headerView = tableView.dequeueReusableHeaderFooterViewWithClass(HIMessageHeaderView.self)
            
            let date = conversation[section].first!.date
            
            dateFormatter.dateFormat = "dd MMM, eee, HH:mm"
            
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
    
    open func shouldUseDayInterval() -> Bool {
        return true
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
