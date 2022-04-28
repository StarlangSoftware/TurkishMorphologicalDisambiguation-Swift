//
//  File.swift
//  
//
//  Created by Olcay Taner YILDIZ on 27.04.2022.
//

import Foundation
import Dictionary
import MorphologicalAnalysis
import NGram

public class NaiveDisambiguation : MorphologicalDisambiguator{

    var wordUniGramModel: NGram<Word> = NGram<Word>(N: 0)
    var igUniGramModel: NGram<Word> = NGram<Word>(N: 0)

    public func train(corpus: DisambiguationCorpus) {
    }
    
    public func disambiguate(fsmParses: [FsmParseList]) -> [FsmParse] {
        return []
    }
    
    /**
     * The saveModel method writes the specified objects i.e wordUniGramModel and igUniGramModel to the
     * words1.txt and igs1.txt.
     */
    public func saveModel() {
    }
    
    /**
     * The loadModel method reads objects at the words1.txt and igs1.txt to the wordUniGramModel and igUniGramModel.
     */
    public func loadModel() {
    }
        
}
