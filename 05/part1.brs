sub Main()
    lines = readLines()
    if lines = invalid then
        print "Failed to read input"
        return
    end if

    freshRanges = []
    ids = []

    readingRanges = true

    for each raw in lines
        line = ("" + raw).trim()

        if readingRanges then
            if line = "" then
                readingRanges = false
            else
                parts = line.Split("-")
                a$ = parts[0].trim()
                b$ = parts[1].trim()
                freshRanges.push({ a: a$, b: b$ })
            end if
        else
            if line <> "" then
                ids.push(line)
            end if
        end if
    end for

    countFresh = 0

    for each id$ in ids
        isFresh = false

        for each r in freshRanges
            if BigIsGE(id$, r.a) and BigIsLE(id$, r.b) then
                isFresh = true
                exit for
            end if
        end for

        if isFresh then
            countFresh = countFresh + 1
        end if
    end for

    print "Day 5, Part 1 answer: "; countFresh
end sub
