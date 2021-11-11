//
//  Markov.swift
//
//  Simple Markov Chain for MIDI notes in combination with AudioKit.
//
//  Created by Jan den Besten.
//

import AudioKit


class MarkovMatrix {

    private var markovChains = [MIDIChannel:Markov]()

    func feed( channel: MIDIChannel, noteData:[MIDINoteData]) {
        markovChains[channel] = Markov()
        markovChains[channel]!.feed(noteData:noteData)
    }

    func next( channel: MIDIChannel, note:MIDINoteNumber ) -> MIDINoteData {
        return markovChains[channel]!.next( note:note )
    }

    func getEntries( channel: MIDIChannel ) -> [MIDINoteNumber] {
        return markovChains[channel]!.getEntries()
    }

    func getChain( channel: MIDIChannel ) -> [MIDINoteNumber:[MIDINoteData]] {
        return markovChains[channel]!.getChain()
    }

    func getChainOfNotes( channel: MIDIChannel ) -> [MIDINoteNumber:[MIDINoteNumber]] {
        return markovChains[channel]!.getChainOfNotes()
    }

}


class Markov {

    private var notes = [MIDINoteNumber:MIDINoteData]()
    private var chain = [MIDINoteNumber:[MIDINoteData]]()
    private var entries = [MIDINoteNumber]()

    private var last:MIDINoteNumber? = nil

    // Feed the chain with notedata, results in filled
    func feed( noteData:[MIDINoteData] )
    {
        var prevNote:MIDINoteNumber?
        for data in noteData {
            let note = data.noteNumber
            notes[note] = data
            // If not exists in chain, add it
            if (chain[note]==nil) {
                chain[note] = [MIDINoteData]()
            }
            // prev
            if let prev = prevNote {
                chain[prev]!.append(data)
            }
            prevNote = note
        }
        entries = Array(chain.keys)
    }

    // Get next (random) number from chain
    func next( note:MIDINoteNumber ) -> MIDINoteData
    {
        var nextNote:MIDINoteData

        // first note is a random note from the input feed
        if last==nil {
            nextNote = notes.values.randomElement()!
        }
        // next just get a random one from the chain
        else {
            nextNote = chain[last!]!.randomElement()!
        }
        // remember state
        last = note

        return nextNote
    }


    func getNotes() -> [MIDINoteNumber] {
        return Array(notes.keys)
    }

    func getEntries() -> [MIDINoteNumber] {
        return entries
    }

    func getChain() -> [MIDINoteNumber:[MIDINoteData]] {
        return chain
    }

    func getChainOfNotes() -> [MIDINoteNumber:[MIDINoteNumber]] {
        var chainOfNotes = [MIDINoteNumber:[MIDINoteNumber]]()
        for (note,data) in chain {
            var notes = [MIDINoteNumber]()
            for item in data {
                notes.append(item.noteNumber)
            }
            chainOfNotes[note] = notes
        }
        return chainOfNotes
    }



}
