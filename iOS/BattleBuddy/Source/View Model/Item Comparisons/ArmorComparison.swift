//
//  ArmorComparison.swift
//  BattleBuddy
//
//  Created by Mike on 7/14/19.
//  Copyright © 2019 Veritas. All rights reserved.
//

import UIKit

struct ArmorComparison: ItemComparison {
    var propertyType: ComparablePropertyType = .armor
    var allItems: [Comparable]
    var itemsBeingCompared: [Comparable]
    var possibleOptions: [Comparable]
    var recommendedOptions: [Comparable]
    var secondaryRecommendedOptions: [Comparable] = []
    var secondaryRecommendedOptionsTitle: String? = nil
    var propertyOptions: [ComparableProperty] = ComparableProperty.propertiesForType(type: .armor)
    var recommendedOptionsTitle: String?
    var preferRecommended: Bool = true

    init(_ initialArmor: Armor? = nil, allArmor: [Armor]) {
        allItems = allArmor
        possibleOptions = allArmor

        if let armor = initialArmor {
            itemsBeingCompared = ArmorComparison.generateRecommendedOptions(armor, allArmor: allArmor)
            recommendedOptions = itemsBeingCompared
            recommendedOptionsTitle = armor.armorClass.local()

            // Filter out recommendations from all possible
            for recommended in recommendedOptions {
                possibleOptions.removeAll{ $0.identifier == recommended.identifier }
            }
        } else {
            itemsBeingCompared = []
            recommendedOptions = []
        }
    }

    private static func generateRecommendedOptions(_ initialArmor: Armor, allArmor: [Armor]) -> [Armor] {
        let armorMatchingClassAndType = allArmor.filter {
            if initialArmor.armorType != $0.armorType { return false }
            if initialArmor.armorClass != $0.armorClass { return false }
            return true
        }
        return armorMatchingClassAndType
    }

    func getComparedItemsSummaryMap() -> [ComparableProperty: PropertyRange] {
        var classRange = PropertyRange()
        var durabilityRange = PropertyRange()
        var zonesRange = PropertyRange()
        var speedPenRange = PropertyRange()
        var turnSpeedPenRange = PropertyRange()
        var ergoPenRange = PropertyRange()

        for case let armor as Armor in allItems {
            classRange.updatedRangeIfNeeded(candidateValue: Float(armor.armorClass.rawValue))
            durabilityRange.updatedRangeIfNeeded(candidateValue: Float(armor.maxDurability))
            zonesRange.updatedRangeIfNeeded(candidateValue: armor.armorZoneConfig.coveragePercent(type: armor.armorType))
            speedPenRange.updatedRangeIfNeeded(candidateValue: Float(armor.penalties.movementSpeed))
            turnSpeedPenRange.updatedRangeIfNeeded(candidateValue: Float(armor.penalties.turnSpeed))
            ergoPenRange.updatedRangeIfNeeded(candidateValue: Float(armor.penalties.ergonomics))
        }

        return [
            .armorClass: classRange,
            .armorDurability: durabilityRange,
            .armorZones: zonesRange,
            .speedPenalty: speedPenRange,
            .turnSpeedPenalty: turnSpeedPenRange,
            .ergoPenalty: ergoPenRange
        ]
    }

    func getPercentValue(item: Comparable, property: ComparableProperty, traitCollection: UITraitCollection) -> Float {
        guard let armor = item as? Armor else { fatalError() }
        let range = getComparedItemsSummaryMap()[property]!

        switch property {
        case .armorClass: return scaledValue(propertyValue: Float(armor.armorClass.rawValue), range: range)
        case .armorDurability: return scaledValue(propertyValue: Float(armor.maxDurability), range: range)
        case .armorZones: return scaledValue(propertyValue: armor.armorZoneConfig.coveragePercent(type: armor.armorType), range: range)
        case .speedPenalty: return scaledValue(propertyValue: Float(armor.penalties.movementSpeed), range: range)
        case .turnSpeedPenalty: return scaledValue(propertyValue: Float(armor.penalties.turnSpeed), range: range)
        case .ergoPenalty: return scaledValue(propertyValue: Float(armor.penalties.ergonomics), range: range)
        default: fatalError()
        }
    }
}
