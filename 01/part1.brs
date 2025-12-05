sub Main()
    lines = readLines()
    if lines = invalid then
        print "Failed to read input"
        return
    end if

    ' State: p = position, h = hits on 0
    state = { pos: 50, hits: 0 }

    for each line in lines
        if line = "" then
            goto nextLine
        end if

        dir = left(line, 1)
        dist = val(mid(line, 2))

        if dir = "R" then
            state.pos = (state.pos + dist) mod 100
        else
            state.pos = (state.pos - dist + 10000) mod 100
        end if

        if state.pos = 0 then
            state.hits = state.hits + 1
        end if

        nextLine:
    end for

    print "Day 1, Part 1 answer: "; state.hits
end sub


