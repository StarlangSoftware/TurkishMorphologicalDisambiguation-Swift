//
//  File.swift
//  
//
//  Created by Olcay Taner YILDIZ on 27.04.2022.
//

import Foundation
import NGram
import Dictionary
import MorphologicalAnalysis
import AnnotatedSentence

public class RootFirstDisambiguation : NaiveDisambiguation{
    
    var wordBiGramModel : NGram<Word> = NGram<Word>(N: 0)
    var igBiGramModel : NGram<Word> = NGram<Word>(N: 0)
    
    /**
     * The train method initially creates new NGrams; wordUniGramModel, wordBiGramModel, igUniGramModel, and igBiGramModel. It gets the
     * sentences from given corpus and gets each word as a DisambiguatedWord. Then, adds the word together with its part of speech
     * tags to the wordUniGramModel. It also gets the transition list of that word and adds it to the igUniGramModel.
     * <p>
     * If there exists a next word in the sentence, it adds the current and next {@link DisambiguatedWord} to the wordBiGramModel with
     * their part of speech tags. It also adds them to the igBiGramModel with their transition lists.
     * <p>
     * At the end, it calculates the NGram probabilities of both word and ig unigram models by using LaplaceSmoothing, and
     * both word and ig bigram models by using InterpolatedSmoothing.
     *
        - Parameters:
        - corpus {@link DisambiguationCorpus} to train.
     */
    public override func train(corpus: DisambiguationCorpus) {
        var words1 : [Word] = [Word(name: "")]
        var igs1 : [Word] = [Word(name: "")]
        var words2 : [Word] = [Word(name: ""), Word(name: "")]
        var igs2 : [Word] = [Word(name: ""), Word(name: "")]
        wordUniGramModel = NGram<Word>(N: 1)
        wordBiGramModel = NGram<Word>(N: 2)
        igUniGramModel = NGram<Word>(N: 1)
        igBiGramModel = NGram<Word>(N: 2)
        for i in 0..<corpus.sentenceCount(){
            let sentence = corpus.getSentence(index: i)
            for j in 0..<sentence.wordCount(){
                let word = sentence.getWord(index: j) as! AnnotatedWord
                words1[0] = (word.getParse()?.getWordWithPos())!
                wordUniGramModel.addNGram(symbols: words1)
                igs1[0] = Word(name: (word.getParse()?.getTransitionList())!)
                igUniGramModel.addNGram(symbols: igs1)
                if j + 1 < sentence.wordCount(){
                    words2[0] = words1[0]
                    words2[1] = ((sentence.getWord(index: j + 1) as! AnnotatedWord).getParse()?.getWordWithPos())!
                    wordBiGramModel.addNGram(symbols: words2)
                    igs2[0] = igs1[0]
                    igs2[1] = Word(name: ((sentence.getWord(index: j + 1) as! AnnotatedWord).getParse()?.getTransitionList())!)
                }
            }
        }
        wordUniGramModel.calculateNGramProbabilitiesSimple(simpleSmoothing: LaplaceSmoothing<Word>())
        igUniGramModel.calculateNGramProbabilitiesSimple(simpleSmoothing: LaplaceSmoothing<Word>())
        wordBiGramModel.calculateNGramProbabilitiesSimple(simpleSmoothing: LaplaceSmoothing<Word>())
        igBiGramModel.calculateNGramProbabilitiesSimple(simpleSmoothing: LaplaceSmoothing<Word>())
    }
    
    /**
     * The getWordProbability method returns the probability of a word by using word bigram or unigram model.
        - Parameters:
        - word             Word to find the probability.
        - correctFsmParses FsmParse of given word which will be used for getting part of speech tags.
        - index            Index of FsmParse of which part of speech tag will be used to get the probability.
        - Returns: The probability of the given word.
     */
    func getWordProbability(word: Word, correctFsmParses: [FsmParse], index: Int) -> Double{
        if index != 0 && correctFsmParses.count == index{
            return wordBiGramModel.getProbability(correctFsmParses[index - 1].getWordWithPos(), word)
        } else {
            return wordUniGramModel.getProbability(word)
        }
    }
    
