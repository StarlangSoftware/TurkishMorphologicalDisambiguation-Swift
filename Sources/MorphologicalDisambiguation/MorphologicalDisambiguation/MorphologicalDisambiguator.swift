//
//  File.swift
//  
//
//  Created by Olcay Taner YILDIZ on 26.04.2022.
//

import Foundation
import MorphologicalAnalysis

public protocol MorphologicalDisambiguator{
    
    /**
     * Method to train the given {@link DisambiguationCorpus}.
     - Parameters:
        - corpus {@link DisambiguationCorpus} to train.
     */
    func train(corpus: DisambiguationCorpus)
    
    /**
     * Method to disambiguate the given {@link FsmParseList}.
     - Parameters:
        - fsmParses {@link FsmParseList} to disambiguate.
     - Returns: ArrayList of {@link FsmParse}.
     */
    func disambiguate(fsmParses: [FsmParseList]) -> [FsmParse]
    
    /**
     * Method to save a model.
     */
    func saveModel()
    
    /**
     * Method to load a model.
     */
    func loadModel()
}
