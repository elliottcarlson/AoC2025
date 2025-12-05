sub Main()
    lines = readLines()
    if lines = invalid then
        print "Failed to read input"
        return
    end if

    if lines.count() = 0 then
        print "Day 4, Part 2 answer: 0"
        return
    end if

    grid = []
    for each l in lines
        l$ = "" + l            ' ensure true string
        row = []
        L = Len(l$)

        for i = 1 to L
            ch$ = Mid(l$, i, 1)
            if ch$ = "@" then
                row.push(1)
            else
                row.push(0)
            end if
        end for

        grid.push(row)
    end for

    h = grid.count()
    w = grid[0].count()

    removed = 0

    while true
        rm = []

        for y = 0 to h - 1
            row = grid[y]

            for x = 0 to w - 1
                if row[x] <> 1 then continue for

                adj = 0

                for dy = -1 to 1
                    ny = y + dy
                    if ny < 0 or ny >= h then continue for

                    nrow = grid[ny]

                    for dx = -1 to 1
                        nx = x + dx
                        if dx = 0 and dy = 0 then continue for
                        if nx < 0 or nx >= w then continue for

                        if nrow[nx] = 1 then
                            adj = adj + 1
                        end if
                    end for
                end for

                if adj < 4 then
                    rm.push([y, x])
                end if
            end for
        end for

        if rm.count() = 0 then exit while

        for each cell in rm
            y = cell[0]
            x = cell[1]
            if grid[y][x] = 1 then
                grid[y][x] = 0
                removed = removed + 1
            end if
        end for
    end while

    print "Day 4, Part 2 answer: "; removed
end sub

