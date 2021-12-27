---
date: 26 de Desembre de 2021
math: true
---


# Some testing

Inline math like this: $\int_0^1 x^2 dx$.

Some math displayed:

$$ \int_0^1 x^2 dx $$

Some haskell code:

```haskell
main = putStrLn "Hello, world!"
```

Some **lean** code:

```lean
import data.set.basic

structure filter (X : Type) :=
(sets                   : set (set X))
(univ_sets              : set.univ ∈ sets)
(sets_of_superset {x y} : x ∈ sets → x ⊆ y → y ∈ sets)
(inter_sets {x y}       : x ∈ sets → y ∈ sets → x ∩ y ∈ sets)
```

With this definition, we can proceed to define the principal filter of a set.
Note that we can also add numberlines.

```{.lean .numberLines}
open set

def principal {X : Type} (s : set X) : filter X :=
{ sets              := {t | s ⊆ t},
  univ_sets         := subset_univ s,
  sets_of_superset  := assume x y hx hy, subset.trans hx hy,
  inter_sets        := assume x y, subset_inter }
```


Now we handle a completely different problem.

```{.lean .reset .numberLines startFrom="1"}
#check 1 + 1
```


Some zig code:

```zig
main = print "Hello, world!"
```


Some python code:

```python
print("Hello, $world$!")
```

Agda code:

```{.agda}
module Main where

main = putStrLn "Hello, world!"
```

Some **rust** code:

```rust
fn main() {
    println!("Hello, world!");
}
```
