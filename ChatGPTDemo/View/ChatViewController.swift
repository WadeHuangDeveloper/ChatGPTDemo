//
//  ChatViewController.swift
//  ChatGPTDemo
//
//  Created by Huei-Der Huang on 2025/3/5.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import Combine

class ChatViewController: MessagesViewController {
    var viewModel = ChatViewControllerViewModel()
    var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()

        initUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupCombine()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        cancellables.removeAll()
    }
    
    private func initUI() {
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        
        messageInputBar.delegate = self
        messageInputBar.inputTextView.textColor = .label
        messageInputBar.inputTextView.placeholder = "Ask any questions"
        messageInputBar.inputTextView.layer.borderWidth = 0.4
        messageInputBar.inputTextView.layer.borderColor = UIColor.label.cgColor
        messageInputBar.inputTextView.layer.cornerRadius = 10
        messageInputBar.sendButton.layer.cornerRadius = 5
        
        view.backgroundColor = .white
    }
    
    private func setupCombine() {
        viewModel.$messages
            .receive(on: DispatchQueue.main)
            .sink { _ in self.reload() }
            .store(in: &cancellables)
    }
    
    private func reload() {
        self.messagesCollectionView.reloadData()
        self.messagesCollectionView.scrollToLastItem()
    }

}

extension ChatViewController: MessagesDataSource {
    var currentSender: SenderType {
        return viewModel.user
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessageKit.MessagesCollectionView) -> any MessageKit.MessageType {
        return viewModel.messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessageKit.MessagesCollectionView) -> Int {
        return viewModel.messages.count
    }
}

extension ChatViewController: MessagesLayoutDelegate {
    func avatarSize(for message: any MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGSize? {
        return message.sender.senderId == viewModel.user.senderId ? .zero : CGSize(width: 25, height: 25)
    }
    
    func messageBottomLabelHeight(for message: any MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 20
    }
    
    func messageBottomLabelAlignment(for message: any MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> LabelAlignment? {
        let textAlignment = message.sender.senderId == viewModel.user.senderId ?
            NSTextAlignment.right :
            NSTextAlignment.left
        let textInsets = message.sender.senderId == viewModel.user.senderId ?
            UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 5) :
            UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 0)
        let alignment = LabelAlignment(textAlignment: textAlignment, textInsets: textInsets)
        return alignment
    }
}

extension ChatViewController: MessagesDisplayDelegate {
    func textColor(for message: any MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return message.sender.senderId == viewModel.user.senderId ? .lightText : .lightText
    }
    
    func backgroundColor(for message: any MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return message.sender.senderId == viewModel.user.senderId ? .systemGray : .black
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: any MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        if message.sender.senderId == viewModel.user.senderId {
            avatarView.image = nil
        } else {
            avatarView.image = UIImage(named: "chatgpt.png")
            avatarView.backgroundColor = .white
        }
    }
    
    func messageBottomLabelAttributedText(for message: any MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let dateString = dateFormatter.string(from: viewModel.messages[indexPath.section].sentDate)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = message.sender.senderId == viewModel.user.senderId ? .right : .left
        return NSAttributedString(
            string: dateString,
            attributes: [
                .font: UIFont.systemFont(ofSize: 10, weight: .regular),
                .foregroundColor: UIColor.systemGray,
            ]
        )
    }
}

extension ChatViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        inputBar.inputTextView.text = ""
        view.endEditing(true)
        
        Task {
            await viewModel.chat(content: text)
        }
    }
}
