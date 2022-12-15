Puzzle.create!(
  variant: Puzzle.variants[:thermo],
  difficulty: Puzzle.difficulties[:easy4x4],
  constraints: {
    grid_size: 4,
    fixed_numbers: [
      { position: { row: 0, col: 2 }, value: 4 },
    ],
    thermos: [
      [
        { row: 0, col: 0 },
        { row: 0, col: 1 },
        { row: 0, col: 2 },
      ],
      [
        { row: 2, col: 0 },
        { row: 2, col: 1 },
        { row: 2, col: 2 },
      ],
    ]
  },
  solution: [
    [2, 3, 4, 1],
    [4, 1, 2, 3],
    [1, 2, 3, 4],
    [3, 4, 1, 2],
  ],
)

# WSC booklet 6x6 thermo https://uploads-ssl.webflow.com/62793457876c001d28edf162/6348945a45b06acb414391b7_WSC_2022_IB_v2.1.pdf
Puzzle.create!(
  variant: Puzzle.variants[:thermo],
  difficulty: Puzzle.difficulties[:easy6x6],
  constraints: {
    grid_size: 6,
    fixed_numbers: [
      { position: { row: 1, col: 0 }, value: 4 },
      { position: { row: 2, col: 0 }, value: 5 },
      { position: { row: 4, col: 5 }, value: 2 },
      { position: { row: 5, col: 4 }, value: 4 },
      { position: { row: 5, col: 5 }, value: 3 },
    ],
    thermos: [
      [
        { row: 0, col: 0 },
        { row: 0, col: 1 },
        { row: 0, col: 2 },
        { row: 0, col: 3 },
        { row: 0, col: 4 },
        { row: 0, col: 5 },
      ],
      [
        { row: 1, col: 4 },
        { row: 2, col: 4 },
        { row: 3, col: 4 },
      ],
      [
        { row: 2, col: 2 },
        { row: 3, col: 2 },
        { row: 4, col: 2 },
        { row: 4, col: 3 },
      ],
      [
        { row: 3, col: 0 },
        { row: 4, col: 0 },
        { row: 5, col: 0 },
      ],
      [
        { row: 3, col: 3 },
        { row: 2, col: 3 },
        { row: 1, col: 3 },
        { row: 1, col: 2 },
      ],
    ]
  },
  solution: [
    [ 1, 2, 3, 4, 5, 6 ],
    [ 4, 5, 6, 3, 2, 1 ],
    [ 5, 6, 1, 2, 3, 4 ],
    [ 2, 3, 4, 1, 6, 5 ],
    [ 3, 4, 5, 6, 1, 2 ],
    [ 6, 1, 2, 5, 4, 3 ],
  ],
)

Puzzle.create!(
  variant: Puzzle.variants[:thermo],
  difficulty: Puzzle.difficulties[:easy9x9],
  constraints: {
    grid_size: 9,
    fixed_numbers: [
      { position: { row: 7, col: 0 }, value: 4 },
      { position: { row: 8, col: 2 }, value: 1 },
      { position: { row: 0, col: 6 }, value: 1 },
      { position: { row: 1, col: 6 }, value: 2 },
      { position: { row: 2, col: 6 }, value: 3 },
      { position: { row: 3, col: 6 }, value: 4 },
      { position: { row: 4, col: 6 }, value: 5 },
      { position: { row: 4, col: 7 }, value: 3 },
      { position: { row: 4, col: 8 }, value: 8 },
      { position: { row: 2, col: 7 }, value: 8 },
      { position: { row: 2, col: 8 }, value: 9 },
      { position: { row: 0, col: 7 }, value: 6 },
      { position: { row: 0, col: 8 }, value: 5 },
      { position: { row: 8, col: 6 }, value: 9 },
      { position: { row: 7, col: 8 }, value: 2 },
      { position: { row: 5, col: 4 }, value: 4 },
      { position: { row: 8, col: 1 }, value: 5 },
    ],
    thermos: [
      [
        { row: 1, col: 3 },
        { row: 0, col: 2 },
        { row: 0, col: 1 },
        { row: 1, col: 0 },
        { row: 2, col: 0 },
        { row: 3, col: 0 },
      ],
      [
        { row: 4, col: 0 },
        { row: 5, col: 1 },
        { row: 5, col: 2 },
        { row: 4, col: 3 },
        { row: 3, col: 3 },
        { row: 3, col: 2 },
      ],
      [
        { row: 6, col: 5 },
        { row: 6, col: 4 },
        { row: 6, col: 3 },
        { row: 7, col: 3 },
        { row: 8, col: 3 },
        { row: 8, col: 4 },
        { row: 8, col: 5 },
        { row: 7, col: 5 },
      ],
    ]
  },
  solution: [
    [3, 4, 2, 9, 8, 7, 1, 6, 5],
    [5, 9, 8, 1, 6, 3, 2, 7, 4],
    [6, 1, 7, 2, 5, 4, 3, 8, 9],
    [7, 3, 9, 8, 1, 5, 4, 2, 6],
    [1, 6, 4, 7, 9, 2, 5, 3, 8],
    [8, 2, 5, 3, 4, 6, 7, 9, 1],
    [9, 8, 3, 4, 2, 1, 6, 5, 7],
    [4, 7, 6, 5, 3, 9, 8, 1, 2],
    [2, 5, 1, 6, 7, 8, 9, 4, 3],
  ],
)

