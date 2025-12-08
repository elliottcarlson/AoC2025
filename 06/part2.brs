sub Main()
    lines = readLines()
    if lines = invalid then
        print "Failed to read input"
        return
    end if

    g = lines
    h = g.count()
    if h = 0 then
        print "Day 6, Part 2 answer: 0"
        return
    end if

    firstRow$ = "" + g[0]
    w = Len(firstRow$)

    total$ = "0"
    x = 1

    while x <= w
        empty = true

        for y = 0 to h - 1
            row$ = "" + g[y]
            c$ = Mid(row$, x, 1)
            if c$ <> " " then
                empty = false
                exit for
            end if
        end for

        if empty then
            x = x + 1
            continue while
        end if

        cols = []

        while x <= w
            blank = true

            for y = 0 to h - 1
                row$ = "" + g[y]
                c$ = Mid(row$, x, 1)
                if c$ <> " " then
                    blank = false
                    exit for
                end if
            end for

            if blank then
                exit while
            end if

            cols.push(x)
            x = x + 1
        end while

        nums = []
        op$ = ""
        bottom = h - 1

        ' find op in bottom row
        for each cx in cols
            brow$ = "" + g[bottom]
            c$ = Mid(brow$, cx, 1)
            if c$ = "+" or c$ = "*" then
                op$ = c$
                exit for
            end if
        end for

        ' read numbers column-wise
        for each cx in cols
            s$ = ""

            for y = 0 to bottom - 1
                row$ = "" + g[y]
                c$ = Mid(row$, cx, 1)
                if c$ >= "0" and c$ <= "9" then
                    s$ = s$ + c$
                end if
            end for

            if s$ <> "" then
                nums.push(s$)
            end if
        end for

        if op$ = "+" then
            res$ = "0"
        else
            res$ = "1"
        end if

        for each n$ in nums
            if op$ = "+" then
                res$ = BigAdd(res$, n$)
            else
                res$ = BigMul(res$, n$)
            end if
        end for

        total$ = BigAdd(total$, res$)
    end while

    print "Day 6, Part 2 answer: "; total$
end sub

