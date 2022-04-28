//
//  File.swift
//  
//
//  Created by Olcay Taner YILDIZ on 28.04.2022.
//

import Foundation
import MorphologicalAnalysis
import AnnotatedSentence

/**
 * Class that implements SentenceAutoDisambiguator for Turkish language.
 */
public class TurkishSentenceAutoDisambiguator : SentenceAutoDisambiguator{
    
    var longestRootFirstDisambiguation : LongestRootFirstDisambiguation
    
    /**
     * Constructor for the class.
     */
    init(){
        longestRootFirstDisambiguation = LongestRootFirstDisambiguation()
        super.init(morphologicalAnalyzer: FsmMorphologicalAnalyzer())
    }
    
    /**
     * Constructor for the class.
        - Parameters:
        - fsm                Finite State Machine based morphological analyzer
     */
    init(fsm: FsmMorphologicalAnalyzer){
        longestRootFirstDisambiguation = LongestRootFirstDisambiguation()
        super.init(morphologicalAnalyzer: fsm)
    }
    
    /**
     * If the words has only single root in its possible parses, the method disambiguates by looking special cases.
     * The cases are implemented in the caseDisambiguator method.
     - Parameters:
        - disambiguatedParse Morphological parse of the word.
        - word Word to be disambiguated.
     */
    private func setParseAutomatically(disambiguatedParse: FsmParse, word: AnnotatedWord){
        word.setParse(parseString: disambiguatedParse.transitionList());
        word.setMetamorphicParse(parseString: disambiguatedParse.withList());
    }
    
    /**
     * The method disambiguates words with multiple possible root words in its morphological parses. If the word
     * is already morphologically disambiguated, the method does not disambiguate that word. The method first check
     * for multiple root words by using rootWords method. If there are multiple root words, the method select the most
     * occurring root word (if its occurence wrt other root words occurence is above some threshold) for that word
     * using the bestRootWord method. If root word is selected, then the case for single root word is called.
     - Parameters:
        - sentence The sentence to be disambiguated automatically.
     */
    override func autoDisambiguateMultipleRootWords(sentence: AnnotatedSentence){
        let fsmParses = morphologicalAnalyzer?.robustMorphologicalAnalysis(sentence: sentence)
        let correctParses = longestRootFirstDisambiguation.disambiguate(fsmParses: fsmParses!)
        for i in 0..<sentence.wordCount(){
            let word = sentence.getWord(index: i) as! AnnotatedWord
            if word.getParse() == nil{
                setParseAutomatically(disambiguatedParse: correctParses[i], word: word)
            }
        }
    }
}
