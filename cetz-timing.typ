#import "@preview/cetz:0.3.1"

/// Width used for transition between different signal levels.
/// Value between 0.0 and 2.0
#let transition-width = state("transition-width", 0.4)

#let sig-info = (
  "L": (
    level: -1,
    color: none,
  ),
  "H": (
    level: 1,
    color: none,
  ),
  "Z": (
    level: 0,
    color: blue,
  ),
  "X": (
    level: 0,
    color: red,
  ),
  "M": (
    level: 0,
    color: maroon,
  )
)

#let is_sig(c) = (
  return c in ("H", "L", "Z", "X", "M")
)

#let is_data(c) = (
  return c in ("D", "U")
)

#let resolve_color(c: str, color: color) = {
  let predefined = none
  if is_sig(c) {
    predefined = sig-info.at(c).color
  }
  else {
    predefined = none
  }

  if predefined == none {
    return color
  }
  else {
    return predefined
  }
}

#let from_data(pos, sig) = {
  import cetz.draw: line
  let trans_startA = (x: pos.x, y: pos.y - 1)
  let trans_startB = (x: pos.x, y: pos.y + 1)
  let trans_end = (x: pos.x + transition-width.get() / 2, y: pos.y)
  if sig == "U" {
    /* TODO: fill pattern */
  }
  line(trans_startA, trans_end)
  line(trans_startB, trans_end)
}

#let to_data(pos, sig) = {
  import cetz.draw: line
  let trans_start = (x: pos.x + transition-width.get() / 2, y: pos.y)
  let trans_endA = (x: pos.x + transition-width.get(), y: pos.y - 1)
  let trans_endB = (x: pos.x + transition-width.get(), y: pos.y + 1)
  if sig == "U" {
    /* TODO: fill pattern */
  }
  line(trans_start, trans_endA)
  line(trans_start, trans_endB)
}

#let pat = pattern(size: (2pt, 3pt))[
  #place(line(start: (0%, 100%), end: (100%, 0%), stroke: 0.5pt)) 
]

#let data(pos, sig, x_end: float) = {
  import cetz.draw: line, rect
  let sig_startA = (x: pos.x, y: pos.y + 1)
  let sig_endA = (x: x_end, y: pos.y + 1)
  let sig_startB = (x: pos.x, y: pos.y - 1)
  let sig_endB = (x: x_end, y: pos.y - 1)
  if sig == "U" {
    rect(sig_startA, sig_endB, stroke: none, fill: pat)
  }
  else {
    rect(sig_startA, sig_endB, stroke: none)
  }
  line(sig_startA, sig_endA)
  line(sig_startB, sig_endB)
}

#let from_sig(pos, sig, instant: bool) = {
  import cetz.draw: line
  // resolve transition width
  let width = if instant { 0 } else { transition-width.get() }
  let trans_start = (x: pos.x, y: pos.y + sig-info.at(sig).level)
  let trans_end = (x: pos.x + width / 2, y: pos.y)
  line(trans_start, trans_end)
}

#let to_sig(pos, sig, instant: bool) = {
  import cetz.draw: line
  // resolve transition width
  let width = if instant { 0 } else { transition-width.get() }
  let trans_start = (x: pos.x + width / 2, y: pos.y)
  let trans_end = (x: pos.x + width, y: pos.y + sig-info.at(sig).level)
  line(trans_start, trans_end)
}

