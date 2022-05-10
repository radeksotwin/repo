//
//  ConversationsModel.swift
//  Chatie
//
//  Created by Rdm on 06/05/2022.
//

import Foundation
import MessageKit

struct Conversation {
    
    var id: String
    var name: String
    var otherUserEmail: String
    var latestMessage: LatestMessage
    
}

struct Sender: SenderType {
    
    public var photoURL: String
    public var senderId: String
    public var displayName: String
    
}
