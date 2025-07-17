#import "@preview/typst-apollo:0.1.0": pages
#import "@preview/shiroa:0.2.3": *
#import "@preview/unequivocal-ams:0.1.0": theorem, proof
#import "@preview/cetz:0.4.0"
#import "@preview/plotsy-3d:0.2.0": plot-3d-parametric-curve
#import "@preview/ansi-render:0.8.0": *
#import "@preview/lilaq:0.4.0" as lq
#import "@preview/physica:0.9.5": *
#import pages: *

#show: project.with(
  title: [],
  authors: (
    (
      name: "CoffeeImpliesCode",
      email: "coffeeimpliescode@proton.me",
    ),
  ),
)

// #set text(font: main-font)

#show outline.entry: it => link(it.element.location(), it.indented(it.prefix(), it.body()))

= This is a technology test
Let's see what works with Typst + web!

= Some Text 
#lorem(200)

= Some Math
$ curl (grad f), pdv(,x,y,z,[2,k]), tensor(Gamma, +k, -i, -j) = pdv(vb(e_i),x^j)vb(e^k) $

= Some Diagrams

#lq.diagram(
  width: 4cm, height: 4cm,
  lq.colormesh(
    lq.linspace(-4, 4, num: 10),
    lq.linspace(-4, 4, num: 10),
    (x, y) => x * y,
    map: color.map.magma
  )
)

#lq.diagram(
  lq.boxplot(
    stroke: blue.darken(50%),
    (1, 2, 3, 4, 5, 6, 7, 8, 9, 21, 19),
    range(1, 30),
    (1, 28, 25, 30),
    (1, 2, 3, 4, 5, 6, 32),
  )
)
#let xs = lq.linspace(0, 10, num: 30)

#lq.diagram(
  lq.stem(
    xs,
    xs.map(calc.cos),
    color: orange,
    mark: "d",
    base: -0.25,
    base-stroke: black,
  )
)

#import "@preview/suiji:0.3.0"
#let rng = suiji.gen-rng(33)
#let (rng, x) = suiji.uniform(rng, size: 20)
#let (rng, y) = suiji.uniform(rng, size: 20)
#let (rng, colors) = suiji.uniform(rng, size: 20)
#let (rng, sizes) = suiji.uniform(rng, size: 20)

#lq.diagram(
  lq.scatter(
    x, y,
    size: sizes.map(size => 200 * size),
    color: colors,
    map: color.map.magma
  )
)

= Some Code
```rust
fn main() -> Result<()> {
  println!("All you codebase are belong to us.");
  Ok(())
}
```

= Signals
#signals("10.1")

#signals("-|=|-", step: 2em)

#signals("-<=>-<=")

#signals(" #.... X=... ..... ..... X=... ..... ..... X#.", step: 0.5em)


#lorem(200)
