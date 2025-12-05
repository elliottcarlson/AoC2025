sub Main()
    lines = readLines()
    if lines = invalid then
        print "Failed to read input"
        return
    end if

    ranges = []
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
                ranges.push({ a: a$, b: b$ })
            end if
        end if
    end for

    if ranges.count() = 0 then
        print "Day 5, Part 2 answer: 0"
        return
    end if

    n = ranges.count()
    for i = 0 to n - 2
        for j = i + 1 to n - 1
            ri = ranges[i]
            rj = ranges[j]
            cmp = BigCmp(ri.a, rj.a)
            if cmp > 0 or (cmp = 0 and BigCmp(ri.b, rj.b) > 0) then
                tmp = ranges[i]
                ranges[i] = ranges[j]
                ranges[j] = tmp
            end if
        end for
    end for

    currentStart$ = ranges[0].a
    currentEnd$   = ranges[0].b
    total$ = "0"

    for i = 1 to n - 1
        r = ranges[i]
        nextStart$ = r.a
        nextEnd$   = r.b

        endPlusOne$ = BigAdd(currentEnd$, "1")

        if BigCmp(nextStart$, endPlusOne$) <= 0 then
            if BigCmp(nextEnd$, currentEnd$) > 0 then
                currentEnd$ = nextEnd$
            end if
        else
            len$ = BigAdd(BigSub(currentEnd$, currentStart$), "1")
            total$ = BigAdd(total$, len$)
            currentStart$ = nextStart$
            currentEnd$   = nextEnd$
        end if
    end for

    lenLast$ = BigAdd(BigSub(currentEnd$, currentStart$), "1")
    total$ = BigAdd(total$, lenLast$)

    print "Day 5, Part 2 answer: "; total$
end sub

