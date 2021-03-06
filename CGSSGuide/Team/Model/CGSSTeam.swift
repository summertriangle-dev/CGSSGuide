//
//  CGSSTeam.swift
//  CGSSGuide
//
//  Created by zzk on 16/7/28.
//  Copyright © 2016年 zzk. All rights reserved.
//

import UIKit

enum LeaderSkillUpType {
    case vocal
    case dance
    case visual
    case life
    case proc
}

struct LeaderSkillUpContent {
    var upType: LeaderSkillUpType
    var upTarget: CGSSCardTypes
    var upValue: Int
}

class CGSSTeam: NSObject, NSCoding {
    var leader: CGSSTeamMember!
    var subs: [CGSSTeamMember]!
    var friendLeader: CGSSTeamMember!
    // 队伍总表现值
    var manualValue: Int!
    var backSupportValue: Int!
    var testLive: CGSSLive? {
        if let id = testLiveId {
            return CGSSDAO.sharedDAO.findLiveById(id)
        }
        return nil
    }
    var testLiveId: Int?
    var testDiff: Int?
    var skills: [CGSSRankedSkill] {
        var arr = [CGSSRankedSkill]()
        for i in 0...4 {
            if let skill = self[i]?.cardRef?.skill {
                let rankedSkill = CGSSRankedSkill.init(skill: skill, level: (self[i]?.skillLevel)!)
                arr.append(rankedSkill)
            }
        }
        return arr
    }
    subscript (index: Int) -> CGSSTeamMember? {
        if index == 0 {
            return leader
        } else if index < 5 {
            return subs[index - 1]
        } else {
            return friendLeader
        }
    }
    
    // 队伍原始值
    var rawPresentValue: CGSSAttributeValue {
        let attValue = CGSSAttributeValue.init(visual: rawVisual, vocal: rawVocal, dance: rawDance, life: rawHP)
        return attValue
    }
    var rawPresentValueInGroove: CGSSAttributeValue {
        let attValue = CGSSAttributeValue.init(visual: rawVisualInGroove, vocal: rawVocalInGroove, dance: rawDanceInGroove, life: rawHPInGroove)
        return attValue
    }
    var rawVocal: Int {
        var sum = 0
        for i in 0...5 {
            sum += (self[i]?.cardRef?.vocal) ?? 0
            sum += (self[i]?.cardRef?.attByPotential(lv: self[i]?.vocalLevel ?? 0)) ?? 0
        }
        return sum
    }
    var rawVocalInGroove: Int {
        var sum = 0
        for i in 0...4 {
            sum += (self[i]?.cardRef?.vocal) ?? 0
            sum += (self[i]?.cardRef?.attByPotential(lv: self[i]?.vocalLevel ?? 0)) ?? 0
        }
        return sum
    }
    var rawDance: Int {
        var sum = 0
        for i in 0...5 {
            sum += (self[i]?.cardRef?.dance) ?? 0
            sum += (self[i]?.cardRef?.attByPotential(lv: self[i]?.danceLevel ?? 0)) ?? 0
        }
        return sum
    }
    var rawDanceInGroove: Int {
        var sum = 0
        for i in 0...4 {
            sum += (self[i]?.cardRef?.dance) ?? 0
            sum += (self[i]?.cardRef?.attByPotential(lv: self[i]?.danceLevel ?? 0)) ?? 0
        }
        return sum
    }
    var rawVisual: Int {
        var sum = 0
        for i in 0...5 {
            sum += (self[i]?.cardRef?.visual) ?? 0
            sum += (self[i]?.cardRef?.attByPotential(lv: self[i]?.visualLevel ?? 0)) ?? 0
        }
        return sum
    }
    var rawVisualInGroove: Int {
        var sum = 0
        for i in 0...4 {
            sum += (self[i]?.cardRef?.visual) ?? 0
            sum += (self[i]?.cardRef?.attByPotential(lv: self[i]?.visualLevel ?? 0)) ?? 0
        }
        return sum
    }
    var rawHP: Int {
        var sum = 0
        for i in 0...5 {
            sum += (self[i]?.cardRef?.life) ?? 0
        }
        return sum
    }
    var rawHPInGroove: Int {
        var sum = 0
        for i in 0...5 {
            sum += (self[i]?.cardRef?.life) ?? 0
        }
        return sum
    }
    
