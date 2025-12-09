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
        print "Day 2, Part 2 answer: 0"
        return
    end if

    sum$ = "0"

    ' Process each candidate length separately
    for L = 1 to maxLen
        maxHalf = L \ 2
        if maxHalf = 0 then continue for

        ' Collect unique candidates of length L that fall in at least one range
        validCandidates = {}

        for k = 1 to maxHalf
            if (L mod k) <> 0 then continue for

            reps = L / k
            startT = pow10(k - 1)
            endT = pow10(k) - 1

            for each r in ranges
                a$ = BigNormalize(r.a)
                b$ = BigNormalize(r.b)

                ' Quick length check - candidate has exactly L digits
                if L < len(a$) or L > len(b$) then continue for

                ' Binary search for first t where candidate >= a$
                lo = startT
                hi = endT
                firstValid = -1
                while lo <= hi
                    mid = (lo + hi) \ 2
                    c$ = repeatDigits(mid, reps)
                    if BigIsGE(c$, a$) then
                        firstValid = mid
                        hi = mid - 1
                    else
                        lo = mid + 1
                    end if
                end while

                if firstValid = -1 then continue for

                ' Binary search for last t where candidate <= b$
                lo = firstValid
                hi = endT
                lastValid = -1
                while lo <= hi
                    mid = (lo + hi) \ 2
                    c$ = repeatDigits(mid, reps)
                    if BigIsLE(c$, b$) then
                        lastValid = mid
                        lo = mid + 1
                    else
                        hi = mid - 1
                    end if
                end while

                if lastValid = -1 then continue for

                ' Add valid candidates to set (deduplicates across k values)
                for t = firstValid to lastValid
                    c$ = repeatDigits(t, reps)
                    validCandidates[c$] = true
                end for
            end for
        end for

        ' For each unique candidate, count how many ranges contain it
        for each c$ in validCandidates
            for each r in ranges
                if BigIsGE(c$, r.a) and BigIsLE(c$, r.b) then
                    sum$ = BigAdd(sum$, c$)
                end if
            end for
        end for
    end for

    print "Day 2, Part 2 answer: "; sum$
end sub

function repeatDigits(t as integer, reps as integer) as string
    t$ = str(t).trim()
    s$ = ""
    for i = 1 to reps
        s$ = s$ + t$
    end for
    return s$
end function

function pow10(k as integer) as integer
    r = 1
    for i = 1 to k
        r = r * 10
    end for
    return r
end function