Puzzle.create!(
  variant: Puzzle.variants[:thermo],
  difficulty: Puzzle.difficulties[:medium9x9],
  constraints: {
    grid_size: 9,
    fixed_numbers: [
      { position: { row: 4, col: 2 }, value: 4 },
      { position: { row: 8, col: 6 }, value: 7 },
      { position: { row: 2, col: 3 }, value: 6 },
      { position: { row: 6, col: 2 }, value: 2 },
      { position: { row: 1, col: 8 }, value: 6 },
      { position: { row: 1, col: 3 }, value: 9 },
      { position: { row: 1, col: 1 }, value: 4 },
      { position: { row: 4, col: 7 }, value: 8 },
      { position: { row: 3, col: 1 }, value: 2 },
      { position: { row: 7, col: 1 }, value: 7 },
      { position: { row: 6, col: 6 }, value: 4 },
    ],
    thermos: [
      [
        { row: 8, col: 8 },
        { row: 7, col: 8 },
        { row: 6, col: 8 },
        { row: 5, col: 8 },
        { row: 4, col: 8 },
        { row: 3, col: 8 },
      ],
      [
        { row: 8, col: 0 },
        { row: 7, col: 0 },
        { row: 6, col: 0 },
        { row: 5, col: 0 },
        { row: 4, col: 0 },
        { row: 3, col: 0 },
      ],
      [
        { row: 0, col: 4 },
        { row: 1, col: 4 },
        { row: 2, col: 4 },
        { row: 3, col: 4 },
        { row: 4, col: 4 },
        { row: 5, col: 4 },
      ],
      [
        { row: 0, col: 2 },
        { row: 1, col: 2 },
        { row: 2, col: 2 },
        { row: 3, col: 2 },
      ],
      [
        { row: 0, col: 6 },
        { row: 1, col: 6 },
        { row: 2, col: 6 },
        { row: 3, col: 6 },
      ],
      [
        { row: 8, col: 5 },
        { row: 7, col: 5 },
        { row: 6, col: 5 },
        { row: 5, col: 5 },
      ],
      [
        { row: 8, col: 3 },
        { row: 7, col: 3 },
        { row: 6, col: 3 },
        { row: 5, col: 3 },
      ],
    ]
  },
  solution: [
    [8, 6, 3, 5, 2, 7, 1, 4, 9],
    [1, 4, 5, 9, 3, 8, 2, 7, 6],
    [2, 9, 7, 6, 4, 1, 5, 3, 8],
    [9, 2, 8, 4, 5, 3, 6, 1, 7],
    [7, 3, 4, 1, 6, 2, 9, 8, 5],
    [6, 5, 1, 8, 7, 9, 3, 2, 4],
    [5, 1, 2, 7, 8, 6, 4, 9, 3],
    [4, 7, 9, 3, 1, 5, 8, 6, 2],
    [3, 8, 6, 2, 9, 4, 7, 5, 1],
  ],
)

# UK Sudoku Championship 2022 booklet - 9x9 thermo https://ukpuzzles.org/file_download.php?fileid=247&md5=c200e06d8822177932d906103919ceba
Puzzle.create!(
  variant: Puzzle.variants[:thermo],
  difficulty: Puzzle.difficulties[:hard9x9],
  constraints: {
    grid_size: 9,
    fixed_numbers: [
      { position: { row: 2, col: 2 }, value: 2 },
      { position: { row: 2, col: 6 }, value: 4 },
      { position: { row: 3, col: 4 }, value: 5 },
      { position: { row: 5, col: 4 }, value: 1 },
      { position: { row: 6, col: 2 }, value: 9 },
      { position: { row: 6, col: 6 }, value: 5 },
    ],
    thermos: [
      [
        { row: 0, col: 6 },
        { row: 0, col: 5 },
        { row: 0, col: 4 },
        { row: 0, col: 3 },
        { row: 0, col: 2 },
        { row: 0, col: 1 },
        { row: 0, col: 0 },
      ],
      [
        { row: 2, col: 0 },
        { row: 3, col: 0 },
        { row: 4, col: 0 },
        { row: 5, col: 0 },
        { row: 6, col: 0 },
        { row: 7, col: 0 },
        { row: 8, col: 0 },
      ],
      [
        { row: 2, col: 5 },
        { row: 2, col: 4 },
        { row: 2, col: 3 },
      ],
      [
        { row: 3, col: 2 },
        { row: 4, col: 2 },
        { row: 5, col: 2 },
      ],
      [
        { row: 5, col: 6 },
        { row: 4, col: 6 },
        { row: 3, col: 6 },
      ],
      [
        { row: 6, col: 3 },
        { row: 6, col: 4 },
        { row: 6, col: 5 },
      ],
      [
        { row: 6, col: 8 },
        { row: 5, col: 8 },
        { row: 4, col: 8 },
        { row: 3, col: 8 },
        { row: 2, col: 8 },
        { row: 1, col: 8 },
        { row: 0, col: 8 },
      ],
      [
        { row: 8, col: 2 },
        { row: 8, col: 3 },
        { row: 8, col: 4 },
        { row: 8, col: 5 },
        { row: 8, col: 6 },
        { row: 8, col: 7 },
        { row: 8, col: 8 },
      ],
    ]
  },
  solution: [
    [9, 8, 6, 5, 4, 2, 1, 3, 7],
    [3, 5, 4, 7, 8, 1, 2, 9, 6],
    [1, 7, 2, 9, 6, 3, 4, 8, 5],
    [2, 6, 3, 8, 5, 7, 9, 1, 4],
    [4, 1, 7, 6, 2, 9, 8, 5, 3],
    [5, 9, 8, 3, 1, 4, 7, 6, 2],
    [6, 3, 9, 4, 7, 8, 5, 2, 1],
    [7, 2, 5, 1, 9, 6, 3, 4, 8],
    [8, 4, 1, 2, 3, 5, 6, 7, 9],
  ],
)
