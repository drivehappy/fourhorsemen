module Entity

open Microsoft.FSharp.Data.UnitSystems.SI.UnitSymbols


[<Measure>] type milli

let secondToMillisecond (s : float<s>) : float<milli s> =
    s * 1000.0<milli>


type Vec2 = {
    x : float32
    y : float32
}

type Dimensions = {
    width : float32
    height : float32
}


// Mark helpers
type MarkTimerAndStacks = float<milli s> * int

type MonsterMarks = {
    mograineMark : MarkTimerAndStacks option
    thaneMark : MarkTimerAndStacks option
    blaumeuxMark : MarkTimerAndStacks option
    zeliekMark : MarkTimerAndStacks option
}
