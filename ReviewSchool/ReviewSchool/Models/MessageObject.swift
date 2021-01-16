//
//  MessageObject.swift
//  ReviewSchool
//
//  Created by Cao Phúc on 16/01/2021.
//

import Foundation
import FirebaseFirestoreSwift

class MessageObject: Codable {
    @DocumentID var id = UUID().uuidString
    var content: String?
    var contentType = ContentType.unknown
    var timestamp = Int(Date().timeIntervalSince1970)
    var ownerID: String?
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encodeIfPresent(timestamp, forKey: .timestamp)
        try container.encodeIfPresent(ownerID, forKey: .ownerID)
        try container.encodeIfPresent(contentType.rawValue, forKey: .contentType)
        try container.encodeIfPresent(content, forKey: .content)
    }
    
    public required convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        timestamp = try container.decodeIfPresent(Int.self, forKey: .timestamp) ?? Int(Date().timeIntervalSince1970)
        ownerID = try container.decodeIfPresent(String.self, forKey: .ownerID)
        content = try container.decodeIfPresent(String.self, forKey: .content)
        if let contentTypeValue = try container.decodeIfPresent(Int.self, forKey: .contentType) {
            contentType = ContentType(rawValue: contentTypeValue) ?? ContentType.unknown
        }
    }
}

extension MessageObject {
    private enum CodingKeys: String, CodingKey {
        case id
        case message
        case timestamp
        case ownerID
        case contentType
        case content
    }
    
    enum ContentType: Int, Codable {
        case text = 0
        case photo = 1
        case unknown = 2
    }
    
    static func startedMessage() -> MessageObject{
        let msg = MessageObject()
        msg.contentType = .text
        msg.content = "Cuộc trò chuyện đã được bắt đầu"
        msg.ownerID = "system"
        msg.id = UUID().uuidString
        return msg
    }
}
