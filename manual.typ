#import "@preview/mantys:0.1.4": *
#import "@preview/cetz:0.3.1"
#import "./cetz-timing.typ": texttiming, timingtable, draw-sequence, parse-sequence

#show: mantys.with(
  name: "cetz-timing",
  title: "cetz-timing",
  subtitle: "A Typst Package for Timing Diagrams",
  authors: "Johannes Schiffer",
  version: "0.1.0",
  date: datetime.today(),
)

#set table(
  stroke: (x, y) => if y == 0 {
    (bottom: 0.7pt + black)
  },
  align: (x, y) => (
    if x > 0 { center }
    else { left }
  )
)

= Introduction

This package uses CeTZ to produce timing diagrams inside text./* */

It is a port of `tikz-timing` by Martin Scharrer to Typst.

The signal levels of the timing diagram can be given by corresponding characters/letters like '`H`' for _Logical High_
or '`L`' for _Logical Low_. So e.g. '`{HLZXD}`' gives '#texttiming("HLZXD")'. In order to fit (in)to normal text size the diagram size (i.e. its height, width and line width) is defined relatively to the size of the character 'A' in the current context.

This way the diagram can also be scaled width the font size. (Example: #text(size: 8pt, [Hello #texttiming("HLZXD")]), #text(size: 14pt, [Hello #texttiming("HLZXD")])).
A single timing character produces a diagram width a width identical to its height ('`H`' $->$ '#texttiming("H")'). Longer diagrams can be produced by either using the same character multiple times ('`HHH`' $->$ '#texttiming("HHH")') or writing the width as number in front of the character ('`3H`' $->$ '#texttiming("3H")')/* */.
Recurring character combinations can be repeated using character groups ('`3{HLZ}`' $->$ '#texttiming("3{HLZ}")') /* */. Character groups can be nested arbitrarily ('`2{H3{ZL}}`' $->$ #texttiming("2{H3{ZL}}")).

= Usage

== Timing Characters

The logic levels are described by so called timing characters. Actually all of them are letters, but the general term character
is used here. @timing-chars shows all by default defined logic characters and @timing-transitions all possible two-character transitions.

#figure(
  table(
    columns: 4,
    table.header(
      [Character], [Description], [Diagram], [Transition Example]
    ),
    [`H`], 
    [High], 
    [#texttiming("H", draw-grid: true)], 
    [#texttiming("H", initchar: "L", draw-grid: true)],
    [`L`], 
    [Low], 
    [#texttiming("L", draw-grid: true)],
    [#texttiming("L", initchar: "H", draw-grid: true)],
    [`Z`], 
    [High impedance], 
    [#texttiming("Z", draw-grid: true)], 
    [#texttiming("Z", initchar: "L", draw-grid: true)],
    [`X`], 
    [Don't care], 
    [#texttiming("X", draw-grid: true)], 
    [#texttiming("X", initchar: "L", draw-grid: true)],
    [`D`], 
    [Data], 
    [#texttiming("D", draw-grid: true)], 
    [#texttiming("D", initchar: "D", draw-grid: true)],
    [`U`], 
    [Unknown data], 
    [#texttiming("U", draw-grid: true)], 
    [#texttiming("U", initchar: "D", draw-grid: true)],
    [`T`], [Toggle],
    [#texttiming("L", draw-grid: true) or #texttiming("H", draw-grid: true) ], 
    [#texttiming("TTTT", draw-grid: true)],
    [`C`], [Clock], 
    [#texttiming("L", draw-grid: true) or #texttiming("H", draw-grid: true) ], 
    [#texttiming("CCCC", draw-grid: true)],
    [`M`], [Metastable condition], [#texttiming("M", draw-grid: true)], [#texttiming("M", initchar: "D", draw-grid: true)],
    [`G`], [Glitch], [-], [-],
    [`S`], [Space], [-], [-],
  ),
  caption: [Timing Characters]
) <timing-chars>

#figure(
  table(
    columns: 10,
    table.header(
      [From], [H], [L], [Z], [X], [M], [D], [U], [T], [C]
    ),
    [H],
    [#texttiming("HH", draw-grid: true)],
    [#texttiming("HL", draw-grid: true)],
    [#texttiming("HZ", draw-grid: true)],
    [#texttiming("HX", draw-grid: true)],
    [#texttiming("HM", draw-grid: true)],
    [#texttiming("HD", draw-grid: true)],
    [#texttiming("HU", draw-grid: true)],
    [#texttiming("HT", draw-grid: true)],
    [#texttiming("HC", draw-grid: true)],
    [L],
    [#texttiming("LH", draw-grid: true)],
    [#texttiming("LH", draw-grid: true)],
    [#texttiming("LZ", draw-grid: true)],
    [#texttiming("LX", draw-grid: true)],
    [#texttiming("LM", draw-grid: true)],
    [#texttiming("LD", draw-grid: true)],
    [#texttiming("LU", draw-grid: true)],
    [#texttiming("LT", draw-grid: true)],
    [#texttiming("LC", draw-grid: true)],
    [Z], 
    [#texttiming("ZH", draw-grid: true)],
    [#texttiming("ZH", draw-grid: true)],
    [#texttiming("ZZ", draw-grid: true)],
    [#texttiming("ZX", draw-grid: true)],
    [#texttiming("ZM", draw-grid: true)],
    [#texttiming("ZD", draw-grid: true)],
    [#texttiming("ZU", draw-grid: true)],
    [#texttiming("ZT", draw-grid: true)],
    [#texttiming("ZC", draw-grid: true)],
    [X], 
    [#texttiming("XH", draw-grid: true)],
    [#texttiming("XH", draw-grid: true)],
    [#texttiming("XZ", draw-grid: true)],
    [#texttiming("XX", draw-grid: true)],
    [#texttiming("XM", draw-grid: true)],
    [#texttiming("XD", draw-grid: true)],
    [#texttiming("XU", draw-grid: true)],
    [#texttiming("XT", draw-grid: true)],
    [#texttiming("XC", draw-grid: true)],
    [M], 
    [#texttiming("MH", draw-grid: true)],
    [#texttiming("MH", draw-grid: true)],
    [#texttiming("MZ", draw-grid: true)],
    [#texttiming("MX", draw-grid: true)],
    [#texttiming("MM", draw-grid: true)],
    [#texttiming("MD", draw-grid: true)],
    [#texttiming("MU", draw-grid: true)],
    [#texttiming("MT", draw-grid: true)],
    [#texttiming("MC", draw-grid: true)],
    [D], 
    [#texttiming("DH", draw-grid: true)],
    [#texttiming("DH", draw-grid: true)],
    [#texttiming("DZ", draw-grid: true)],
    [#texttiming("DX", draw-grid: true)],
    [#texttiming("DM", draw-grid: true)],
    [#texttiming("DD", draw-grid: true)],
    [#texttiming("DU", draw-grid: true)],
    [#texttiming("DT", draw-grid: true)],
    [#texttiming("DC", draw-grid: true)],
    [U], 
    [#texttiming("UH", draw-grid: true)],
    [#texttiming("UH", draw-grid: true)],
    [#texttiming("UZ", draw-grid: true)],
    [#texttiming("UX", draw-grid: true)],
    [#texttiming("UM", draw-grid: true)],
    [#texttiming("UD", draw-grid: true)],
    [#texttiming("UU", draw-grid: true)],
    [#texttiming("UT", draw-grid: true)],
    [#texttiming("UC", draw-grid: true)],
    [T], 
    [#texttiming("TH", draw-grid: true)],
    [#texttiming("TH", draw-grid: true)],
    [#texttiming("TZ", draw-grid: true)],
    [#texttiming("TX", draw-grid: true)],
    [#texttiming("TM", draw-grid: true)],
    [#texttiming("TD", draw-grid: true)],
    [#texttiming("TU", draw-grid: true)],
    [#texttiming("TT", draw-grid: true)],
    [#texttiming("TC", draw-grid: true)],
    [C],
    [#texttiming("CH", draw-grid: true)],
    [#texttiming("CH", draw-grid: true)],
    [#texttiming("CZ", draw-grid: true)],
    [#texttiming("CX", draw-grid: true)],
    [#texttiming("CM", draw-grid: true)],
    [#texttiming("CD", draw-grid: true)],
    [#texttiming("CU", draw-grid: true)],
    [#texttiming("CT", draw-grid: true)],
    [#texttiming("CC", draw-grid: true)],
  ),
  caption: [Overview over all transitions]
) <timing-transitions>

#figure(
  table(
    columns: 2,
    table.header(
      [Modifier Syntax], [Description]
    ),
    [`D|D`], [Produces an explicit transition. By default, repeating signals don't have a transition. _E.g.:_ '`3D|D`' $->$ #texttiming("3D|D", draw-grid: true), '`L|LLL`' $->$ #texttiming("L|LLL", draw-grid: true)]
  ),
  caption: [Modifiers for Timing Characters]
) <timing-modifier>

== Timing Diagram Table

Using the `timingtable` command, a timing diagram with several logic lines can be drawn to a CeTZ canvas.

The used layout is shown in @timing-layout.

#figure(
  {
    set text(30pt) 
  context {
    let unit = measure("X").width / 2.0
  cetz.canvas(length: unit, {
    import cetz.draw: * 

    let spec0 = "4{HL}"
    let (parsed0, diagram-length) = parse-sequence(spec0)

    let spec1 = "8C"
    let (parsed1, _) = parse-sequence(spec1)

    let col-dist = unit * 1.4
    let row-dist = calc.max(text.size, unit) * 1.4
    line((0, -3), (0, (6)), stroke: (dash: "dashed", paint: gray))
    line((2, -3), (2, (6)), stroke: (dash: "dashed", paint: gray))
    line((-col-dist, -3), (-col-dist, (6)), stroke: (dash: "dashed", paint: gray))

    line((0, 1), (diagram-length * 2 + 1, 1), stroke: (dash: "dashed", paint: gray))
    line((0, 0), (diagram-length * 2 + 1, 0), stroke: (dash: "dashed", paint: gray))
    line((0, -1), (diagram-length * 2 + 1, -1), stroke: (dash: "dashed", paint: gray))

    line((0, -row-dist), (diagram-length * 2 + 1, -row-dist), stroke: (dash: "dashed", paint: gray))

    line((6, -3), (6, (6)), stroke: (dash: "dashed", paint: gray))
    line((6.4, -3), (6.4, (6)), stroke: (dash: "dashed", paint: gray))

    circle((0, 0),
      radius: (0.1), 
      name: "origin", 
      fill: black
      )

    content("origin",
      anchor: "north-west", 
      padding: .1, 
      [#text(size: 8pt, [origin])]
      )

    content((-col-dist, -0 * row-dist), anchor: "mid-east", "First Row")
    draw-sequence(
      initchar: "L",
      origin: (x: 0, y: 0), 
      stroke: 1pt + black,
      parsed: parsed0,
      diagram-length: diagram-length
      )

    content((-col-dist, -1 * row-dist), anchor: "mid-east", "Second Row")
    draw-sequence(
      initchar: "L",
      origin: (x: 0, y: -row-dist / unit), 
      stroke: 1pt + black,
      parsed: parsed1,
      diagram-length: diagram-length
      )
    set-style(mark: (symbol: ">", scale: 0.5, fill: black))
    line((0, 5), (2, 5), name: "unit")
    content("unit.mid", angle: 90deg, anchor: "west", padding: .4, [#text(size: 8pt, [2 CeTZ units])])

    line((-col-dist, 5), (0, 5), name: "coldist")
    content("coldist.mid", angle: 90deg, anchor: "west", padding: .4, [#text(size: 8pt, [col-dist])])

    line((diagram-length * 2 + 1, 0), (diagram-length * 2 + 1, 1), name: "yunit0")
    content("yunit0.mid", anchor: "west", padding: .4, [#text(size: 8pt, [1 CeTZ unit])])

    line((diagram-length * 2 + 1, 0), (diagram-length * 2 + 1, -1), name: "yunit1")
    content("yunit1.mid", anchor: "west", padding: .4, [#text(size: 8pt, [1 CeTZ unit])])

    line((diagram-length + 1, 0), (diagram-length + 1, -row-dist), name: "rowdist")
    content("rowdist.mid", anchor: "west", padding: .4, [#text(size: 8pt, [row-dist])])

    line((6, 6), (6.4, 6), name: "trans")
    content("trans.mid", anchor: "west", padding: .4, [#text(size: 8pt, [transition-width])])
  })

  }},
  caption: [Distances and Nodes inside a `timingtable`]
) <timing-layout>

= Available Commands

#command("texttiming", arg(strok:black + 1pt), arg(initchar:none), arg(draw-grid:false), arg(sequence:str))[
  This macro places a single timing diagram line into the current text. The signal have the same height has an uppercase letter (like 'X') of the current font, i.e. they scale with the font size. The macro argument must contain only valid logic characters and modifiers which define the logical levels of the diagram line.

  #argument("strok", types:"stroke", default: black + 1pt)[
    Stroke of the diagram line. This does not affect `X`, `Z`, and `M` logic levels.
    
    Note: I couldn't manage to get `stroke` to work, so it is named `strok` for now.

    *Examples*

    `#texttiming(strok: orange + 1pt, "HLZXDUTCM")` $->$ #texttiming(strok: orange + 1pt, "HLZXDUTCM")

    `#texttiming(strok: blue + 1pt, "HLZXDUTCM")` $->$ #texttiming(strok: blue + 1pt, "HLZXDUTCM")
  ]
  #argument("initchar", types:"str", default: none)[
    Initial logical level. This is used to draw a transition right at the beginning. It must be `none` or one of the logic levels.

    *Examples*

    `#texttiming(initchar: "L", "Z")` $->$ #texttiming(initchar: "L", "Z")

    `#texttiming(initchar: "H", "Z")` $->$ #texttiming(initchar: "H", "Z")
  ]
  #argument("draw-grid", types:"bool", default: false)[
    Draw a gray grid on the CeTZ canvas background.

    *Examples*

    `#texttiming(draw-grid: true, "HLZXDUTCM")` $->$ #texttiming(draw-grid: true, "HLZXDUTCM")
  ]
  #argument("sequence", types: "str")[
    The timing sequence to visualize.
  ]
]

#command("timingtable", arg(col-dist:10pt), arg(row-dist:auto), sarg[body])[
  This macro draws a timing diagram table to a CeTZ canvas.

  #argument("col-dist", types: length, default: 10pt)[
    The distance between columns.

    *Example*

    #grid(
     columns: (40%, 40%), 
     [

        *20 pt*
        ```
        #timingtable(col-dist: 20pt,
          [Name], [HLLLH],
          [Clock], [10{C}],
          [Signal], [Z4DZ],
        )
        ```

        #timingtable(col-dist: 20pt,
          [Name], [HLLLH],
          [Clock], [10{C}],
          [Signal], [Z4DZ],
        )
     ], 
     [
        *40 pt*
        ```
        #timingtable(col-dist: 40pt,
          [Name], [HLLLH],
          [Clock], [10{C}],
          [Signal], [Z4DZ],
        )
        ```

        #timingtable(col-dist: 40pt,
          [Name], [HLLLH],
          [Clock], [10{C}],
          [Signal], [Z4DZ],
        )
     ]
    )
  ]
  #argument("row-dist", types: length, default: auto)[
    The distance between rows.
    
    *Example*

    #grid(
     columns: (40%, 40%), 
     [

        *10 pt*
        ```
        #timingtable(row-dist: 10pt,
          [Name], [HLLLH],
          [Clock], [10{C}],
          [Signal], [Z4DZ],
        )
        ```

        #timingtable(row-dist: 10pt,
          [Name], [HLLLH],
          [Clock], [10{C}],
          [Signal], [Z4DZ],
        )
     ], 
     [
        *40 pt*
        ```
        #timingtable(row-dist: 40pt,
          [Name], [HLLLH],
          [Clock], [10{C}],
          [Signal], [Z4DZ],
        )
        ```

        #timingtable(row-dist: 40pt,
          [Name], [HLLLH],
          [Clock], [10{C}],
          [Signal], [Z4DZ],
        )
     ]
    )
  ]
  #argument("body", is-sink: true)[
    The captions and timing sequences to visualize.
  ]
]

= TODO

- Add data labels: `D[MISO]`. `content` in braces.
- Add CeTZ anchors for diagram.
- Add optional CeTZ anchors for individual signals: `D<miso>`, `D<miso>[MISO]`.
- Make anchors available so users can do custom arrows and annotations -> leave drawing CeTZ `canvas` to the user?
- Apply color to `U` pattern.
- Add option to omit first column of timing table.
- [_Optional_] Add caption to timing table.
- [_Optional_] Add table header to timing table.
- [_Optional_] Add tick marks.
- [_Optional_] Add grouping of table rows.
- [_Optional_] Add highlighting of row groups and ticks.
- [_Optional_] Correct `strok` argument.
- [_Optional_] Resolve `mantys` warnings.
- [_Optional_] Allow non-integer lengths for logic levels.