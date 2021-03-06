/-
Copyright (c) 2017 Microsoft Corporation. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Leonardo de Moura
-/
prelude
import Init.Coe
import Init.Data.Option.Basic
import Init.Data.List.BasicAux
import Init.System.IO

universes u v w w'

inductive color
| Red | Black

inductive Tree
| Leaf  {}                                                                       : Tree
| Node  (color : color) (lchild : Tree) (key : Nat) (val : Bool) (rchild : Tree) : Tree

/- variables {σ : Type w} -/
open color Nat Tree

def tfold : (Nat → Bool → Nat → Nat) -> Tree → Nat → Nat
| f, Leaf, b               => b
| f, Node _ l k v r,     b => tfold f r (f k v (tfold f l b))

@[inline]
def balance1 : Nat → Bool → Tree → Tree → Tree
| kv, vv, t, Node _ (Node Red l kx vx r₁) ky vy r₂   => Node Red (Node Black l kx vx r₁) ky vy (Node Black r₂ kv vv t)
| kv, vv, t, Node _ l₁ ky vy (Node Red l₂ kx vx r)   => Node Red (Node Black l₁ ky vy l₂) kx vx (Node Black r kv vv t)
| kv, vv, t, Node _ l  ky vy r                       => Node Black (Node Red l ky vy r) kv vv t
| _,  _,  _,                                       _ => Leaf

@[inline]
def balance2 : Tree → Nat → Bool → Tree → Tree
| t, kv, vv, Node _ (Node Red l kx₁ vx₁ r₁) ky vy r₂    => Node Red (Node Black t kv vv l) kx₁ vx₁ (Node Black r₁ ky vy r₂)
| t, kv, vv, Node _ l₁ ky vy (Node Red l₂ kx₂ vx₂ r₂)   => Node Red (Node Black t kv vv l₁) ky vy (Node Black l₂ kx₂ vx₂ r₂)
| t, kv, vv, Node _ l ky vy r                           => Node Black t kv vv (Node Red l ky vy r)
| _, _, _,                                         _    => Leaf

def isRed : Tree → Bool
| Node Red _ _ _ _   => true
| _                  => false

def ins : Tree → Nat → Bool → Tree
| Leaf,                 kx, vx => Node Red Leaf kx vx Leaf
| Node Red a ky vy b,   kx, vx =>
   (if kx < ky then Node Red (ins a kx vx) ky vy b
    else if kx = ky then Node Red a kx vx b
    else Node Red a ky vy (ins b kx vx))
| Node Black a ky vy b,   kx, vx =>
    if kx < ky then
      (if isRed a then balance1 ky vy b (ins a kx vx)
       else Node Black (ins a kx vx) ky vy b)
    else if kx = ky then Node Black a kx vx b
    else if isRed b then balance2 a ky vy (ins b kx vx)
         else Node Black a ky vy (ins b kx vx)

def setBlack : Tree → Tree
| Node _ l k v r   => Node Black l k v r
| e                => e

def insert (t : Tree) (k : Nat) (v : Bool) : Tree :=
if isRed t then setBlack (ins t k v)
else ins t k v

def mkMapAux : Nat -> Nat → Tree → List Tree → List Tree
| freq, 0,     m, r => m::r
| freq, n+1,   m, r =>
  let m := insert m n (n % 10 = 0);
  let r := if n % freq == 0 then m::r else r;
  mkMapAux freq n m r

def mkMap (n : Nat) (freq : Nat) : List Tree :=
mkMapAux freq n Leaf []

def myLen : List Tree → Nat → Nat
| Node _ _ _ _ _ :: xs,   r => myLen xs (r + 1)
| _ :: xs,   r => myLen xs r
| [], r => r

def head : List Tree -> Tree
| t::_ => t
| _    => Leaf

def main : IO UInt32 := do
let n     := 4200000;
let freq  := 5;
let mList := mkMap n freq;
let t     := head mList 
let v     := tfold (fun (k : Nat) (v : Bool) (r : Nat) => if v then r + 1 else r) t 0;
IO.println (toString (myLen mList 0) ++ " " ++ toString v) *>
pure 0