//
//  File.swift
//  
//
//  Created by Olcay Taner YILDIZ on 28.04.2022.
//

import Foundation
import MorphologicalAnalysis
import NGram
import Dictionary
import AnnotatedSentence

public class HmmDisambiguation : NaiveDisambiguation{
    
    var wordBiGramModel : NGram<Word> = NGram<Word>(N: 0)
    var igBiGramModel : NGram<Word> = NGram<Word>(N: 0)
    
    /**
     * The train method gets sentences from given {@link DisambiguationCorpus} and both word and the next word of that sentence at each iteration.
     * Then, adds these words together with their part of speech tags to word unigram and bigram models. It also adds the last inflectional group of
     * word to the ig unigram and bigram models.
     * <p>
     * At the end, it calculates the NGram probabilities of both word and ig unigram models by using LaplaceSmoothing, and
     * both word and ig bigram models by using InterpolatedSmoothing.
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
            for j in 0..<sentence.wordCount() - 1{
                let word = sentence.getWord(index: j) as! AnnotatedWord
                let nextWord = sentence.getWord(index: j + 1) as! AnnotatedWord
                words2[0] = (word.getParse()?.getWordWithPos())!
                words1[0] = words2[0]
                words2[1] = (nextWord.getParse()?.getWordWithPos())!
                wordUniGramModel.addNGram(symbols: words1)
                wordBiGramModel.addNGram(symbols: words2)
                for k in 0..<nextWord.getParse()!.size(){
                    igs2[0] = Word(name: word.getParse()!.getLastInflectionalGroup().description())
                    igs2[1] = Word(name: nextWord.getParse()!.getInflectionalGroup(index: k).description())
                    igBiGramModel.addNGram(symbols: igs2)
                    igs1[0] = igs2[1]
                    igUniGramModel.addNGram(symbols: igs1)
                }
            }
        }
        wordUniGramModel.calculateNGramProbabilitiesSimple(simpleSmoothing: LaplaceSmoothing<Word>())
        igUniGramModel.calculateNGramProbabilitiesSimple(simpleSmoothing: LaplaceSmoothing<Word>())
        wordBiGramModel.calculateNGramProbabilitiesSimple(simpleSmoothing: LaplaceSmoothing<Word>())
        igBiGramModel.calculateNGramProbabilitiesSimple(simpleSmoothing: LaplaceSmoothing<Word>())
    }

    /**
     * The disambiguate method gets an array of fsmParses. Then loops through that parses and finds the longest root
     * word. At the end, gets the parse with longest word among the fsmParses and adds it to the correctFsmParses
     * {@link ArrayList}.
     - Parameters:
     - fsmParses {@link FsmParseList} to disambiguate.
     - Returns: correctFsmParses {@link ArrayList} which holds the parses with longest root words.
     */
    public override func disambiguate(fsmParses: [FsmParseList]) -> [FsmParse] {
        if fsmParses.count == 0{
            return []
        }
        for i in 0..<fsmParses.count{
            if fsmParses[i].size() == 0{
                return []
            }
        }
        var correctFsmParses : [FsmParse] = []
        var probabilities: [[Double]] = []
        var best: [[Int]] = []
        var probabilityArray: [Double] = []
        var indexArray: [Int] = []
        for i in 0..<fsmParses[0].size(){
            let currentParse = fsmParses[0].getFsmParse(index: i)
            let w1 = currentParse.getWordWithPos()
            var probability : Double = wordUniGramModel.getProbability(w1)
            for j in 0..<currentParse.size(){
                let ig1 = Word(name: currentParse.getInflectionalGroup(index: j).description())
                probability *= igUniGramModel.getProbability(ig1)
            }
            probabilityArray.append(log(probability))
        }
        probabilities.append(probabilityArray)
        for i in 1..<fsmParses.count{
            probabilityArray = []
            indexArray = []
            for j in 0..<fsmParses[i].size(){
                var bestProbability : Double = Double(Int.min)
                var bestIndex : Int = -1
                let currentParse = fsmParses[i].getFsmParse(index: j)
                for k in 0..<fsmParses[i - 1].size(){
                    let previousParse = fsmParses[i - 1].getFsmParse(index: k)
                    let w1 = previousParse.getWordWithPos()
                    let w2 = currentParse.getWordWithPos()
                    var probability = probabilities[0][k] + log(wordBiGramModel.getProbability(w1, w2))
                    for t in 0..<fsmParses[i].getFsmParse(index: j).size(){
                        let ig1 = Word(name: previousParse.lastInflectionalGroup().description())
                        let ig2 = Word(name: currentParse.getInflectionalGroup(index: t).description())
                        probability += log(igBiGramModel.getProbability(ig1, ig2))
                    }
                    if probability > bestProbability{
                        bestIndex = k
                        bestProbability = probability
                    }
                }
                probabilityArray.append(bestProbability)
                indexArray.append(bestIndex)
            }
            probabilities.append(probabilityArray)
            best.append(indexArray)
        }
        var bestProbability : Double = Double(Int.min)
        var bestIndex : Int = -1
        for i in 0..<fsmParses[fsmParses.count - 1].size(){
            if probabilities[fsmParses.count - 1][i] > bestProbability{
                bestProbability = probabilities[fsmParses.count - 1][i]
                bestIndex = i
            }
        }
        if bestIndex == -1{
            return []
        }
        correctFsmParses.append(fsmParses[fsmParses.count - 1].getFsmParse(index: bestIndex))
        for i in stride(from: fsmParses.count - 2, through: 0, by: -1){
            bestIndex = best[i + 1][bestIndex]
            if bestIndex == -1{
                return []
            }
            correctFsmParses.insert(fsmParses[i].getFsmParse(index: bestIndex), at: 0)
        }
        return correctFsmParses
    }
    
    /**
     * Overridden saveModel method to save a model.
     */
    public override func saveModel() {
    }
    
    /**
     * Overridden loadModel method to load a model.
     */
    public override func loadModel() {
    }

}
