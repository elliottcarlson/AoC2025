sub Main()
    lines = readLines()
    if lines = invalid then
        print "Failed to read input"
        return
    end if

    grid = lines
    h = grid.count()
    if h = 0 then
        print "Day 4, Part 1 answer: 0"
        return
    end if

    w = len(grid[0])
    total = 0

    for y = 0 to h - 1
        row$ = grid[y]
        for x = 1 to w       ' BrightScript strings are 1-indexed
            if mid(row$, x, 1) <> "@" then continue for

            adj = 0

            for dy = -1 to 1
                for dx = -1 to 1
                    if dx = 0 and dy = 0 then continue for

                    ny = y + dy
                    nx = x + dx

                    if ny < 0 or ny >= h or nx < 1 or nx > w then continue for

                    if mid(grid[ny], nx, 1) = "@" then
                        adj = adj + 1
                    end if
                end for
            end for

            if adj < 4 then
                total = total + 1
            end if
        end for
    end for

    print "Day 4, Part 1 answer: "; total
end sub

