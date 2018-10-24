//
//  GameInfo.swift
//  Hearthbase
//
//  Created by Paulo José on 19/10/18.
//  Copyright © 2018 Paulo José. All rights reserved.
//

import Foundation

enum ParameterType : String{
    case cardClass = "CardClass"
    case type = "Type"
    case quality = "Quality"
    case race = "Race"
}

enum CardClass : String, CaseIterable {
    case cavaleiroDaMorte = "Cavaleiro da Morte"
    case druida = "Druida"
    case cacador = "Caçador"
    case mago = "Mago"
    case paladino = "Paladino"
    case sacerdote = "Sacerdote"
    case ladino = "Ladino"
    case xama = "Xamã"
    case bruxo = "Bruxo"
    case guerreiro = "Guerreiro"
    case dream = "Dream"
    case neutro = "Neutro"
    
}

enum Type : String, CaseIterable {
    case heroi = "Herói"
    case lacaio = "Lacaio"
    case feitico = "Feitiço"
    case encatamento = "Encantamento"
    case arma = "Arma"
    case poderHeroico = "Poder Heroico"
}

enum Quality : String, CaseIterable {
    case gratis = "Grátis"
    case comum = "Comum"
    case raro = "Raro"
    case epico = "Épico"
    case lendario = "Lendário"
}

enum Race : String, CaseIterable {
    case demonio = "Demônio"
    case dragao = "Dragão"
    case elemental = "Elemental"
    case mecanoide = "Mecanoide"
    case murloc = "Murloc"
    case fera = "Fera"
    case pirata = "Pirata"
    case totem = "Totem"
}
