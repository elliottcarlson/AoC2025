sub Main()
    lines = readLines()
    if lines = invalid then
        print "Failed to read input"
        return
    end if

    ' ----- Parse points -----
    pts = []
    for each raw in lines
        s$ = "" + raw
        if s$ = "" then continue for

        parts = s$.Split(",")
        if parts.count() <> 2 then continue for

        x = val(parts[0])
        y = val(parts[1])

        pts.push({ x: x, y: y })
    end for

    n = pts.count()
    if n < 2 then
        print "Less than 2 points!"
        return
    end if

    ' ----- Find bounding box -----
    minX = pts[0].x : maxX = pts[0].x
    minY = pts[0].y : maxY = pts[0].y
    for i = 1 to n - 1
        p = pts[i]
        if p.x < minX then minX = p.x
        if p.x > maxX then maxX = p.x
        if p.y < minY then minY = p.y
        if p.y > maxY then maxY = p.y
    end for

    ' ----- Coordinate compression: X and Y -----
    xs = []
    ys = []
    xsSeen = {}
    ysSeen = {}

    ' helper inline: add unique X
    v = minX - 1
    key$ = Str(v + 0.0).Trim()
    xsSeen[key$] = true
    xs.push(v)

    v = maxX + 1
    key$ = Str(v + 0.0).Trim()
    if not xsSeen.doesExist(key$) then
        xsSeen[key$] = true
        xs.push(v)
    end if

    ' helper inline: add unique Y
    v = minY - 1
    key$ = Str(v + 0.0).Trim()
    ysSeen[key$] = true
    ys.push(v)

    v = maxY + 1
    key$ = Str(v + 0.0).Trim()
    if not ysSeen.doesExist(key$) then
        ysSeen[key$] = true
        ys.push(v)
    end if

    ' add all red tile coords
    for each p in pts
        ' X
        vx = p.x
        kx$ = Str(vx + 0.0).Trim()
        if not xsSeen.doesExist(kx$) then
            xsSeen[kx$] = true
            xs.push(vx)
        end if

        ' Y
        vy = p.y
        ky$ = Str(vy + 0.0).Trim()
        if not ysSeen.doesExist(ky$) then
            ysSeen[ky$] = true
            ys.push(vy)
        end if
    end for

    ' sort xs ascending (selection sort)
    nx = xs.count()
    for i = 0 to nx - 2
        minIdx = i
        minVal = xs[i]
        for j = i + 1 to nx - 1
            if xs[j] < minVal then
                minVal = xs[j]
                minIdx = j
            end if
        end for
        if minIdx <> i then
            tmp = xs[i]
            xs[i] = xs[minIdx]
            xs[minIdx] = tmp
        end if
    end for

    ' sort ys ascending
    ny = ys.count()
    for i = 0 to ny - 2
        minIdx = i
        minVal = ys[i]
        for j = i + 1 to ny - 1
            if ys[j] < minVal then
                minVal = ys[j]
                minIdx = j
            end if
        end for
        if minIdx <> i then
            tmp = ys[i]
            ys[i] = ys[minIdx]
            ys[minIdx] = tmp
        end if
    end for

    ' build maps coord -> index
    xIndexMap = {}
    for i = 0 to nx - 1
        key$ = Str(xs[i] + 0.0).Trim()
        xIndexMap[key$] = i
    end for

    yIndexMap = {}
    for i = 0 to ny - 1
        key$ = Str(ys[i] + 0.0).Trim()
        yIndexMap[key$] = i
    end for

    ' ----- Compressed grid: 1 = allowed (red/green), 0 = forbidden -----
    grid = []
    for iy = 0 to ny - 1
        row = []
        for ix = 0 to nx - 1
            row.push(0)
        end for
        grid.push(row)
    end for

    ' map each red tile to compressed index, store for later
    pxIdx = []
    pyIdx = []
    for i = 0 to n - 1
        p = pts[i]
        kx$ = Str(p.x + 0.0).Trim()
        ky$ = Str(p.y + 0.0).Trim()
        ix = xIndexMap[kx$]
        iy = yIndexMap[ky$]
        pxIdx.push(ix)
        pyIdx.push(iy)
        grid[iy][ix] = 1
    end for

    ' ----- Draw boundary (green) between consecutive red tiles (with wrap) -----
    for i = 0 to n - 1
        a = pts[i]
        b = pts[(i + 1) mod n]

        kax$ = Str(a.x + 0.0).Trim()
        kay$ = Str(a.y + 0.0).Trim()
        kbx$ = Str(b.x + 0.0).Trim()
        kby$ = Str(b.y + 0.0).Trim()

        ax = xIndexMap[kax$] : ay = yIndexMap[kay$]
        bx = xIndexMap[kbx$] : by = yIndexMap[kby$]

        if ax = bx then
            ' vertical segment
            if ay <= by then
                sy = ay : ey = by
            else
                sy = by : ey = ay
            end if
            for iy = sy to ey
                grid[iy][ax] = 1
            end for
        else if ay = by then
            ' horizontal segment
            if ax <= bx then
                sx = ax : ex = bx
            else
                sx = bx : ex = ax
            end if
            for ix = sx to ex
                grid[ay][ix] = 1
            end for
        else
            ' per problem, should not happen
        end if
    end for

    ' ----- Flood fill "outside" from border where grid=0 -----
    visited = []
    for iy = 0 to ny - 1
        row = []
        for ix = 0 to nx - 1
            row.push(0)
        end for
        visited.push(row)
    end for

    queue = []
    head = 0

    ' top and bottom rows
    for ix = 0 to nx - 1
        if grid[0][ix] = 0 and visited[0][ix] = 0 then
            visited[0][ix] = 1
            queue.push({ x: ix, y: 0 })
        end if
        if grid[ny - 1][ix] = 0 and visited[ny - 1][ix] = 0 then
            visited[ny - 1][ix] = 1
            queue.push({ x: ix, y: ny - 1 })
        end if
    end for

    ' left and right columns
    for iy = 0 to ny - 1
        if grid[iy][0] = 0 and visited[iy][0] = 0 then
            visited[iy][0] = 1
            queue.push({ x: 0, y: iy })
        end if
        if grid[iy][nx - 1] = 0 and visited[iy][nx - 1] = 0 then
            visited[iy][nx - 1] = 1
            queue.push({ x: nx - 1, y: iy })
        end if
    end for

    while head < queue.count()
        node = queue[head]
        head = head + 1

        x = node.x
        y = node.y

        ' 4 neighbors
        if x > 0 then
            if grid[y][x - 1] = 0 and visited[y][x - 1] = 0 then
                visited[y][x - 1] = 1
                queue.push({ x: x - 1, y: y })
            end if
        end if
        if x < nx - 1 then
            if grid[y][x + 1] = 0 and visited[y][x + 1] = 0 then
                visited[y][x + 1] = 1
                queue.push({ x: x + 1, y: y })
            end if
        end if
        if y > 0 then
            if grid[y - 1][x] = 0 and visited[y - 1][x] = 0 then
                visited[y - 1][x] = 1
                queue.push({ x: x, y: y - 1 })
            end if
        end if
        if y < ny - 1 then
            if grid[y + 1][x] = 0 and visited[y + 1][x] = 0 then
                visited[y + 1][x] = 1
                queue.push({ x: x, y: y + 1 })
            end if
        end if
    end while

    ' mark interior (unvisited zeros) as allowed
    for iy = 0 to ny - 1
        for ix = 0 to nx - 1
            if grid[iy][ix] = 0 and visited[iy][ix] = 0 then
                grid[iy][ix] = 1
            end if
        end for
    end for

    ' ----- 2D prefix sum of forbidden cells (grid=0) -----
    bad = []
    for iy = 0 to ny
        row = []
        for ix = 0 to nx
            row.push(0)
        end for
        bad.push(row)
    end for

    for iy = 0 to ny - 1
        rowBad = bad[iy + 1]
        prevRowBad = bad[iy]
        sumRow = 0
        for ix = 0 to nx - 1
            v = 0
            if grid[iy][ix] = 0 then v = 1
            sumRow = sumRow + v
            rowBad[ix + 1] = sumRow + prevRowBad[ix + 1]
        end for
    end for

    ' ----- Try all red-pair rectangles -----
    maxArea$ = "0"

    for i = 0 to n - 1
        p1 = pts[i]
        ix1 = pxIdx[i]
        iy1 = pyIdx[i]

        for j = i + 1 to n - 1
            p2 = pts[j]
            ix2 = pxIdx[j]
            iy2 = pyIdx[j]

            ' compressed rectangle indices
            if ix1 <= ix2 then
                cx0 = ix1 : cx1 = ix2
            else
                cx0 = ix2 : cx1 = ix1
            end if

            if iy1 <= iy2 then
                cy0 = iy1 : cy1 = iy2
            else
                cy0 = iy2 : cy1 = iy1
            end if

            ' any forbidden cells?
            totalBad = bad[cy1 + 1][cx1 + 1] - bad[cy0][cx1 + 1] - bad[cy1 + 1][cx0] + bad[cy0][cx0]
            if totalBad <> 0 then
                continue for
            end if

            ' compute real area (bigint)
            dx = p1.x - p2.x : if dx < 0 then dx = -dx
            dy = p1.y - p2.y : if dy < 0 then dy = -dy

            width$  = Str(dx + 1.0).Trim()
            height$ = Str(dy + 1.0).Trim()

            area$ = BigMul(width$, height$)

            if BigCmp(area$, maxArea$) > 0 then
                maxArea$ = area$
            end if
        end for
    end for

    print "Day 9, Part 2 answer: "; maxArea$
end sub

