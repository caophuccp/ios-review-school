//
//  MessageObject.swift
//  ReviewSchool
//
//  Created by Cao Phúc on 16/01/2021.
//

import Foundation
import FirebaseFirestoreSwift

class MessageObject: Codable {
    var id: String
    var content: String?
    var contentType: ContentType
    var timestamp: Int
    var ownerID: String?
    
    init() {
        self.id = UUID().uuidString
        contentType = .unknown
        timestamp = Int((Date().timeIntervalSince1970))
    }
    
    init(content:String?, type:ContentType, ownerID: String?) {
        self.id = UUID().uuidString
        self.content = content
        self.contentType = type
        self.ownerID = ownerID
        self.timestamp = Int((Date().timeIntervalSince1970))
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encodeIfPresent(timestamp, forKey: .timestamp)
        try container.encodeIfPresent(ownerID, forKey: .ownerID)
        try container.encodeIfPresent(contentType.rawValue, forKey: .contentType)
        try container.encodeIfPresent(content, forKey: .content)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.timestamp = try container.decode(Int.self, forKey: .timestamp)
        self.ownerID = try container.decodeIfPresent(String.self, forKey: .ownerID)
        self.content = try container.decodeIfPresent(String.self, forKey: .content)
        let contentTypeValue = try container.decode(Int.self, forKey: .contentType)
        self.contentType = ContentType(rawValue: contentTypeValue) ?? ContentType.unknown
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
        let msg = MessageObject(content: "Cuộc trò chuyện đã được bắt đầu", type: .text, ownerID: "system")
        return msg
    }
}
