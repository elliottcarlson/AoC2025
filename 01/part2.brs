sub Main()
    lines = readLines()
    if lines = invalid then
        print "Failed to read input"
        return
    end if

    state = { pos: 50, hits: 0 }

    for each line in lines
        if line = "" then goto nextLine

        dir = left(line, 1)
        dist = val(mid(line, 2))
        isRight = (dir = "R")

        if isRight then
            f = (100 - state.pos) mod 100
        else
            f = state.pos mod 100
        end if

        if f = 0 then f = 100

        if f <= dist then
            state.hits = state.hits + 1 + ((dist - f) \ 100)
        end if

        if isRight then
            state.pos = (state.pos + dist) mod 100
        else
            state.pos = (state.pos - dist + 10000) mod 100
        end if

        nextLine:
    end for

    print "Day 1, Part 2 answer: "; state.hits
end sub