    func getPresentValue(_ type: CGSSCardTypes) -> CGSSAttributeValue {
        var attValue = CGSSAttributeValue.init(visual: 0, vocal: 0, dance: 0, life: 0)
        for i in 0...5 {
            attValue += self[i]!.cardRef!.getPresentValue(type, roomUpValue: 10, contents: getUpContent(), vocalLevel: self[i]?.vocalLevel ?? 0, danceLevel: self[i]?.danceLevel ?? 0, visualLevel: self[i]?.visualLevel ?? 0)
        }
        return attValue
    }
    
    func getPresentValueInGroove(_ type: CGSSCardTypes, burstType: LeaderSkillUpType) -> CGSSAttributeValue {
        var attValue = CGSSAttributeValue.init(visual: 0, vocal: 0, dance: 0, life: 0)
        for i in 0...4 {
            attValue += self[i]!.cardRef!.getPresentValue(type, roomUpValue: 10, contents: getUpContentInGroove(burstType), vocalLevel: self[i]?.vocalLevel ?? 0, danceLevel: self[i]?.danceLevel ?? 0, visualLevel: self[i]?.visualLevel ?? 0)
        }
        return attValue
    }
    
    func getPresentValueInParade(_ type: CGSSSongTypes) -> CGSSAttributeValue {
        var attValue = CGSSAttributeValue.init(visual: 0, vocal: 0, dance: 0, life: 0)
        for i in 0...4 {
            attValue += self[i]!.cardRef!.getPresentValue(type, roomUpValue: 10, contents: getUpContentInParade(), vocalLevel: self[i]?.vocalLevel ?? 0, danceLevel: self[i]?.danceLevel ?? 0, visualLevel: self[i]?.visualLevel ?? 0)
        }
        return attValue
    }
    
    func getPresentValueByType(_ liveType: CGSSLiveType, songType: CGSSSongTypes) -> CGSSAttributeValue {
        switch liveType {
        case .normal:
            return getPresentValue(songType)
        case .visual:
            return getPresentValueInGroove(songType, burstType: .visual)
        case .dance:
            return getPresentValueInGroove(songType, burstType: .dance)
        case .vocal:
            return getPresentValueInGroove(songType, burstType: .vocal)
        case .parade:
            return getPresentValueInParade(songType)
        }
    }
    
    // 判断需要的指定颜色的队员是否满足条件
    func hasType(_ type: CGSSCardTypes, count: Int?, inGroove:Bool) -> Bool {
        if count == 0 {
            return true
        }
        var c = 0
        for i in 0...(inGroove ? 4 : 5) {
            if self[i]?.cardRef?.cardType == type {
                c += 1
            }
        }
        if c >= count ?? 0 {
            return true
        } else {
            return false
        }
    }
    
