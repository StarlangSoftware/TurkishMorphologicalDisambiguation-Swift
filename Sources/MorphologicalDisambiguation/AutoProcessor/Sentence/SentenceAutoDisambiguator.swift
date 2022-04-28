//
//  File.swift
//  
//
//  Created by Olcay Taner YILDIZ on 28.04.2022.
//

import Foundation
import AnnotatedSentence
import MorphologicalAnalysis

public class SentenceAutoDisambiguator : AutoDisambiguator{
    
    /**
     * The method should disambiguate morphological analyses where there are multiple candidate root words
     * and possibly multiple candidate morphological analyses for each candidate root word. If it finds the correct
     * morphological analysis of a word(s), it should set morphological analysis and metamorpheme of that(those) word(s).
     * To disambiguate between the root words, one can use the root word statistics.
        - Parameters:
        - sentence The sentence to be disambiguated automatically.
     */
    func autoDisambiguateMultipleRootWords(sentence: AnnotatedSentence){
        
    }
    
    /**
     * Constructor for the class.
        - Parameters:
        - morphologicalAnalyzer Morphological analyzer for parsing the words. Morphological analyzer will return all possible parses of each word so that the automatic disambiguator can disambiguate the words.
     */
    public init(morphologicalAnalyzer: FsmMorphologicalAnalyzer){
        super.init()
        self.morphologicalAnalyzer = morphologicalAnalyzer
    }
    
    /**
     * The main method to automatically disambiguate a sentence. The algorithm
     * 1. Disambiguates the morphological analyses with a single analysis.
     * 2. Disambiguates the morphological analyses in which the possible analyses contain only one
     * distinct root word.
     * 3. Disambiguates the morphological analyses where there are multiple candidate root words and
     * possibly multiple candidate morphological analyses for each candidate root word.
        - Parameters:
        - sentence The sentence to be disambiguated automatically.
     */
    public func autoDisambiguate(sentence: AnnotatedSentence){
        autoDisambiguate(sentence: sentence)
    }
}
