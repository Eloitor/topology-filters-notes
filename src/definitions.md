---
my-title: Definicions
math: true
number-sections: true
---

# Filter definition and ordered structure


We will start defining filters and, then the elementary filter propositions will be proved by the usual way and by Lean.
This chapter aims to define an algebraic structure with filters using two operations.

## Filter definition

Firstly, we will introduce the filter definition of a giving set.

**Definition 1.1.1** (Filter). *Let* $X$ *be a set, a filter is a family of subsets of the power ser* $\mathcal{F}\subseteq \mathcal{P}(X)$ *satisfying 
the next properties*

:::{.roman-list}
1. *The universal set is in the filter* $X\in \mathcal{F}$.
2. *If* $E\in\mathcal{F}$, *then* $\forall A\in\mathcal{P}(X)$ *such that* $E\subseteq A$, *we have* $A\in\mathcal{F}$.
3. *If* $E,A\in\mathcal{F}$, *then* $E\cap A\in\mathcal{F}$.
:::

The reader might have noticed we have not included the empty axiom (states that the empty set cannot be in any filter) commonly used in filter definitions and required for topology filter convergence. 
Assuming it, would make it impossible to define the neutral element in one of the operations we will use later.

Having the conceptual definition of filters, we can define this structure in Lean. The following code lines were published
in the mathlib repository, being the current definition of filters on that repository.

```lean
  import data.set.basic
  open set
  
  structure filter (X : Type) :=
  (sets                   : set (set X))
  (univ_sets              : set.univ ∈ sets)
  (sets_of_superset {x y} : x ∈ sets → x ⊆ y → y ∈ sets)
  (inter_sets {x y}       : x ∈ sets → y ∈ sets → x ∩ y ∈ sets)
```

As we have just seen, the concept of filter in Lean is a structure. Conceptually we understand that two filters are equal if and only if both have the same subset associated, but in Lean code we will need to prove this statement. This trivial lemma will be useful for future proofs.

```lean
  variable {X : Type}
  lemma filter_eq : ∀ {f g : filter X}, f.sets = g.sets → f = g
  | ⟨a, _, _, _⟩ ⟨._, _, _, _⟩ rfl := rfl
```

Having introduced the definition of filters, we will proceed with defining the principal filters. Those are essential to lots of topological structures as the open neighbourhood of a point.

**Definition 1.1.2** (Principal Filter). *Let* $X$ *a set and* $A\subseteq X$ *a subset. We define the principal filter as the subset* $\left\{t\in\mathcal{P}(X)\ |\ s\subseteq t\right\}$ *that, from now onwards, will be denoted as* $P(A)$.

We have introduced a definition of what we have supposed to be a particular type of filter. Now, we should prove that it fulfils the conditions for being a filter.

**Proposition 1.1.3** *Let* $X$ *a set. For all* $A\subseteq X$ *subsets, the principal filter of* $A$ *is a filter.*

*Proof*. We will prove that a principal filter is a filter by proving the three properties of filters.

:::{.roman-list}
1. It is clear that $A\subseteq X$. Then, by definition, we have $X\in  P(A)$.  
2. If we have $E \in P(A)$, by definition, we also have $A \subseteq E$. For all $B\in\mathcal{P}(X)$ such that $E\subseteq B$, we will have $A\subseteq B$ because of fundamental set propositions. Then we can conclude that $B \in P(A)$.
3. If we have $B,C \in P(A)$, by definition, we will have $A \subseteq B$ and $A\subseteq C$. Because $A$ is contained in both subsets, we also have $A\subseteq B \cap C$, which led us to $B \cap C \in P(A)$. $\square$ 
:::

When we attend to define a principal filter in Lean, we will be required to prove that this object is a filter. The following lines are from mathlib repository, being the definition for principal filters that Lean community uses.

```lean  
  def principal {X : Type} (s : set X) : filter X :=
  { sets              := {t | s ⊆ t},
    univ_sets         := subset_univ s,
    sets_of_superset  := assume x y hx hy, subset.trans hx hy,
    inter_sets        := assume x y, subset_inter }
    
  localized "notation `P` := filter.principal" in filter
```

