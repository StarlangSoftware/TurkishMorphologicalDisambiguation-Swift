//
//  File.swift
//  
//
//  Created by Olcay Taner YILDIZ on 27.04.2022.
//

import Foundation
import MorphologicalAnalysis
import Util

public class DummyDisambiguation : MorphologicalDisambiguator{

    /**
     * Train method implements method in {@link MorphologicalDisambiguator}.
     - Parameters:
        - corpus {@link DisambiguationCorpus} to train.
     */
    public func train(corpus: DisambiguationCorpus) {
        
    }
    
    /**
     * Overridden disambiguate method takes an array of {@link FsmParseList} and loops through its items, if the current FsmParseList's
     * size is greater than 0, it adds a random parse of this list to the correctFsmParses {@link ArrayList}.
     - Parameters:
        - fsmParses {@link FsmParseList} to disambiguate.
     - Returns: correctFsmParses {@link ArrayList}.
     */
    public func disambiguate(fsmParses: [FsmParseList]) -> [FsmParse] {
        let random = Random()
        var correctFsmParses : [FsmParse] = []
        for fsmParseList in fsmParses{
            if fsmParseList.size() > 0{
                correctFsmParses.append(fsmParseList.getFsmParse(index: random.nextInt(maxRange: fsmParseList.size())))
            }
        }
        return correctFsmParses
    }
    
    /**
     * Overridden saveModel method to save a model.
     */
    public func saveModel() {
    }
    
    /**
     * Overridden loadModel method to load a model.
     */
    public func loadModel() {
    }
    
}
