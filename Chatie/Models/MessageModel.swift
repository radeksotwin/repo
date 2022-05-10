//
//  MessageModel.swift
//  Chatie
//
//  Created by Rdm on 07/05/2022.
//

import Foundation
import MessageKit

struct Message: MessageType {
    
    public var sender: SenderType
    public var messageId: String
    public var sentDate: Date
    public var kind: MessageKind
}

struct LatestMessage {
    
    let date: String
    let text: String
    let senderName: String
    let isRead: Bool
}

extension MessageKind {
    
    var messageKindString: String {
        switch self {
        case .text(_):
            return "text"
        case .attributedText(_):
            return "attributted text"
        case .photo(_):
            return "photo"
        case .video(_):
            return "video"
        case .location(_):
            return "location"
        case .emoji(_):
            return "emoji"
        case .audio(_):
            return "audio"
        case .contact(_):
            return "contact"
        case .linkPreview(_):
            return "linkPreview"
        case .custom(_):
            return "custom"
        }
    }
}
