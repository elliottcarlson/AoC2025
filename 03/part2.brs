sub Main()
    lines = readLines()
    if lines = invalid then
        print "Failed to read input"
        return
    end if

    sum$ = "0"

    for each line in lines
        if line = "" then continue for

        need = 12
        i = 1
        out$ = ""
        L = len(line)

        while need > 0 and i <= L
            windowEnd = L - (need - 1)
            if windowEnd < i then exit while

            bestDigit = -1
            bestIndex = i

            for j = i to windowEnd
                d = asc(mid(line, j, 1)) - 48
                if d > bestDigit then
                    bestDigit = d
                    bestIndex = j
                    if d = 9 then exit for
                end if
            end for

            out$ = out$ + chr(48 + bestDigit)
            i = bestIndex + 1
            need = need - 1
        end while

        sum$ = BigAdd(sum$, out$)
    end for

    print "Day 3, Part 2 answer: "; sum$
end sub