    /**
     * The getIgProbability method returns the probability of a word by using ig bigram or unigram model.
        - Parameters:
        - word             Word to find the probability.
        - correctFsmParses FsmParse of given word which will be used for getting transition list.
        - index            Index of FsmParse of which transition list will be used to get the probability.
        - Returns: The probability of the given word.
     */
    func getIgProbability(word: Word, correctFsmParses: [FsmParse], index: Int) -> Double{
        if index != 0 && correctFsmParses.count == index{
            return igBiGramModel.getProbability(Word(name: correctFsmParses[index - 1].getTransitionList()), word)
        } else {
            return igUniGramModel.getProbability(word)
        }
    }
    
    /**
     * The getBestRootWord method takes a {@link FsmParseList} as an input and loops through the list. It gets each word with its
     * part of speech tags as a new {@link Word} word and its transition list as a {@link Word} ig. Then, finds their corresponding
     * probabilities. At the end returns the word with the highest probability.
        - Parameters:
        - fsmParseList {@link FsmParseList} is used to get the part of speech tags and transition lists of words.
        - Returns: The word with the highest probability.
     */
    func getBestRootWord(fsmParseList: FsmParseList) -> Word{
        var bestProbability = Double(Int.min)
        var bestWord : Word? = nil
        for j in 0..<fsmParseList.size(){
            let word = fsmParseList.getFsmParse(index: j).getWordWithPos()
            let ig = Word(name: fsmParseList.getFsmParse(index: j).getTransitionList())
            let wordProbability = wordUniGramModel.getProbability(word)
            let igProbability = igUniGramModel.getProbability(ig)
            let probability = wordProbability * igProbability
            if probability > bestProbability{
                bestWord = word
                bestProbability = probability
            }
        }
        return bestWord!
    }
    
    /**
     * The getParseWithBestIgProbability gets each {@link FsmParse}'s transition list as a {@link Word} ig. Then, finds the corresponding
     * probabilitt. At the end returns the parse with the highest ig probability.
        - Parameters:
        - parseList        {@link FsmParseList} is used to get the {@link FsmParse}.
        - correctFsmParses FsmParse is used to get the transition lists.
        - index            Index of FsmParse of which transition list will be used to get the probability.
        - Returns: The parse with the highest probability.
     */
    func getParseWithBestIgProbability(parseList: FsmParseList, correctFsmParses: [FsmParse], index: Int) -> FsmParse?{
        var bestProbability = Double(Int.min)
        var bestParse : FsmParse? = nil
        for j in 0..<parseList.size(){
            let ig = Word(name: parseList.getFsmParse(index: j).getTransitionList())
            let probability = getIgProbability(word: ig, correctFsmParses: correctFsmParses, index: index)
            if probability > bestProbability{
                bestParse = parseList.getFsmParse(index: j)
                bestProbability = probability
            }
        }
        return bestParse
    }
    
    /**
     * The disambiguate method gets an array of fsmParses. Then loops through that parses and finds the most probable root
     * word and removes the other words which are identical to the most probable root word. At the end, gets the most probable parse
     * among the fsmParses and adds it to the correctFsmParses {@link ArrayList}.
        - Parameters:
        - fsmParses {@link FsmParseList} to disambiguate.
        - Returns: correctFsmParses {@link ArrayList} which holds the most probable parses.
     */
    public override func disambiguate(fsmParses: [FsmParseList]) -> [FsmParse] {
        var correctFsmParses : [FsmParse] = []
        for i in 0..<fsmParses.count{
            let bestWord = getBestRootWord(fsmParseList: fsmParses[i])
            fsmParses[i].reduceToParsesWithSameRootAndPos(currentWithPos: bestWord)
            let bestParse = getParseWithBestIgProbability(parseList: fsmParses[i], correctFsmParses: correctFsmParses, index: i)
            if bestParse != nil{
                correctFsmParses.append(bestParse!)
            }
        }
        return correctFsmParses
    }
    
    /**
     * Method to save unigrams and bigrams.
     */
    public override func saveModel() {
    }
    
    /**
     * Method to load unigrams and bigrams.
     */
    public override func loadModel() {
    }

}
