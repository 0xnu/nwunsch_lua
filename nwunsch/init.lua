-- nwunsch/init.lua
local nwunsch = {}

function nwunsch.NeedlemanWunsch(seq1, seq2, match, mismatch, gap)
    local m, n = #seq1, #seq2
    local dp = nwunsch.generateDPTable(m, n, gap)
    nwunsch.fillDPTable(seq1, seq2, dp, match, mismatch, gap)
    local align1, align2 = nwunsch.traceback(seq1, seq2, dp, match, mismatch, gap)
    return dp[m+1][n+1], align1, align2
end

function nwunsch.generateDPTable(m, n, gap)
    local dp = {}
    for i = 0, m do
        dp[i+1] = {}
        dp[i+1][1] = i * gap
    end
    for j = 0, n do
        dp[1][j+1] = j * gap
    end
    return dp
end

function nwunsch.fillDPTable(seq1, seq2, dp, match, mismatch, gap)
    for i = 1, #seq1 do
        for j = 1, #seq2 do
            local matchScore = dp[i][j]
            local score = mismatch
            if seq1:sub(i,i) == seq2:sub(j,j) then
                score = match
            end
            dp[i+1][j+1] = nwunsch.max(matchScore+score, dp[i][j+1]+gap, dp[i+1][j]+gap)
        end
    end
end

function nwunsch.traceback(seq1, seq2, dp, match, mismatch, gap)
    local align1, align2 = "", ""
    local i, j = #seq1, #seq2
    while i > 0 and j > 0 do
        local score = mismatch
        if seq1:sub(i,i) == seq2:sub(j,j) then
            score = match
        end
        if dp[i+1][j+1] == dp[i][j] + score then
            align1, align2 = seq1:sub(i,i) .. align1, seq2:sub(j,j) .. align2
            i, j = i-1, j-1
        elseif dp[i+1][j+1] == dp[i][j+1] + gap then
            align1, align2 = seq1:sub(i,i) .. align1, "-" .. align2
            i = i-1
        else
            align1, align2 = "-" .. align1, seq2:sub(j,j) .. align2
            j = j-1
        end
    end
    while i > 0 do
        align1, align2 = seq1:sub(i,i) .. align1, "-" .. align2
        i = i-1
    end
    while j > 0 do
        align1, align2 = "-" .. align1, seq2:sub(j,j) .. align2
        j = j-1
    end
    return align1, align2
end

function nwunsch.max(a, b, c)
    if a > b then
        if a > c then
            return a
        end
        return c
    end
    if b > c then
        return b
    end
    return c
end

return nwunsch