    func getContentFor(_ leaderSkill: CGSSLeaderSkill, inGroove:Bool) -> [LeaderSkillUpContent] {
        var contents = [LeaderSkillUpContent]()
        if hasType(.cute, count: leaderSkill.needCute, inGroove: inGroove) && hasType(.cool, count: leaderSkill.needCool, inGroove: inGroove) && hasType(.passion, count: leaderSkill.needPassion, inGroove: inGroove) {
            switch leaderSkill.targetAttribute! {
            case "cute":
                for upType in getUpType(leaderSkill) {
                    let content = LeaderSkillUpContent.init(upType: upType, upTarget: .cute, upValue: leaderSkill.upValue!)
                    contents.append(content)
                }
            case "cool":
                for upType in getUpType(leaderSkill) {
                    let content = LeaderSkillUpContent.init(upType: upType, upTarget: .cool, upValue: leaderSkill.upValue!)
                    contents.append(content)
                }
            case "passion":
                for upType in getUpType(leaderSkill) {
                    let content = LeaderSkillUpContent.init(upType: upType, upTarget: .passion, upValue: leaderSkill.upValue!)
                    contents.append(content)
                }
            case "all":
                for upType in getUpType(leaderSkill) {
                    let content1 = LeaderSkillUpContent.init(upType: upType, upTarget: .cute, upValue: leaderSkill.upValue!)
                    contents.append(content1)
                    let content2 = LeaderSkillUpContent.init(upType: upType, upTarget: .cool, upValue: leaderSkill.upValue!)
                    contents.append(content2)
                    let content3 = LeaderSkillUpContent.init(upType: upType, upTarget: .passion, upValue: leaderSkill.upValue!)
                    contents.append(content3)
                }
            default:
                break
            }
            
        }
        return contents
    }
    
    // 获取队长技能对队伍的加成效果
    func getUpContent() -> [CGSSCardTypes: [LeaderSkillUpType: Int]] {
        var contents = [LeaderSkillUpContent]()
        // 自己的队长技能
        if let leaderSkill = leader.cardRef?.leaderSkill {
            contents.append(contentsOf: getContentFor(leaderSkill, inGroove: false))
        }
        // 队友的队长技能
        if let leaderSkill = friendLeader.cardRef?.leaderSkill {
            contents.append(contentsOf: getContentFor(leaderSkill, inGroove: false))
        }
        
        // 合并同类型
        var newContents = [CGSSCardTypes: [LeaderSkillUpType: Int]]()
        for content in contents {
            if newContents.keys.contains(content.upTarget) {
                if newContents[content.upTarget]!.keys.contains(content.upType) {
                    newContents[content.upTarget]![content.upType]! += content.upValue
                } else {
                    newContents[content.upTarget]![content.upType] = content.upValue
                }
            } else {
                newContents[content.upTarget] = [LeaderSkillUpType: Int]()
                newContents[content.upTarget]![content.upType] = content.upValue
            }
            
        }
        return newContents
    }
    
    func getUpContentInGroove(_ burstType: LeaderSkillUpType) -> [CGSSCardTypes: [LeaderSkillUpType: Int]] {
        var contents = [LeaderSkillUpContent]()
        // 自己的队长技能
        if let leaderSkill = leader.cardRef?.leaderSkill {
            contents.append(contentsOf: getContentFor(leaderSkill, inGroove: true))
        }
        // 设定Groove中的up值
        contents.append(LeaderSkillUpContent.init(upType: burstType, upTarget: .cool, upValue: 150))
        contents.append(LeaderSkillUpContent.init(upType: burstType, upTarget: .cute, upValue: 150))
        contents.append(LeaderSkillUpContent.init(upType: burstType, upTarget: .passion, upValue: 150))
        
        // 合并同类型
        var newContents = [CGSSCardTypes: [LeaderSkillUpType: Int]]()
        for content in contents {
            if newContents.keys.contains(content.upTarget) {
                if newContents[content.upTarget]!.keys.contains(content.upType) {
                    newContents[content.upTarget]![content.upType]! += content.upValue
                } else {
                    newContents[content.upTarget]![content.upType] = content.upValue
                }
            } else {
                newContents[content.upTarget] = [LeaderSkillUpType: Int]()
                newContents[content.upTarget]![content.upType] = content.upValue
            }
            
        }
        return newContents
    }
    
    func getUpContentInParade() -> [CGSSCardTypes: [LeaderSkillUpType: Int]] {
        var contents = [LeaderSkillUpContent]()
        // 自己的队长技能
        if let leaderSkill = leader.cardRef?.leaderSkill {
            contents.append(contentsOf: getContentFor(leaderSkill, inGroove: true))
        }
        var newContents = [CGSSCardTypes: [LeaderSkillUpType: Int]]()
        for content in contents {
            newContents[content.upTarget] = [LeaderSkillUpType: Int]()
            newContents[content.upTarget]![content.upType] = content.upValue
        }
        return newContents
    }
    