#let sig(pos, sig, x_end: float) = {
  import cetz.draw: line
  let sig_start = (x: pos.x, y: pos.y + sig-info.at(sig).level)
  let sig_end = (x: x_end, y: pos.y + sig-info.at(sig).level)
  if sig == "M" {

    // zick zack repetitions
    let rep = 4
    // zick zack amplitude
    let amp = 0.2
    // length of one zick zack repetition
    let rep_len = (x_end - pos.x) / rep
    // length of one zick zack element
    let seg_len = rep_len / 4

    for i in range(rep) {
      let x_start = sig_start.x + i * rep_len
      // draw zick zack
      line(
        (x: x_start, y: sig_start.y), 
        (x: x_start + seg_len, y: sig_start.y + amp))
      line(
        (x: x_start + seg_len, y: sig_start.y + amp), 
        (x: x_start + 3 * seg_len, y: sig_start.y - amp))
      line(
        (x: x_start + 3 * seg_len, y: sig_start.y - amp), 
        (x: x_start + 4 * seg_len, y: sig_end.y))
    }
  }
  else {
    line(sig_start, sig_end)
  }
}

#let toggle-lut = (
  "H": "L",
  "L": "H",
  "Z": "H",
  "X": "H",
  "M": "H",
  "D": "L",
  "U": "L",
)

#let timing-characters = ("H", "L", "Z", "X", "M", "D", "U", "T", "C", "|")
#let parse-sequence(sequence, depth: 0) = {
  // Resulting parsed string after resolving repetitions and groups
  let parsed = ""

  // length of the diagram, exluding command chars like '|'
  let diagram-length = 0

  // How often to repeat the next timing character
  // Examples that show different ways to specify the next repetition are 
  // '11H', '11.H', '11.11H', '.11H'
  let rep = "1"

  // Grouped sub-sequence in brackets ({})
  let group = ""

  // Track group nesting level to escape '}' characters.
  let nesting-level = 0

  // State machine to parse the sequence string
  // Input event: sequence character (c)

  // Capture timing character
  let state-timing-capture = 0

  // Capture sub group
  let state-group-capture = 1

  // Capture repetition prefix 
  let state-rep-capture = 2

  // current state
  let state = state-timing-capture

  for c in sequence {
    if state == state-timing-capture {
      if c == "{" {
        state = state-group-capture 
        group = ""
      }
      else if c == "}" {
        panic("Syntax error: Extra closed bracket. Recursion level: " + str(depth) + ", sequence: ", sequence)
      }
      else if c not in timing-characters {
        state = state-rep-capture
        rep = c
      }
      else {
        parsed += c
        if c != "|" {
          diagram-length += 1
        }
      }
    }
    else if state == state-group-capture {
      if c == "{" {
        nesting-level += 1
        group += c
      }
      else if c == "}" {
        if nesting-level == 0 {
          // exit transition
          state = state-timing-capture
          let parsed-group = parse-sequence(group, depth: depth + 1)
          let rep_num = int(rep)
          rep = "1"
          for i in range(rep_num) {
            parsed += parsed-group.at(0)
            diagram-length += parsed-group.at(1)
          }
        }
        else {
          nesting-level -= 1
          group += c
        }
      }
      else {
        group += c
      }
    }
    else if state == state-rep-capture {
      if c == "{" {
        state = state-group-capture
        group = ""
      }
      else if c == "}" {
        panic("Syntax error: Unexpected closed bracket")
      }
      else if c in timing-characters {
        state = state-timing-capture
        let rep_num = int(rep)
        rep = "1"
        for i in range(rep_num) {
          parsed += c
          if c != "|" {
            diagram-length += 1
          }
        }
      }
      else {
        rep += c 
      }
    } 
    else {
      panic("Invalid parser state")
    }
  }

  assert(nesting-level == 0, message: "Unclosed bracket in sequence " + sequence);
  return (parsed, diagram-length)
}

