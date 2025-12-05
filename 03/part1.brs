sub Main()
    lines = readLines()
    if lines = invalid then
        print "Failed to read input"
        return
    end if

    sum = 0

    for each line in lines
        best = 0
        bestRight = -1

        for i = len(line) to 1 step -1
            d = asc(mid(line, i, 1)) - 48   ' digit 0–9

            if bestRight >= 0 then
                val = d * 10 + bestRight
                if val > best then best = val
            end if

            if d > bestRight then bestRight = d
        end for

        sum = sum + best
    end for

    print "Day 3, Part 1 answer: "; sum
end sub