    func getUpType(_ leaderSkill: CGSSLeaderSkill) -> [LeaderSkillUpType] {
        switch leaderSkill.targetParam! {
        case "vocal":
            return [LeaderSkillUpType.vocal]
        case "dance":
            return [LeaderSkillUpType.dance]
        case "visual":
            return [LeaderSkillUpType.visual]
        case "all":
            return [LeaderSkillUpType.vocal, LeaderSkillUpType.dance, LeaderSkillUpType.visual]
        case "life":
            return [LeaderSkillUpType.life]
        case "skill_probability":
            return [LeaderSkillUpType.proc]
        default:
            return [LeaderSkillUpType]()
        }
    }
    
    func validateCardRef() -> Bool {
        if leader.cardRef == nil {
            return false
        }
        if friendLeader.cardRef == nil {
            return false
        }
        for sub in subs {
            if sub.cardRef == nil {
                return false
            }
        }
        return true
    }
    
    init(leader: CGSSTeamMember, subs: [CGSSTeamMember], backSupportValue: Int, friendLeader: CGSSTeamMember?) {
        self.leader = leader
        self.subs = subs
        self.backSupportValue = backSupportValue
        self.friendLeader = friendLeader ?? leader
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.leader = aDecoder.decodeObject(forKey: "leader") as? CGSSTeamMember
        self.subs = aDecoder.decodeObject(forKey: "subs") as? [CGSSTeamMember]
        self.backSupportValue = aDecoder.decodeObject(forKey: "backSupportValue") as? Int ?? CGSSGlobal.presetBackValue
        self.friendLeader = aDecoder.decodeObject(forKey: "friendLeader") as? CGSSTeamMember
        self.testDiff = aDecoder.decodeObject(forKey: "testDiff") as? Int
        self.testLiveId = aDecoder.decodeObject(forKey: "testLiveId") as? Int
        self.manualValue = aDecoder.decodeObject(forKey: "manualValue") as? Int ?? 0
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(leader, forKey: "leader")
        aCoder.encode(subs, forKey: "subs")
        aCoder.encode(backSupportValue, forKey: "backSupportValue")
        aCoder.encode(friendLeader, forKey: "friendLeader")
        aCoder.encode(testLiveId, forKey: "testLiveId")
        aCoder.encode(testDiff, forKey: "testDiff")
        aCoder.encode(manualValue, forKey: "manualValue")
    }
    
}

extension CGSSCard {
    // 扩展一个获取卡片在队伍中的表现值的方法
    func getPresentValue(_ songType: CGSSCardTypes, roomUpValue: Int?, contents: [CGSSCardTypes: [LeaderSkillUpType: Int]], vocalLevel:Int, danceLevel:Int, visualLevel:Int) -> CGSSAttributeValue {
        var attValue = CGSSAttributeValue.init(visual: visual + attByPotential(lv: visualLevel), vocal: vocal + attByPotential(lv: vocalLevel), dance: dance + attByPotential(lv: danceLevel), life: life)
        var factor = 100 + (roomUpValue ?? 10)
        if songType == cardType || songType == .office {
            factor += 30
        }
        
        attValue.vocal = Int(ceil(Float(attValue.vocal * (factor + (contents[cardType]?[.vocal] ?? 0))) / 100))
        attValue.dance = Int(ceil(Float(attValue.dance * (factor + (contents[cardType]?[.dance] ?? 0))) / 100))
        attValue.visual = Int(ceil(Float(attValue.visual * (factor + (contents[cardType]?[.visual] ?? 0))) / 100))
        attValue.life = Int(ceil(Float(attValue.visual * (100 + (contents[cardType]?[.life] ?? 0))) / 100))
        return attValue
    }
}