#let draw-sequence(origin: (x: 0, y: 0), initchar: none, stroke: stroke, parsed: array, diagram-length: int) = {
  import cetz.draw: set-style, rect
  // Must always draw invisible rect to allocate canvas space
  rect((origin.x, origin.y - 1), (origin.x + diagram-length * 2, origin.y + 1), stroke: none)

  // Resolve toggle commands
  let previous = initchar
  if previous == none {
    previous = parsed.at(0)
  }
  if previous == "T" {
    previous = "L"
  }
  if previous == "C" {
    previous = "L"
  }

  // parse char sequence
  let tick = 0
  let explicit-transition = false
  for c in parsed {
    let instant = false
    if c == "|" {
      explicit-transition = true
      continue
    }
    else if c == "T" {
      c = toggle-lut.at(previous)
    }
    else if c == "C" {
      c = toggle-lut.at(previous)
      instant = true
    }
    let col = resolve_color(c: c, color: stroke.paint)
    set-style(stroke: stroke.thickness + col)
    let pos = (x: origin.x + tick, y: origin.y)
    let sig_pos = pos
    if c != previous or explicit-transition {
      if is_sig(previous) {
        from_sig(pos, previous, instant: instant)
      }
      else if is_data(previous) {
        from_data(pos, previous)
      }
      if is_sig(c) {
        to_sig(pos, c, instant: instant)
      }
      else if is_data(c){
        to_data(pos, c)
      }
      if not instant {
        sig_pos.x += transition-width.get()
      }
    }
    if is_sig(c) {
      sig(
        sig_pos,
        c,
        x_end: pos.x + 2, 
      )
    }
    else if is_data(c) {
      data(
        sig_pos,
        c, 
        x_end: pos.x + 2,
      )
    }
    previous = c
    tick += 2
    explicit-transition = false
  }
}

#let texttiming(strok: black + 1pt, initchar: none, draw-grid: false, sequence) = {
  let (parsed, diagram-length) = parse-sequence(sequence)
  if diagram-length == 0 {
    return
  }
  context{
    let unit = measure("X").height / 2.0
    import cetz.draw: *
    box()[
    #cetz.canvas(padding: 0, length: unit,
      {
        // Draw background grid
        //
        // It must always be drawn so signals always have the correct 
        // relative position.
        //
        // If draw-grid is turned off, we set transparency to 100%.
        if draw-grid {
          grid((0, -1), (diagram-length * 2, 1), stroke: gray.transparentize(20%))
        }

        draw-sequence(
          initchar: initchar,
          stroke: strok,
          parsed: parsed,
          diagram-length: diagram-length
          )
      }
    )
    ]
  }
}

#let timingtable(
  row-dist: auto,
  col-dist: 10pt,
  ..body) = {
    context {
    let args = ()
    let i = 0
    let row = ("name": none, "sequence": none)
    let max-name-width-pt = 0pt
    let max-signal-width = 0
    for arg in body.pos() {
      if calc.rem(i, 2) == 0 {
        if i > 0 {
          args.push(row)
        }
        let width = measure(arg).width
        if width > max-name-width-pt {
          max-name-width-pt = width
        }
        row.at("name") = arg
      }
      else {
        let diag = texttiming(arg.text)
        row.at("sequence") = parse-sequence(arg.text)
        let width = row.at("sequence").at(1) * 2
        if width > max-signal-width {
          max-signal-width = width
        }
      }
      i += 1
    }
    args.push(row)
    // CeTZ unit
    let unit = measure("X").height / 2.0

    // Calculate row distance based on text height or user input
    let rowdist-pt = if row-dist == auto {
      // auto selection
      calc.max(text.size, unit) * 1.4
    }
    else {
      // user input
      row-dist
    }

    // Convert pixel distance to CeTZ unit
    let rowdist = rowdist-pt / unit

    cetz.canvas(length: unit, {
      import cetz.draw: *
      // grid((0, 1), (max-signal-width, -args.len() * rowdist + 1), stroke: gray) 
      let row = 0
      for arg in args {
        content((-col-dist, -row * rowdist), anchor: "mid-east", arg.name)
        let (parsed, diagram-length) = arg.sequence
        draw-sequence(
          origin: (x: 0, y: -row * rowdist), 
          stroke: 1pt + black,
          parsed: parsed,
          diagram-length: diagram-length
          )
        row += 1
      }
    })
    }
}