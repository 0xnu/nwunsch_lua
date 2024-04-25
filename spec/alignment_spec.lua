-- spec/alignment_spec.lua
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

describe("Sequence Alignment", function()
  local gene_ids = {"ENSG00000157764", "ENSG00000198804"}

  it("should retrieve sequences from Ensembl REST API", function()
    local sequences = download_sequences(gene_ids)

    assert.is_not_nil(sequences["ENSG00000157764"])
    assert.is_not_nil(sequences["ENSG00000198804"])

    assert.is_string(sequences["ENSG00000157764"])
    assert.is_string(sequences["ENSG00000198804"])
  end)

  it("should perform sequence alignment using nwunsch package", function()
    local sequences = download_sequences(gene_ids)
    local seq1 = sequences["ENSG00000157764"]
    local seq2 = sequences["ENSG00000198804"]

    local match = 2
    local mismatch = -1
    local gap = -2

    local score, align1, align2 = nwunsch.NeedlemanWunsch(seq1, seq2, match, mismatch, gap)

    assert.is_number(score)
    assert.is_string(align1)
    assert.is_string(align2)

    assert.are.equal(#align1, #align2)
  end)

  it("should handle error when sequences are not retrieved", function()
    local invalid_gene_ids = {"INVALID_ID_1", "INVALID_ID_2"}
    local sequences = download_sequences(invalid_gene_ids)

    assert.has_error(function()
      if not sequences["INVALID_ID_1"] or not sequences["INVALID_ID_2"] then
        error("Sequences for both gene IDs are required for comparison.")
      end
    end)
  end)
end)