## nwunsch

[Needleman–Wunsch](https://en.wikipedia.org/wiki/Needleman%E2%80%93Wunsch_algorithm) algorithm implementation in Lua.

### Features

- **Sequence Comparison**: The package enables the comparison of two sequences (seq1 and seq2) by considering all possible alignments and choosing the best one.

- **Scoring System**: The scoring system is customisable with match, mismatch, and gap parameters, allowing users to define the reward for matched characters and penalties for mismatches and gaps.

- **Matrix Generation and Population**: It creates a dynamic programming matrix of sequence lengths and populates it accordingly based on optimal alignment values.

- **Traceback Functionality**: It includes a traceback procedure which identifies the optimal path through the matrix, producing the final alignment of the input sequences.

- **Efficient Evaluation**: It utilises a max function to determine the maximum score between match, mismatch, and gap; this feature guarantees the efficiency of the sequence alignment process.

### Installation

Install the `nwunsch` package in your `Lua` project by installing it with the following command:

```shell
luarocks install nwunsch
```

### Usage

```lua
local nwunsch = require("nwunsch")

-- Use the package functions
local seq1 = "AGACTAGTTACCGTAGGCTCGAGTCGGATCGGATCGGATCGGATCAA"
local seq2 = "CGAGACGTGACCTTAGGCTCGAGTCGGATCGGATCGGATCGGA"
local match = 2
local mismatch = -1
local gap = -2

local score, align1, align2 = nwunsch.NeedlemanWunsch(seq1, seq2, match, mismatch, gap)
print("Alignment score:", score)
print("Alignment 1:", align1)
print("Alignment 2:", align2)
```

### License

This project is licensed under the [MIT License](./LICENSE).

### Copyright

(c) 2024 [Finbarrs Oketunji](https://finbarrs.eu).