sub Main()
    lines = readLines()
    if lines = invalid then
        print "Failed to read input"
        return
    end if

    ranges = []
    maxLen = 0

    for each line in lines
        if line = "" then continue for

        parts = line.Split(",")
        for each r in parts
            if r = "" then continue for

            dash = r.Split("-")
            a$ = dash[0].trim()
            b$ = dash[1].trim()

            ranges.push({ a: a$, b: b$ })

            if len(b$) > maxLen then
                maxLen = len(b$)
            end if
        end for
    end for

    if ranges.count() = 0 then
        print "Day 2, Part 1 answer: 0"
        return
    end if

    candidates = []
    maxK = maxLen \ 2

    for k = 1 to maxK
        startT = pow10(k - 1)
        endT = pow10(k) - 1
        for t = startT to endT
            t$ = str(t).trim()
            c$ = t$ + t$
            candidates.push(c$)
        end for
    end for

    sum$ = "0"

    for each r in ranges
        a$ = r.a
        b$ = r.b
        for each c$ in candidates
            if BigIsGE(c$, a$) and BigIsLE(c$, b$) then
                sum$ = BigAdd(sum$, c$)
            end if
        end for
    end for

    print "Day 2, Part 1 answer: "; sum$
end sub

function pow10(k as integer) as integer
    r = 1
    for i = 1 to k
        r = r * 10
    end for
    return r
end function

