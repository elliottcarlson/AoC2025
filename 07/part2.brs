sub Main()
    lines = readLines()
    if lines = invalid then
        print "Failed to read input"
        return
    end if

    g = lines
    h = g.count()
    if h = 0 then
        print "Day 7, Part 2 answer: 0"
        return
    end if

    firstRow$ = "" + g[0]
    w = Len(firstRow$)

    sx = 0
    sy = 0

    ' find S
    for y = 0 to h - 1
        row$ = "" + g[y]
        for x = 0 to w - 1
            c$ = Mid(row$, x + 1, 1)
            if c$ = "S" then
                sx = x
                sy = y
            end if
        end for
    end for

    ' dp[y][x] is bigint string count
    dp = []
    for y = 0 to h - 1
        row = []
        for x = 0 to w - 1
            row.push("0")
        end for
        dp.push(row)
    end for

    if sy + 1 < h then
        dp[sy + 1][sx] = "1"
    end if

    total$ = "0"

    for y = sy + 1 to h - 1
        for x = 0 to w - 1
            c$ = dp[y][x]
            if c$ = "0" then
                continue for
            end if

            if y = h - 1 then
                total$ = BigAdd(total$, c$)
                continue for
            end if

            belowRow$ = "" + g[y + 1]
            below$ = Mid(belowRow$, x + 1, 1)

            if below$ = "." then
                dp[y + 1][x] = BigAdd(dp[y + 1][x], c$)
            else if below$ = "^" then
                ny = y + 1
                lx = x - 1
                rx = x + 1

                if lx >= 0 then
                    dp[ny][lx] = BigAdd(dp[ny][lx], c$)
                else
                    total$ = BigAdd(total$, c$)
                end if

                if rx < w then
                    dp[ny][rx] = BigAdd(dp[ny][rx], c$)
                else
                    total$ = BigAdd(total$, c$)
                end if
            else
                dp[y + 1][x] = BigAdd(dp[y + 1][x], c$)
            end if
        end for
    end for

    print "Day 7, Part 2 answer: "; total$
end sub

