module Entity

[<Measure>] type milli
[<Measure>] type second


type Vec2 = {
    x : float32
    y : float32
}

type Dimensions = {
    width : float32
    height : float32
}


// Mark helpers
type MarkTimerAndStacks = float<milli second> * int

type MonsterMark =
    | MograineMark of MarkTimerAndStacks
    | ThaneMark of MarkTimerAndStacks
    | BlaumeuxMark of MarkTimerAndStacks
    | ZeliekMark of MarkTimerAndStacks
