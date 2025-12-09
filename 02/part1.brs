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

    sum$ = "0"
    maxK = maxLen \ 2

    for k = 1 to maxK
        startT = pow10(k - 1)
        endT = pow10(k) - 1

        ' Multiplier for this k: candidate = t * (10^k + 1)
        multiplier$ = str(pow10(k) + 1).trim()

        for each r in ranges
            a$ = BigNormalize(r.a)
            b$ = BigNormalize(r.b)

            ' Quick length check - candidate has exactly 2*k digits
            candidateLen = 2 * k
            if candidateLen < len(a$) or candidateLen > len(b$) then
                continue for
            end if

            ' Binary search for first t where t$+t$ >= a$
            lo = startT
            hi = endT
            firstValid = -1
            while lo <= hi
                mid = (lo + hi) \ 2
                mid$ = str(mid).trim()
                c$ = mid$ + mid$
                if BigIsGE(c$, a$) then
                    firstValid = mid
                    hi = mid - 1
                else
                    lo = mid + 1
                end if
            end while

            if firstValid = -1 then continue for

            ' Binary search for last t where t$+t$ <= b$
            lo = firstValid
            hi = endT
            lastValid = -1
            while lo <= hi
                mid = (lo + hi) \ 2
                mid$ = str(mid).trim()
                c$ = mid$ + mid$
                if BigIsLE(c$, b$) then
                    lastValid = mid
                    lo = mid + 1
                else
                    hi = mid - 1
                end if
            end while

            if lastValid = -1 then continue for

            ' Sum of t from firstValid to lastValid = count * (first + last) / 2
            ' One of count or (first+last) is always even, so divide that one first
            count = lastValid - firstValid + 1
            sumEnds = firstValid + lastValid

            if count mod 2 = 0 then
                halfCount$ = str(count \ 2).trim()
                sumEnds$ = str(sumEnds).trim()
            else
                halfCount$ = str(count).trim()
                sumEnds$ = str(sumEnds \ 2).trim()
            end if

            tSum$ = BigMul(halfCount$, sumEnds$)

            ' Sum of candidates = tSum * multiplier (since each candidate = t * multiplier)
            rangeSum$ = BigMul(tSum$, multiplier$)
            sum$ = BigAdd(sum$, rangeSum$)
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

