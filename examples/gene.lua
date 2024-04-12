-- example/gene.lua

-- The alignment score of -405038 indicates that the two sequences
-- compared have high dissimilarity and little to no meaningful alignment.

-- Load the required packages
local nwunsch = require("nwunsch")
local http = require("socket.http")
local ltn12 = require("ltn12")
local coroutine = require("coroutine")

-- Function to retrieve DNA sequence from Ensembl REST API
local function get_sequence(gene_id)
  local server = "http://rest.ensembl.org"
  local ext = "/sequence/id/" .. gene_id .. "?content-type=text/plain"
  local response_body = {}
  local status_code = http.request {
    url = server .. ext,
    method = "GET",
    sink = ltn12.sink.table(response_body)
  }
  if status_code ~= 200 then
    error("Failed to retrieve sequence for " .. gene_id .. ". Status code: " .. status_code)
  end
  return table.concat(response_body)
end

-- Function to download sequences in parallel
local function download_sequences(gene_ids)
  local sequences = {}
  local threads = {}
  for _, gene_id in ipairs(gene_ids) do
    local thread = coroutine.create(function()
      local sequence = get_sequence(gene_id)
      sequences[gene_id] = sequence
    end)
    table.insert(threads, thread)
  end
  for _, thread in ipairs(threads) do
    coroutine.resume(thread)
  end
  return sequences
end

-- Retrieve DNA sequences
local gene_ids = {"ENSG00000157764", "ENSG00000198804"}
local sequences = download_sequences(gene_ids)

-- Check if sequences for both gene IDs are retrieved
if not sequences["ENSG00000157764"] or not sequences["ENSG00000198804"] then
  error("Sequences for both gene IDs are required for comparison.")
end

-- Assign sequences to variables
local seq1 = sequences["ENSG00000157764"]
local seq2 = sequences["ENSG00000198804"]

-- Set scoring parameters
local match = 2
local mismatch = -1
local gap = -2

-- Perform sequence alignment using nwunsch package
local score, align1, align2 = nwunsch.NeedlemanWunsch(seq1, seq2, match, mismatch, gap)

-- Print the alignment results
print("Alignment score:", score)
print("Alignment 1:", align1)
print("Alignment 2:", align2)