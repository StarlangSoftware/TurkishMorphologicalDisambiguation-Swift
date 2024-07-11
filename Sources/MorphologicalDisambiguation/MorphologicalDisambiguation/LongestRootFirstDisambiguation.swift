//
//  File.swift
//  
//
//  Created by Olcay Taner YILDIZ on 28.04.2022.
//

import Foundation
import MorphologicalAnalysis

public class LongestRootFirstDisambiguation : MorphologicalDisambiguator{

    private var rootList: [String:String] = [:]
    
    /// Constructor for the longest root first disambiguation algorithm. The method reads a list of (surface form, most
    /// frequent root word for that surface form) pairs from a given file.
    /// - Parameter fileName: File that contains list of (surface form, most frequent root word for that surface form) pairs.
    public init(fileName: String){
        readFromFile(fileName: fileName)
    }
    
    /// Constructor for the longest root first disambiguation algorithm. The method reads a list of (surface form, most
    /// frequent root word for that surface form) pairs from 'rootlist.txt' file.
    public init(){
        readFromFile()
    }
    
    /**
     * Train method implements method in {@link MorphologicalDisambiguator}.
        - Parameters:
        - corpus {@link DisambiguationCorpus} to train.
     */
    public func train(corpus: DisambiguationCorpus) {
    }
    
    private func readFromFile(fileName: String = "rootlist"){
        let url = Bundle.module.url(forResource: fileName, withExtension: "txt")
        do{
            let fileContent = try String(contentsOf: url!, encoding: .utf8)
            let lines : [String] = fileContent.split(whereSeparator: \.isNewline).map(String.init)
            for line in lines{
                let items : [String] = line.split(separator: " ").map(String.init)
                if items.count == 2{
                    rootList[items[0]] = items[1]
                }
            }
        }catch{
        }
    }

    /**
     * The disambiguate method gets an array of fsmParses. Then loops through that parses and finds the longest root
     * word. At the end, gets the parse with longest word among the fsmParses and adds it to the correctFsmParses
     * {@link ArrayList}.
        - Parameters:
        - fsmParses {@link FsmParseList} to disambiguate.
        - Returns: correctFsmParses {@link ArrayList} which holds the parses with longest root words.
     */
    public func disambiguate(fsmParses: [FsmParseList]) -> [FsmParse] {
        var correctFsmParses : [FsmParse] = []
        var i : Int = 0
        var bestParse : FsmParse
        for fsmParseList in fsmParses{
            let surfaceForm = fsmParseList.getFsmParse(index: 0).getSurfaceForm()
            let bestRoot = rootList[surfaceForm]
            var rootFound : Bool = false
            for j in 0..<fsmParseList.size(){
                if fsmParseList.getFsmParse(index: j).getWord().getName() == bestRoot{
                    rootFound = true
                    break
                }
            }
            if bestRoot == nil || !rootFound{
                bestParse = fsmParseList.getParseWithLongestRootWord()
                fsmParseList.reduceToParsesWithSameRoot(currentRoot: bestParse.getWord().getName())
            } else {
                fsmParseList.reduceToParsesWithSameRoot(currentRoot: bestRoot!)
            }
            let newBestParse = AutoDisambiguator.caseDisambiguator(index: i, fsmParses: fsmParses, correctParses: correctFsmParses)
            if newBestParse != nil{
                bestParse = newBestParse!
            } else {
                bestParse = fsmParseList.getFsmParse(index: 0)
            }
            correctFsmParses.append(bestParse)
            i = i + 1
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