## Filter Order

Having the filter definition, we can define an order with filters using the regular inclusion order of set power subsets.

**Definition 1.2.1** (Filter Order). *Let* $X$ *be a set. We say that a filter* $\mathcal{F}$ *is finer than a filter* $\mathcal{V}$ *if* $\mathcal{V}\subseteq \mathcal{F}$ *and denoted as* $\mathcal{F}\leq\mathcal{V}$.

After defining an order is natural to prove the type of order that it is. In this case, we will prove that this is a partial order.

**Proposition 1.2.2** *The filter order is a partial order.*

*Proof*. To prove the statement, we will see that this relation is reflexive, antisymmetric and transitive.

:::{.roman-list}
1. Giving a filter $\mathcal{F}$. It is clear that $\mathcal{F}\subseteq\mathcal{F}$ then, by definition, we have $\mathcal{F}\leq\mathcal{F}$.
2. Giving two filters $\mathcal{F}$ and $\mathcal{V}$ satisfying $\mathcal{F}\leq \mathcal{V}$ and $\mathcal{V}\leq\mathcal{F}$. Using the order definition, we have $\mathcal{V}\subseteq\mathcal{F}$ and $\mathcal{F}\subseteq\mathcal{V}$ consequently, $\mathcal{F}=\mathcal{V}$ by the double inclusion lemma.
3. Let three filters $\mathcal{F}$, $\mathcal{V}$ and $\mathcal{T}$ satisfying $\mathcal{F}\leq\mathcal{V}$ and $\mathcal{V}\leq\mathcal{T}$. By definition, we have $\mathcal{V}\subseteq\mathcal{F}$ and $\mathcal{T}\subseteq\mathcal{V}$. Using the partial order of subsets, we have $\mathcal{T}\subseteq \mathcal{F}$ concluding $\mathcal{F}\leq\mathcal{T}. $\square$ 
:::

When we attend to define an order relation in LEAN, we are required to specify the type of order together with the proof that defines the chosen order. The following lines are from the mathlib repository where this order is defined.

```lean  
  instance : partial_order (filter X) :=
  { le            := λ f g, ∀ ⦃U : set X⦄, U ∈ g.sets → U ∈ f.sets,
    le_antisymm   := λ a b h₁ h₂, filter_eq $ subset.antisymm h₂ h₁,
    le_refl       := λ a, subset.rfl,
    le_trans      := λ a b c h₁ h₂, subset.trans h₂ h₁ }
```

## Lattice Structure

Once we have define an order, we can naturally ask if this set has a lattice associated. From the filter axioms 

## Exercices

This subsection aims to propose some exercises that will help the reader to test the knowledge presented above. All are written in Lean and the usual way and separated into the sections we have followed.

### Filter definition
:::{.roman-list}
  1. **Exercise 1.** Let $X$ be a set, a filter $\mathcal{F}$ of $X$ and two subsets $V,U \subseteq X$. The intersection of the subsets is on the filter if only if both are in the filter.
```{.lean .skip}
  variable {F : filter X}
  
  lemma exercise1 {V U} : V ∩ U ∈ F.sets ↔ V ∈ F.sets ∧ U ∈ F.sets :=
  begin
    sorry
  end
```
  2. **Exercise 2.** Let $X$ be a set, a filter $\mathcal{F}$ of $X$ and two subsets $V,U \subseteq X$. If the subset $\left\{ x\in X\ |\ \textup{if} x\in V\textup{ then } x\in U\right\}$ is in the filter, then $U$ is in the filter if $V$ is in the filter.
  
```{.lean .skip}  
  variable {F : filter X}

  lemma exercise2 {V U} (h : {x | x ∈ V → x ∈ U} ∈ F.sets) : 
    V ∈ F.sets → U ∈ F.sets :=
  begin
    sorry
  end
```
:::
