sub Main()
    lines = readLines()
    if lines = invalid then
        print "Failed to read input"
        return
    end if

    g = []
    for each l in lines
        g.push(l)         ' each row is a string
    end for

    h = g.count()
    if h = 0 then
        print "Day 4, Part 2 answer: 0"
        return
    end if
    w = len(g[0])

    removed = 0

    while true
        rm = []   ' list of { y: y, x: x } to remove

        for y = 0 to h - 1
            row$ = g[y]

            for x = 1 to w
                if mid(row$, x, 1) <> "@" then
                    continue for
                end if

                adj = 0

                for dy = -1 to 1
                    for dx = -1 to 1
                        if dx = 0 and dy = 0 then continue for

                        ny = y + dy
                        nx = x + dx

                        if ny < 0 or ny >= h then continue for
                        if nx < 1 or nx > w then continue for

                        if mid(g[ny], nx, 1) = "@" then
                            adj = adj + 1
                        end if
                    end for
                end for

                if adj < 4 then
                    rm.push({ y: y, x: x })
                end if
            end for
        end for

        if rm.count() = 0 then
            exit while
        end if

        for each cell in rm
            y = cell.y
            x = cell.x

            row$ = g[y]
            left$  = ""
            right$ = ""

            if x > 1 then
                left$ = mid(row$, 1, x - 1)
            end if
            if x < w then
                right$ = mid(row$, x + 1, w - x)
            end if

            g[y] = left$ + "." + right$
            removed = removed + 1
        end for
    end while

    print "Day 4, Part 2 answer: "; removed
end sub

